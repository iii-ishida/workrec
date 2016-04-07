package db

import (
	"testing"
)

func TestNextWorkID(t *testing.T) {
	workID := NextWorkID()
	want := "1"
	if workID != want {
		t.Errorf("NextWorkID() = %+v, want %+v", workID, want)
	}

	workID = NextWorkID()
	want = "2"
	if workID != want {
		t.Errorf("NextWorkID() = %+v, want %+v", workID, want)
	}

	const loopCnt = 10000
	c := make(chan string, loopCnt-3)
	for i := 3; i < loopCnt; i++ {
		go func() {
			c <- NextWorkID()
		}()
	}

	workIDs := make(map[string]struct{})
	for i := 3; i < loopCnt; i++ {
		workID := <-c
		if _, ok := workIDs[workID]; ok {
			t.Errorf("Duplicate NextWorkID() = %+v", workID)
			break
		}
		workIDs[workID] = struct{}{}
	}
}
