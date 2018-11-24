package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := NewRouter()
	http.ListenAndServe(fmt.Sprintf(":%s", port), r)
}
