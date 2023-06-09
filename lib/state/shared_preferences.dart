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

import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences _setSharedPreferences(
  SharedPreferences? sharedPreferences,
  SetSharedPreferencesAction action,
) {
  return action.sharedPreferences;
}

class SetSharedPreferencesAction {
  const SetSharedPreferencesAction(this.sharedPreferences);

  final SharedPreferences sharedPreferences;
}

final sharedPreferencesReducer = combineReducers<SharedPreferences?>([
  TypedReducer<SharedPreferences?, SetSharedPreferencesAction>(
    _setSharedPreferences,
  ),
]);
