package model_test

import (
	"reflect"
	"testing"
	"time"
	"workrec/api/event"
	"workrec/query/model"
)

func TestCreateSummary(t *testing.T) {
	t2017_05_20_12_30 := time.Date(2017, 5, 20, 12, 30, 15, 0, time.UTC).Unix()
	t2017_05_20_14_30 := time.Date(2017, 5, 20, 14, 30, 15, 0, time.UTC).Unix()

	tests := []struct {
		label   string
		initial model.Work
		e       event.Event
		wants   model.Work
	}{
		{
			"Created",
			model.Work{},
			event.Event{Type: event.Created, WorkID: "1", Title: "A", UpdatedAt: 10},
			model.Work{ID: "1", Title: "A", State: model.Unstarted, UpdatedAt: 10},
		},
		{
			"Updated",
			model.Work{ID: "1", Title: "A"},
			event.Event{Type: event.Updated, WorkID: "1", Title: "B", UpdatedAt: 10},
			model.Work{ID: "1", Title: "B", State: model.Unstarted, UpdatedAt: 10},
		},
		{
			"Started",
			model.Work{ID: "1"},
			event.Event{Type: event.Started, Time: t2017_05_20_12_30, UpdatedAt: 10},
			model.Work{ID: "1", WorkTime: 0, State: model.Started, StateChangedAt: t2017_05_20_12_30, UpdatedAt: 10},
		},
		{
			"Paused",
			model.Work{ID: "1", WorkTime: 0, StateChangedAt: t2017_05_20_12_30},
			event.Event{Type: event.Paused, Time: t2017_05_20_14_30, UpdatedAt: 10},
			model.Work{ID: "1", WorkTime: 120, State: model.Paused, StateChangedAt: t2017_05_20_14_30, UpdatedAt: 10},
		},
		{
			"Resumed",
			model.Work{ID: "1", PauseTime: 0, StateChangedAt: t2017_05_20_12_30},
			event.Event{Type: event.Resumed, Time: t2017_05_20_14_30, UpdatedAt: 10},
			model.Work{ID: "1", PauseTime: 120, State: model.Resumed, StateChangedAt: t2017_05_20_14_30, UpdatedAt: 10},
		},
		{
			"Finished (from Paused)",
			model.Work{ID: "1", WorkTime: 120, PauseTime: 120, State: model.Paused, StateChangedAt: t2017_05_20_12_30},
			event.Event{Type: event.Finished, Time: t2017_05_20_14_30, UpdatedAt: 10},
			model.Work{ID: "1", WorkTime: 120, PauseTime: 120, State: model.Finished, StateChangedAt: t2017_05_20_14_30, UpdatedAt: 10},
		},
		{
			"Finished (from Resumed)",
			model.Work{ID: "1", WorkTime: 120, PauseTime: 120, State: model.Resumed, StateChangedAt: t2017_05_20_12_30},
			event.Event{Type: event.Finished, Time: t2017_05_20_14_30, UpdatedAt: 10},
			model.Work{ID: "1", WorkTime: 240, PauseTime: 120, State: model.Finished, StateChangedAt: t2017_05_20_14_30, UpdatedAt: 10},
		},
	}

	for _, test := range tests {
		if w := test.initial.Process(test.e); !reflect.DeepEqual(w, test.wants) {
			t.Errorf("[%s] processed = %#v, wants = %#v", test.label, w, test.wants)
		}
	}
}
