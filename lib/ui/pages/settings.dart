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
import 'package:hsas_h4o5f_app/app_state.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/preference/implementations/server_url.dart';
import 'package:hsas_h4o5f_app/preference/string_preference.dart';
import 'package:hsas_h4o5f_app/ui/widgets/animated_linear_progress_indicator.dart';
import 'package:hsas_h4o5f_app/ui/widgets/app_bar.dart';
import 'package:hsas_h4o5f_app/ui/widgets/dialog.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';

part 'settings/server_url.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? _sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverBlurredLargeAppBar(
            title: Text(AppLocalizations.of(context)!.settings),
          ),
          SliverPinnedHeader(
            child: AnimatedLinearProgressIndicator(
              visible: _sharedPreferences == null,
            ),
          ),
          if (_sharedPreferences != null)
            SliverList.list(
              children: [
                ServerUrlSetting(prefs: _sharedPreferences!),
              ].mapWithFirstLast((first, last, child) {
                return SafeArea(
                  top: false,
                  bottom: last,
                  child: child,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _sharedPreferences = SharedPreferencesState.of(context);
    super.didChangeDependencies();
  }
}
