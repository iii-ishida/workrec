package httpclient

import (
	"fmt"
	"net/http"
	"strings"

	"golang.org/x/net/context"
	"google.golang.org/appengine"
	"google.golang.org/appengine/delay"
	"google.golang.org/appengine/taskqueue"
	"google.golang.org/appengine/urlfetch"
)

type appengineHTTPClient struct {
	ctx context.Context
}

// AppengineHTTPClient is an Appengine implementation of HTTPClient.
var AppengineHTTPClient = appengineHTTPClient{}

var postFunc = delay.Func("post", func(ctx context.Context, url, contentType, body string) error {
	client := urlfetch.Client(ctx)
	res, err := client.Post(url, contentType, strings.NewReader(body))

	if err != nil {
		return err
	}
	defer res.Body.Close()

	if res.StatusCode >= 400 {
		return fmt.Errorf("response error status: %d", res.StatusCode)
	}

	return nil
})

func (c appengineHTTPClient) WithRequest(req *http.Request) HTTPClient {
	return appengineHTTPClient{ctx: appengine.NewContext(req)}
}

func (c appengineHTTPClient) Get(url string) (*http.Response, error) {
	client := urlfetch.Client(c.ctx)
	return client.Get(url)
}

func (c appengineHTTPClient) AsyncPost(url, contentType, body string, retryLimit int) error {
	t, err := postFunc.Task(url, contentType, body)
	if err != nil {
		return err
	}

	t.RetryOptions = &taskqueue.RetryOptions{
		RetryLimit: int32(retryLimit),
	}

	_, err = taskqueue.Add(c.ctx, t, "")

	return err
}
