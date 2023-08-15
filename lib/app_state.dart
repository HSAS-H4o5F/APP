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
import 'package:shared_preferences/shared_preferences.dart';

part 'app_state/app_feed.dart';
part 'app_state/education_feed.dart';
part 'app_state/shared_preferences.dart';

abstract class AppState<T> extends InheritedWidget {
  const AppState({
    super.key,
    required this.value,
    required super.child,
  });

  final T value;

  static T of<T, S extends AppState<T>>(BuildContext context) {
    final state = context.dependOnInheritedWidgetOfExactType<S>();

    if (state == null) throw AppStateNotFoundError();

    return state.value;
  }

  @override
  bool updateShouldNotify(AppState oldWidget) => value != oldWidget.value;
}

class AppStateNotFoundError extends Error {
  @override
  String toString() => 'Error: AppState not found.';
}

class AppStateBuilder<T, S extends AppState<T>> {
  const AppStateBuilder({
    required this.builder,
    required this.value,
  });

  final S Function({
    Key? key,
    required T value,
    required Widget child,
  }) builder;
  final T value;

  S build(Widget child) {
    return builder(
      value: value,
      child: child,
    );
  }
}

class AppStateProvider extends StatelessWidget {
  const AppStateProvider({
    super.key,
    required this.builders,
    required this.child,
  });

  final List<AppStateBuilder> builders;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final builder in builders) {
      tree = builder.build(tree);
    }
    return tree;
  }
}
