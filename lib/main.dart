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
import 'package:hsas_h4o5f_app/ui/pages/home.dart';
import 'package:hsas_h4o5f_app/ui/pages/login_register.dart';
import 'package:hsas_h4o5f_app/ui/pages/settings.dart';
import 'package:hsas_h4o5f_app/vectors.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// TODO: 提取组件
class _SmartCommunityAppState extends State<SmartCommunityApp>
    with TickerProviderStateMixin {
  final _globalNavigatorKey = GlobalKey<NavigatorState>();
  final _shellRouteNavigatorKey = GlobalKey<NavigatorState>();

  late final Future<void> _initFuture;
  late final AnimationController _progressIndicatorController;
  late final AnimationController _pageTransitionController;
  late final AnimationStatusListener _pageTransitionStatusListener;
  late final GoRouter router;

  bool _completed = false;

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

    _progressIndicatorController.forward();
    _pageTransitionController.forward();
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

    _pageTransitionStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _completed = true;
        });
        _pageTransitionController
            .removeStatusListener(_pageTransitionStatusListener);

        _progressIndicatorController.dispose();
        _pageTransitionController.dispose();
      }
    };

    _progressIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..animateTo(0.9);
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addStatusListener(_pageTransitionStatusListener);
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

            if (state.uri.path == '/home') {
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
            location: state.uri.path,
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
                      opacity:
                          animation.drive(CurveTween(curve: Curves.easeInOut)),
                      child: FadeTransition(
                        opacity: ReverseAnimation(secondaryAnimation)
                            .drive(CurveTween(curve: Curves.easeInOut)),
                        child: child,
                      ),
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

    _initFuture = _init();
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
                onInitialBuild: (_) async {
                  StoreProvider.of<AppState>(context).dispatch(
                      SetSharedPreferencesAction(
                          await SharedPreferences.getInstance()));
                },
                builder: (context, _) {
                  return Stack(
                    children: [
                      FutureBuilder(
                        future: _initFuture,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              return const SizedBox();
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
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
                      ),
                      if (!_completed)
                        FadeTransition(
                          opacity: ReverseAnimation(_pageTransitionController)
                              .drive(CurveTween(curve: Curves.easeInOut)),
                          child: Scaffold(
                            body: LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Logo(
                                        size: max(
                                              constraints.maxWidth,
                                              constraints.maxHeight,
                                            ) *
                                            0.15,
                                        fill: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      SizedBox(
                                        height: constraints.maxHeight * 0.1,
                                      ),
                                      ClipPath.shape(
                                        shape: const StadiumBorder(),
                                        child: Container(
                                          width: constraints.maxWidth * 0.5,
                                          height: constraints.maxWidth * 0.02,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          child: SlideTransition(
                                            position: Tween(
                                              begin: const Offset(-1, 0),
                                              end: const Offset(0, 0),
                                            ).animate(
                                              CurvedAnimation(
                                                parent:
                                                    _progressIndicatorController,
                                                curve: Curves.easeInOut,
                                              ),
                                            ),
                                            child: ClipPath.shape(
                                              shape: const StadiumBorder(),
                                              child: Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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
}

Future<Parse> initParse(String serverUrl) async {
  final serverUri = Uri.parse(serverUrl).replace(path: '/api');

  return await Parse().initialize(
    "smartCommunity",
    serverUri.toString(),
    coreStore: await CoreStoreSembast.getInstance(),
  );
}
