package main

import (
	"encoding/json"
	"io"
	"net/http"
)


func main() {
  http.HandleFunc("/anything", echoHandler)
  http.ListenAndServe(":8080", nil)
}

func echoHandler(w http.ResponseWriter, r *http.Request) {
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
