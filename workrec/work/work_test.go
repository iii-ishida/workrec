package work

import (
	"strings"
	"testing"
	"time"
)

func TestCurrentState(t *testing.T) {
	work := New("TestCurrentState", 0)
	want := Unknown
	if work.CurrentState() != want {
		t.Errorf("work.CurrentState() = %+v, want %+v", work.CurrentState(), want)
	}

	work = work.Start(time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC))
	want = Start
	if work.CurrentState() != want {
		t.Errorf("work.CurrentState() = %+v, want %+v", work.CurrentState(), want)
	}

	work = work.Toggle(time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC))
	want = Pause
	if work.CurrentState() != want {
		t.Errorf("work.CurrentState() = %+v, want %+v", work.CurrentState(), want)
	}

	work = work.Toggle(time.Date(2015, 7, 29, 13, 25, 0, 0, time.UTC))
	want = Resume
	if work.CurrentState() != want {
		t.Errorf("work.CurrentState() = %+v, want %+v", work.CurrentState(), want)
	}

	work = work.Finish(time.Date(2015, 7, 29, 18, 30, 0, 0, time.UTC))
	want = Finish
	if work.CurrentState() != want {
		t.Errorf("work.CurrentState() = %+v, want %+v", work.CurrentState(), want)
	}
}

func TestStartWork(t *testing.T) {
	original := New("TestStartWork", 0)

	started := original.Start(time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC))
	want := Start
	if started.CurrentState() != want {
		t.Errorf("started.CurrentState() = %+v, want %+v", started.CurrentState(), want)
	}

	want = Unknown
	if original.CurrentState() != want {
		t.Errorf("original.CurrentState() = %+v, want %+v", original.CurrentState(), want)
	}
}

func TestToggleWork(t *testing.T) {
	startTime := time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC)
	pauseTime := time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC)
	resumeTime := time.Date(2015, 7, 29, 13, 25, 0, 0, time.UTC)

	original := New("TestToggleWork", 0)

	paused := original.Start(startTime).Toggle(pauseTime)
	want := Pause
	if paused.CurrentState() != want {
		t.Errorf("paused.CurrentState() = %+v, want %+v", paused.CurrentState(), want)
	}

	resumed := paused.Toggle(resumeTime)
	want = Resume
	if resumed.CurrentState() != want {
		t.Errorf("resumed.CurrentState() = %+v, want %+v", resumed.CurrentState(), want)
	}

	want = Unknown
	if original.CurrentState() != want {
		t.Errorf("original.CurrentState() = %+v, want %+v", original.CurrentState(), want)
	}
}

func TestFinishWork(t *testing.T) {
	startTime := time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC)
	pauseTime := time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC)
	resumeTime := time.Date(2015, 7, 29, 13, 25, 0, 0, time.UTC)
	finishTime := time.Date(2015, 7, 29, 18, 30, 0, 0, time.UTC)

	original := New("TestFinishWork", 0)

	finished := original.Start(startTime).Toggle(pauseTime).Toggle(resumeTime).Finish(finishTime)
	want := Finish
	if finished.CurrentState() != want {
		t.Errorf("finished.CurrentState() = %+v, want %+v", finished.CurrentState(), want)
	}

	want = Unknown
	if original.CurrentState() != want {
		t.Errorf("original.CurrentState() = %+v, want %+v", original.CurrentState(), want)
	}
}

func TestStartTime(t *testing.T) {
	startTime := time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC)
	pauseTime := time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC)
	resumeTime := time.Date(2015, 7, 29, 13, 25, 0, 0, time.UTC)
	finishTime := time.Date(2015, 7, 29, 18, 30, 0, 0, time.UTC)

	work := New("TestStartTime", 0)
	if !work.StartTime().IsZero() {
		t.Errorf("work.StartTime() = %+v, want Zero", work.StartTime())
	}

	started := work.Start(startTime)
	want := startTime
	if !started.StartTime().Equal(want) {
		t.Errorf("started.StartTime() = %+v, want %+v", started.StartTime(), want)
	}

	paused := started.Toggle(pauseTime)
	if !paused.StartTime().Equal(want) {
		t.Errorf("paused.StartTime() = %+v, want %+v", paused.StartTime(), want)
	}

	resumed := paused.Toggle(resumeTime)
	if !resumed.StartTime().Equal(want) {
		t.Errorf("resumed.StartTime() = %+v, want %+v", resumed.StartTime(), want)
	}

	finished := resumed.Finish(finishTime)
	if !finished.StartTime().Equal(want) {
		t.Errorf("finished.StartTime() = %+v, want %+v", finished.StartTime(), want)
	}
}

func TestWorkFromJSON(t *testing.T) {
	const jsonString = `
	{
		"title": "TestWorkFromJSON", 
		"actions": [
			{
				"state": 1,
				"time": "2015-07-29T09:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-29T12:30:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-29T13:25:00+00:00"
			},
			{
				"state": 4,
				"time": "2015-07-29T18:30:00+00:00"
			}
		],
		"goal_minutes": 500
	}
	`

	if _, err := FromJSON(strings.NewReader(`{"title": 1}`)); err == nil {
		t.Errorf("err = nil, want not nil")
	}

	work, err := FromJSON(strings.NewReader(jsonString))
	if err != nil {
		t.Errorf("err = %+v, want nil", err)
	}

	want := "TestWorkFromJSON"
	if work.Title != want {
		t.Errorf("work.Title = %+v, want %+v", work.Title, want)
	}

	wantActions := []action{
		{State: Start, Time: time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC)},
		{State: Pause, Time: time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC)},
		{State: Resume, Time: time.Date(2015, 7, 29, 13, 25, 0, 0, time.UTC)},
		{State: Finish, Time: time.Date(2015, 7, 29, 18, 30, 0, 0, time.UTC)},
	}

	for i, wantAction := range wantActions {
		action := work.Actions[i]
		if action.State != wantAction.State || !action.Time.Equal(wantAction.Time) {
			t.Errorf("work.Actions[%d] = %+v, want %+v", i, action, wantAction)
		}
	}

	wantGoalMinutes := 500
	if work.GoalMinutes != wantGoalMinutes {
		t.Errorf("work.GoalMinutes = %+v, want %+v", work.GoalMinutes, wantGoalMinutes)
	}
}
