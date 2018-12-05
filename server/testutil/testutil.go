package testutil

import (
	"time"

	"github.com/gofrs/uuid"
)

// IsUUID reports whether u is UUID.
func IsUUID(u string) bool {
	_, err := uuid.FromString(u)
	return err == nil
}

// IsSystemTime reports whether t is System Time (time.Now +-1min).
func IsSystemTime(t time.Time) bool {
	now := time.Now()
	aMinAgo := now.Add(time.Minute * -1)
	aMinLat := now.Add(time.Minute * 1)

	return t.After(aMinAgo) && t.Before(aMinLat)
}
