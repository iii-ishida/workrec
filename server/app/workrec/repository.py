from typing import Optional

from google.cloud import datastore


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

    def add(self, kind: str, *, id: str, entity: dict):
        key = self._client.key(kind, id)

        e = datastore.Entity(key=key)
        for k, v in entity.items():
            e[k] = v

        self._client.put(e)

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
        entities = [e for e in self._data.get(kind, {}).values()]
        last = entities[-1] if entities else {}

        for prop, op, value in filters:
            entities = [e for e in entities if self._compare(e.get(prop), op, value)]

        for prop in order:
            entities = sorted(entities, key=lambda e: e.get(prop))

        if cursor:
            cursor_index = next(
                (i for i, e in enumerate(entities) if e["key"] == cursor), None
            )
            if cursor_index is not None:
                entities = entities[cursor_index + 1 :]

        if limit:
            entities = entities[:limit]

        cursor = entities[-1]["key"] if entities else ""
        cursor = cursor if cursor != last["key"] else ""

        return entities, cursor

    def get(self, kind: str, *, id: str):
        return self._data.get(kind, {}).get(id)

    def add(self, kind: str, *, id: str, entity: dict):
        self._data.setdefault(kind, {})[id] = entity

    def put(self, kind: str, *, id: str, entity: dict):
        self._data.setdefault(kind, {})[id] = entity

    def transaction(self):
        return None

    def _compare(self, a, op, b):
        if op == "=":
            return a == b
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
