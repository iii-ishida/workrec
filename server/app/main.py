import os
from functools import cached_property

from app.schema import schema
from app.repo import CloudDatastoreRepo
from app.workrec import WorkrecClient
from fastapi import FastAPI
from firebase_admin import auth, initialize_app
from strawberry.fastapi import BaseContext, GraphQLRouter

if os.getenv("FIREBASE_AUTH_EMULATOR_HOST", "") == "":
    initialize_app()
else:
    initialize_app(options={"projectId": "demo-test"})


class CustomContext(BaseContext):
    def __init__(self, client: WorkrecClient):
        self.client = client

    @cached_property
    def user_id(self) -> str | None:
        if not self.request:
            return None

        authorization = self.request.headers.get("Authorization", None)
        if authorization is None:
            return None

        cookieOrIdToken = authorization.split(" ")[-1]

        try:
            decoded = auth.verify_session_cookie(cookieOrIdToken)
            return decoded["uid"] if decoded else None
        except Exception:
            decoded = auth.verify_id_token(cookieOrIdToken)
            return decoded["uid"] if decoded else None


repo = CloudDatastoreRepo()
client = WorkrecClient(repo=repo)


def get_context() -> CustomContext:
    return CustomContext(client)


graphql_app = GraphQLRouter(
    schema,
    context_getter=get_context,
)

app = FastAPI()
app.include_router(graphql_app, prefix="/graphql")
