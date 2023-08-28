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

part of '../main.dart';

class FutureScreen extends StatelessWidget {
  const FutureScreen({
    super.key,
    required this.future,
    required this.builder,
  });

  final Future<void> future;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const SizedBox();
          case ConnectionState.none:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      snapshot.error.toString(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              );
            } else {
              return builder();
            }
        }
      },
    );
  }
}
