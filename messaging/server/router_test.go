package server_test

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"reflect"
	"sort"
	"strings"
	"testing"
	"workrec/libs/httpclient"
	"workrec/libs/logger"
	"workrec/messaging/repo"
	"workrec/messaging/server"
)

type subscriptions []string

func TestAddSubscription(t *testing.T) {
	type wants struct {
		topic         string
		subscriptions subscriptions
	}
	tests := []struct {
		path          string
		subscriptions subscriptions
		wants         wants
	}{
		{
			"/messaging/v1/sample/subscriptions",
			subscriptions{
				"https://localhost:8080/sub1/endpoint",
			},
			wants{
				"sample",
				subscriptions{
					"https://localhost:8080/sub1/endpoint",
				},
			},
		},
		{
			"/messaging/v1/sample/subscriptions",
			subscriptions{
				"https://localhost:8080/sub1/endpoint",
				"https://localhost:8080/sub2/endpoint",
			},
			wants{
				"sample",
				subscriptions{
					"https://localhost:8080/sub1/endpoint",
					"https://localhost:8080/sub2/endpoint",
				},
			},
		},
		{
			"/messaging/v1/sample/subscriptions",
			subscriptions{
				"https://localhost:8080/sub1/endpoint",
				"https://localhost:8080/sub1/endpoint",
			},
			wants{
				"sample",
				subscriptions{
					"https://localhost:8080/sub1/endpoint",
				},
			},
		},
		{
			"/messaging/v1/sample/subscriptions",
			subscriptions{
				"htt://localhost:8080/sub1/endpoint",
			},
			wants{
				"sample",
				nil,
			},
		},
	}

	re := repo.InmemoryRepo
	conf := server.Config{Repo: re, HTTPClient: httpclient.EmptyHTTPClient, Log: logger.StandardLog}
	server := httptest.NewServer(server.NewRouterForMessaging(conf))
	defer server.Close()

	for i, test := range tests {
		re.Reset()

		for _, s := range test.subscriptions {
			req, _ := http.NewRequest("PUT", server.URL+test.path, param(s))
			_, err := http.DefaultClient.Do(req)

			if err != nil {
				t.Errorf("[%s] [%s] request error %v", test.path, s, err)
			}
		}

		s, _ := re.GetSubscriptions(test.wants.topic)
		sort.Strings(s)
		if !reflect.DeepEqual(subscriptions(s), test.wants.subscriptions) {
			t.Errorf("CASE %d: subscriptions = %#v, wants = %#v", i+1, subscriptions(s), test.wants.subscriptions)
		}
	}
}

func TestPublish(t *testing.T) {
	type data struct {
		topic         string
		subscriptions subscriptions
	}
	type wants struct {
		status        int
		message       string
		subscriptions subscriptions
	}

	tests := []struct {
		path    string
		message string
		initial []data
		wants   wants
	}{
		{
			path:    "/messaging/v1/sample1/publish",
			message: "Test Message",
			initial: []data{
				{
					"sample1",
					subscriptions{
						"https://localhost:8080/sub1-1/endpoint",
						"https://localhost:8080/sub1-2/endpoint",
					},
				},
				{
					"sample2",
					subscriptions{
						"https://localhost:8080/sub2-1/endpoint",
						"https://localhost:8080/sub2-2/endpoint",
					},
				},
			},
			wants: wants{
				http.StatusOK,
				"Test Message",
				subscriptions{
					"https://localhost:8080/sub1-1/endpoint",
					"https://localhost:8080/sub1-2/endpoint",
				},
			},
		},
		{
			path:    "/messaging/v1/sample2/publish",
			message: "Sample Message",
			initial: []data{
				{
					"sample1",
					subscriptions{
						"https://localhost:8080/sub1-1/endpoint",
						"https://localhost:8080/sub1-2/endpoint",
					},
				},
				{
					"sample2",
					subscriptions{
						"https://localhost:8080/sub2-1/endpoint",
						"https://localhost:8080/sub2-2/endpoint",
					},
				},
			},
			wants: wants{
				http.StatusOK,
				"Sample Message",
				subscriptions{
					"https://localhost:8080/sub2-1/endpoint",
					"https://localhost:8080/sub2-2/endpoint",
				},
			},
		},
		{
			path:    "/messaging/v1/sample3/publish",
			message: "Sample Message",
			initial: []data{
				{
					"sample1",
					subscriptions{
						"https://localhost:8080/sub1-1/endpoint",
						"https://localhost:8080/sub1-2/endpoint",
					},
				},
				{
					"sample2",
					subscriptions{
						"https://localhost:8080/sub2-1/endpoint",
						"https://localhost:8080/sub2-2/endpoint",
					},
				},
			},
			wants: wants{
				status: http.StatusNotFound,
			},
		},
	}

	re := repo.InmemoryRepo
	client := httpclient.EmptyHTTPClient
	conf := server.Config{Repo: re, HTTPClient: client, Log: logger.StandardLog}
	server := httptest.NewServer(server.NewRouterForMessaging(conf))
	defer server.Close()

	for i, test := range tests {
		client.Reset()
		re.Reset()
		for _, d := range test.initial {
			re.SaveSubscriptions(d.topic, d.subscriptions)
		}

		req, _ := http.NewRequest("POST", server.URL+test.path, strings.NewReader(test.message))
		res, err := http.DefaultClient.Do(req)

		if err != nil {
			t.Errorf("[%s] request error %v", test.path, err)
		}
		if res.StatusCode != test.wants.status {
			t.Errorf("[%s] StatusCode = %d, wants = %d", test.path, res.StatusCode, test.wants.status)
		}

		existsPath := func(path string) bool {
			for _, p := range client.PostedLogs() {
				if path == p.URL {
					return true
				}
			}
			return false
		}

		for _, s := range test.wants.subscriptions {
			if !existsPath(s) {
				t.Errorf("CASE %d: %s was not posted.", i+1, s)
			}
		}
		for _, p := range client.PostedLogs() {
			if p.Body != test.wants.message {
				t.Errorf("CASE %d: POST BODY = %s, wants = %s.", i+1, p.Body, test.wants.message)
			}
		}
	}
}

func param(s string) io.Reader {
	p := struct {
		Subscription string `json:"subscription"`
	}{s}

	var buf bytes.Buffer
	json.NewEncoder(&buf).Encode(p)
	return bytes.NewReader(buf.Bytes())
}
