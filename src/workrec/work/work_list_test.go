package work

import (
	"reflect"
	"strings"
	"testing"
	"time"
)

func TestWorkListEqual(t *testing.T) {
	if !(WorkList{}).Equal(WorkList{}) {
		t.Errorf("WorkList{}.Equal(WorkList{}) is false")
	}

	workList1 := make(WorkList, len(testWorkList))
	copy(workList1, testWorkList)

	workList2 := make(WorkList, len(testWorkList))
	copy(workList2, testWorkList)

	if !workList1.Equal(workList2) {
		t.Errorf("workList1.Equal(workList2) = false, want true")
	}

	workList3 := make(WorkList, len(testWorkList))
	copy(workList3, testWorkList)
	workList3[0].Title = "TEST TITLE"
	if workList1.Equal(workList3) {
		t.Errorf("workList1.Equal(workList3) = true, want false")
	}

	workList4 := make(WorkList, len(testWorkList))
	copy(workList4, append(testWorkList[1:], testWorkList[0]))
	if workList1.Equal(workList4) {
		t.Errorf("workList1.Equal(workList4) = true, want false")
	}

	workList5 := make(WorkList, len(testWorkList)-1)
	copy(workList5, testWorkList[1:])
	if workList1.Equal(workList5) {
		t.Errorf("workList1.Equal(workList5) = true, want false")
	}
}

func TestWorkListFromJSON(t *testing.T) {
	if _, err := WorkListFromJSON(strings.NewReader(`{}`)); err == nil {
		t.Errorf("err = nil, want not nil")
	}

	workList, err := WorkListFromJSON(strings.NewReader(workListJSONString))
	if err != nil {
		t.Errorf("err = %+v, want nil", err)
	}

	if !workList.Equal(testWorkList) {
		t.Errorf("workList = %+v, want %+v", workList, testWorkList)
	}
}

func TestWorkListOrder(t *testing.T) {
	wants := []string{
		"作業03",
		"作業01",
		"作業05",
		"作業02",
		"作業04",
	}

	original := testWorkList

	ordered := original.Ordered()
	for i, work := range ordered {
		want := wants[i]
		if work.Title != want {
			t.Errorf("ordered[%d] = %+v, want %+v", i, work, want)
		}
	}

	wants = []string{
		"作業01",
		"作業02",
		"作業03",
		"作業04",
		"作業05",
	}
	for i, work := range original {
		want := wants[i]
		if work.Title != want {
			t.Errorf("original[%d] = %+v, want %+v", i, work, want)
		}
	}
}

func TestWorkSelect(t *testing.T) {
	selected := testWorkList.Select([]string{})
	if len(selected) != 0 {
		t.Errorf("Select([]) = %+v, want []", workIDs(selected))
	}

	selected = testWorkList.Select([]string{"ABC"})
	if len(selected) != 0 {
		t.Errorf("Select([\"ABC\"]) = %+v, want []", workIDs(selected))
	}

	selectedIDs := workIDs(testWorkList.Select([]string{"1", "3", "5"}))
	want := []string{"1", "3", "5"}
	if !reflect.DeepEqual(selectedIDs, want) {
		t.Errorf("selected = %+v, want %+v", selectedIDs, want)
	}

	selectedIDs = workIDs(testWorkList.Ordered().Select([]string{"1", "3", "5"}))
	want = []string{"3", "1", "5"}
	if !reflect.DeepEqual(selectedIDs, want) {
		t.Errorf("orderedSelected = %+v, want %+v", selectedIDs, want)
	}
}

var testWorkList = WorkList{
	func() Work {
		work := New("作業01", 0)
		work = work.Start(time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC))
		work = work.Toggle(time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC))
		work = work.Toggle(time.Date(2015, 7, 29, 13, 30, 0, 0, time.UTC))
		work = work.Toggle(time.Date(2015, 7, 29, 18, 30, 0, 0, time.UTC))
		return work
	}(),
	func() Work {
		work := New("作業02", 500)
		work = work.Start(time.Date(2015, 7, 28, 10, 00, 0, 0, time.UTC))  // 開始
		work = work.Toggle(time.Date(2015, 7, 28, 12, 00, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 28, 14, 30, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 28, 19, 30, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 29, 10, 00, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 29, 12, 00, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 29, 14, 30, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 30, 1, 00, 0, 0, time.UTC))  // 停止
		work = work.Toggle(time.Date(2015, 7, 30, 13, 30, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 30, 15, 30, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 30, 16, 30, 0, 0, time.UTC)) // 再開
		return work
	}(),
	func() Work {
		work := New("作業03", 1000)
		work = work.Start(time.Date(2015, 7, 30, 10, 00, 0, 0, time.UTC))  // 開始
		work = work.Toggle(time.Date(2015, 7, 30, 12, 00, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 30, 14, 30, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 30, 18, 30, 0, 0, time.UTC)) // 停止
		return work
	}(),
	func() Work {
		work := New("作業04", 750)
		work = work.Start(time.Date(2015, 7, 27, 10, 00, 0, 0, time.UTC))  // 開始
		work = work.Toggle(time.Date(2015, 7, 27, 12, 00, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 27, 14, 30, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 27, 18, 30, 0, 0, time.UTC)) // 停止
		return work
	}(),
	func() Work {
		work := New("作業05", 0)
		work = work.Start(time.Date(2015, 7, 28, 10, 00, 0, 0, time.UTC))  // 開始
		work = work.Toggle(time.Date(2015, 7, 28, 12, 00, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 28, 14, 30, 0, 0, time.UTC)) // 再開
		work = work.Finish(time.Date(2015, 7, 28, 18, 30, 0, 0, time.UTC)) // 完了
		return work
	}(),
}

const workListJSONString = `
[
	{
		"id": "1",
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
		"id": "2",
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
		"id": "3",
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
		"id": "4",
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
		"id": "5",
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

func workIDs(works []Work) []string {
	workIDs := []string{}
	for _, work := range works {
		workIDs = append(workIDs, work.ID)
	}
	return workIDs
}
