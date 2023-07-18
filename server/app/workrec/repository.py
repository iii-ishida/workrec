from typing import Optional

from google.cloud import datastore
from contextlib import contextmanager


class CloudDatastoreRepo:
    def __init__(self, *, client: Optional[datastore.Client] = None):
        self._client = client or datastore.Client()

    def list(
        self,
        kind: str,
        *,
        filters: list[tuple[str, str, str]] = [],
        order: list[str] = [],
        limit: Optional[int] = None,
        cursor: Optional[str] = None,
    ):
        query = self._client.query(kind=kind, filters=filters, order=order)
        result = query.fetch(
            limit=limit,
            start_cursor=cursor,
        )
        entities = [e for e in result]

        cursor = ""
        if self._has_next(kind, filters, order, result.next_page_token):
            cursor = result.next_page_token.decode()

        return entities, cursor

    def get(self, kind: str, *, id: str):
        key = self._client.key(kind, id)
        entity = self._client.get(key)
        return entity

    def put(self, kind: str, *, id: str, entity: dict):
        key = self._client.key(kind, id)

        e = datastore.Entity(key=key)
        for k, v in entity.items():
            e[k] = v

        self._client.put(e)

    def transaction(self):
        return self._client.transaction()

    def _has_next(self, kind, filters, order, next_page_token):
        if not next_page_token:
            return False

        query = self._client.query(kind=kind, filters=filters, order=order)
        result = query.fetch(
            limit=1,
            start_cursor=next_page_token,
        )
        entities = [e for e in result]

        return len(entities) > 0


class InMemoryRepo:
    def __init__(self):
        self._data = {}

    def list(
        self,
        kind: str,
        *,
        filters: list[tuple[str, str, str]] = [],
        order: list[str] = [],
        limit: Optional[int] = None,
        cursor: Optional[str] = None,
    ):
        entities_map = self._data.get(kind, {})

        for prop, op, value in filters:
            entities_map = {
                k: v
                for k, v in entities_map.items()
                if self._compare(v.get(prop), op, value)
            }

        for prop in order:
            desc = prop.startswith("-")
            prop = prop[1:] if desc else prop
            entities_map = {
                k: v
                for k, v in sorted(
                    entities_map.items(),
                    key=lambda item: item[1].get(prop),
                    reverse=desc,
                )
            }

        entities = list(entities_map.values())

        if cursor:
            cursor_index = next(
                (i for i, key in enumerate(entities_map.keys()) if key == cursor), None
            )
            if cursor_index is not None:
                entities = entities[cursor_index + 1 :]

        if limit:
            entities = entities[:limit]

        cursor = (
            list(entities_map.keys())[list(entities_map.values()).index(entities[-1])]
            if entities
            else ""
        )
        if entities_map and cursor == list(entities_map.keys())[-1]:
            cursor = ""

        return entities, cursor

    def get(self, kind: str, *, id: str):
        return self._data.get(kind, {}).get(id)

    def put(self, kind: str, *, id: str, entity: dict):
        self._data.setdefault(kind, {})[id] = entity

    @contextmanager
    def transaction(self):
        yield None

    def _compare(self, a, op, b):
        if op == "=":
            return a == b
        elif op == "!=":
            return a != b
        elif op == "<":
            return a < b
        elif op == ">":
            return a > b
        elif op == "<=":
            return a <= b
        elif op == ">=":
            return a >= b
        else:
            raise ValueError(f"Invalid operator: {op}")
