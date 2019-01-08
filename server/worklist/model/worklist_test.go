package model_test

import (
	"testing"

	"github.com/iii-ishida/workrec/server/worklist/model"
	"time"
)

func TestCalculateBaseWorkingTime(t *testing.T) {
	var (
		startTime, _  = time.Parse(time.RFC3339, "2019-01-08T09:30:00Z")
		pauseTime, _  = time.Parse(time.RFC3339, "2019-01-08T12:00:00Z")
		resumeTime, _ = time.Parse(time.RFC3339, "2019-01-08T13:00:00Z")

		observedAt, _ = time.Parse(time.RFC3339, "2019-01-08T18:00:00Z")

		expectedWorkingTimeInMinute = 7.5 * 60.0
	)

	w := model.WorkListItem{BaseWorkingTime: startTime, PausedAt: pauseTime}
	baseWorkingTime := w.CalculateBaseWorkingTime(resumeTime)
	workingTimeInMinute := observedAt.Sub(baseWorkingTime).Minutes()

	if workingTimeInMinute != expectedWorkingTimeInMinute {
		t.Errorf("workingTimeInMinute = %f, wants = %f", workingTimeInMinute, expectedWorkingTimeInMinute)
	}
}
