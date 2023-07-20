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
import 'package:hsas_h4o5f_app/ui/pages/home.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/fitness_equipments.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/guide_dogs.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/medical_care.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/mutual_aid.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/route.dart';
import 'package:hsas_h4o5f_app/ui/pages/login_register.dart';
import 'package:hsas_h4o5f_app/ui/pages/settings.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) {
  final parsedArgs =
      (ArgParser()..addOption('serverUrl', abbr: 's')).parse(args);

  String? serverUrl = parsedArgs['serverUrl'] as String?;

  final store = Store<AppState>(
    appReducer,
    initialState: const AppState(),
  );

  if (kIsWeb) {
    serverUrl = Uri.base.toString();
  }

  runApp(SmartCommunityApp(
    store: store,
    serverUrl: serverUrl,
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

  late final GoRouter router;

  Future<void> _init(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    StoreProvider.of<AppState>(context)
        .dispatch(SetSharedPreferencesAction(prefs));

    if (widget.serverUrl != null) {
      prefs.setStringPreference(
        serverUrlPreference,
        widget.serverUrl!,
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

    router = GoRouter(
      navigatorKey: _globalNavigatorKey,
      routes: [
        GoRoute(
          parentNavigatorKey: _globalNavigatorKey,
          path: '/',
          redirect: (context, state) => '/home',
        ),
        GoRoute(
          parentNavigatorKey: _globalNavigatorKey,
          path: '/home',
          redirect: (context, state) async {
            final currentUser = await ParseUser.currentUser();
            if (currentUser == null) {
              return '/login';
            }

            if (state.location == '/home') {
              return HomePageRoute.routes.keys.first;
            }

            return null;
          },
          routes: [
            GoRoute(
              parentNavigatorKey: _globalNavigatorKey,
              path: ':medical-care',
              builder: (context, state) => const MedicalCarePage(),
            ),
            GoRoute(
              parentNavigatorKey: _globalNavigatorKey,
              path: ':guide-dogs',
              builder: (context, state) => const GuideDogsPage(),
            ),
            GoRoute(
              parentNavigatorKey: _globalNavigatorKey,
              path: ':mutual-aid',
              builder: (context, state) => const MutualAidPage(),
            ),
            GoRoute(
              parentNavigatorKey: _globalNavigatorKey,
              path: ':fitness-equipments',
              builder: (context, state) => const FitnessEquipmentsPage(),
            ),
          ],
        ),
        ShellRoute(
          navigatorKey: _shellRouteNavigatorKey,
          builder: (context, state, child) => HomePage(
            location: state.location,
            child: child,
          ),
          routes: HomePageRoute.routes.entries.map((entry) {
            return GoRoute(
              parentNavigatorKey: _shellRouteNavigatorKey,
              path: entry.key,
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: entry.value.builder(context, state),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(curve: Curves.easeInOut)
                          .animate(animation),
                      child: child,
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
        GoRoute(
          parentNavigatorKey: _globalNavigatorKey,
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          parentNavigatorKey: _globalNavigatorKey,
          path: '/login',
          builder: (context, state) => const LoginRegisterPage(
            type: LoginRegisterPageType.login,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _globalNavigatorKey,
          path: '/register',
          builder: (context, state) => const LoginRegisterPage(
            type: LoginRegisterPageType.register,
          ),
        ),
      ],
      initialLocation: '/',
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: widget.store,
      child: DynamicColorBuilder(
        builder: (light, dark) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
            theme: ThemeData(
              colorScheme: light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: dark,
              useMaterial3: true,
            ),
            themeMode: ThemeMode.system,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
            builder: (context, child) {
              return FutureBuilder(
                future: _init(context),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                snapshot.error.toString(),
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return child ?? const SizedBox();
                      }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

Future<Parse> initParse(String serverUrl) async {
  final serverUri = Uri.parse(serverUrl).replace(path: '/api');

  return await Parse().initialize(
    "smartCommunity",
    serverUri.toString(),
    coreStore: await CoreStoreSembastImp.getInstance(),
  );
}
