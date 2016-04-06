package work

import (
	"testing"
	"time"
)

func TestWorkCollectionOrder(t *testing.T) {
	wants := []string{
		"作業03",
		"作業01",
		"作業05",
		"作業02",
		"作業04",
	}

	original := testWorkCollection

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

var testWorkCollection = WorkCollection{
	func() Work {
		work := New("作業01", 0)
		work = work.Start(time.Date(2015, 7, 29, 9, 30, 0, 0, time.UTC))
		work = work.Toggle(time.Date(2015, 7, 29, 12, 30, 0, 0, time.UTC))
		work = work.Toggle(time.Date(2015, 7, 29, 13, 30, 0, 0, time.UTC))
		work = work.Toggle(time.Date(2015, 7, 29, 18, 30, 0, 0, time.UTC))
		return work
	}(),
	func() Work {
		work := New("作業02", 0)
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
		work := New("作業03", 0)
		work = work.Start(time.Date(2015, 7, 30, 10, 00, 0, 0, time.UTC))  // 開始
		work = work.Toggle(time.Date(2015, 7, 30, 12, 00, 0, 0, time.UTC)) // 停止
		work = work.Toggle(time.Date(2015, 7, 30, 14, 30, 0, 0, time.UTC)) // 再開
		work = work.Toggle(time.Date(2015, 7, 30, 18, 30, 0, 0, time.UTC)) // 停止
		return work
	}(),
	func() Work {
		work := New("作業04", 0)
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
