package logger

import (
	"net/http"
	"net/http/httputil"

	"google.golang.org/appengine"
	"google.golang.org/appengine/log"
)

type appengineLog struct {
	r *http.Request
}

// AppengineLog is an Appengine implementation of Log.
var AppengineLog = appengineLog{}

func (appengineLog) WithRequest(r *http.Request) Log {
	return appengineLog{r: r}
}

func (l appengineLog) Debugf(format string, args ...interface{}) {
	log.Debugf(appengine.NewContext(l.r), format, args)
}

func (l appengineLog) Errorf(format string, args ...interface{}) {
	s, _ := httputil.DumpRequest(l.r, true)
	log.Errorf(appengine.NewContext(l.r), format+"\n[request]\n %s", args, s)
}

func (l appengineLog) Warningf(format string, args ...interface{}) {
	log.Warningf(appengine.NewContext(l.r), format, args)
}
