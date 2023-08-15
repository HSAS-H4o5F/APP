/*
 * This file is part of hsas_h4o5f_app.
 * Copyright (c) 2023 HSAS H4o5F Team. All Rights Reserved.
 *
 * hsas_h4o5f_app is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * hsas_h4o5f_app is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * hsas_h4o5f_app. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:math';

import 'package:args/args.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/color_schemes.dart';
import 'package:hsas_h4o5f_app/ui/pages/about.dart';
import 'package:hsas_h4o5f_app/ui/pages/face_recogntion.dart';
import 'package:hsas_h4o5f_app/ui/pages/home.dart';
import 'package:hsas_h4o5f_app/ui/pages/login_register.dart';
import 'package:hsas_h4o5f_app/ui/pages/settings.dart';
import 'package:hsas_h4o5f_app/ui/widgets.dart';
import 'package:hsas_h4o5f_app/vectors.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences/implementations.dart';

part 'main/future_screen.dart';
part 'main/loading_screen.dart';
part 'main/router.dart';

void main(List<String> args) {
  final parsedArgs =
      (ArgParser()..addOption('serverUrl', abbr: 's')).parse(args);

  WidgetsFlutterBinding.ensureInitialized();

  runApp(SmartCommunityApp(
    serverUrl: parsedArgs['serverUrl'] as String?,
  ));
}

class SmartCommunityApp extends StatefulWidget {
  const SmartCommunityApp({
    super.key,
    required this.serverUrl,
  });

  final String? serverUrl;

  @override
  State<SmartCommunityApp> createState() => _SmartCommunityAppState();
}

class _SmartCommunityAppState extends State<SmartCommunityApp> {
  final _globalNavigatorKey = GlobalKey<NavigatorState>();
  final _shellRouteNavigatorKey = GlobalKey<NavigatorState>();

  late final Future<void> _initFuture;
  late final GoRouter router;

  late final SharedPreferences _sharedPreferences;

  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (light, dark) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          theme: ThemeData(
            colorScheme: light ?? lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: dark ?? darkColorScheme,
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) {
            return Stack(
              children: [
                FutureScreen(
                  future: _initFuture,
                  builder: () => PreferencesProvider(
                    sharedPreferences: _sharedPreferences,
                    child: child ?? const SizedBox(),
                  ),
                ),
                if (!_completed)
                  LoadingScreen(
                    future: _initFuture,
                    onAnimationCompleted: () {
                      setState(() {
                        _completed = true;
                      });
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    router = AppRouter(
      navigatorKey: _globalNavigatorKey,
      shellRouteNavigatorKey: _shellRouteNavigatorKey,
    );

    _initFuture = _initApp();
    super.initState();
  }

  Future<void> _initApp() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    final serverUrl = widget.serverUrl;
    if (serverUrl != null) {
      ServerUrlPreference(context, serverUrl).update(_sharedPreferences);
    }

    if (!ServerUrlPreference.check(_sharedPreferences) && kIsWeb) {
      ServerUrlPreference(context, Uri.base.toString())
          .update(_sharedPreferences);
    }

    if (!ServerUrlPreference.check(_sharedPreferences)) {
      ServerUrlPreference(context, defaultServerUrl).update(_sharedPreferences);
    }

    await initParse(
        ServerUrlPreference.from(context, _sharedPreferences).value);

    SubscribedFeedPreference([]).update(_sharedPreferences);
  }
}

Future<Parse> initParse(String serverUrl) async {
  final serverUri = Uri.parse(serverUrl).replace(path: '/api');

  return await Parse().initialize(
    "smartCommunity",
    serverUri.toString(),
    coreStore: await CoreStoreSembast.getInstance(),
  );
}
