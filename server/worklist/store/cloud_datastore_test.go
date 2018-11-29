package store_test

import (
	"fmt"
	"net/http"
	"testing"
	"time"

	"cloud.google.com/go/datastore"
	"github.com/google/go-cmp/cmp"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist/model"
	"github.com/iii-ishida/workrec/server/worklist/store"
)

func TestGetWorks(t *testing.T) {
	t.Run("pageSizeが0の場合", func(t *testing.T) {
		t.Run(fmt.Sprintf("pageSizeを%dとして取得すること", store.DefaultPageSize), func(t *testing.T) {
		})
	})

	t.Run("pageTokenなしの場合", func(t *testing.T) {
		t.Run("先頭から取得すること", func(t *testing.T) {
		})
	})

	t.Run("pageTokenありの場合", func(t *testing.T) {
		t.Run("続きから取得すること", func(t *testing.T) {
		})
	})

	t.Run("取得件数がpageSizeより大きい場合", func(t *testing.T) {
		t.Run("有効なnextPageTokenを返却すること", func(t *testing.T) {
		})
	})

	t.Run("取得件数がpageSizeと同じ場合", func(t *testing.T) {
		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
		})
	})

	t.Run("取得件数がpageSizeより小さい場合", func(t *testing.T) {
		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
		})
	})
}

func TestGetWork(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		source = newWork()
	)

	t.Run("対象が存在する場合", func(t *testing.T) {
		defer clearStore(r)

		putWork(r, source)

		var work model.WorkListItem
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

		var work model.WorkListItem
		err := s.GetWork("someid", &work)
		if err != store.ErrNotfound {
			t.Errorf("error = %#v, wants = ErrNotfound", err)
		}
	})
}

func TestPutWork(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		source = newWork()
	)

	t.Run("対象が既に存在する場合", func(t *testing.T) {
		defer clearStore(r)

		putWork(r, source)

		updated := source
		updated.Title = "Updated Title"
		updated.UpdatedAt = source.UpdatedAt.Add(1 * time.Hour)

		err := s.PutWork(updated)

		t.Run("Workが更新されること", func(t *testing.T) {
			if w := getWork(r, source.ID); !cmp.Equal(w, updated) {
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
		defer clearStore(r)

		err := s.PutWork(source)

		t.Run("Workを新規登録すること", func(t *testing.T) {
			if w := getWork(r, source.ID); !cmp.Equal(w, source) {
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

func TestDeleteWork(t *testing.T) {
	var (
		r, _   = http.NewRequest("GET", "/", nil)
		s, _   = store.NewCloudDataStore(r)
		source = newWork()
	)

	t.Run("対象が存在する場合", func(t *testing.T) {
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

		err := s.DeleteWork("someid")
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})
}

func TestGetEvents(t *testing.T) {
	t.Run("CreatedAt>lastConstructedAtに該当するEventを取得すること", func(t *testing.T) {
	})

	t.Run("結果をCreatedAtの昇順にソートすること", func(t *testing.T) {
	})

	t.Run("pageSizeが0の場合", func(t *testing.T) {
		t.Run(fmt.Sprintf("pageSizeを%dとして取得すること", store.DefaultPageSize), func(t *testing.T) {
		})
	})

	t.Run("pageTokenなしの場合", func(t *testing.T) {
		t.Run("先頭から取得すること", func(t *testing.T) {
		})
	})

	t.Run("pageTokenありの場合", func(t *testing.T) {
		t.Run("続きから取得すること", func(t *testing.T) {
		})
	})

	t.Run("取得件数がpageSizeより大きい場合", func(t *testing.T) {
		t.Run("有効なnextPageTokenを返却すること", func(t *testing.T) {
		})
	})

	t.Run("取得件数がpageSizeと同じ場合", func(t *testing.T) {
		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
		})
	})

	t.Run("取得件数がpageSizeより小さい場合", func(t *testing.T) {
		t.Run("nextPageTokenを空文字で返却すること", func(t *testing.T) {
		})
	})
}

func getWork(r *http.Request, id string) model.WorkListItem {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	key := datastore.NameKey(model.KindNameWork, id, nil)

	var w model.WorkListItem
	client.Get(ctx, key, &w)

	return w
}

func newWork() model.WorkListItem {
	return model.WorkListItem{
		ID:        util.NewUUID(),
		Title:     "Some Title",
		State:     model.Unstarted,
		CreatedAt: time.Now().Truncate(time.Millisecond).Add(-2 * time.Hour),
		UpdatedAt: time.Now().Truncate(time.Millisecond).Add(-1 * time.Hour),
	}
}

func putWork(r *http.Request, w model.WorkListItem) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	key := datastore.NameKey(model.KindNameWork, w.ID, nil)

	client.Put(ctx, key, &w)
}

func clearStore(r *http.Request) {
	ctx := r.Context()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())

	for _, kind := range []string{model.KindNameWork, model.KindNameLastConstructedAt, event.KindName} {
		q := datastore.NewQuery(kind).KeysOnly()
		keys, _ := client.GetAll(ctx, q, nil)
		client.DeleteMulti(ctx, keys)
	}
}
