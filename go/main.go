package main

import (
	"fmt"
	//"log/slog"
	"net/http"
	"os"
	"time"
	"strconv"
	"context"
	"github.com/jackc/pgx/v5/pgxpool"
)

func upHandler(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func helloHandler(host string, pool *pgxpool.Pool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// slog.Info("Request", "host", host, "request_id", r.Header.Get("X-Request-ID"), "method", r.Method, "url", r.URL)

		queryParams := r.URL.Query()

		delaySeconds, err := strconv.ParseFloat(queryParams.Get("delay"), 64)
		if err != nil {
			delaySeconds = 0
		}

		count, err := strconv.Atoi(queryParams.Get("count"))
		if err != nil {
			// fmt.Println("Failed count param: %v", err)
			count = 1
		}

		var randomID int
		var sleep string
		if delaySeconds > 0 {
			for i := 0; i < count; i++ {
				err = pool.QueryRow(
					context.Background(),
					"SELECT random(1, 1_000_000) id, pg_sleep($1)",
					delaySeconds,
				).Scan(&randomID, &sleep)
				if err != nil {
					fmt.Println("Query failed: %v", err)
				}
			}
		}

		cpuParam := r.URL.Query().Get("cpu")
		if cpuParam != "" {
			cpuValue, err := strconv.Atoi(cpuParam)
			if err != nil {
				http.Error(w, "Invalid cpu parameter", http.StatusBadRequest)
				return
			}
	
			for i := 0; i < 10_000_000_000; i++ {
				_ = i * cpuValue
			}
		}

		w.Header().Add("Content-Type", "text/html")
		fmt.Fprintf(w, "Hello from Go host=%s time=%s delay=%s %s",
			host,
			time.Now().Format(time.RFC3339),
			strconv.FormatFloat(delaySeconds, 'f', -1, 64),
			strconv.Itoa(randomID),
		)
	}
}

func main() {
	host, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	url := fmt.Sprintf("postgres://user:pass@localhost:5432/db1?pool_max_conns=40&application_name=go_app")

	dbpool, err := pgxpool.New(context.Background(), url)
	if err != nil {
		panic("failed to create connection pool")
	}

	http.HandleFunc("/up", upHandler)
	http.HandleFunc("/", helloHandler(host, dbpool))

	panic(http.ListenAndServe(":3003", nil))
}
