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
import 'package:flutter_svg/svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class LogoWithText extends StatelessWidget {
  const LogoWithText({
    Key? key,
    this.size,
    this.fill,
  }) : super(key: key);

  final double? size;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return SvgPicture(
      const AssetBytesLoader('assets/vectors/logo_with_text.svg.vec'),
      width: size,
      height: size,
      colorFilter:
          fill != null ? ColorFilter.mode(fill!, BlendMode.srcIn) : null,
      semanticsLabel: 'HSAS H4o5F',
    );
  }
}
