package worklist_test

import (
	"errors"
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
	userID := "some-userid"

	t.Run("Get#OK", func(t *testing.T) {
		var (
			fixture = model.WorkList{
				Works: []model.WorkListItem{
					{UserID: userID, ID: util.NewUUID(), Title: "some title 01", State: model.Unstarted, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{UserID: userID, ID: util.NewUUID(), Title: "some title 02", State: model.Started, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{UserID: userID, ID: util.NewUUID(), Title: "some title 03", State: model.Paused, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{UserID: userID, ID: util.NewUUID(), Title: "some title 04", State: model.Resumed, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					{UserID: userID, ID: util.NewUUID(), Title: "some title 05", State: model.Finished, CreatedAt: time.Now(), UpdatedAt: time.Now()},
				},
				NextPageToken: util.NewUUID(),
			}

			mockCtrl  = gomock.NewController(t)
			mockStore = store.NewMockStore(mockCtrl)
			query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			param     = worklist.Param{PageSize: 30, PageToken: "sometoken"}
		)
		defer mockCtrl.Finish()

		mockStore.EXPECT().GetWorks(userID, param.PageSize, param.PageToken, gomock.Any()).DoAndReturn(func(_ string, _ int, _ string, dst *[]model.WorkListItem) (string, error) {
			*dst = make([]model.WorkListItem, len(fixture.Works))
			copy(*dst, fixture.Works)
			return fixture.NextPageToken, nil
		})

		list, err := query.Get(userID, param)

		t.Run("errorがnilであること", func(t *testing.T) {
			if err != nil {
				t.Fatalf("Get error: %s", err.Error())
			}
		})

		t.Run("WorksにStore#GetWorksから取得したWorkのリストがセットされること", func(t *testing.T) {
			if !cmp.Equal(list.Works, fixture.Works) {
				t.Errorf("Works = %#v, wants = %#v", list.Works, fixture.Works)
			}
		})

		t.Run("NextPageTokenにStore#GetWorksから取得したNextPageTokenがセットされること", func(t *testing.T) {
			if list.NextPageToken != fixture.NextPageToken {
				t.Errorf("NextPageToken = %s, wants = %s", list.NextPageToken, fixture.NextPageToken)
			}
		})
	})

	t.Run("Get#Error", func(t *testing.T) {
		t.Run("Store#GetWorksがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			var (
				mockCtrl  = gomock.NewController(t)
				mockStore = store.NewMockStore(mockCtrl)
				query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
				param     = worklist.Param{}
			)
			defer mockCtrl.Finish()

			someErr := errors.New("Some Error")
			mockStore.EXPECT().GetWorks(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Return("", someErr)

			_, err := query.Get(userID, param)

			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})
	})
}

func TestConstructWorks(t *testing.T) {
	userID := "some-userid"

	t.Run("ConstructWorks#OK", func(t *testing.T) {
		var (
			eventTime01 = time.Now().Add(1 + time.Second)
			eventTime02 = time.Now().Add(2 + time.Second)
			eventTime03 = time.Now().Add(3 + time.Second)
			eventTime04 = time.Now().Add(4 + time.Second)

			fixtureEvents = []event.Event{
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: eventTime01},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.CreateWork, Title: "some title 02", CreatedAt: eventTime02},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-1", Action: event.StartWork, Time: eventTime03, CreatedAt: eventTime03},
				{ID: util.NewUUID(), UserID: userID, WorkID: "workid-2", Action: event.UpdateWork, Title: "updated title 02", CreatedAt: eventTime04},
			}
			fixtureWork1 = model.WorkListItem{
				UserID:          userID,
				ID:              "workid-1",
				Title:           "some title 01",
				BaseWorkingTime: eventTime03,
				PausedAt:        time.Time{},
				State:           model.Started,
				StartedAt:       eventTime03,
				CreatedAt:       eventTime01,
				UpdatedAt:       eventTime03,
			}
			fixtureWork2 = model.WorkListItem{
				UserID:          userID,
				ID:              "workid-2",
				Title:           "updated title 02",
				BaseWorkingTime: time.Time{},
				PausedAt:        time.Time{},
				State:           model.Unstarted,
				StartedAt:       time.Time{},
				CreatedAt:       eventTime02,
				UpdatedAt:       eventTime04,
			}

			fixtureLastConstructedAt = time.Now()
			pageSize                 = 100

			mockCtrl  = gomock.NewController(t)
			mockStore = store.NewMockStore(mockCtrl)
			query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
		)
		defer mockCtrl.Finish()

		mockStore.EXPECT().GetLastConstructedAt(userID, gomock.Any()).DoAndReturn(func(id string, dst *model.LastConstructedAt) error {
			*dst = model.LastConstructedAt{ID: userID, Time: fixtureLastConstructedAt}
			return nil
		})

		mockStore.EXPECT().GetEvents(userID, fixtureLastConstructedAt, pageSize, "", gomock.Any()).DoAndReturn(func(_ string, _ time.Time, _ int, _ string, dst *[]event.Event) (string, error) {
			*dst = make([]event.Event, len(fixtureEvents))
			copy(*dst, fixtureEvents)
			return "", nil
		})

		// Assert

		mockStore.EXPECT().GetWork(fixtureWork1.ID, gomock.Any())
		mockStore.EXPECT().PutWork(fixtureWork1)

		mockStore.EXPECT().GetWork(fixtureWork2.ID, gomock.Any())
		mockStore.EXPECT().PutWork(fixtureWork2)

		mockStore.EXPECT().PutLastConstructedAt(model.LastConstructedAt{
			ID:   userID,
			Time: fixtureEvents[len(fixtureEvents)-1].CreatedAt,
		})

		// Act
		query.ConstructWorks(userID)
	})

	t.Run("ConstructWorks#Error", func(t *testing.T) {
		someErr := errors.New("Some Error")

		t.Run("Store#GetLastConstructedAtがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			var (
				mockCtrl  = gomock.NewController(t)
				mockStore = store.NewMockStore(mockCtrl)
				query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			)
			defer mockCtrl.Finish()

			mockStore.EXPECT().GetLastConstructedAt(gomock.Any(), gomock.Any()).Return(someErr)

			err := query.ConstructWorks(userID)
			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#GetEventsがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			var (
				mockCtrl  = gomock.NewController(t)
				mockStore = store.NewMockStore(mockCtrl)
				query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			)
			defer mockCtrl.Finish()

			mockStore.EXPECT().GetLastConstructedAt(gomock.Any(), gomock.Any())
			mockStore.EXPECT().GetEvents(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).Return("", someErr)

			err := query.ConstructWorks(userID)
			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#GetWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			var (
				fixtureEvents = []event.Event{
					{ID: util.NewUUID(), WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: time.Now()},
				}

				mockCtrl  = gomock.NewController(t)
				mockStore = store.NewMockStore(mockCtrl)
				query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			)
			defer mockCtrl.Finish()

			mockStore.EXPECT().GetLastConstructedAt(gomock.Any(), gomock.Any())
			mockStore.EXPECT().GetEvents(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).DoAndReturn(func(_ string, _ time.Time, _ int, _ string, dst *[]event.Event) (string, error) {
				*dst = make([]event.Event, len(fixtureEvents))
				copy(*dst, fixtureEvents)
				return "", nil
			})

			mockStore.EXPECT().GetWork(gomock.Any(), gomock.Any()).Return(someErr)

			err := query.ConstructWorks(userID)
			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})

		t.Run("Store#GetWorkがErrNotfoundを返した場合は処理を続行すること", func(t *testing.T) {
			var (
				fixtureEvents = []event.Event{
					{ID: util.NewUUID(), WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: time.Now()},
				}

				mockCtrl  = gomock.NewController(t)
				mockStore = store.NewMockStore(mockCtrl)
				query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			)
			defer mockCtrl.Finish()

			mockStore.EXPECT().GetLastConstructedAt(gomock.Any(), gomock.Any())
			mockStore.EXPECT().GetEvents(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).DoAndReturn(func(_ string, _ time.Time, _ int, _ string, dst *[]event.Event) (string, error) {
				*dst = make([]event.Event, len(fixtureEvents))
				copy(*dst, fixtureEvents)
				return "", nil
			})

			mockStore.EXPECT().GetWork(gomock.Any(), gomock.Any()).Return(store.ErrNotfound)
			mockStore.EXPECT().PutWork(gomock.Any())
			mockStore.EXPECT().PutLastConstructedAt(gomock.Any())

			err := query.ConstructWorks(userID)
			if err != nil {
				t.Errorf("error = %#v, wants = nil", err)
			}
		})

		t.Run("Store#PutWorkがエラーになった場合はerrorを返すこと", func(t *testing.T) {
			var (
				fixtureEvents = []event.Event{
					{ID: util.NewUUID(), WorkID: "workid-1", Action: event.CreateWork, Title: "some title 01", CreatedAt: time.Now()},
				}
				mockCtrl  = gomock.NewController(t)
				mockStore = store.NewMockStore(mockCtrl)
				query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
			)
			defer mockCtrl.Finish()

			mockStore.EXPECT().GetLastConstructedAt(gomock.Any(), gomock.Any())
			mockStore.EXPECT().GetEvents(gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any(), gomock.Any()).DoAndReturn(func(_ string, _ time.Time, _ int, _ string, dst *[]event.Event) (string, error) {
				*dst = make([]event.Event, len(fixtureEvents))
				copy(*dst, fixtureEvents)
				return "", nil
			})
			mockStore.EXPECT().GetWork(gomock.Any(), gomock.Any())

			mockStore.EXPECT().PutWork(gomock.Any()).Return(someErr)

			err := query.ConstructWorks(userID)
			if err != someErr {
				t.Errorf("error = %#v, wants = %#v", err, someErr)
			}
		})
	})
}

func TestClose(t *testing.T) {
	var (
		mockCtrl  = gomock.NewController(t)
		mockStore = store.NewMockStore(mockCtrl)
		query     = worklist.NewQuery(worklist.Dependency{Store: mockStore})
	)
	defer mockCtrl.Finish()

	t.Run("dep.Store#Closeを呼ぶこと", func(t *testing.T) {
		mockStore.EXPECT().Close()
		query.Close()
	})

	t.Run("dep.Store#Closeがエラーでない場合はnilを返すこと", func(t *testing.T) {
		mockStore.EXPECT().Close()
		err := query.Close()
		if err != nil {
			t.Errorf("error = %#v, wants = nil", err)
		}
	})

	t.Run("dep.Store#Closeがエラーになった場合はerrorを返すこと", func(t *testing.T) {
		someErr := errors.New("Some Error")

		mockStore.EXPECT().Close().Return(someErr)
		err := query.Close()
		if err != someErr {
			t.Errorf("error = %#v, wants = %#v", err, someErr)
		}
	})
}
