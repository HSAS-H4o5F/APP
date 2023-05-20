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

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

const defaultServerUrl = 'http://127.0.0.1:1337';

const double smallWidthBreakpoint = 450;
const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;

extension IfNotNull<T, R> on T? {
  R? ifNotNull(R? Function(T value) f) {
    if (this != null) {
      return f(this as T);
    }
    return null;
  }
}

extension CompareTimeOfDay on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour == other.hour) {
      return minute.compareTo(other.minute);
    }
    return hour.compareTo(other.hour);
  }
}

extension MapIndexed<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T value) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }

  Iterable<E> mapWithFirstLast<E>(
      E Function(
        bool first,
        bool last,
        T value,
      ) f) {
    var index = -1;
    return map((e) {
      index += 1;
      return f(index == 0, index == length - 1, e);
    });
  }
}
