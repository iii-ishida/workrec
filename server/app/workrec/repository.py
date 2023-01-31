from abc import ABC, abstractclassmethod, abstractmethod
from copy import deepcopy
from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from uuid import uuid4
from google.cloud import datastore


@dataclass
class BaseEntity(ABC):
    id: str
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    @abstractclassmethod
    def from_dict(cls, dic):
        return None

    @abstractmethod
    def to_dict(self):
        return {}


class Query:
    """CloudDatastoreRepo.execute で使用する Query

    :param klass: 取得する kind を表す class
    :param filters: [(<property>, <operator>, <value>)] 形式のフィルターリスト  see `filter_by`
    """

    def __init__(
        self,
        klass,
        *,
        filters: list[tuple[str, str, str]] = [],
        limit: Optional[int] = None,
        cursor: Optional[str] = None,
    ):
        self._klass = klass
        self._filters = filters
        self._limit = limit
        self._cursor = cursor

    def filter_by(self, /, property, operator, value):
        """filter を追加します

        :param property: フィルタリングするプロパティ名
        :param operator: 次のいずれか (``=``, ``<``, ``<=``, ``>``, ``>=``, ``!=``, ``IN``, ``NOT_IN``)
        :param value: フィルタリングの値
        """
        q = deepcopy(self)
        q._filters = self._filters + [(property, operator, value)]
        return q

    def limit(self, limit):
        q = deepcopy(self)
        q._limit = limit
        return q

    def cursor(self, cursor):
        q = deepcopy(self)
        q._cursor = cursor
        return q

    def to_datastore_query_param(self):
        """`google.cloud.datastore.query.Query` 形式に変換した値を返します"""
        return {"kind": self._klass.__name__, "filters": self._filters}


class CloudDatastoreRepo:
    def __init__(self, *, client: Optional[datastore.Client] = None):
        self._client = client or datastore.Client()

    def execute(self, query: Query):
        result = self._client.query(**query.to_datastore_query_param()).fetch(
            limit=query._limit,
            start_cursor=query._cursor,
        )
        entities = [query._klass.from_dict(e) for e in result]
        cursor = result.next_page_token.decode() if result.next_page_token else ""

        return entities, cursor

    def get(self, klass, *, id: str):
        key = self._client.key(klass.__name__, id)
        entity = self._client.get(key)
        return klass.from_dict(entity) if entity is not None else None

    def add(self, obj) -> str:
        id = f"{obj.__class__.__name__}-{str(uuid4())}"
        key = self._client.key(obj.__class__.__name__, id)

        now = datetime.now()

        entity = datastore.Entity(key=key)
        for k, v in obj.to_dict().items():
            entity[k] = v

        entity["id"] = id
        entity["created_at"] = now
        entity["updated_at"] = now

        self._client.put(entity)

        return id

    def put(self, obj):
        key = self._client.key(obj.__class__.__name__, int(obj.id))

        now = datetime.now()

        entity = datastore.Entity(key=key)
        for k, v in obj.to_dict().items():
            entity[k] = v

        entity["updated_at"] = now
        self._client.put(entity)

    def transaction(self):
        return self._client.transaction()
