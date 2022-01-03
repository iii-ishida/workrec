import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec_app/workrec_client/models/task.dart';
import 'package:workrec_app/workrec_client/models/work_time.dart';

typedef _QueryDocument = DocumentSnapshot<Map<String, dynamic>>;

/// [Task] から Firestore 用の [Map] を生成して返します
Map<String, dynamic> taskToFirestoreData({
  Task? task,
  FieldValue? createdAt,
  FieldValue? updatedAt,
}) {
  return <String, dynamic>{
    if (task != null) 'title': task.title,
    if (task != null) 'description': task.description,
    if (task != null) 'estimatedTime': task.estimatedTime,
    if (task != null) 'state': task.state.name,
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
  _QueryDocument doc,
  List<_QueryDocument> workTimeDocs,
) {
  final data = doc.data();
  if (data == null) {
    return Task.create(title: '');
  }

  return Task(
    id: doc.id,
    title: data['title'] as String,
    description: data['description'] as String,
    estimatedTime: data['estimatedTime'] as int,
    state: TaskState.values.byName(data['state'] as String),
    timeRecords: workTimeListFromFirestoreDocs(workTimeDocs),
  );
}

List<WorkTime> workTimeListFromFirestoreDocs(List<_QueryDocument> docs) {
  return docs.map((doc) => _workTimeFromFirestoreDoc(doc)).toList();
}

WorkTime _workTimeFromFirestoreDoc(_QueryDocument doc) {
  final data = doc.data();
  if (data == null) {
    return WorkTime(id: '', start: DateTime.now(), end: DateTime.now());
  }

  return WorkTime(
    id: doc.id,
    start: (data['start'] as Timestamp).toDate(),
    end: (data['end'] as Timestamp).toDate(),
  );
}
