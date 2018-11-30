package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	log.SetFlags(log.Lshortfile)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := NewRouter()
	http.ListenAndServe(fmt.Sprintf(":%s", port), r)
}
