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

class ProvideScreenOrientation extends StatefulWidget {
  const ProvideScreenOrientation({
    super.key,
    required this.builder,
  });

  final Widget Function(DeviceOrientation? orientation) builder;

  @override
  State<ProvideScreenOrientation> createState() =>
      _ProvideScreenOrientationState();
}

class _ProvideScreenOrientationState extends State<ProvideScreenOrientation> {
  final _screenOrientationChannel =
      const MethodChannel('hsas_h4o5f_app/screen_orientation');

  DeviceOrientation? _orientation;

  @override
  Widget build(BuildContext context) {
    return widget.builder(_orientation);
  }

  @override
  void initState() {
    _screenOrientationChannel.setMethodCallHandler(_onMethodCall);
    _screenOrientationChannel.invokeMethod('getOrientation').then((value) {
      setState(() {
        _orientation = DeviceOrientation.values[value as int];
      });
    });
    super.initState();
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'updateOrientation':
        setState(() {
          _orientation = DeviceOrientation.values[call.arguments as int];
        });
        break;
      default:
        break;
    }
  }
}
