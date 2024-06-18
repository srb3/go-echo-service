package main

import (
	"encoding/json"
	"io"
	"net/http"
	"sync/atomic"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var requestCount uint64 // Use atomic for safe concurrent access

func main() {
	// Create a new Prometheus counter for requests
	requestCounter := prometheus.NewCounter(prometheus.CounterOpts{
		Name: "http_requests_total",
		Help: "Total number of HTTP requests",
	})

	// Register the counter with Prometheus's default registry
	prometheus.MustRegister(requestCounter)

	http.HandleFunc("/anything", func(w http.ResponseWriter, r *http.Request) {
		echoHandler(w, r, requestCounter)
	})

	// Add the Prometheus handler to serve metrics at `/metrics`
	http.Handle("/metrics", promhttp.Handler())

	http.ListenAndServe(":8080", nil)
}

func echoHandler(w http.ResponseWriter, r *http.Request, requestCounter prometheus.Counter) {
	// Increment the request counter
	atomic.AddUint64(&requestCount, 1)
	requestCounter.Inc()

	response := make(map[string]interface{})
	headers := make(map[string]string)
	for name, values := range r.Header {
		headers[name] = values[0]
	}
	response["headers"] = headers

	// Extract query params
	args := make(map[string]string)
	for name, values := range r.URL.Query() {
		args[name] = values[0]
	}
	response["args"] = args

	// Extract method
	response["method"] = r.Method

	// Extract URL
	response["url"] = r.URL.String()

	// Read the body data
	body, err := io.ReadAll(r.Body)
	if err == nil {
		response["data"] = string(body)
	}
	response["origin"] = r.RemoteAddr

	w.Header().Set("Content-Type", "application/json")
	prettyJSON, err := json.MarshalIndent(response, "", "  ") // Adds indentation of two spaces
	if err != nil {
		http.Error(w, "Error processing JSON", http.StatusInternalServerError)
		return
	}
	w.Write(prettyJSON)
}
