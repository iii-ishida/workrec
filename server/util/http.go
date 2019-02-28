package util

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

// RespondError responds status>
func RespondError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

// RespondErrorAndLog responds status and output log.
func RespondErrorAndLog(w http.ResponseWriter, status int, format string, v ...interface{}) {
	var out io.Writer
	if status >= 500 {
		out = os.Stderr
	} else {
		out = os.Stdout
	}
	log.New(out, "", log.Lshortfile).Output(1, fmt.Sprintf(format, v...))

	RespondError(w, status)
}
