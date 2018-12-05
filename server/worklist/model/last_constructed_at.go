package model

import "time"

// LastConstructedAtID  is ID for LastConstructedAt.
const LastConstructedAtID = "LAST_CONSTRUCTED_AT"

// LastConstructedAt is time at last ConstructWorks.
type LastConstructedAt struct {
	ID   string
	Time time.Time
}

// for store

// KindNameLastConstructedAt is a datastore kind name for LastConstructedAt.
const KindNameLastConstructedAt = "WorkListLastConstructedAt"
