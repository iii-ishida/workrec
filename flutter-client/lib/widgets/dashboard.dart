import 'package:flutter/cupertino.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text('作業中のタスク名'),
        ),
        SliverList(
            delegate: SliverChildListDelegate.fixed([
          Text('CURRENT_作業時間: xx:xx'),
          Text('TOTAL_作業時間: xx:xx'),
          Text('開始日時: yyyy-mm-dd hh:mm'),
          Text('作業履歴一覧: '),
        ])),
      ],
    );
  }
}
