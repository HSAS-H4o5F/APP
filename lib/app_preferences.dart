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
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences/implementations.dart';

part 'app_preferences/string_list_preference.dart';
part 'app_preferences/string_preference.dart';

class AppPreferences {
  const AppPreferences({
    this.serverUrl,
    this.subscribedFeed,
  });

  factory AppPreferences.from(
    BuildContext context,
    SharedPreferences sharedPreferences,
  ) {
    return AppPreferences(
      serverUrl: ServerUrlPreference.from(context, sharedPreferences),
      subscribedFeed: SubscribedFeedPreference.from(sharedPreferences),
    );
  }

  final ServerUrlPreference? serverUrl;
  final SubscribedFeedPreference? subscribedFeed;

  AppPreferences copyWith({
    ServerUrlPreference? serverUrl,
    SubscribedFeedPreference? subscribedFeed,
  }) {
    return AppPreferences(
      serverUrl: serverUrl ?? this.serverUrl,
      subscribedFeed: subscribedFeed ?? this.subscribedFeed,
    );
  }

  Future<bool> update(SharedPreferences sharedPreferences) {
    bool result = true;

    serverUrl
        ?.update(sharedPreferences)
        .then((value) => result = result && value);
    subscribedFeed
        ?.update(sharedPreferences)
        .then((value) => result = result && value);

    return Future.value(result);
  }
}

abstract class Preference<T> {
  const Preference(
    this._updater, {
    required this.key,
    required this.value,
    this.title,
    this.beforeSetValue,
    this.onValueChanged,
  });

  final Future<bool> Function(
    SharedPreferences sharedPreferences,
    String key,
    T value,
  ) _updater;
  final String key;
  final String? title;
  final T value;
  final T? Function(T value)? beforeSetValue;
  final void Function(T value)? onValueChanged;

  Future<bool> update(SharedPreferences sharedPreferences) async {
    final value = this.value;
    if (value == null) {
      return sharedPreferences.remove(key);
    }

    T finalValue = value;
    if (beforeSetValue != null) {
      final hookResult = beforeSetValue!(value);
      if (hookResult != null) {
        finalValue = hookResult;
      } else {
        return false;
      }
    }
    final result = await _updater(sharedPreferences, key, finalValue);
    if (onValueChanged != null && result) {
      onValueChanged!(finalValue);
    }
    return result;
  }
}

class GeneratingPreferenceFromSharedPreferencesError extends Error {
  GeneratingPreferenceFromSharedPreferencesError(this.key);

  final String key;

  @override
  String toString() {
    return 'Generating `Preference` from `SharedPreferences` failed. '
        'Key: $key';
  }
}
