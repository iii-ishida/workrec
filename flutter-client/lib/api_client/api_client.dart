import 'package:graphql/client.dart';
import 'package:workrec/api_client/task.dart';

class ApiClient {
  final String idToken;
  late final GraphQLClient _client;

  ApiClient({required this.idToken}) {
    _client = _getGithubGraphQLClient(idToken);
  }

  /// Get tasks.
  Future<List<Task>> getTasks(int limit) async {
    final QueryOptions options = QueryOptions(
      document: gql(
        r'''
        query Query($limit: Int!) {
          tasks(cursor: "", limit: $limit) {
            edges {
              node {
                id
                state
                title
                totalWorkingTime
              }
            }
            pageInfo {
              endCursor
              hasNextPage
            }
          }
        }
      ''',
      ),
      variables: {
        'limit': limit,
      },
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> repositories =
        result.data!['tasks']['edges'] as List<dynamic>;
    return repositories
        .map(
          (dynamic f) => Task(
            id: f['node']['id'],
            title: f['node']['title'],
            state: TaskState.values.asNameMap()[f['node']['state']]!,
            totalWorkingTime: f['node']['totalWorkingTime'],
          ),
        )
        .toList();
  }
}

GraphQLClient _getGithubGraphQLClient(String idToken) {
  final Link link = HttpLink(
    'http://localhost:8080/graphql',
    defaultHeaders: {
      'Authorization': 'Bearer $idToken',
    },
  );

  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}
