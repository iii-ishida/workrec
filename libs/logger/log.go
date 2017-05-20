package logger

import "net/http"

// Log is a log.
type Log interface {
	WithRequest(*http.Request) Log

	Debugf(format string, args ...interface{})
	Errorf(format string, args ...interface{})
	Warningf(format string, args ...interface{})
}
