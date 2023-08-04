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

class DirectionalSafeArea extends StatelessWidget {
  const DirectionalSafeArea({
    super.key,
    this.start = true,
    this.top = true,
    this.end = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    required this.child,
  });

  final bool start;

  final bool top;

  final bool end;

  final bool bottom;

  final EdgeInsets minimum;

  final bool maintainBottomViewPadding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    return SafeArea(
      key: key,
      left: textDirection == TextDirection.ltr ? start : end,
      top: top,
      right: textDirection == TextDirection.ltr ? end : start,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}
