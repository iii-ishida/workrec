package util

import "os"

// GetProjectID returns the GCP Project ID.
func GetProjectID() string {
	return os.Getenv("GOOGLE_CLOUD_PROJECT")
}

// GetQueryAPIOrigin returns the origin for query api.
func GetQueryAPIOrigin() string {
	origin := os.Getenv("QUERY_API_ORIGIN")
	if origin != "" {
		return origin
	}
	return "https://query-dot-" + GetProjectID() + ".appspot.com"
}
