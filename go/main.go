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
		delayStr := queryParams.Get("delay")

		// Convert the delay parameter to an integer
		delaySeconds, err := strconv.ParseFloat(delayStr, 64)
		if err != nil {
			// fmt.Println("Invalid delay parameter, defaulting to 0 seconds")
			delaySeconds = 0
		}

		var randomID int
		var sleep string
		if delaySeconds > 0 {
			query := fmt.Sprintf("SELECT random(1, 1_000_000) id, pg_sleep(%s)", delayStr)
			err = pool.QueryRow(context.Background(), query).Scan(&randomID, &sleep)
			if err != nil {
				fmt.Println("Query failed: %v", err)
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

	url := fmt.Sprintf("postgres://user:pass@localhost:5432/db1?pool_max_conns=20")

	dbpool, err := pgxpool.New(context.Background(), url)
	if err != nil {
		panic("failed to create connection pool")
	}


	http.HandleFunc("/up", upHandler)
	http.HandleFunc("/", helloHandler(host, dbpool))

	panic(http.ListenAndServe(":3003", nil))
}
