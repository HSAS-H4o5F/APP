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

part of '../implementations.dart';

const _serverUrlPreferenceKey = 'serverUrl';

class ServerUrlPreference extends StringPreference {
  ServerUrlPreference(BuildContext context, String value)
      : super(
          key: _serverUrlPreferenceKey,
          title: AppLocalizations.of(context)?.serverUrl,
          value: value,
          beforeSetValue: validateServerUrl,
          onValueChanged: initParse,
        );

  factory ServerUrlPreference.from(
    BuildContext context,
    SharedPreferences sharedPreferences,
  ) {
    final value = sharedPreferences.getString(_serverUrlPreferenceKey);
    if (value == null) {
      throw GeneratingPreferenceFromSharedPreferencesError(
        _serverUrlPreferenceKey,
      );
    }
    return ServerUrlPreference(context, value);
  }

  static bool check(SharedPreferences sharedPreferences) {
    return sharedPreferences.containsKey(_serverUrlPreferenceKey);
  }

  StringPreferenceListTile listTile(BuildContext context) {
    return StringPreferenceListTile(
      preference: this,
      onValueUpdate: (value) async {
        final preferences = PreferencesProvider.of(context);
        final result = await preferences.update(
          preferences.preferences.copyWith(
            serverUrl: ServerUrlPreference(context, value),
          ),
        );

        if (context.mounted && result) {
          try {
            await (await ParseUser.currentUser() as ParseUser).logout();
          } finally {
            // TODO: 优化此处逻辑
            context.go('/');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error),
            ),
          );
        }
      },
      validate: (value) {
        final result = validateServerUrl(value);
        if (result == null) {
          return AppLocalizations.of(context)?.formatError;
        } else {
          return null;
        }
      },
    );
  }
}

String? validateServerUrl(String value) {
  try {
    final uri = Uri.parse(value);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
    ).toString();
  } catch (e) {
    return null;
  }
}
