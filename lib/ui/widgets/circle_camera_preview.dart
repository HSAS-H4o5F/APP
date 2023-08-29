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

class CircleCameraPreview extends StatelessWidget {
  const CircleCameraPreview(
    CameraController controller, {
    super.key,
  }) : _controller = controller;

  final CameraController _controller;

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? NativeDeviceOrientationReader(
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final aspectRatio = value.isPortrait
                      ? 1 / value.aspectRatio
                      : value.aspectRatio;

                  return ClipPath.shape(
                    shape: const CircleBorder(),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final widgetSize = constraints.biggest.shortestSide;

                          return OverflowBox(
                            maxWidth: double.infinity,
                            maxHeight: double.infinity,
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.none,
                              child: SizedBox(
                                width: aspectRatio > 1
                                    ? widgetSize * aspectRatio
                                    : widgetSize,
                                height: aspectRatio < 1
                                    ? widgetSize / aspectRatio
                                    : widgetSize,
                                child: CameraPreview(_controller),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          )
        : const SizedBox();
  }
}
