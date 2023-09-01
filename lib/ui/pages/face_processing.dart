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

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/widgets.dart';
import 'package:hsas_h4o5f_app/utils.dart';
import 'package:socket_io_client/socket_io_client.dart';

class FaceProcessingPage extends StatefulWidget {
  const FaceProcessingPage({
    super.key,
    required this.mode,
  });

  final FaceProcessingMode mode;

  @override
  State<FaceProcessingPage> createState() => _FaceProcessingPageState();
}

class _FaceProcessingPageState extends State<FaceProcessingPage> {
  late final Future<void> _initFuture;
  late final List<CameraDescription> _cameras;
  late final CameraController _controller;
  late final Socket _socket;

  late String _statusMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.faceRecognition),
      ),
      body: Align(
        alignment: const Alignment(0, -0.75),
        child: FractionallySizedBox(
          widthFactor: 0.75,
          heightFactor: 0.75,
          child: AspectRatio(
            aspectRatio: 1,
            child: FutureBuilder(
              future: _initFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    }

                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runAlignment: WrapAlignment.center,
                      runSpacing: 16,
                      children: [
                        ClipPath.shape(
                          shape: const CircleBorder(),
                          child: SquareCameraPreview(_controller),
                        ),
                        Text(
                          _statusMessage,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _statusMessage = AppLocalizations.of(context)!.faceDetectionMessage;
    _initFuture = _init();
    super.initState();
  }

  Future<void> _init() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return await showAlertDialog(
        context: context,
        barrierDismissible: false,
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(AppLocalizations.of(context)!.cameraSupportMessage),
        actions: [
          TextButton(
            onPressed: () {
              context.popDialog();
              context.pop();
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    }

    _cameras = (await availableCameras())
      ..sort((a, b) {
        if (a.lensDirection == b.lensDirection) {
          return 0;
        } else if (a.lensDirection == CameraLensDirection.front) {
          return -1;
        } else if (b.lensDirection == CameraLensDirection.front) {
          return 1;
        } else if (a.lensDirection == CameraLensDirection.external) {
          return -1;
        } else if (b.lensDirection == CameraLensDirection.external) {
          return 1;
        } else {
          return 0;
        }
      });

    if (!mounted) return;

    if (_cameras.isEmpty) {
      return await showAlertDialog(
        context: context,
        barrierDismissible: false,
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(AppLocalizations.of(context)!.noAvailableCamera),
        actions: [
          TextButton(
            onPressed: () {
              context.popDialog();
              context.pop();
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    }

    // TODO: 优化相机授权
    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );

    _socket = io(
      PreferencesProvider.of(context).preferences.serverUrl!.value,
      OptionBuilder()
          .setPath('/face')
          .setExtraHeaders({
            'api-version': '1',
            'accept-language': Localizations.localeOf(context).languageCode,
          })
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    )..connect();

    try {
      await _controller.initialize();
    } catch (e) {
      if (!mounted) return;
      clean();
      return await showAlertDialog(
        context: context,
        barrierDismissible: false,
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(AppLocalizations.of(context)!.cameraInitError),
        actions: [
          TextButton(
            onPressed: () {
              context.popDialog();
              context.pop();
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    }

    _socket.on('success', (_) {
      bool lock = false;
      bool rotationError = false;

      _socket.on('detection', (data) {
        lock = false;

        if (data is! Uint8List) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.fetchingError),
            ),
          );
          return;
        }

        if (data == [0]) {
          _statusMessage = AppLocalizations.of(context)!.faceDetectionMessage;
          return;
        }

        if (data == [1]) {
          _statusMessage =
              AppLocalizations.of(context)!.faceDetectionTooManyMessage;
          return;
        }

        if (data == [2]) {
          _statusMessage =
              AppLocalizations.of(context)!.faceDetectionTooSmallMessage;
          return;
        }

        _statusMessage =
            AppLocalizations.of(context)!.faceDetectionProcessingMessage;
      });

      _controller.startImageStream((image) async {
        if (lock) return;
        lock = true;

        int width = image.width;
        int height = image.height;
        List<int> bytes;

        switch (image.format.group) {
          case ImageFormatGroup.yuv420:
            bytes = image.planes[0].bytes.toList();
            break;
          case ImageFormatGroup.bgra8888:
            bytes = image.planes[0].bytes.toList();
            break;
          default:
            // TODO: 支持更多格式
            return;
        }

        if (Platform.isAndroid) {
          // TODO: 这种方式仍存在很多问题，可想办法使用 CameraX 来解决
          // TODO: 包括等待 Flutter CameraX 插件稳定和自行编写
          int screenRotation = await getScreenRotation();
          if (screenRotation == -1) {
            if (!rotationError && mounted) {
              rotationError = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.cameraStreamRotationError),
                  duration: const Duration(seconds: 5),
                ),
              );
            }

            screenRotation = 0;
          } else {
            rotationError = false;
          }

          final sensorOrientation = _controller.description.sensorOrientation;
          final rotation = (screenRotation - 360 + sensorOrientation) % 360;

          if (rotation == 180) {
            bytes = bytes.reversed.toList();
          } else if (rotation != 0) {
            List<int> temp = [];
            if (rotation == 90) {
              for (int i = 0; i < width; i++) {
                for (int j = height - 1; j >= 0; j--) {
                  temp.add(bytes[j * width + i]);
                }
              }
            } else if (rotation == 270) {
              for (int i = width - 1; i >= 0; i--) {
                for (int j = 0; j < height; j++) {
                  temp.add(bytes[j * width + i]);
                }
              }
            }

            width = image.height;
            height = image.width;
            bytes = temp;
          }
        }

        if (width > height) {
          List<int> temp = [];
          for (int i = 0; i < height; i++) {
            temp.addAll(bytes.sublist(
              i * width + (width - height) ~/ 2,
              i * width + height + (width - height) ~/ 2,
            ));
          }
          bytes = temp;
        } else if (width < height) {
          bytes = bytes.sublist(
            (height - width) ~/ 2 * width,
            (height - width) ~/ 2 * width + width * width,
          );
        }

        _socket.emit('detection', Uint8List.fromList(bytes));
      });
    });

    _socket.emit('request', {
      'operation': 'detection',
    });
  }

  void clean() {
    _controller.stopImageStream();
    _controller.dispose();
    _socket.dispose();
  }

  @override
  void dispose() {
    clean();
    super.dispose();
  }
}

enum FaceProcessingMode {
  registration,
  recognition,
}
