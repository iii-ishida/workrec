import strawberry

from fastapi import FastAPI
from strawberry.asgi import GraphQL

from google.cloud import datastore

@strawberry.type
class User:
    name: str
    age: int


@strawberry.type
class Query:
    @strawberry.field
    def user(self) -> User:
        return User(name="Sam", age=30)


# Instantiates a client
datastore_client = datastore.Client()

# The kind for the new entity
kind = "Task"
# The name/ID for the new entity
name = "sampletask1"
# The Cloud Datastore key for the new entity
task_key = datastore_client.key(kind, name)

# Prepares the new entity
task = datastore.Entity(key=task_key)
task["description"] = "Buy milk"

# Saves the entity
datastore_client.put(task)

print(f"Saved {task.key.name}: {task['description']}")

schema = strawberry.Schema(query=Query)

graphql_app = GraphQL(schema)


app = FastAPI()
app.add_route("/graphql", graphql_app)
app.add_websocket_route("/graphql", graphql_app)
