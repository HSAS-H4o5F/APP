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

part of '../widgets.dart';

typedef ProvidedPreferences = ({
  AppPreferences preferences,
  Future<bool> Function(AppPreferences preferences) update,
});

class PreferencesProvider extends StatefulWidget {
  const PreferencesProvider({
    super.key,
    required this.sharedPreferences,
    required this.child,
  });

  final SharedPreferences sharedPreferences;
  final Widget child;

  static ProvidedPreferences of(BuildContext context) =>
      _PreferencesProviderInherited.of(context);

  @override
  State<PreferencesProvider> createState() => _PreferencesProviderState();
}

class _PreferencesProviderState extends State<PreferencesProvider> {
  late AppPreferences _preferences;

  @override
  Widget build(BuildContext context) {
    return _PreferencesProviderInherited(
      preferences: _preferences,
      update: (AppPreferences preferences) async {
        if (!await preferences.update(widget.sharedPreferences)) return false;

        setState(() {
          _preferences = preferences;
        });
        return true;
      },
      child: widget.child,
    );
  }

  @override
  void initState() {
    _preferences = AppPreferences.from(context, widget.sharedPreferences);
    super.initState();
  }
}

class _PreferencesProviderInherited extends InheritedWidget {
  const _PreferencesProviderInherited({
    required this.preferences,
    required this.update,
    required super.child,
  });

  final AppPreferences preferences;
  final Future<bool> Function(AppPreferences preferences) update;

  static ProvidedPreferences of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_PreferencesProviderInherited>();

    if (provider == null) throw PreferencesProviderNotFoundError();

    return (
      preferences: provider.preferences,
      update: provider.update,
    );
  }

  @override
  bool updateShouldNotify(_PreferencesProviderInherited oldWidget) {
    return preferences != oldWidget.preferences || update != oldWidget.update;
  }
}

class PreferencesProviderNotFoundError extends Error {
  @override
  String toString() => 'Error: PreferencesProvider not found.';
}

enum PreferencesWidgetType {
  normal,
  sliver,
}

class StringPreferenceListTile extends StatefulWidget {
  const StringPreferenceListTile({
    super.key,
    required this.preference,
    required this.onValueUpdate,
    required this.validate,
  });

  final StringPreference preference;
  final void Function(String preference) onValueUpdate;
  final String? Function(String value) validate;

  @override
  State<StringPreferenceListTile> createState() =>
      _StringPreferenceListTileState();
}

class _StringPreferenceListTileState extends State<StringPreferenceListTile> {
  late TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.preference.title!),
      subtitle: Text(widget.preference.value),
      onTap: _onTap,
    );
  }

  void _onTap() async {
    void submit(String value) {
      context.popDialog(value);
    }

    String? errorMessage;

    final newValue = await showStatefulAlertDialog<String>(
      context: context,
      builder: (context, setState) {
        return StatefulAlertDialogContent(
          title: Text(widget.preference.title!),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              errorText: errorMessage,
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                errorMessage = widget.validate(value);
              });
            },
            onSubmitted: submit,
          ),
          actions: [
            TextButton(
              onPressed: () => context.popDialog(),
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
              ),
            ),
            TextButton(
              onPressed: () => submit(_controller.value.text),
              child: Text(
                MaterialLocalizations.of(context).okButtonLabel,
              ),
            ),
          ],
        );
      },
    );

    if (newValue != null) {
      widget.onValueUpdate(newValue);
    }
  }

  @override
  void initState() {
    _controller = TextEditingController(
      text: widget.preference.value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
