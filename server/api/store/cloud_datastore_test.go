package store_test

import (
	"context"
	"errors"
	"net/http"
	"testing"
	"time"

	"cloud.google.com/go/datastore"
	"github.com/google/go-cmp/cmp"
	"github.com/iii-ishida/workrec/server/api/model"
	"github.com/iii-ishida/workrec/server/api/store"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
)

func TestRunInTransaction(t *testing.T) {
	var (
		r, _ = http.NewRequest("GET", "/", nil)
		s, _ = store.NewCloudDataStore(r)
	)
	defer s.Close()

	t.Run("errorがnilの場合は全ての変更を適用すること", func(t *testing.T) {
		defer clearStore()

		s.RunInTransaction(func(s store.Store) error {
			s.PutWork(model.Work{
				ID: "some-workid",
			})
			s.PutEvent(event.Event{
				ID: "some-eventid",
			})
			return nil
		})

		if w := getWork(r, "some-workid"); w.ID == "" {
			t.Fatal("Work is not saved")
		}
		if e := getEvent(r, "some-eventid"); e.ID == "" {
			t.Fatal("Event is not saved")
		}
	})

	t.Run("errorがnilでない場合は全ての変更を適用しないこと", func(t *testing.T) {
		defer clearStore()

		s.RunInTransaction(func(s store.Store) error {
			s.PutWork(model.Work{
				ID: "some-workid",
			})
			s.PutEvent(event.Event{
				ID: "some-eventid",
			})
			return errors.New("some error")
		})

		if w := getWork(r, "some-workid"); w.ID != "" {
			t.Fatal("Work is saved")
		}
		if e := getEvent(r, "some-eventid"); e.ID != "" {
			t.Fatal("Event is saved")
		}
	})

	t.Run("トランザクション中の関数で発生したerrorをそのまま返却すること", func(t *testing.T) {
		defer clearStore()

		someErr := errors.New("some error")
		err := s.RunInTransaction(func(s store.Store) error {
			return someErr
		})
		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func TestGetWork(t *testing.T) {
	var (
		r, _ = http.NewRequest("GET", "/", nil)
		s, _ = store.NewCloudDataStore(r)
	)
	defer s.Close()

	t.Run("対象あり", func(t *testing.T) {
		defer clearStore()

		source := model.Work{
			ID:        util.NewUUID(),
			EventID:   util.NewUUID(),
			Title:     "Some Title",
			State:     model.Started,
			UpdatedAt: time.Now().Truncate(time.Millisecond),
		}

		putWork(r, source)

		var work model.Work
		err := s.GetWork(source.ID, &work)

		t.Run("Workが取得されること", func(t *testing.T) {
			if !cmp.Equal(work, source) {
				t.Errorf("stored != source, diff = %s", cmp.Diff(work, source))
			}
		})

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})

	t.Run("対象が存在しない場合はErrNotfoundが返却されること", func(t *testing.T) {
		defer clearStore()

		var work model.Work
		err := s.GetWork("some-workid", &work)
		if err != store.ErrNotfound {
			t.Errorf("error = %#v, wants = ErrNotfound", err)
		}
	})
}

func TestPutWork(t *testing.T) {
	var (
		r, _ = http.NewRequest("GET", "/", nil)
		s, _ = store.NewCloudDataStore(r)

		source = model.Work{
			ID:        util.NewUUID(),
			EventID:   util.NewUUID(),
			Title:     "Some Title",
			State:     model.Started,
			UpdatedAt: time.Now().Truncate(time.Millisecond),
		}
	)
	defer s.Close()

	t.Run("対象あり", func(t *testing.T) {
		defer clearStore()

		putWork(r, source)

		work := model.Work{
			ID:        source.ID,
			EventID:   "some-eventid",
			Title:     "Updated Title",
			State:     model.Finished,
			UpdatedAt: time.Now().Truncate(time.Millisecond),
		}
		err := s.PutWork(work)

		t.Run("Workが更新されること", func(t *testing.T) {
			if w := getWork(r, source.ID); !cmp.Equal(w, work) {
				t.Errorf("updated != source, diff = %s", cmp.Diff(w, work))
			}
		})

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})

	t.Run("対象が存在しない場合Workを新規登録すること", func(t *testing.T) {
		defer clearStore()

		s.PutWork(source)

		if w := getWork(r, source.ID); !cmp.Equal(w, source) {
			t.Errorf("created != source, diff = %s", cmp.Diff(w, source))
		}
	})
}

func TestDeleteWork(t *testing.T) {
	var (
		r, _ = http.NewRequest("GET", "/", nil)
		s, _ = store.NewCloudDataStore(r)

		source = model.Work{
			ID:        util.NewUUID(),
			EventID:   util.NewUUID(),
			Title:     "Some Title",
			State:     model.Started,
			UpdatedAt: time.Now().Truncate(time.Millisecond),
		}
	)
	defer s.Close()

	t.Run("対象あり", func(t *testing.T) {
		defer clearStore()

		putWork(r, source)

		err := s.DeleteWork(source.ID)

		t.Run("Workが削除されること", func(t *testing.T) {
			if w := getWork(r, source.ID); w.ID != "" {
				t.Fatal("Work is not deleted")
			}
		})
		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})

	t.Run("対象が存在しない場合でもerrorがnilであること", func(t *testing.T) {
		defer clearStore()

		err := s.DeleteWork("some-workid")
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})
}

func TestPutEvent(t *testing.T) {
	var (
		r, _ = http.NewRequest("GET", "/", nil)
		s, _ = store.NewCloudDataStore(r)

		e = event.Event{
			ID:        util.NewUUID(),
			PrevID:    util.NewUUID(),
			WorkID:    util.NewUUID(),
			Action:    event.UpdateWork,
			Title:     "Some Title",
			Time:      time.Now().Truncate(time.Millisecond),
			CreatedAt: time.Now().Truncate(time.Millisecond),
		}
	)
	defer s.Close()
	defer clearStore()

	err := s.PutEvent(e)

	t.Run("Eventが登録されること", func(t *testing.T) {
		if saved := getEvent(r, e.ID); !cmp.Equal(saved, e) {
			t.Errorf("created != stored, diff = %s", cmp.Diff(saved, e))
		}
	})
	t.Run("errorがnilであること", func(t *testing.T) {
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})
}

func TestGetEvents(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		userID = "some-userid"
	)
	defer s.Close()

	t.Run("CreatedAt>lastConstructedAtに該当するEventを取得すること", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "some title 03", CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "some title 04", CreatedAt: now.Add(4 * time.Second)},
			}

			lastConstructedAt = fixtureEvents[1].CreatedAt
			pageSize          = len(fixtureEvents)
		)
		putEvents(r, fixtureEvents)

		var gotEvents []event.Event
		s.GetEvents(userID, lastConstructedAt, pageSize, "", &gotEvents)

		if l := len(gotEvents); l != 2 {
			t.Errorf("len(gotEvents) = %d, wants = 2", l)
		}
		for i, e := range gotEvents {
			if e.CreatedAt.Before(lastConstructedAt) {
				t.Errorf("gotEvents[%d].CreatedAt < lastConstructedAt", i)
			}
		}
	})

	t.Run("結果をCreatedAtの昇順にソートすること", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "number-3", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "number-1", CreatedAt: now.Add(0 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "number-2", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "number-4", CreatedAt: now.Add(3 * time.Second)},
			}

			oldestEvent       = fixtureEvents[1]
			lastConstructedAt = now.Add(-1 * time.Second)
			pageSize          = len(fixtureEvents)
		)
		putEvents(r, fixtureEvents)

		var gotEvents []event.Event
		s.GetEvents(userID, lastConstructedAt, pageSize, "", &gotEvents)

		if !gotEvents[0].CreatedAt.Equal(oldestEvent.CreatedAt) {
			t.Errorf("gotEvents[0] = %s, wants = %s", gotEvents[0].Title, oldestEvent.Title)
		}

		for i, gotEvent := range gotEvents {
			if i == 0 {
				continue
			}

			if !gotEvents[i-1].CreatedAt.Before(gotEvent.CreatedAt) {
				t.Errorf("gotEvents[%d].CreatedAt > gotEvents[%d].CreatedAt", i-1, i)
			}
		}
	})

	t.Run("pageTokenなしの場合は先頭から取得すること", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "some title 03", CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "some title 04", CreatedAt: now.Add(4 * time.Second)},
			}
			oldestEvent       = fixtureEvents[0]
			lastConstructedAt = now.Add(-1 * time.Second)
			pageSize          = len(fixtureEvents)
		)
		putEvents(r, fixtureEvents)

		var gotEvents []event.Event
		s.GetEvents(userID, lastConstructedAt, pageSize, "", &gotEvents)

		if gotEvents[0].ID != oldestEvent.ID {
			t.Errorf("gotEvents[0] = %s, wants = %s", gotEvents[0].Title, oldestEvent.Title)
		}
	})

	t.Run("pageTokenありの場合は続きから取得すること", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "some title 03", CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "some title 04", CreatedAt: now.Add(4 * time.Second)},
			}
			secondPageEvent   = fixtureEvents[2]
			lastConstructedAt = now.Add(-1 * time.Second)
			pageSize          = 2
		)
		putEvents(r, fixtureEvents)

		var tmp []event.Event
		pageToken, _ := s.GetEvents(userID, lastConstructedAt, pageSize, "", &tmp)

		var gotEvents []event.Event
		s.GetEvents(userID, lastConstructedAt, pageSize, pageToken, &gotEvents)

		if gotEvents[0].ID != secondPageEvent.ID {
			t.Errorf("gotEvents[0] = %s, wants = %s", gotEvents[0].Title, secondPageEvent.Title)
		}
	})

	t.Run("データ件数がpageSizeより多い場合", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "some title 03", CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "some title 04", CreatedAt: now.Add(4 * time.Second)},
			}
			lastConstructedAt = now.Add(-1 * time.Second)
			pageSize          = len(fixtureEvents) - 1
		)
		putEvents(r, fixtureEvents)

		var gotEvents []event.Event
		pageToken, _ := s.GetEvents(userID, lastConstructedAt, pageSize, "", &gotEvents)

		t.Run("pageSizeと同じ件数取得されること", func(t *testing.T) {
			if l := len(gotEvents); l != pageSize {
				t.Errorf("len(gotEvents) = %d, wants = %d", l, pageSize)
			}
		})

		t.Run("有効なnextPageTokenを返却すること", func(t *testing.T) {
			if pageToken == "" {
				t.Error("pageToken is empty, wants not empty")
			}
		})
	})

	t.Run("データ件数がpageSizeと同じ場合", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "some title 03", CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "some title 04", CreatedAt: now.Add(4 * time.Second)},
			}
			lastConstructedAt = now.Add(-1 * time.Second)
			pageSize          = len(fixtureEvents)
		)
		putEvents(r, fixtureEvents)

		var gotEvents []event.Event
		pageToken, _ := s.GetEvents(userID, lastConstructedAt, pageSize, "", &gotEvents)

		t.Run("pageSizeと同じ件数取得されること", func(t *testing.T) {
			if l := len(gotEvents); l != pageSize {
				t.Errorf("len(gotEvents) = %d, wants = %d", l, pageSize)
			}
		})

		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
			if pageToken != "" {
				t.Errorf("pageToken = %s, wants empty", pageToken)
			}
		})
	})

	t.Run("データ件数がpageSizeより小さい場合", func(t *testing.T) {
		defer clearStore()

		var (
			now = time.Now().Truncate(time.Millisecond)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-3", Action: event.CreateWork, Title: "some title 03", CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-4", Action: event.CreateWork, Title: "some title 04", CreatedAt: now.Add(4 * time.Second)},
			}
			lastConstructedAt = now.Add(-1 * time.Second)
			pageSize          = len(fixtureEvents) + 1
		)
		putEvents(r, fixtureEvents)

		var gotEvents []event.Event
		pageToken, _ := s.GetEvents(userID, lastConstructedAt, pageSize, "", &gotEvents)

		t.Run("データ件数と同じ件数取得されること", func(t *testing.T) {
			eventSize := len(fixtureEvents)
			if l := len(gotEvents); l != eventSize {
				t.Errorf("len(gotEvents) = %d, wants = %d", l, eventSize)
			}
		})

		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
			if pageToken != "" {
				t.Errorf("pageToken = %s, wants empty", pageToken)
			}
		})
	})
}

