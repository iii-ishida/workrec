package util

import uuid "github.com/satori/go.uuid"

// NewUUID returns a UUID String.
func NewUUID() string {
	return uuid.NewV4().String()
}
