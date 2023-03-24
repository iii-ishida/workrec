import 'package:flutter/material.dart';
import 'package:workrec/page/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'dart:ui';

import '../widget/hover_card.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskListScreen();
  }
}

class TaskListScreen extends StatefulWidget {
  @visibleForTesting
  const TaskListScreen({super.key});

  @override
  createState() => TaskListState();
}

class TaskListState extends State<TaskListScreen> {
  double x = 1;
  late ScrollController controller;
  final k = GlobalKey();
  final hoverCardController = HoverCardController();

  @override
  initState() {
    super.initState();

    controller = ScrollController()
      ..addListener(() {
        if (!controller.hasClients) {
          return;
        }

        final statusBarHeight = MediaQuery.of(context).viewPadding.top;
        final appBarHeight =
            (MediaQuery.of(context).size.width / 1.6) - statusBarHeight;
        final ratio = controller.offset / appBarHeight;
        setState(() {
          x = 1 - min(ratio, 1);
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = (MediaQuery.of(context).size.width / 1.6);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ThemeColors.primary100,
      ),
      child: Stack(
        children: [
          CustomScrollView(
            controller: controller,
            slivers: [
              SliverAppBar(
                backgroundColor: ThemeColors.primary100,
                expandedHeight: appBarHeight,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  expandedTitleScale: 1,
                  background: SvgPicture.asset(
                    'assets/current-task-background.svg',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final settings =
                          context.dependOnInheritedWidgetOfExactType<
                              FlexibleSpaceBarSettings>()!;

                      return Opacity(
                        opacity: _appBarOpacity(
                          minExtent: settings.minExtent,
                          maxExtent: settings.maxExtent,
                          currentExtent: settings.currentExtent,
                          toolbarHeight: kToolbarHeight,
                        ),
                        child: HoverCard(
                          controller: hoverCardController,
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 40,
                              right: 40,
                              bottom: 32,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 32,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeColors.primary300,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const FittedBox(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '作業中タスク001',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColors.primary500,
                                        ),
                                      ),
                                      SizedBox(height: 16.0),
                                      Text(
                                        '02:00:00',
                                        style: TextStyle(
                                          fontSize: 34.0,
                                          color: ThemeColors.primary900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                FittedBox(
                                  child: HoverCardAnimationDisable(
                                    controller: hoverCardController,
                                    child: _ToggleButton(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                      const SizedBox(height: 8),
                      _Tile(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (_, child) {
              final renderbox = k.currentContext?.findRenderObject();
              final width = renderbox == null
                  ? 1000
                  : (renderbox as RenderBox).size.width;

              return Positioned(
                key: k,
                right: x * -width,
                bottom: 100,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemeColors.primary300.withAlpha(210),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 8, left: 16, right: 8),
                      child: Row(
                        children: [
                          const Text(
                            '02:00:00',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.primary900,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _ToggleButton()
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _appBarOpacity({
    required double minExtent,
    required double maxExtent,
    required double currentExtent,
    required double toolbarHeight,
  }) {
    final deltaExtent = maxExtent - minExtent;
    final fadeStart = max(0.0, 1.0 - toolbarHeight / deltaExtent);
    const fadeEnd = 1.0;
    final t = (1.0 - (currentExtent - minExtent) / deltaExtent).clamp(0.0, 1.0);

    return maxExtent == minExtent
        ? 1.0
        : 1.0 - Interval(fadeStart, fadeEnd).transform(t);
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
          color: ThemeColors.primary200,
          child: InkWell(
            splashColor: Colors.transparent,
            child: Center(
              child: Ink(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: ThemeColors.primary800,
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

class _Tile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: ThemeColors.gray100),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                height: double.infinity,
                width: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: ThemeColors.primary300),
                ),
              ),
              const SizedBox(width: 16),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'タスク001',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.gray800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '02-01 10:00:00 - 02-01 12:00:00',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColors.gray600,
                      ),
                    ),
                    Text(
                      '01:00:00',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _ToggleButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
