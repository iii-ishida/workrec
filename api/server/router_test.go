package server_test

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"workrec/api/event"
	"workrec/api/model"
	"workrec/api/repo"
	"workrec/api/server"
	"workrec/libs/logger"
)

type p struct {
	Title string
	Time  int64
}

type wants struct {
	status int
	work   model.Work
	event  event.Event
}

type testcase struct {
	tag     string
	initial model.Work
	method  string
	path    string
	param   p
	wants   wants
}

func TestRouter(t *testing.T) {
	tests := []testcase{
		{
			tag:    "create work",
			method: "POST",
			path:   "/api/v1/works",
			param:  p{Title: "A"},

			wants: wants{
				status: http.StatusCreated,
				work:   model.Work{Title: "A"},
				event:  event.Event{Type: event.Created, Title: "A"},
			},
		},
		{
			tag:     "update work",
			initial: model.Work{ID: "1", Title: "A"},
			method:  "PUT",
			path:    "/api/v1/works/1",
			param:   p{Title: "B"},
			wants: wants{
				status: http.StatusOK,
				work:   model.Work{Title: "B"},
				event:  event.Event{Type: event.Updated, Title: "B"},
			},
		},
		{
			tag:     "delete work",
			initial: model.Work{ID: "1", Title: "A"},
			method:  "DELETE",
			path:    "/api/v1/works/1",
			wants: wants{
				status: http.StatusOK,
				work:   model.Work{},
				event:  event.Event{Type: event.Deleted},
			},
		},
		{
			tag:     "start work",
			initial: model.Work{ID: "1", Title: "A"},
			method:  "POST",
			path:    "/api/v1/works/1/start",
			param:   p{Time: 10},
			wants: wants{
				status: http.StatusOK,
				work:   model.Work{ID: "1", Title: "A", Actions: []model.Action{{State: model.Started, Time: 10}}},
				event:  event.Event{Type: event.Started, WorkID: "1", Time: 10},
			},
		},
		{
			tag:     "pause work",
			initial: model.Work{ID: "1", Title: "A", Actions: []model.Action{{State: model.Started, Time: 10}}},
			method:  "POST",
			path:    "/api/v1/works/1/pause",
			param:   p{Time: 20},
			wants: wants{
				status: http.StatusOK,
				work: model.Work{
					ID:      "1",
					Title:   "A",
					Actions: []model.Action{{State: model.Started, Time: 10}, {State: model.Paused, Time: 20}},
				},
				event: event.Event{Type: event.Paused, WorkID: "1", Time: 20},
			},
		},
		{
			tag:     "resume work",
			initial: model.Work{ID: "1", Title: "A", Actions: []model.Action{{State: model.Started, Time: 10}, {State: model.Paused, Time: 20}}},
			method:  "POST",
			path:    "/api/v1/works/1/resume",
			param:   p{Time: 30},
			wants: wants{
				status: http.StatusOK,
				work: model.Work{
					ID:      "1",
					Title:   "A",
					Actions: []model.Action{{State: model.Started, Time: 10}, {State: model.Paused, Time: 20}, {State: model.Resumed, Time: 30}},
				},
				event: event.Event{Type: event.Resumed, WorkID: "1", Time: 30},
			},
		},
		{
			tag: "finish work",
			initial: model.Work{
				ID:      "1",
				Title:   "A",
				Actions: []model.Action{{State: model.Started, Time: 10}, {State: model.Paused, Time: 20}, {State: model.Resumed, Time: 30}},
			},
			method: "POST",
			path:   "/api/v1/works/1/finish",
			param:  p{Time: 40},
			wants: wants{
				status: http.StatusOK,
				work: model.Work{
					ID:    "1",
					Title: "A",
					Actions: []model.Action{
						{State: model.Started, Time: 10}, {State: model.Paused, Time: 20}, {State: model.Resumed, Time: 30}, {State: model.Finished, Time: 40},
					},
				},
				event: event.Event{Type: event.Finished, WorkID: "1", Time: 40},
			},
		},
		{
			tag:     "work not found",
			initial: model.Work{ID: "1", Title: "A"},
			method:  "PUT",
			path:    "/api/v1/works/2",
			param:   p{Title: "B"},
			wants: wants{
				status: http.StatusNotFound,
			},
		},
	}

	testRouter(tests, t)
}

func testRouter(tests []testcase, t *testing.T) {
	re := repo.InmemoryRepo
	conf := server.Config{
		Repo: re,
		Log:  logger.StandardLog,
	}

	server := httptest.NewServer(server.NewRouterForAPI(conf))
	defer server.Close()

	for _, test := range tests {
		if !test.initial.IsEmpty() {
			re.SaveWork(test.initial)
		}

		req, _ := http.NewRequest(test.method, server.URL+test.path, newParam(test.param))
		res, err := http.DefaultClient.Do(req)

		if err != nil {
			t.Errorf("[%s] request error: %v", test.tag, err)
		}
		defer res.Body.Close()

		if res.StatusCode != test.wants.status {
			t.Errorf("[%s] res.StatusCode = %d, wants = %d", test.tag, res.StatusCode, test.wants.status)
		}

		if !test.wants.work.IsEmpty() {
			w := re.LatestSavedWork()
			if !equalWork(w, test.wants.work) {
				t.Errorf("[%s] savedWork = %#v, wants = %#v", test.tag, w, test.wants.work)
			}
		}

		if test.wants.event.Type != event.Unknown {
			w := re.LatestSavedWork()
			e := re.LatestSavedEvent()
			if e.WorkID != w.ID {
				t.Errorf("[%s] savedEvent.ID = %#v, want = %#v", test.tag, e.ID, w.ID)
			}
			if !equalEvent(e, test.wants.event) {
				t.Errorf("[%s] savedEvent = %#v, want = %#v", test.tag, e, test.wants.event)
			}
		}
	}
}

func newParam(param p) io.Reader {
	var buf bytes.Buffer
	json.NewEncoder(&buf).Encode(param)
	return bytes.NewReader(buf.Bytes())
}

func equalWork(w, wants model.Work) bool {
	if w.Title != wants.Title || len(w.Actions) != len(wants.Actions) {
		return false
	}

	if len(wants.Actions) > 0 {
		for i, wa := range wants.Actions {
			a := w.Actions[i]
			isEqual := a.State == wa.State &&
				a.Time == wa.Time

			if !isEqual {
				return false
			}
		}
	}
	return true
}

func equalEvent(e, wants event.Event) bool {
	return e.Type == wants.Type &&
		e.Title == wants.Title &&
		e.Time == wants.Time
}
