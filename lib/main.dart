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
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/preference/implementations/server_url.dart';
import 'package:hsas_h4o5f_app/preference/preference.dart';
import 'package:hsas_h4o5f_app/preference/string_preference.dart';
import 'package:hsas_h4o5f_app/state/app_state.dart';
import 'package:hsas_h4o5f_app/state/shared_preferences.dart';
import 'package:hsas_h4o5f_app/ui/color_schemes.dart';
import 'package:hsas_h4o5f_app/ui/pages/about.dart';
import 'package:hsas_h4o5f_app/ui/pages/home.dart';
import 'package:hsas_h4o5f_app/ui/pages/login_register.dart';
import 'package:hsas_h4o5f_app/ui/pages/settings.dart';
import 'package:hsas_h4o5f_app/vectors.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'main/future_screen.dart';
part 'main/loading_screen.dart';
part 'main/router.dart';

void main(List<String> args) {
  final parsedArgs =
      (ArgParser()..addOption('serverUrl', abbr: 's')).parse(args);

  final store = Store<AppState>(
    appReducer,
    initialState: const AppState(),
  );

  runApp(SmartCommunityApp(
    store: store,
    serverUrl: parsedArgs['serverUrl'] as String?,
  ));
}

class SmartCommunityApp extends StatefulWidget {
  const SmartCommunityApp({
    super.key,
    required this.store,
    required this.serverUrl,
  });

  final Store<AppState> store;
  final String? serverUrl;

  @override
  State<SmartCommunityApp> createState() => _SmartCommunityAppState();
}

class _SmartCommunityAppState extends State<SmartCommunityApp> {
  final _globalNavigatorKey = GlobalKey<NavigatorState>();
  final _shellRouteNavigatorKey = GlobalKey<NavigatorState>();

  late final Future<void> _initFuture;
  late final GoRouter router;

  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: widget.store,
      child: DynamicColorBuilder(
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
              return StoreConnector<AppState, void>(
                converter: (store) {},
                onInit: (_) async {
                  StoreProvider.of<AppState>(context).dispatch(
                    SetSharedPreferencesAction(
                        await SharedPreferences.getInstance()),
                  );
                },
                builder: (context, _) {
                  return Stack(
                    children: [
                      FutureScreen(
                        future: _initFuture,
                        child: child ?? const SizedBox(),
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
        },
      ),
    );
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.serverUrl != null) {
      prefs.setStringPreference(
        serverUrlPreference,
        widget.serverUrl!,
      );
    }

    if (!prefs.containsPreference(serverUrlPreference) && kIsWeb) {
      prefs.setStringPreference(
        serverUrlPreference,
        Uri.base.toString(),
      );
    }

    if (!prefs.containsPreference(serverUrlPreference)) {
      prefs.setStringPreference(
        serverUrlPreference,
        defaultServerUrl,
      );
    }

    await initParse(prefs.getStringPreference(serverUrlPreference)!);
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

    _initFuture = _init();
    super.initState();
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
