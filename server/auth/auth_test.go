package auth_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	gomock "github.com/golang/mock/gomock"
	"github.com/iii-ishida/workrec/server/auth"
	"github.com/iii-ishida/workrec/server/util"
)

func TestHandler(t *testing.T) {
	dummyCode := 999
	dummyHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(dummyCode) })

	t.Run("空白で区切られたAuthorizationヘッダ設定されている場合", func(t *testing.T) {
		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
			req, _           = http.NewRequest("GET", "/", nil)
			res              = httptest.NewRecorder()
			a                = auth.New(auth.Dependency{UserIDGetter: mockUserIDGetter})
			authCode         = "validauthcode"
			userID           = "some-userid"
		)
		req.Header.Add("Authorization", "Bearer "+authCode)

		t.Run("UesrIDGetter#GetUserIDを実行すること", func(t *testing.T) {
			mockUserIDGetter.EXPECT().GetUserID(authCode).Return(userID, nil)
		})

		t.Run("request.Context()にGetUserIDで取得したuserIDを設定すること", func(t *testing.T) {
			// Act and Assert
			a.Handler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if gotUserID := auth.GetUserID(r.Context()); gotUserID != userID {
					t.Errorf("userID = %s, wants = %s", gotUserID, userID)
				}

				dummyHandler(w, r)
			})).ServeHTTP(res, req)
		})

		t.Run("次のハンドラを呼ぶこと", func(t *testing.T) {
			if res.Code != dummyCode {
				t.Error("next handler is not called")
			}
		})
	})

	t.Run("Authorizationヘッダが未設定の場合はUesrIDGetter#GetUserIDを実行せずに次のハンドラを呼ぶこと", func(t *testing.T) {
		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
			req, _           = http.NewRequest("GET", "/", nil)
			res              = httptest.NewRecorder()
			a                = auth.New(auth.Dependency{UserIDGetter: mockUserIDGetter})
		)

		a.Handler(dummyHandler).ServeHTTP(res, req)
		if res.Code != dummyCode {
			t.Error("next handler is not called")
		}
	})

	t.Run("Authorizationヘッダが空白で区切られていない場合はUesrIDGetter#GetUserIDを実行せずに次のハンドラを呼ぶこと", func(t *testing.T) {
		var (
			mockCtrl         = gomock.NewController(t)
			mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
			req, _           = http.NewRequest("GET", "/", nil)
			res              = httptest.NewRecorder()
			a                = auth.New(auth.Dependency{UserIDGetter: mockUserIDGetter})
		)
		req.Header.Add("Authorization", "nosepvalue")

		a.Handler(dummyHandler).ServeHTTP(res, req)
		if res.Code != dummyCode {
			t.Error("next handler is not called")
		}
	})
}

func TestUserID(t *testing.T) {
	t.Run("ContextWithUserIDでセットしたUserIDをGetUserIDで取得できること", func(t *testing.T) {
		userID := util.NewUUID()

		ctx := auth.ContextWithUserID(context.Background(), userID)
		if gotUserID := auth.GetUserID(ctx); gotUserID != userID {
			t.Errorf("userID = %s, wants = %s", gotUserID, userID)
		}
	})
	t.Run("ctxにUserIDがセットされていない場合はGetUserIDが空文字を返すこと", func(t *testing.T) {
		if gotUserID := auth.GetUserID(context.Background()); gotUserID != "" {
			t.Errorf("userID = %s, wants = \"\"", gotUserID)
		}
	})
}
