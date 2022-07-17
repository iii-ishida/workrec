import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workrec/widgets/styles.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TaskListScreen();
  }
}

class TaskListScreen extends StatelessWidget {
  @visibleForTesting
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: const [
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
          Divider(height: 1, color: Color(0xFFA5A5A5)),
          TaskListTile(),
        ],
      ),
    );
  }
}

class TaskListTile extends StatelessWidget {
  @visibleForTesting
  const TaskListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingUnit.medium),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('タスク 001'),
                SizedBox(height: SpacingUnit.small),
                Text('説明 001'),
                SizedBox(height: SpacingUnit.small),
                Text('開始日時: 2022-01-01 10:00'),
                Text('作業時間: 30分'),
              ],
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1, color: Colors.blue),
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingUnit.medium,
                  vertical: SpacingUnit.small,
                ),
              ),
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(CupertinoIcons.pause, size: SpacingUnit.medium),
                  Text('停止'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
