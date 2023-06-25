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
import 'package:flutter_redux/flutter_redux.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/state/app_state.dart';
import 'package:hsas_h4o5f_app/state/feed.dart';
import 'package:hsas_h4o5f_app/ui/widgets/animated_linear_progress_indicator.dart';
import 'package:hsas_h4o5f_app/ui/widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomePageNews extends StatefulWidget {
  const HomePageNews({Key? key}) : super(key: key);

  @override
  State<HomePageNews> createState() => _HomePageNewsState();
}

class _HomePageNewsState extends State<HomePageNews> {
  bool _fetching = false;
  final List<String> _unselectedOrigins = [];

  void showFilterDialog() {
    showStatefulAlertDialog(
      context: context,
      builder: (context, setState) {
        return StatefulAlertDialogContent(
          title: Text(AppLocalizations.of(context)!.filter),
          content: StoreConnector<
              AppState,
              ({
                Map<String, FeedOriginInfo> origins,
                SharedPreferences? prefs,
              })>(
            converter: (store) => (
              origins: store.state.feed.origins ?? {},
              prefs: store.state.sharedPreferences,
            ),
            builder: (context, state) {
              return Wrap(
                spacing: 4,
                runSpacing: 4,
                children: state.origins.entries.map((entry) {
                  final key = entry.key;
                  final origin = entry.value;

                  return FilterChip(
                    label: Text(origin.name),
                    selected: !_unselectedOrigins.contains(key),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _unselectedOrigins.remove(key);
                        } else {
                          _unselectedOrigins.add(key);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => context.popDialog(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {},
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(AppLocalizations.of(context)!.news),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _fetching = !_fetching;
                });
              },
              tooltip: AppLocalizations.of(context)!.refresh,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: showFilterDialog,
              tooltip: AppLocalizations.of(context)!.filter,
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        SliverPinnedHeader(
          child: AnimatedLinearProgressIndicator(visible: _fetching),
        ),
      ],
    );
  }
}
