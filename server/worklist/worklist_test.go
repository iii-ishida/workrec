package worklist_test

import (
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	"github.com/google/go-cmp/cmp"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist"
	"github.com/iii-ishida/workrec/server/worklist/model"
	"github.com/iii-ishida/workrec/server/worklist/store"
)

func TestGet(t *testing.T) {
	t.Run("取得OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		var (
			fixture = model.WorkList{
				Works: []model.WorkListItem{
					{ID: util.NewUUID(), Title: "some title 01", State: model.Unstarted, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{ID: util.NewUUID(), Title: "some title 02", State: model.Started, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{ID: util.NewUUID(), Title: "some title 03", State: model.Paused, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{ID: util.NewUUID(), Title: "some title 04", State: model.Resumed, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{ID: util.NewUUID(), Title: "some title 05", State: model.Finished, CreatedAt: time.Now(), UpdatedAt: time.Now()},
				},
				NextPageToken: util.NewUUID(),
			}

			mockStore = store.NewMockStore(mockCtrl)
			q         = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			param     = worklist.Param{PageSize: 30, PageToken: "sometoken"}
		)

		mockStore.EXPECT().GetWorks(param.PageSize, param.PageToken, gomock.Any()).DoAndReturn(func(_ int, _ string, dst *[]model.WorkListItem) (string, error) {
			*dst = make([]model.WorkListItem, len(fixture.Works))
			copy(*dst, fixture.Works)
			return fixture.NextPageToken, nil
		})

		list, err := q.Get(param)
		if err != nil {
			t.Fatalf("Get error: %s", err.Error())
		}

		if !cmp.Equal(list.Works, fixture.Works) {
			t.Errorf("Works = %#v, wants = %#v", list.Works, fixture.Works)
		}
		if list.NextPageToken != fixture.NextPageToken {
			t.Errorf("NextPageToken = %s, wants = %s", list.NextPageToken, fixture.NextPageToken)
		}
	})
}

func TestConstructWorks(t *testing.T) {
	t.Run("生成OK", func(t *testing.T) {
		mockCtrl := gomock.NewController(t)
		defer mockCtrl.Finish()

		var (
			eventTime01 = time.Now().Add(1 + time.Second)
			eventTime02 = time.Now().Add(2 + time.Second)
			eventTime03 = time.Now().Add(3 + time.Second)
			eventTime04 = time.Now().Add(4 + time.Second)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: eventTime01},
				{ID: util.NewUUID(), WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: eventTime02},
				{ID: util.NewUUID(), WorkID: "workid-1", Action: event.StartWork, Time: time.Now(), CreatedAt: eventTime03},
				{ID: util.NewUUID(), WorkID: "workid-2", Action: event.UpdateWork, Title: "updated title 02", CreatedAt: eventTime04},
			}
			fixtureWork1 = model.WorkListItem{ID: "workid-1", Title: "some title 01", State: model.Started, CreatedAt: eventTime01, UpdatedAt: eventTime03}
			fixtureWork2 = model.WorkListItem{ID: "workid-2", Title: "updated title 02", State: model.Unstarted, CreatedAt: eventTime02, UpdatedAt: eventTime04}

			fixtureLastConstructedAt = time.Now()
			pageSize                 = 100
			mockStore                = store.NewMockStore(mockCtrl)
			q                        = worklist.NewQuery(worklist.Dependency{Store: mockStore})
		)

		mockStore.EXPECT().GetLastConstructedAt(model.LastConstructedAtID, gomock.Any()).DoAndReturn(func(id string, dst *model.LastConstructedAt) error {
			*dst = model.LastConstructedAt{ID: id, Time: fixtureLastConstructedAt}
			return nil
		})

		mockStore.EXPECT().GetEvents(fixtureLastConstructedAt, pageSize, "", gomock.Any()).DoAndReturn(func(_ time.Time, _ int, _ string, dst *[]event.Event) (string, error) {
			*dst = make([]event.Event, len(fixtureEvents))
			copy(*dst, fixtureEvents)
			return "", nil
		})

		mockStore.EXPECT().GetWork(fixtureWork1.ID, gomock.Any())
		mockStore.EXPECT().PutWork(fixtureWork1)

		mockStore.EXPECT().GetWork(fixtureWork2.ID, gomock.Any())
		mockStore.EXPECT().PutWork(fixtureWork2)

		mockStore.EXPECT().PutLastConstructedAt(model.LastConstructedAt{
			ID:   model.LastConstructedAtID,
			Time: fixtureEvents[len(fixtureEvents)-1].CreatedAt,
		})

		q.ConstructWorks()
	})
}
