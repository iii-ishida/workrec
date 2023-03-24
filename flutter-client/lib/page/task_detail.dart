import 'package:flutter/material.dart';
import 'package:workrec/page/styles.dart';

class TaskDetail extends StatelessWidget {
  const TaskDetail({super.key});

  @override
  Widget build(BuildContext context) {
    const appBarHeight = 286.0 - 48;

    return DecoratedBox(
      decoration: const BoxDecoration(color: ThemeColors.gray200),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ThemeColors.gray200,
            expandedHeight: appBarHeight,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              expandedTitleScale: 1,
              background: Container(
                margin: const EdgeInsets.only(bottom: 36),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeColors.primary100,
                      ThemeColors.primary200,
                    ],
                  ),
                ),
              ),
              title: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 64),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: ThemeColors.primary300,
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: PopupMenuButton(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              itemBuilder: (context) => [],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(child: _Current()),
                        const SizedBox(height: 24),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: ThemeColors.gray100,
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: ThemeColors.primary500,
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: const Text(
                              "完了",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            sliver: SliverToBoxAdapter(child: _Calendar()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const Text("2022-01-01"),
                  const SizedBox(height: 8),
                  _Tile(),
                  const SizedBox(height: 8),
                  _Tile(),
                  const SizedBox(height: 8),
                  _TileTotal(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemeColors.gray100,
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary400.withAlpha(
              (255 * 0.25).round(),
            ),
            offset: const Offset(0, 4.0),
            blurRadius: 4.0,
          )
        ],
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                height: double.infinity,
                width: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: ThemeColors.primary300),
                ),
              ),
              SizedBox(width: 16),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("10:00:00 ~ 12:00:00"),
              ),
              Spacer(),
              Text("02:00"),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileTotal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: ThemeColors.gray100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                height: double.infinity,
                width: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: ThemeColors.primary500),
                ),
              ),
              SizedBox(width: 16),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("合計"),
              ),
              Spacer(),
              Text("04:00"),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.primary100,
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary400.withAlpha(
              (255 * 0.25).round(),
            ),
            offset: const Offset(0, 4.0),
            blurRadius: 4.0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                "2022-01",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary800,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: ThemeColors.primary500,
              ),
              SizedBox(width: 24),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ThemeColors.primary500,
              ),
              SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            defaultColumnWidth: const FixedColumnWidth(44),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  Center(
                    child: Text(
                      "SUN",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "MON",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "TUE",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "WED",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "THU",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "FRI",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "SAT",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  SizedBox(
                    height: 44,
                    width: 44,
                    child: Center(
                      child: Container(
                        height: 22,
                        width: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: ThemeColors.primary500,
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: const Text(
                          "1",
                          style: TextStyle(
                            fontSize: 15,
                            color: ThemeColors.primary200,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "2",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "3",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "4",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "5",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "6",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "7",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        "8",
                        style: TextStyle(
                          fontSize: 15,
                          color: ThemeColors.primary600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "9",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "10",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "11",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "12",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "13",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "14",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        "15",
                        style: TextStyle(
                          fontSize: 15,
                          color: ThemeColors.primary600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "16",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "17",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "18",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "19",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "20",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "21",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        "22",
                        style: TextStyle(
                          fontSize: 15,
                          color: ThemeColors.primary600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "23",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "24",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "25",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "26",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "27",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "28",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        "29",
                        style: TextStyle(
                          fontSize: 15,
                          color: ThemeColors.primary600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "30",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "31",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "1",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "2",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "3",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "4",
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeColors.primary600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Current extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "作業中のタスク",
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: ThemeColors.primary800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "02:00:00",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w400,
                color: ThemeColors.primary800,
              ),
            ),
            const SizedBox(width: 32),
            _ToggleButton(),
          ],
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        child: Ink(
          width: 44,
          height: 44,
          color: ThemeColors.primary300,
          child: InkWell(
            splashColor: Colors.transparent,
            child: Center(
              child: Ink(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: ThemeColors.primary600,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
