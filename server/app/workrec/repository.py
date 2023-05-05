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
        cursor = (
            result.next_page_token.decode()
            if self._has_next(kind, filters, order, result.next_page_token)
            else ""
        )

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
