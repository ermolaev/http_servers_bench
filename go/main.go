package main

import (
	"fmt"
	//"log/slog"
	"net/http"
	"os"
	"time"
	"strconv"
)

func upHandler(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func helloHandler(host string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// slog.Info("Request", "host", host, "request_id", r.Header.Get("X-Request-ID"), "method", r.Method, "url", r.URL)

		queryParams := r.URL.Query()
		delayStr := queryParams.Get("delay")

		// Convert the delay parameter to an integer
		delaySeconds, err := strconv.Atoi(delayStr)
		if err != nil {
			// fmt.Println("Invalid delay parameter, defaulting to 0 seconds")
			delaySeconds = 0
		}

		if delaySeconds > 0 {
		  time.Sleep(time.Duration(delaySeconds) * time.Second)
		}

		w.Header().Add("Content-Type", "text/html")
		fmt.Fprintf(w, "Hello from Go host=%s time=%s delay=%s",
			host,
			time.Now().Format(time.RFC3339),
			strconv.Itoa(delaySeconds),
		)
	}
}

func main() {
	host, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	http.HandleFunc("/up", upHandler)
	http.HandleFunc("/", helloHandler(host))

	panic(http.ListenAndServe(":3003", nil))
}
