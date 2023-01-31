from google.cloud import datastore

class _Query:
    def __init__(self, kind):
        self.kind = kind
        self.filters = []

    def filter_by(self, **filter):
        key, val = list(filter.items())[0]
        self.filters.append((key, '=', val))
        return self

    def to_datastore_query_param(self):
        return {'kind': self.kind.__name__, 'filters': self.filters}


def select(cls):
    return _Query(cls)


class CloudDatastoreRepo:
    def __init__(self, client=None):
        self._client = client or datastore.Client()

    def execute(self, query):
        result = self._client.query(**query.to_datastore_query_param()).fetch()
        return [query.kind.from_dict(e) for e in result]

    def put(self, obj):
        key = self._client.key(obj.__class__.__name__)
        key = self._client.allocate_ids(key, 1)[0]

        entity = datastore.Entity(key=key)
        entity["id"] = str(key.id)
        for k, v in obj.to_dict().items():
            if k != "id":
                entity[k] = v

        self._client.put(entity)
