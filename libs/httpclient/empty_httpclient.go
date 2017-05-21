package httpclient

import "net/http"

type emptyHTTPClient struct{}

type postParam struct {
	URL         string
	ContentType string
	Body        string
	RetryLimit  int
}

var postedLogs = []postParam{}

// EmptyHTTPClient is a empty implementation of HTTPClient.
var EmptyHTTPClient = emptyHTTPClient{}

func (c emptyHTTPClient) WithRequest(_ *http.Request) HTTPClient {
	return emptyHTTPClient{}
}

func (c emptyHTTPClient) Get(url string) (*http.Response, error) {
	return &http.Response{}, nil
}

func (c emptyHTTPClient) AsyncPost(url string, contentType string, body string, retryLimit int) error {
	p := postParam{
		URL:         url,
		ContentType: contentType,
		Body:        body,
		RetryLimit:  retryLimit,
	}
	postedLogs = append(postedLogs, p)
	return nil
}

func (c emptyHTTPClient) Reset() {
	postedLogs = []postParam{}
}

func (c emptyHTTPClient) PostedLogs() []postParam {
	return postedLogs
}
