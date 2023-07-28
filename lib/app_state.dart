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

import 'package:hsas_h4o5f_app/data/feed.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_state/education_feed.dart';
part 'app_state/feed.dart';
part 'app_state/shared_preferences.dart';

class AppState {
  const AppState({
    this.sharedPreferences,
    this.educationFeed,
    this.feed = const AppFeed(),
  });

  final SharedPreferences? sharedPreferences;
  final Feed? educationFeed;
  final AppFeed feed;
}

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    sharedPreferences: sharedPreferencesReducer(
      state.sharedPreferences,
      action,
    ),
    educationFeed: educationFeedReducer(state.educationFeed, action),
    feed: feedReducer(state.feed, action),
  );
}
