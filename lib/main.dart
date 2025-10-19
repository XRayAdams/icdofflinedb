import 'package:flutter/material.dart';
import 'package:icdofflinedb/providers/db_settings_provider.dart';
import 'package:icdofflinedb/providers/result_provider.dart';
import 'package:icdofflinedb/ui/home_page.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yaru/widgets.dart';
import 'package:yaru/yaru.dart';

import 'app_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await YaruWindowTitleBar.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) {
              return DbSettingsProvider();
            },
            // ResultProvider
          ),
          ChangeNotifierProvider(
            create: (context) {
              return ResultProvider();
            },
          )
        ],
        child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return YaruTheme(
        builder: (context, yaru, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            // Assign the GlobalKey
            title: AppConst.title,
            theme: yaru.theme,
            debugShowCheckedModeBanner: false,
            darkTheme: yaru.darkTheme,
            themeMode: ThemeMode.system,
            home: const HomePage(title: AppConst.title),
          );
        }
    );
  }
}