package util

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	uuid "github.com/satori/go.uuid"
)

// NewUUID returns a UUID String.
func NewUUID() string {
	return uuid.NewV4().String()
}

// Now returns the current time as a unix nanoseconds.
func Now() int64 {
	return time.Now().UTC().UnixNano()
}

// RespondRaw writes status and data to w.
func RespondRaw(w http.ResponseWriter, status int, contentType string, data []byte) {
	w.Header().Set("Content-Type", contentType)
	w.WriteHeader(status)
	if data != nil {
		w.Write(data)
	}
}

// RespondJSON writes status and data(JSON) to w.
func RespondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(status)
	if data != nil {
		json.NewEncoder(w).Encode(data)
	}
}

// RespondHTTPErr writes status and err to w.
func RespondHTTPErr(w http.ResponseWriter, status int, err error) {
	e := struct {
		Error string `json:"error"`
	}{
		Error: fmt.Sprint(err),
	}
	RespondJSON(w, status, e)
}
