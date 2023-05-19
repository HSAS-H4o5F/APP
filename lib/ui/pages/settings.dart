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
import 'package:hsas_h4o5f_app/preference/extension.dart';
import 'package:hsas_h4o5f_app/preference/implementations/server_url.dart';
import 'package:hsas_h4o5f_app/state/app_state.dart';
import 'package:hsas_h4o5f_app/ui/widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: StoreConnector<AppState, SharedPreferences?>(
        converter: (store) => store.state.sharedPreferences,
        builder: (context, prefs) {
          if (prefs == null) return const SizedBox.shrink();

          return ListView(
            children: [
              ServerUrlListTile(prefs: prefs),
            ],
          );
        },
      ),
    );
  }
}

class ServerUrlListTile extends StatefulWidget {
  const ServerUrlListTile({
    Key? key,
    required this.prefs,
  }) : super(key: key);

  final SharedPreferences prefs;

  @override
  State<ServerUrlListTile> createState() => _ServerUrlListTileState();
}

class _ServerUrlListTileState extends State<ServerUrlListTile> {
  void _submit(String value) {
    popDialog(
      context,
      value != '' ? value : defaultServerUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.serverUrl),
      subtitle: Text(
        widget.prefs.getStringPreference(serverUrlPreference)!,
      ),
      onTap: () async {
        final controller = TextEditingController(
          text: widget.prefs.getStringPreference(serverUrlPreference) ?? '',
        );

        bool validated = true;

        final serverUrl = await showStatefulAlertDialog<String>(
          context: context,
          builder: (context, setState) {
            return StatefulAlertDialogContent(
              title: Text(AppLocalizations.of(context)!.serverUrl),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  errorText: validated
                      ? null
                      : AppLocalizations.of(context)!.formatError,
                ),
                keyboardType: TextInputType.url,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    validated = validateServerUrl(controller.value.text);
                  });
                },
                onSubmitted: (value) => _submit(value),
              ),
              actions: [
                TextButton(
                  onPressed: () => popDialog(context),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                TextButton(
                  onPressed: () => _submit(controller.value.text),
                  child: Text(
                    MaterialLocalizations.of(context).okButtonLabel,
                  ),
                ),
              ],
            );
          },
        );

        controller.dispose();

        if (serverUrl != null) {
          final updated = await widget.prefs.setStringPreference(
            serverUrlPreference,
            serverUrl,
          );

          if (!mounted) return;

          if (!updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.formatError),
              ),
            );

            return;
          }
          setState(() {});
        }
      },
    );
  }
}
