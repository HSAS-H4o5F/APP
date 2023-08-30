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
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/widgets.dart';
import 'package:hsas_h4o5f_app/utils.dart';
import 'package:socket_io_client/socket_io_client.dart';

class FaceRecognitionPage extends StatefulWidget {
  const FaceRecognitionPage({Key? key}) : super(key: key);

  @override
  State<FaceRecognitionPage> createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  late final Future<void> _initFuture;
  late final List<CameraDescription> _cameras;
  late final CameraController _controller;
  late final Socket _socket;

  bool _rotationError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.faceRecognition),
      ),
      body: FutureBuilder(
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
                // TODO: 处理错误
                return const SizedBox();
              }
              // TODO: 优化相机授权
              // TODO: 增加文字提示
              return Align(
                alignment: const Alignment(0, -0.75),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FractionallySizedBox(
                    widthFactor: 0.75,
                    heightFactor: 0.75,
                    child: CircleCameraPreview(_controller),
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    _initFuture = _init();
    super.initState();
  }

  Future<void> _init() async {
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

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );

    if (!mounted) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cameraInitError),
        ),
      );
      return;
    }

    _socket.on('success', (_) {
      bool lock = false;

      _socket.on('detection', (data) {
        lock = false;
        print(data);
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
            return;
        }

        if (Platform.isAndroid) {
          // TODO: 这种方式仍存在很多问题，可想办法使用 CameraX 来解决
          // TODO: 包括等待 Flutter CameraX 插件稳定和自行编写
          int screenRotation = await getScreenRotation();
          if (screenRotation == -1) {
            _rotationError = true;
            screenRotation = 0;
          } else {
            _rotationError = false;
          }

          final rotation = (screenRotation -
                  360 +
                  _controller.description.sensorOrientation) %
              360;

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
