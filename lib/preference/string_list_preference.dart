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

import 'package:hsas_h4o5f_app/preference/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StringListPreference extends Preference<List<String>> {
  const StringListPreference({
    required super.key,
    super.beforeSetValue,
    super.onValueChanged,
  });
}

extension StringListPreferencesExtension on SharedPreferences {
  Future<bool> setStringListPreference(
    StringListPreference preference,
    List<String> value,
  ) async {
    List<String> finalValue = value;
    if (preference.beforeSetValue != null) {
      final hookResult = preference.beforeSetValue!(value);
      if (hookResult != null) {
        finalValue = hookResult;
      } else {
        return false;
      }
    }
    final result = await setStringList(preference.key, value);
    if (preference.onValueChanged != null && result) {
      preference.onValueChanged!(value);
    }
    return result;
  }

  List<String>? getStringListPreference(StringListPreference preference) {
    return getStringList(preference.key);
  }
}
