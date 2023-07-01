from datetime import datetime
from typing import Optional

import strawberry
from app.workrec import Task, WorkSession, WorkrecClient
from strawberry.types import Info


@strawberry.type
class WorkSessionNode:
    id: strawberry.ID
    start_time: datetime
    end_time: datetime
    working_time: int

    @classmethod
    def from_work(cls, work: WorkSession) -> "WorkSessionNode":
        return WorkSessionNode(
            id=work.id,
            start_time=work.start_time,
            end_time=work.end_time,
            working_time=work.working_time,
        )


@strawberry.type
class WorkSessionEdge:
    node: WorkSessionNode


@strawberry.type
class WorkSessionsConnection:
    edges: list[WorkSessionEdge]
    page_info: "PageInfo"


def work_session_list(
    root: "TaskNode",
    *,
    limit: Optional[int] = None,
    cursor: Optional[str] = None,
    info: Info
) -> "WorkSessionsConnection":
    client: WorkrecClient = info.context.client
    work_sessions, cursor = client.work_session_list(
        task_id=root.id, limit=limit, cursor=cursor
    )
    edges = [WorkSessionEdge(node=WorkSessionNode.from_work(w)) for w in work_sessions]
    return WorkSessionsConnection(
        edges=edges,
        page_info=PageInfo(has_next_page=bool(cursor), end_cursor=cursor),
    )


@strawberry.type
class TaskNode:
    id: strawberry.ID
    title: str
    total_working_time: int
    last_work: WorkSessionNode
    state: str
    work_sessions: WorkSessionsConnection = strawberry.field(resolver=work_session_list)

    @classmethod
    def from_task(cls, task: Task) -> "TaskNode":
        return TaskNode(
            id=task.id,
            title=task.title,
            total_working_time=task.total_working_time,
            state=task.state,
            last_work=WorkSessionNode.from_work(task.last_work),
        )


@strawberry.type
class TaskEdge:
    node: TaskNode


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
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        tasks, cursor = client.task_list(user_id=user_id, limit=limit, cursor=cursor)
        edges = [TaskEdge(node=TaskNode.from_task(t)) for t in tasks]
        return TasksConnection(
            edges=edges,
            page_info=PageInfo(has_next_page=bool(cursor), end_cursor=cursor),
        )

    @strawberry.field
    def task(self, *, id: strawberry.ID, info: Info) -> TaskNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        task = client.find_task(user_id=user_id, task_id=id)
        return TaskNode.from_task(task)


@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_task(self, title: str, info: Info) -> TaskNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        task_id = client.create_task(user_id=user_id, title=title)
        t = client.find_task(user_id=user_id, task_id=task_id)
        return TaskNode.from_task(t)

    @strawberry.mutation
    def start_work_on_task(
        self, task_id: strawberry.ID, timestamp: datetime, info: Info
    ) -> TaskNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        client.start_work_on_task(user_id=user_id, task_id=task_id, timestamp=timestamp)
        t = client.find_task(user_id=user_id, task_id=task_id)
        return TaskNode.from_task(t)

    @strawberry.mutation
    def stop_work_on_task(
        self, task_id: str, timestamp: datetime, info: Info
    ) -> TaskNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        client.stop_work_on_task(user_id=user_id, task_id=task_id, timestamp=timestamp)
        t = client.find_task(user_id=user_id, task_id=task_id)
        return TaskNode.from_task(t)

    @strawberry.mutation
    def complete_task(
        self, task_id: strawberry.ID, timestamp: datetime, info: Info
    ) -> TaskNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        client.complete_task(user_id=user_id, task_id=task_id, timestamp=timestamp)
        t = client.find_task(user_id=user_id, task_id=task_id)
        return TaskNode.from_task(t)

    @strawberry.mutation
    def add_work_session(
        self,
        task_id: strawberry.ID,
        start_time: datetime,
        end_time: datetime,
        info: Info,
    ) -> WorkSessionNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        work_session_id = client.add_work_session(
            user_id=user_id, task_id=task_id, start_time=start_time, end_time=end_time
        )
        w = client.find_work_session(user_id=user_id, work_session_id=work_session_id)
        return WorkSessionNode.from_work(w)

    @strawberry.mutation
    def edit_work_session(
        self,
        work_session_id: strawberry.ID,
        start_time: datetime,
        end_time: datetime,
        info: Info,
    ) -> WorkSessionNode:
        user_id = info.context.user_id
        if user_id is None:
            raise Exception("unauthorized")

        client: WorkrecClient = info.context.client
        client.edit_work_session(
            user_id=user_id,
            work_session_id=work_session_id,
            start_time=start_time,
            end_time=end_time,
        )
        w = client.find_work_session(user_id=user_id, work_session_id=work_session_id)
        return WorkSessionNode.from_work(w)


schema = strawberry.Schema(query=Query, mutation=Mutation)
