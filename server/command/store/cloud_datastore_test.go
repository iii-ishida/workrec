package store_test

import (
	"errors"
	"net/http"
	"testing"
	"time"

	"cloud.google.com/go/datastore"
	"github.com/google/go-cmp/cmp"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/command/store"
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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
		defer clearStore(r)

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
	defer clearStore(r)

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

func getWork(r *http.Request, id string) model.Work {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	defer client.Close()

	key := datastore.NameKey(model.KindNameWork, id, nil)

	var w model.Work
	client.Get(ctx, key, &w)

	return w
}

func getEvent(r *http.Request, id string) event.Event {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	defer client.Close()

	key := datastore.NameKey(event.KindName, id, nil)

	var e event.Event
	client.Get(ctx, key, &e)

	return e
}

func putWork(r *http.Request, w model.Work) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	defer client.Close()

	key := datastore.NameKey(model.KindNameWork, w.ID, nil)

	client.Put(ctx, key, &w)
}

func clearStore(r *http.Request) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	defer client.Close()

	for _, kind := range []string{model.KindNameWork, event.KindName} {
		q := datastore.NewQuery(kind).KeysOnly()
		keys, _ := client.GetAll(ctx, q, nil)
		client.DeleteMulti(ctx, keys)
	}
}
