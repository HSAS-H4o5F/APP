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

import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/preference/implementations/server_url.dart';
import 'package:hsas_h4o5f_app/preference/string_preference.dart';
import 'package:hsas_h4o5f_app/state/app_state.dart';
import 'package:hsas_h4o5f_app/ui/pages/home/route.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.location,
    required this.child,
  }) : super(key: key);

  final String location;
  final Widget child;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _size = 0;

  @override
  void initState() {
    // TODO: 完善初始化逻辑
    //_initFeed();
    super.initState();
  }

  void _initFeed() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final serverUrl = store.state.sharedPreferences!
        .getStringPreference(serverUrlPreference)!;

    final client = Client();
    final response = await client.get(Uri.parse(serverUrl).replace(
      path: '/feed/origins',
    ));

    (jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final width = MediaQuery.of(context).size.width;
    if (width > mediumWidthBreakpoint) {
      _size = 2;
    } else if (width > smallWidthBreakpoint) {
      _size = 1;
    } else {
      _size = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (_size > 0) ...[
            NavigationRail(
              extended: _size == 2,
              destinations: HomePageRoute.routes.entries
                  .map((entry) => entry.value.getDestinations(context).item1)
                  .toList(),
              selectedIndex: HomePageRoute.routes.entries
                  .toList()
                  .indexWhere((entry) => entry.key == widget.location),
              onDestinationSelected: (index) => context.go(
                HomePageRoute.routes.entries.toList()[index].key,
              ),
              labelType: _size == 1 ? NavigationRailLabelType.all : null,
            ),
          ],
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _size == 0
          ? NavigationBar(
              destinations: HomePageRoute.routes.entries
                  .map((entry) => entry.value.getDestinations(context).item2)
                  .toList(),
              selectedIndex: HomePageRoute.routes.entries
                  .toList()
                  .indexWhere((entry) => entry.key == widget.location),
              onDestinationSelected: (index) => context.go(
                HomePageRoute.routes.entries.toList()[index].key,
              ),
            )
          : null,
    );
  }
}
