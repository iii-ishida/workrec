package util

import (
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
