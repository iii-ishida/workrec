package model_test

import (
	"reflect"
	"testing"
	"workrec/api/event"
	"workrec/api/model"
)

func TestCreateWork(t *testing.T) {
	w := model.CreateWork("A")

	if w.ID == "" {
		t.Error("w.ID is empty")
	}
	if w.Title != "A" {
		t.Errorf("w.Title = %s, wants = A", w.Title)
	}
	if l := len(w.Actions); l != 0 {
		t.Errorf("len(w.Actions) = %d, wants = 0", l)
	}
}

func TestUpdate(t *testing.T) {
	w := model.CreateWork("A")
	w2 := w.DeepCopy()

	updated := w.Update("B")

	if !reflect.DeepEqual(w, w2) {
		t.Fatal("Work#Update is not immutable.")
	}

	if updated.Title != "B" {
		t.Errorf("updated.Title = %s, wants = B", updated.Title)
	}
	if updated.ID != w.ID {
		t.Errorf("Work#Update modified ID")
	}
	if !reflect.DeepEqual(updated.Actions, w.Actions) {
		t.Error("Work#Update modified Actions")
	}
}

func TestDelete(t *testing.T) {
	w := model.CreateWork("A")
	w2 := w.DeepCopy()

	deleted := w.Delete()

	if !reflect.DeepEqual(w, w2) {
		t.Fatal("Work#Delete is not immutable.")
	}

	if deleted.ID != w.ID {
		t.Errorf("Work#Delete modified ID")
	}
	if deleted.Title != "" {
		t.Error("deleted.Title is not empty.")
	}
	if deleted.Actions != nil {
		t.Error("deleted.Actions is not nil")
	}

	if !deleted.IsDeleted() {
		t.Error("deleted.IsDeleted() = false, wants = true")
	}
	if w.IsDeleted() {
		t.Error("w.IsDeleted() = true, wants = false")
	}
}

func TestStart(t *testing.T) {
	w := model.CreateWork("A")
	w2 := w.DeepCopy()

	started := w.Start(10)

	if !reflect.DeepEqual(w, w2) {
		t.Fatal("Work#Start is not immutable.")
	}

	if l := len(started.Actions); l != 1 {
		t.Fatalf("len(started.Actions) = %d, wants = 1", l)
	}
	if s := started.Actions[0].State; s != model.Started {
		t.Errorf("started.Actions.State = %s, wants = %s", s, model.Started)
	}
	if tm := started.Actions[0].Time; tm != 10 {
		t.Errorf("started.Actions.Time = %d, wants = 10", tm)
	}
}

func TestPause(t *testing.T) {
	w := model.CreateWork("A").Start(10)
	w2 := w.DeepCopy()

	paused := w.Pause(20)

	if !reflect.DeepEqual(w, w2) {
		t.Fatalf("Work#Pause is not immutable.")
	}

	idx := 1
	if l := len(paused.Actions); l != idx+1 {
		t.Fatalf("len(paused.Actions) = %d, wants = %d", l, idx+1)
	}
	if s := paused.Actions[idx].State; s != model.Paused {
		t.Errorf("paused.Actions.State = %s, wants = %s", s, model.Paused)
	}
	if tm := paused.Actions[idx].Time; tm != 20 {
		t.Errorf("toggled.Actions.Time = %d, wants = 20", tm)
	}
}

func TestResume(t *testing.T) {
	w := model.CreateWork("A").Start(10).Pause(20)
	w2 := w.DeepCopy()

	resumed := w.Resume(30)

	if !reflect.DeepEqual(w, w2) {
		t.Fatal("Work#Resume is not immutable.")
	}

	idx := 2
	if l := len(resumed.Actions); l != idx+1 {
		t.Fatalf("len(resumed.Actions) = %d, wants = %d", l, idx+1)
	}
	if s := resumed.Actions[idx].State; s != model.Resumed {
		t.Errorf("resumed.Actions.State = %s, wants = %s", s, model.Resumed)
	}
	if tm := resumed.Actions[idx].Time; tm != 30 {
		t.Errorf("resumed.Actions.Time = %d, wants = 30", tm)
	}
}

func TestFinish(t *testing.T) {
	w := model.CreateWork("A").Start(10).Pause(20).Resume(30)
	w2 := w.DeepCopy()

	finished := w.Finish(40)

	if !reflect.DeepEqual(w, w2) {
		t.Fatal("Work#Finish is not immutable.")
	}

	idx := 3
	if l := len(finished.Actions); l != idx+1 {
		t.Fatalf("len(finished.Actions) = %d, wants = %d", l, idx+1)
	}
	if s := finished.Actions[idx].State; s != model.Finished {
		t.Errorf("finished.Actions.State = %s, wants = %s", s, model.Finished)
	}
	if tm := finished.Actions[idx].Time; tm != 40 {
		t.Errorf("finished.Actions.Time = %d, wants = 40", tm)
	}
}

func TestChange(t *testing.T) {
	tests := []struct {
		label string
		w     model.Work
		e     event.Event
	}{
		{
			"Created",
			model.CreateWork("A"),
			event.Event{Type: event.Created, Title: "A"},
		},
		{
			"Updated",
			model.CreateWork("A").Update("B"),
			event.Event{Type: event.Updated, Title: "B"},
		},
		{
			"Deleted",
			model.CreateWork("A").Delete(),
			event.Event{Type: event.Deleted},
		},
		{
			"Started",
			model.CreateWork("A").Start(10),
			event.Event{Type: event.Started, Time: 10},
		},
		{
			"Paused",
			model.CreateWork("A").Start(10).Pause(20),
			event.Event{Type: event.Paused, Time: 20},
		},
		{
			"Resumed",
			model.CreateWork("A").Start(10).Pause(20).Resume(30),
			event.Event{Type: event.Resumed, Time: 30},
		},
		{
			"Finished",
			model.CreateWork("A").Start(10).Pause(20).Resume(30).Finish(40),
			event.Event{Type: event.Finished, Time: 40},
		},
	}

	for _, test := range tests {
		test.e.ID = test.w.Change().ID
		test.e.WorkID = test.w.ID
		test.e.UpdatedAt = test.w.UpdatedAt

		if !reflect.DeepEqual(test.w.Change(), test.e) {
			t.Errorf("[%s] test.w.Change() = %#v, wants =%#v", test.label, test.w.Change(), test.e)
		}
	}
}
