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

import 'package:flutter/material.dart';
import 'package:hsas_h4o5f_app/data/feed.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_state/education_feed.dart';
part 'app_state/feed.dart';
part 'app_state/shared_preferences.dart';

class AppState {
  const AppState({
    required this.update,
    this.sharedPreferences,
    this.educationFeed,
    this.feed = const AppFeed(),
  });

  final void Function(AppState newValue) update;

  final SharedPreferences? sharedPreferences;
  final Feed? educationFeed;
  final AppFeed feed;

  AppState copyWith({
    SharedPreferences? sharedPreferences,
    Feed? educationFeed,
    AppFeed? feed,
  }) {
    return AppState(
      update: update,
      sharedPreferences: sharedPreferences ?? this.sharedPreferences,
      educationFeed: educationFeed ?? this.educationFeed,
      feed: feed ?? this.feed,
    );
  }
}

class GlobalState extends StatefulWidget {
  const GlobalState({
    super.key,
    this.init,
    required this.child,
  });

  final void Function(AppState state)? init;
  final Widget child;

  static AppState of(BuildContext context) => _GlobalStateHolder.of(context);

  @override
  State<GlobalState> createState() => _GlobalStateState();
}

class _GlobalStateState extends State<GlobalState> {
  late AppState state;

  @override
  Widget build(BuildContext context) {
    return _GlobalStateHolder(
      state: state,
      child: widget.child,
    );
  }

  @override
  void initState() {
    state = AppState(
      update: (newValue) => setState(() => state = newValue),
    );
    widget.init?.call(state);

    super.initState();
  }
}

class _GlobalStateHolder extends InheritedWidget {
  const _GlobalStateHolder({
    required this.state,
    required super.child,
  });

  final AppState state;

  static AppState of(BuildContext context) {
    final holder =
        context.dependOnInheritedWidgetOfExactType<_GlobalStateHolder>();

    if (holder == null) throw GlobalStateNotFoundError();

    return holder.state;
  }

  @override
  bool updateShouldNotify(_GlobalStateHolder oldWidget) {
    return oldWidget.state.sharedPreferences != state.sharedPreferences ||
        oldWidget.state.educationFeed != state.educationFeed ||
        oldWidget.state.feed != state.feed;
  }
}

class GlobalStateNotFoundError extends Error {
  @override
  String toString() => 'Error: GlobalStateProvider not found.';
}
