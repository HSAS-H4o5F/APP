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

part of '../main.dart';

class AppRouter extends GoRouter {
  AppRouter({
    required super.navigatorKey,
    required this.shellRouteNavigatorKey,
  }) : super(
          initialLocation: '/',
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: '/',
              redirect: (context, state) => '/home',
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
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
                  parentNavigatorKey: navigatorKey,
                  path: ':medical-care',
                  builder: (context, state) => const MedicalCarePage(),
                ),
                GoRoute(
                  parentNavigatorKey: navigatorKey,
                  path: ':guide-dogs',
                  builder: (context, state) => const GuideDogsPage(),
                ),
                GoRoute(
                  parentNavigatorKey: navigatorKey,
                  path: ':mutual-aid',
                  builder: (context, state) => const MutualAidPage(),
                ),
                GoRoute(
                  parentNavigatorKey: navigatorKey,
                  path: ':fitness-equipments',
                  builder: (context, state) => const FitnessEquipmentsPage(),
                ),
              ],
            ),
            ShellRoute(
              navigatorKey: shellRouteNavigatorKey,
              builder: (context, state, child) => HomePage(
                location: state.uri.path,
                child: child,
              ),
              routes: HomePageRoute.routes.entries.map((entry) {
                return GoRoute(
                  parentNavigatorKey: shellRouteNavigatorKey,
                  path: entry.key,
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: entry.value.builder(context, state),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation
                              .drive(CurveTween(curve: Curves.easeInOut)),
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
              parentNavigatorKey: navigatorKey,
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: '/about',
              builder: (context, state) => const AboutPage(),
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: '/login',
              builder: (context, state) => const LoginRegisterPage(
                type: LoginRegisterPageType.login,
              ),
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: '/register',
              builder: (context, state) => const LoginRegisterPage(
                type: LoginRegisterPageType.register,
              ),
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: '/face-registration-guide',
              builder: (context, state) => FaceRegistrationGuidePage(context),
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: '/face-recognition',
              builder: (context, state) => const FaceRecognitionPage(),
            ),
          ],
        );

  final GlobalKey<NavigatorState> shellRouteNavigatorKey;
}
