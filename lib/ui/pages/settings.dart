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
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/preference/implementations/server_url.dart';
import 'package:hsas_h4o5f_app/preference/string_preference.dart';
import 'package:hsas_h4o5f_app/state/app_state.dart';
import 'package:hsas_h4o5f_app/ui/widgets/animated_linear_progress_indicator.dart';
import 'package:hsas_h4o5f_app/ui/widgets/dialog.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, SharedPreferences?>(
        converter: (store) => store.state.sharedPreferences,
        builder: (context, prefs) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(AppLocalizations.of(context)!.settings),
              ),
              SliverPinnedHeader(
                child: AnimatedLinearProgressIndicator(
                  visible: prefs == null,
                ),
              ),
              if (prefs != null)
                SliverList.list(
                  children: [
                    ServerUrlListTile(prefs: prefs),
                  ].mapWithFirstLast((first, last, child) {
                    return SafeArea(
                      top: false,
                      bottom: last,
                      child: child,
                    );
                  }).toList(),
                ),
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
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.serverUrl),
      subtitle: Text(
        widget.prefs.getStringPreference(serverUrlPreference)!,
      ),
      onTap: () async {
        controller.value = TextEditingValue(
          text: widget.prefs.getStringPreference(serverUrlPreference)!,
        );

        void submit(String value) {
          context.popDialog(value != '' ? value : defaultServerUrl);
        }

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
                onSubmitted: (value) => submit(value),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.popDialog(),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                TextButton(
                  onPressed: () => submit(controller.value.text),
                  child: Text(
                    MaterialLocalizations.of(context).okButtonLabel,
                  ),
                ),
              ],
            );
          },
        );

        if (serverUrl != null) {
          final updated = await widget.prefs.setStringPreference(
            serverUrlPreference,
            serverUrl,
          );

          if (updated) {
            try {
              await (await ParseUser.currentUser() as ParseUser).logout();
            } finally {
              if (mounted) {
                // TODO: 优化此处逻辑
                context.go('/');
              }
            }
          } else {
            if (!mounted) return;

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
