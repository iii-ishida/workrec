from functools import cached_property
from fastapi import FastAPI, Depends
from strawberry.fastapi import BaseContext, GraphQLRouter
from app.workrec import WorkrecClient, CloudDatastoreRepo
from app.schema import schema
import firebase_admin
from firebase_admin import auth
import os

if os.getenv("FIREBASE_AUTH_EMULATOR_HOST", "") == "":
    firebase_admin.initialize_app()
else:
    firebase_admin.initialize_app(options={"projectId": "demo-test"})


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

        idToken = authorization.split(" ")[-1]
        decoded = auth.verify_id_token(idToken)
        return decoded["uid"] if decoded else None


repo = CloudDatastoreRepo()
client = WorkrecClient(repo=repo)


def custom_context_dependency() -> CustomContext:
    return CustomContext(client)


async def get_context(
    custom_context=Depends(custom_context_dependency),
):
    return custom_context


graphql_app = GraphQLRouter(
    schema,
    context_getter=get_context,
)

app = FastAPI()
app.include_router(graphql_app, prefix="/graphql")
