package db

import (
	"strings"
	"testing"

	"google.golang.org/appengine/aetest"
	"google.golang.org/appengine/datastore"

	"workrec/work"
)

func TestNextWorkID(t *testing.T) {
	db, inst := db(t)
	defer inst.Close()
	defer func() { currentId = _UnInitializedId }()

	workID := db.NextWorkID()
	want := "1"
	if workID != want {
		t.Errorf("NextWorkID() = %+v, want %+v", workID, want)
	}

	workID = db.NextWorkID()
	want = "2"
	if workID != want {
		t.Errorf("NextWorkID() = %+v, want %+v", workID, want)
	}

	const loopCnt = 10000
	c := make(chan string, loopCnt-3)
	for i := 3; i < loopCnt; i++ {
		go func() {
			c <- db.NextWorkID()
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

func TestNextWorkIDFromDB(t *testing.T) {
	db, inst := db(t)
	defer inst.Close()

	wk := work.New("TestTitle", 0)
	wk.ID = "3000"

	db.SaveWork(wk)
	defer db.DeleteWork(wk)
	tmp := work.Work{}
	datastore.Get(db.ctx, datastore.NewKey(db.ctx, "Works", wk.ID, 0, nil), &tmp)

	want := "3001"
	if workID := db.NextWorkID(); workID != want {
		t.Errorf("NextWorkID() = %+v, want %+v", workID, want)
	}
}

func TestCRUD(t *testing.T) {
	db, inst := db(t)
	defer inst.Close()

	// Save
	for i, wk := range works {
		savedWork, err := db.SaveWork(wk)
		if err != nil {
			t.Errorf("works[%d], SaveWork err = %+v, want nil", i, err)
		} else if savedWork.ID == "" {
			t.Errorf("savedWorks[%d].ID = \"\"", i)
		} else if wk.ID != "" {
			t.Errorf("work[%d].ID = %+v, want \"\"", i, wk.ID)
		}
		works[i].ID = savedWork.ID

		tmp := work.Work{}
		datastore.Get(db.ctx, datastore.NewKey(db.ctx, "Works", savedWork.ID, 0, nil), &tmp)
	}

	// GetAll
	savedWorks, err := db.GetAllWorks()
	if err != nil {
		t.Errorf("GetAllWorks err = %+v, want nil", err)
	}
	if !savedWorks.Equal(works) {
		t.Errorf("savedWorks.Equal(works) = false, want true")
	}

	// Save (Update)
	const updateWorkIdx = 3
	works[updateWorkIdx].Title = "UPDATE TITLE"
	if _, err := db.SaveWork(works[updateWorkIdx]); err != nil {
		t.Errorf("works[3], SaveWork(Update) err = %+v, want nil", err)
	}
	tmp := work.Work{}
	datastore.Get(db.ctx, datastore.NewKey(db.ctx, "Works", works[updateWorkIdx].ID, 0, nil), &tmp)

	updatedWorks, _ := db.GetAllWorks()
	if !updatedWorks.Equal(works) {
		t.Errorf("updatedWorks.Equal(works) = false, want true")
	}
	if updatedWorks.Equal(savedWorks) {
		t.Errorf("updatedWorks.Equal(savedWorks) = true, want false")
	}

	// Delete
	for i, wk := range works {
		if err := db.DeleteWork(wk); err != nil {
			t.Errorf("works[%d], DeleteWork err = %+v, want nil", i, err)
		}
		tmp := work.Work{}
		datastore.Get(db.ctx, datastore.NewKey(db.ctx, "Works", wk.ID, 0, nil), &tmp)
	}

	if allWorks, _ := db.GetAllWorks(); len(allWorks) != 0 {
		t.Errorf("len(GetAllWorks) = %d, want 0", len(allWorks))
	}

	if err := db.DeleteWork(work.Work{}); err == nil {
		t.Errorf("DeleteWork(Work{}]) err nil, want not nil")
	}
}

const workListJSONString = `
[
	{
		"title": "作業01",
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
				"time": "2015-07-29T13:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-29T18:30:00+00:00"
			}
		],
		"goal_minutes": 0
	},
	{
		"title": "作業02",
		"actions": [
			{
				"state": 1,
				"time": "2015-07-28T10:00:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-28T12:00:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-28T14:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-28T19:30:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-29T10:00:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-29T12:00:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-29T14:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-30T01:00:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-30T13:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-30T15:30:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-30T16:30:00+00:00"
			}
		],
		"goal_minutes": 500
	},
	{
		"title": "作業03",
		"actions": [
			{
				"state": 1,
				"time": "2015-07-30T10:00:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-30T12:00:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-30T14:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-30T18:30:00+00:00"
			}
		],
		"goal_minutes": 1000
	},
	{
		"title": "作業04",
		"actions": [
			{
				"state": 1,
				"time": "2015-07-27T10:00:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-27T12:00:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-27T14:30:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-27T18:30:00+00:00"
			}
		],
		"goal_minutes": 750
	},
	{
		"title": "作業05",
		"actions": [
			{
				"state": 1,
				"time": "2015-07-28T10:00:00+00:00"
			},
			{
				"state": 2,
				"time": "2015-07-28T12:00:00+00:00"
			},
			{
				"state": 3,
				"time": "2015-07-28T14:30:00+00:00"
			},
			{
				"state": 4,
				"time": "2015-07-28T18:30:00+00:00"
			}
		],
		"goal_minutes": 0
	}
]
`

var works, _ = work.WorkListFromJSON(strings.NewReader(workListJSONString))

func db(t *testing.T) (AppengineDB, aetest.Instance) {
	inst, err := aetest.NewInstance(nil)
	if err != nil {
		t.Fatalf("Failed to create instance: %v", err)
	}

	req, err := inst.NewRequest("GET", "/works", nil)
	return NewAppEngineDB(req), inst
}
