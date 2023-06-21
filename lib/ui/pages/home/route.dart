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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/lifestyle.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/news.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/profile.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/security.dart';
import 'package:tuple/tuple.dart';

class HomePageRoute {
  final String Function(BuildContext context) title;
  final IconData icon;
  final GoRouterWidgetBuilder builder;

  static Map<String, HomePageRoute> routes = {
    '/home/security': HomePageRoute(
      title: (context) => AppLocalizations.of(context)!.security,
      icon: Icons.security,
      builder: (context, state) => const HomePageSecurity(),
    ),
    '/home/lifestyle': HomePageRoute(
      title: (context) => AppLocalizations.of(context)!.lifestyle,
      icon: Icons.home,
      builder: (context, state) => const HomePageLifestyle(),
    ),
    '/home/news': HomePageRoute(
      title: (context) => AppLocalizations.of(context)!.news,
      icon: Icons.article,
      builder: (context, state) => const HomePageNews(),
    ),
    '/home/profile': HomePageRoute(
      title: (context) => AppLocalizations.of(context)!.profile,
      icon: Icons.person,
      builder: (context, state) => const HomePageProfile(),
    ),
  };

  const HomePageRoute({
    required this.title,
    required this.icon,
    required this.builder,
  });

  Tuple2<NavigationRailDestination, NavigationDestination> getDestinations(
    BuildContext context,
  ) {
    return Tuple2(
      NavigationRailDestination(
        icon: Icon(icon),
        label: Text(title(context)),
      ),
      NavigationDestination(
        icon: Icon(icon),
        label: title(context),
      ),
    );
  }
}
