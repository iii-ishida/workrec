package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/iii-ishida/workrec/server/auth"
)

func main() {
	log.SetFlags(log.Lshortfile)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := NewRouter(auth.NewFirebaseUserIDGetter())
	http.ListenAndServe(fmt.Sprintf(":%s", port), r)
}
