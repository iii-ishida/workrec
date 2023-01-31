import strawberry
from strawberry.types import Info
from typing import Optional


@strawberry.type
class Task:
    id: strawberry.ID
    title: str
    working_time: int


@strawberry.type
class TaskEdge:
    node: Task


@strawberry.type
class PageInfo:
    has_next_page: bool
    end_cursor: str


@strawberry.type
class TasksConnection:
    edges: list[TaskEdge]
    page_info: PageInfo


@strawberry.type
class Query:
    @strawberry.field
    def tasks(
        self, *, limit: Optional[int] = None, cursor: Optional[str] = None, info: Info
    ) -> TasksConnection:
        client = info.context.client
        tasks, cursor = client.task_list(
            user_id="some-user-id", limit=limit, cursor=cursor
        )
        print(f"TASK: {tasks}")
        edges = [
            TaskEdge(node=Task(id=t.id, title=t.title, working_time=t.working_time))
            for t in tasks
        ]
        return TasksConnection(
            edges=edges,
            page_info=PageInfo(has_next_page=bool(cursor), end_cursor=cursor),
        )


@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_task(self, title: str, info: Info) -> Task:
        client = info.context.client
        task_id = client.create_task(user_id="some-user-id", title=title)
        return client.find_task(id=task_id)


schema = strawberry.Schema(query=Query, mutation=Mutation)