func TestGetWorkList(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		userID = "some-userid"
	)
	defer s.Close()

	t.Run("CreatedAtの降順で取得すること", func(t *testing.T) {
		defer clearStore()

		var (
			now       = time.Now().Truncate(time.Millisecond)
			updatedAt = now.Add(5 * time.Second)

			fixtureWorks = []model.WorkListItem{
				{UserID: userID, ID: "workid-1", Title: "number-3", State: model.Started, CreatedAt: now.Add(1 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: "workid-2", Title: "number-1", State: model.Started, CreatedAt: now.Add(3 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: "workid-3", Title: "number-2", State: model.Started, CreatedAt: now.Add(2 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: "workid-4", Title: "number-4", State: model.Started, CreatedAt: now.Add(0 * time.Second), UpdatedAt: updatedAt},
			}
			latestWork = fixtureWorks[1]
			pageSize   = len(fixtureWorks)
		)
		putWorkListItems(r, fixtureWorks)

		var gotWorks []model.WorkListItem
		s.GetWorkList(userID, pageSize, "", &gotWorks)

		if !gotWorks[0].CreatedAt.Equal(latestWork.CreatedAt) {
			t.Errorf("gotWorks[0] = %s, wants = %s", gotWorks[0].Title, latestWork.Title)
		}

		for i, gotWork := range gotWorks {
			if i == 0 {
				continue
			}
			if !gotWorks[i-1].CreatedAt.After(gotWork.CreatedAt) {
				t.Errorf("gotWorks[%d].CreatedAt < gotWorks[%d].CreatedAt", i-1, i)
			}
		}
	})

	t.Run("pageTokenなしの場合は先頭から取得すること", func(t *testing.T) {
		defer clearStore()

		var (
			now       = time.Now().Truncate(time.Millisecond)
			updatedAt = now.Add(5 * time.Second)

			fixtureWorks = []model.WorkListItem{
				{UserID: userID, ID: util.NewUUID(), Title: "some title 1", State: model.Started, CreatedAt: now.Add(1 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 2", State: model.Started, CreatedAt: now.Add(2 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 3", State: model.Started, CreatedAt: now.Add(3 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 4", State: model.Started, CreatedAt: now.Add(4 * time.Second), UpdatedAt: updatedAt},
			}
			pageSize   = len(fixtureWorks)
			latestWork = fixtureWorks[pageSize-1]
		)
		putWorkListItems(r, fixtureWorks)

		var gotWorks []model.WorkListItem
		s.GetWorkList(userID, pageSize, "", &gotWorks)

		if gotWorks[0].ID != latestWork.ID {
			t.Errorf("gotWorks[0] = %s, wants = %s", gotWorks[0].Title, latestWork.Title)
		}
	})

	t.Run("pageTokenありの場合は続きから取得すること", func(t *testing.T) {
		defer clearStore()

		var (
			now       = time.Now().Truncate(time.Millisecond)
			updatedAt = now.Add(5 * time.Second)

			fixtureWorks = []model.WorkListItem{
				{UserID: userID, ID: util.NewUUID(), Title: "some title 1", State: model.Started, CreatedAt: now.Add(1 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 2", State: model.Started, CreatedAt: now.Add(2 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 3", State: model.Started, CreatedAt: now.Add(3 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 4", State: model.Started, CreatedAt: now.Add(4 * time.Second), UpdatedAt: updatedAt},
			}
			pageSize       = 2
			secondPageWork = fixtureWorks[1]
		)
		putWorkListItems(r, fixtureWorks)

		var tmp []model.WorkListItem
		pageToken, _ := s.GetWorkList(userID, pageSize, "", &tmp)

		var gotWorks []model.WorkListItem
		s.GetWorkList(userID, pageSize, pageToken, &gotWorks)

		if gotWorks[0].ID != secondPageWork.ID {
			t.Errorf("gotWorks[0] = %s, wants = %s", gotWorks[0].Title, secondPageWork.Title)
		}
	})

	t.Run("データ件数がpageSizeより多い場合", func(t *testing.T) {
		defer clearStore()

		var (
			now       = time.Now().Truncate(time.Millisecond)
			updatedAt = now.Add(5 * time.Second)

			fixtureWorks = []model.WorkListItem{
				{UserID: userID, ID: util.NewUUID(), Title: "some title 1", State: model.Started, CreatedAt: now.Add(1 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 2", State: model.Started, CreatedAt: now.Add(2 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 3", State: model.Started, CreatedAt: now.Add(3 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 4", State: model.Started, CreatedAt: now.Add(4 * time.Second), UpdatedAt: updatedAt},
			}
			pageSize = len(fixtureWorks) - 1
		)
		putWorkListItems(r, fixtureWorks)

		var gotWorks []model.WorkListItem
		pageToken, _ := s.GetWorkList(userID, pageSize, "", &gotWorks)

		t.Run("pageSizeと同じ件数取得されること", func(t *testing.T) {
			if l := len(gotWorks); l != pageSize {
				t.Errorf("len(gotWorks) = %d, wants = %d", l, pageSize)
			}
		})

		t.Run("有効なnextPageTokenを返却すること", func(t *testing.T) {
			if pageToken == "" {
				t.Error("pageToken is empty, wants not empty")
			}
		})
	})

	t.Run("データ件数がpageSizeと同じ場合", func(t *testing.T) {
		defer clearStore()

		var (
			now       = time.Now().Truncate(time.Millisecond)
			updatedAt = now.Add(5 * time.Second)

			fixtureWorks = []model.WorkListItem{
				{UserID: userID, ID: util.NewUUID(), Title: "some title 1", State: model.Started, CreatedAt: now.Add(1 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 2", State: model.Started, CreatedAt: now.Add(2 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 3", State: model.Started, CreatedAt: now.Add(3 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 4", State: model.Started, CreatedAt: now.Add(4 * time.Second), UpdatedAt: updatedAt},
			}
			pageSize = len(fixtureWorks)
		)
		putWorkListItems(r, fixtureWorks)

		var gotWorks []model.WorkListItem
		pageToken, _ := s.GetWorkList(userID, pageSize, "", &gotWorks)

		t.Run("pageSizeと同じ件数取得されること", func(t *testing.T) {
			if l := len(gotWorks); l != pageSize {
				t.Errorf("len(gotWorks) = %d, wants = %d", l, pageSize)
			}
		})

		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
			if pageToken != "" {
				t.Errorf("pageToken = %s, wants empty", pageToken)
			}
		})
	})

	t.Run("データ件数がpageSizeより小さい場合", func(t *testing.T) {
		defer clearStore()

		var (
			now       = time.Now().Truncate(time.Millisecond)
			updatedAt = now.Add(5 * time.Second)

			fixtureWorks = []model.WorkListItem{
				{UserID: userID, ID: util.NewUUID(), Title: "some title 1", State: model.Started, CreatedAt: now.Add(1 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 2", State: model.Started, CreatedAt: now.Add(2 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 3", State: model.Started, CreatedAt: now.Add(3 * time.Second), UpdatedAt: updatedAt},
				{UserID: userID, ID: util.NewUUID(), Title: "some title 4", State: model.Started, CreatedAt: now.Add(4 * time.Second), UpdatedAt: updatedAt},
			}
			pageSize = len(fixtureWorks) + 1
		)
		putWorkListItems(r, fixtureWorks)

		var gotWorks []model.WorkListItem
		pageToken, _ := s.GetWorkList(userID, pageSize, "", &gotWorks)

		t.Run("データ件数と同じ件数取得されること", func(t *testing.T) {
			workSize := len(fixtureWorks)
			if l := len(gotWorks); l != workSize {
				t.Errorf("len(gotWorks) = %d, wants = %d", l, workSize)
			}
		})

		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
			if pageToken != "" {
				t.Errorf("pageToken = %s, wants empty", pageToken)
			}
		})
	})
}

func TestGetWorkListItem(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		source = newWorkListItem()
	)
	defer s.Close()

	t.Run("対象が存在する場合", func(t *testing.T) {
		defer clearStore()

		putWorkListItem(r, source)

		var work model.WorkListItem
		err := s.GetWorkListItem(source.ID, &work)

		t.Run("Workが取得されること", func(t *testing.T) {
			if !cmp.Equal(work, source) {
				t.Errorf("stored != source, diff = %s", cmp.Diff(work, source))
			}
		})

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})

	t.Run("対象が存在しない場合はErrNotfoundが返却されること", func(t *testing.T) {
		defer clearStore()

		var work model.WorkListItem
		err := s.GetWorkListItem("someid", &work)
		if err != store.ErrNotfound {
			t.Errorf("error = %#v, wants = ErrNotfound", err)
		}
	})
}

func TestPutWorkListItem(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		source = newWorkListItem()
	)
	defer s.Close()

	t.Run("対象が既に存在する場合", func(t *testing.T) {
		defer clearStore()

		putWorkListItem(r, source)

		updated := source
		updated.Title = "Updated Title"
		updated.UpdatedAt = source.UpdatedAt.Add(1 * time.Hour)

		err := s.PutWorkListItem(updated)

		t.Run("Workが更新されること", func(t *testing.T) {
			if w := getWorkListItem(r, source.ID); !cmp.Equal(w, updated) {
				t.Errorf("updated != source, diff = %s", cmp.Diff(w, updated))
			}
		})

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})

	t.Run("対象が存在しない場合", func(t *testing.T) {
		defer clearStore()

		err := s.PutWorkListItem(source)

		t.Run("Workを新規登録すること", func(t *testing.T) {
			if w := getWorkListItem(r, source.ID); !cmp.Equal(w, source) {
				t.Errorf("created != source, diff = %s", cmp.Diff(w, source))
			}
		})

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})
}

func TestDeleteWorkListItem(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		source = newWorkListItem()
	)
	defer s.Close()

	t.Run("対象が存在する場合", func(t *testing.T) {
		defer clearStore()

		putWorkListItem(r, source)

		err := s.DeleteWorkListItem(source.ID)

		t.Run("Workが削除されること", func(t *testing.T) {
			if w := getWorkListItem(r, source.ID); w.ID != "" {
				t.Fatal("Work is not deleted")
			}
		})

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})
	})

	t.Run("対象が存在しない場合でもerrorがnilであること", func(t *testing.T) {
		defer clearStore()

		err := s.DeleteWork("someid")
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})
}

func getWork(r *http.Request, id string) model.Work {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	key := datastore.NameKey(model.KindNameWork, id, nil)

	var w model.Work
	client.Get(ctx, key, &w)

	return w
}

func getEvent(r *http.Request, id string) event.Event {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	key := datastore.NameKey(event.KindName, id, nil)

	var e event.Event
	client.Get(ctx, key, &e)

	return e
}

func putWork(r *http.Request, w model.Work) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	key := datastore.NameKey(model.KindNameWork, w.ID, nil)

	client.Put(ctx, key, &w)
}

func getWorkListItem(r *http.Request, id string) model.WorkListItem {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	key := datastore.NameKey(model.KindNameWorkListItem, id, nil)

	var w model.WorkListItem
	client.Get(ctx, key, &w)

	return w
}

func newWorkListItem() model.WorkListItem {
	return model.WorkListItem{
		UserID:    util.NewUUID(),
		ID:        util.NewUUID(),
		Title:     "Some Title",
		State:     model.Unstarted,
		CreatedAt: time.Now().Truncate(time.Millisecond).Add(-2 * time.Hour),
		UpdatedAt: time.Now().Truncate(time.Millisecond).Add(-1 * time.Hour),
	}
}

func putWorkListItems(r *http.Request, works []model.WorkListItem) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	for _, w := range works {
		key := datastore.NameKey(model.KindNameWorkListItem, w.ID, nil)

		client.Put(ctx, key, &w)
	}
}

func putWorkListItem(r *http.Request, w model.WorkListItem) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	key := datastore.NameKey(model.KindNameWorkListItem, w.ID, nil)

	client.Put(ctx, key, &w)
}

func putEvents(r *http.Request, events []event.Event) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	for _, e := range events {
		key := datastore.NameKey(event.KindName, e.ID, nil)

		client.Put(ctx, key, &e)
	}
}

func clearStore() {
	ctx := context.Background()
	client, _ := datastore.NewClient(ctx, util.ProjectID())
	defer client.Close()

	kindQuery := datastore.NewQuery("__kind__").KeysOnly()
	kindKeys, _ := client.GetAll(ctx, kindQuery, nil)

	for _, kind := range kindKeys {
		q := datastore.NewQuery(kind.Name).KeysOnly()
		keys, _ := client.GetAll(ctx, q, nil)
		client.DeleteMulti(ctx, keys)
	}
}
