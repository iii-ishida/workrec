package util

import "github.com/gofrs/uuid"

// NewUUID returns a uuid.
func NewUUID() string {
	return uuid.Must(uuid.NewV4()).String()
}
