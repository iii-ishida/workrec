from fastapi import FastAPI, Depends
from strawberry.fastapi import BaseContext, GraphQLRouter
from app.workrec import WorkrecClient, CloudDatastoreRepo
from app.schema import schema


class CustomContext(BaseContext):
    def __init__(self, client: WorkrecClient):
        self.client = client


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
