package logger

import (
	"log"
	"net/http"
)

type standardLog struct{}

// StandardLog is a standard go log.
var StandardLog = standardLog{}

func (standardLog) WithRequest(_ *http.Request) Log {
	return standardLog{}
}

func (standardLog) Debugf(format string, args ...interface{}) {
	log.Printf(format, args)
}
func (l standardLog) Errorf(format string, args ...interface{}) {
	l.Debugf(format, args)
}
func (l standardLog) Warningf(format string, args ...interface{}) {
	l.Debugf(format, args)
}
