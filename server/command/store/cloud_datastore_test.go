package store_test

import (
	"errors"
	"net/http"
	"reflect"
	"testing"
	"time"

	"cloud.google.com/go/datastore"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/command/store"
	"github.com/iii-ishida/workrec/server/util"
)

func TestRunTransaction(t *testing.T) {
	r, _ := http.NewRequest("GET", "/", nil)
	s, _ := store.NewCloudDatastore(r)

	t.Run("errorがnilの場合は全ての変更を適用すること", func(t *testing.T) {
		defer clearStore(r)

		s.RunTransaction(func(s store.Store) error {
			s.PutWork(model.Work{
				ID: model.WorkID("someid"),
			})
			s.PutEvent(model.Event{
				ID: model.EventID("someid"),
			})
			return nil
		})

		if w := getWork(r, model.WorkID("someid")); w.ID == "" {
			t.Fatal("Work is not saved")
		}
		if e := getEvent(r, model.EventID("someid")); e.ID == "" {
			t.Fatal("Event is not saved")
		}
	})

	t.Run("errorがnilでない場合は全ての変更を適用しないこと", func(t *testing.T) {
		defer clearStore(r)

		s.RunTransaction(func(s store.Store) error {
			s.PutWork(model.Work{
				ID: model.WorkID("someid"),
			})
			s.PutEvent(model.Event{
				ID: model.EventID("someid"),
			})
			return errors.New("some error")
		})

		if w := getWork(r, model.WorkID("someid")); w.ID != "" {
			t.Fatal("Work is saved")
		}
		if e := getEvent(r, model.EventID("someid")); e.ID != "" {
			t.Fatal("Event is saved")
		}
	})

	t.Run("トランザクション中の関数で発生したerrorをそのまま返却すること", func(t *testing.T) {
		defer clearStore(r)

		someErr := errors.New("some error")
		err := s.RunTransaction(func(s store.Store) error {
			return someErr
		})
		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}

func TestGetWork(t *testing.T) {
	r, _ := http.NewRequest("GET", "/", nil)

	t.Run("対象あり", func(t *testing.T) {
		defer clearStore(r)

		s, _ := store.NewCloudDatastore(r)

		source := model.Work{
			ID:        model.WorkID(util.NewUUID()),
			EventID:   model.EventID(util.NewUUID()),
			Title:     "Some Title",
			State:     model.Started,
			UpdatedAt: time.Now().Truncate(time.Millisecond),
		}

		putWork(r, source)

		var work model.Work
		err := s.GetWork(source.ID, &work)

		t.Run("Workが取得されること", func(t *testing.T) {
			if !reflect.DeepEqual(work, source) {
				t.Errorf("get = %#v, wants = %#v", work, source)
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

		s, _ := store.NewCloudDatastore(r)

		var work model.Work
		err := s.GetWork(model.WorkID("someid"), &work)
		if err != store.ErrNotfound {
			t.Errorf("error = %#v, wants = ErrNotfound", err)
		}
	})
}

func TestPutWork(t *testing.T) {
	r, _ := http.NewRequest("GET", "/", nil)

	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Started,
		UpdatedAt: time.Now().Truncate(time.Millisecond),
	}

	t.Run("対象あり", func(t *testing.T) {
		defer clearStore(r)

		s, _ := store.NewCloudDatastore(r)

		putWork(r, source)

		work := model.Work{
			ID:        source.ID,
			EventID:   model.EventID("someid"),
			Title:     "Updated Title",
			State:     model.Finished,
			UpdatedAt: time.Now().Truncate(time.Millisecond),
		}
		err := s.PutWork(work)

		t.Run("Workが更新されること", func(t *testing.T) {
			if w := getWork(r, source.ID); !reflect.DeepEqual(w, work) {
				t.Errorf("updated = %#v, wants = %#v", w, work)
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

		s, _ := store.NewCloudDatastore(r)

		s.PutWork(source)

		if w := getWork(r, source.ID); !reflect.DeepEqual(w, source) {
			t.Errorf("created = %#v, wants = %#v", w, source)
		}
	})
}
func TestDeleteWork(t *testing.T) {
	r, _ := http.NewRequest("GET", "/", nil)

	source := model.Work{
		ID:        model.WorkID(util.NewUUID()),
		EventID:   model.EventID(util.NewUUID()),
		Title:     "Some Title",
		State:     model.Started,
		UpdatedAt: time.Now().Truncate(time.Millisecond),
	}
	t.Run("対象あり", func(t *testing.T) {
		defer clearStore(r)

		s, _ := store.NewCloudDatastore(r)

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

		s, _ := store.NewCloudDatastore(r)

		err := s.DeleteWork(model.WorkID("someid"))
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})
}
func TestPutEvent(t *testing.T) {
	r, _ := http.NewRequest("GET", "/", nil)
	s, _ := store.NewCloudDatastore(r)

	defer clearStore(r)

	event := model.Event{
		ID:        model.EventID(util.NewUUID()),
		PrevID:    model.EventID(util.NewUUID()),
		WorkID:    model.WorkID(util.NewUUID()),
		Type:      model.UpdateWork,
		Title:     "Some Title",
		Time:      time.Now().Truncate(time.Millisecond),
		CreatedAt: time.Now().Truncate(time.Millisecond),
	}

	err := s.PutEvent(event)

	t.Run("Eventが登録されること", func(t *testing.T) {
		if e := getEvent(r, event.ID); !reflect.DeepEqual(e, event) {
			t.Errorf("created = %#v, wants = %#v", e, event)
		}
	})
	t.Run("errorがnilであること", func(t *testing.T) {
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})
}

func getWork(r *http.Request, id model.WorkID) model.Work {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	key := datastore.NameKey(store.KindWork, string(id), nil)

	var w model.Work
	client.Get(ctx, key, &w)

	return w
}

func getEvent(r *http.Request, id model.EventID) model.Event {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	key := datastore.NameKey(store.KindEvent, string(id), nil)

	var e model.Event
	client.Get(ctx, key, &e)

	return e
}

func putWork(r *http.Request, w model.Work) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	key := datastore.NameKey(store.KindWork, string(w.ID), nil)

	client.Put(ctx, key, &w)
}

func clearStore(r *http.Request) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())

	for _, kind := range []string{store.KindWork, store.KindEvent} {
		q := datastore.NewQuery(kind).KeysOnly()
		keys, _ := client.GetAll(ctx, q, nil)
		client.DeleteMulti(ctx, keys)
	}
}
