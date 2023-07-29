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

import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/app_state.dart';
import 'package:hsas_h4o5f_app/data/feed.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/preference/implementations/server_url.dart';
import 'package:hsas_h4o5f_app/preference/string_preference.dart';
import 'package:hsas_h4o5f_app/ui/widgets/animated_linear_progress_indicator.dart';
import 'package:hsas_h4o5f_app/ui/widgets/app_bar.dart';
import 'package:hsas_h4o5f_app/ui/widgets/dialog.dart';
import 'package:hsas_h4o5f_app/ui/widgets/safe_area.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher.dart';

part 'home/fitness_equipments.dart';
part 'home/guide_dogs.dart';
part 'home/lifestyle.dart';
part 'home/medical_care.dart';
part 'home/mutual_aid.dart';
part 'home/news.dart';
part 'home/profile.dart';
part 'home/route.dart';
part 'home/security.dart';

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
  AppFeed? _appFeed;
  Feed? _educationFeed;

  int _size = 0;

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      builders: [
        AppFeedState.builder(_appFeed),
        EducationFeedState.builder(_educationFeed),
      ],
      child: Scaffold(
        body: Row(
          children: [
            if (_size > 0) ...[
              NavigationRail(
                extended: _size == 2,
                destinations: HomePageRoute.routes.entries
                    .map((entry) => entry.value.getDestinations(context).$1)
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
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: NavigationBar(
                    destinations: HomePageRoute.routes.entries
                        .map((entry) => entry.value.getDestinations(context).$2)
                        .toList(),
                    selectedIndex: HomePageRoute.routes.entries
                        .toList()
                        .indexWhere((entry) => entry.key == widget.location),
                    onDestinationSelected: (index) => context.go(
                      HomePageRoute.routes.entries.toList()[index].key,
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              )
            : null,
        extendBody: true,
      ),
    );
  }

  void _initFeed() async {
    final serverUrl = SharedPreferencesState.of(context)!
        .getStringPreference(serverUrlPreference)!;

    final client = Client();

    Response? response;
    Object? error;
    try {
      response = await client.get(Uri.parse(serverUrl).replace(
        path: '/feed/origins',
      ));
    } catch (e) {
      error = e;
    } finally {
      client.close();
    }

    if (!mounted) return;

    if (error != null || response?.statusCode != HttpStatus.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fetchingError),
        ),
      );
      return;
    }

    final origins = AppFeed.parseFeedOrigins(response!.body);
    _appFeed = AppFeed(origins: origins);
  }

  void _initEducationFeed() async {
    final serverUrl = SharedPreferencesState.of(context)!
        .getStringPreference(serverUrlPreference)!;

    final client = Client();

    final Response response;

    try {
      response = await client.get(Uri.parse(serverUrl).replace(
        path: '/feed',
        queryParameters: {'origin': 'zhihu'},
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fetchingError)),
      );
      return;
    } finally {
      client.close();
    }

    _educationFeed = Feed.fromJson(response.body);
  }

  @override
  void didChangeDependencies() {
    _initFeed();
    _initEducationFeed();

    final width = MediaQuery.of(context).size.width;
    if (width > mediumWidthBreakpoint) {
      _size = 2;
    } else if (width > smallWidthBreakpoint) {
      _size = 1;
    } else {
      _size = 0;
    }

    super.didChangeDependencies();
  }
}
