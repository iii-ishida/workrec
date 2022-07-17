import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:workrec/widgets/home.dart';
import 'package:workrec/widgets/task_list.dart';

// ignore_for_file: invalid_use_of_visible_for_testing_member
class HotReload extends StatelessWidget {
  const HotReload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      appInfo: AppInfo(name: 'Workrec App'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      themes: [
        WidgetbookTheme(
          name: 'Light',
          data: ThemeData.light(),
        ),
        WidgetbookTheme(
          name: 'Dark',
          data: ThemeData.dark(),
        ),
      ],
      devices: const [
        Apple.iPhoneSE2020,
        Apple.iPhone13Mini,
        Apple.iPhone13Pro,
        Apple.iPhone13ProMax,
      ],
      categories: [
        WidgetbookCategory(
          name: 'pages',
          folders: [
            WidgetbookFolder(
              name: 'Home',
              widgets: [
                WidgetbookComponent(
                  name: 'Home',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Dafault',
                      builder: (context) => const Home(),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'TaskListPage',
              widgets: [
                WidgetbookComponent(
                  name: 'TaskListScreen',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Dafault',
                      builder: (context) => const TaskListScreen(),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'TaskListTile',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Dafault',
                      builder: (context) => const TaskListTile(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
