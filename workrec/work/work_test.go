package work

import (
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
