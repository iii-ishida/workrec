import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/domain/task_recorder/work_time.dart';

typedef QueryDocument = QueryDocumentSnapshot<Map<String, dynamic>?>;

/// [Task] から Firestore 用の [Map] を生成して返します
Map<String, dynamic> taskToFirestoreData(
  Task task, {
  FieldValue? createdAt,
  FieldValue? updatedAt,
}) {
  return <String, dynamic>{
    'title': task.title,
    'state': task.state.toShortString(),
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };
}

/// [WorkTime] から Firestore 用の [Map] を生成して返します
Map<String, dynamic> workTimeToFirestoreData(WorkTime workTime) {
  return <String, dynamic>{
    'start': workTime.start,
    'end': workTime.end,
  };
}

/// [QueryDocumentSnapshot] から [Task] を生成して返します
Task taskFromFirestoreDoc(
  QueryDocument doc,
  List<QueryDocument> workTimeDocs,
) {
  final data = doc.data();
  if (data == null) {
    return Task.empty;
  }

  return Task(
    id: doc.id,
    title: data['title'] as String,
    state: taskStateFromShortString(data['state'] as String),
    workTimeList: _workTimeListFromFirestoreDocs(workTimeDocs),
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  );
}

WorkTimeList _workTimeListFromFirestoreDocs(List<QueryDocument> docs) {
  return WorkTimeList(docs
      .map(
        (doc) => _workTimeFromFirestoreDoc(doc),
      )
      .toList());
}

WorkTime _workTimeFromFirestoreDoc(QueryDocument doc) {
  final data = doc.data();
  if (data == null) {
    return WorkTime.empty;
  }

  return WorkTime(
    id: doc.id,
    start: (data['start'] as Timestamp).toDate(),
    end: (data['end'] as Timestamp).toDate(),
  );
}
