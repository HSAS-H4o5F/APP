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

import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showStatefulAlertDialog<T>({
  required BuildContext context,
  required StatefulAlertDialogContent Function(
    BuildContext context,
    StateSetter setState,
  ) builder,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final content = builder(context, setState);
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              title: content.title,
              content: content.content,
              actions: content.actions,
            ),
          );
        },
      );
    },
  );
}

class StatefulAlertDialogContent {
  StatefulAlertDialogContent({
    required this.title,
    required this.content,
    required this.actions,
  });

  final Widget title;
  final Widget content;
  final List<Widget> actions;
}

Future<T?> showAlertDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
}) {
  return showStatefulAlertDialog<T>(
    context: context,
    builder: (context, setState) {
      return StatefulAlertDialogContent(
        title: title,
        content: content,
        actions: actions,
      );
    },
  );
}

void popDialog<T extends Object?>(BuildContext context, [T? result]) {
  Navigator.of(context, rootNavigator: true).pop(result);
}
