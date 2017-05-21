package httpclient

import "net/http"

// HTTPClient is a http client.
type HTTPClient interface {
	WithRequest(*http.Request) HTTPClient
	AsyncPost(url, contentType, body string, retryLimit int) error
	Get(url string) (*http.Response, error)
}
