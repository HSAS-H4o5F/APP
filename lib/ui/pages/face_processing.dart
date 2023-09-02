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
import 'dart:math';
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

  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.faceRecognition),
      ),
      body: _Preview(_initFuture, _controller, _statusMessage),
    );
  }

  @override
  void initState() {
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

        if (data is! Uint8List ||
            data.isEmpty ||
            (data.length != 1 && data.length != 4)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.fetchingError),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).clearSnackBars();

        if (data.length == 1) {
          setState(() {
            switch (data.first) {
              case 0:
                _statusMessage =
                    AppLocalizations.of(context)!.faceDetectionMessage;
                break;
              case 1:
                _statusMessage =
                    AppLocalizations.of(context)!.faceDetectionTooManyMessage;
                break;
              case 2:
                _statusMessage =
                    AppLocalizations.of(context)!.faceDetectionTooSmallMessage;
                break;
              default:
                _statusMessage =
                    AppLocalizations.of(context)!.faceDetectionMessage;
                break;
            }
          });
          return;
        }

        setState(() {
          _statusMessage =
              AppLocalizations.of(context)!.faceDetectionProcessingMessage;
        });
      });

      _controller.startImageStream((image) async {
        if (lock) return;
        lock = true;

        if (image.format.group == ImageFormatGroup.unknown) {
          showAlertDialog(
            context: context,
            barrierDismissible: false,
            title: Text(AppLocalizations.of(context)!.error),
            content:
                Text(AppLocalizations.of(context)!.cameraStreamFormatError),
            actions: [
              TextButton(
                onPressed: () {
                  clean();
                  context.popDialog();
                  context.pop();
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
          return;
        }

        int width = image.width;
        int height = image.height;
        List<int> bytes = image.planes[0].bytes.toList();

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

        bytes.add(image.format.group.index - 1);

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

class _Preview extends StatelessWidget {
  const _Preview(this._initFuture, this._controller, this._statusMessage);

  final Future<void> _initFuture;
  final CameraController _controller;
  final String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _PreviewLayoutDelegate(),
      children: [
        LayoutId(
          id: #preview,
          child: ClipPath.shape(
            shape: const CircleBorder(),
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

                    return SquareCameraPreview(_controller);
                }
              },
            ),
          ),
        ),
        LayoutId(
          id: #statusText,
          child: Text(
            _statusMessage ??
                AppLocalizations.of(context)!.faceDetectionMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _PreviewLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    const padding = 8;
    const minLandscapeSpace = 800;
    final maxPreviewSize = size.shortestSide;
    final minPreviewSize = size.shortestSide * 0.65;

    Size textSize = Size.zero;
    Size previewSize = Size.zero;

    Offset textOffset = Offset.zero;
    Offset previewOffset = Offset.zero;

    if (size.height >= maxPreviewSize ||
        size.width - maxPreviewSize < minLandscapeSpace) {
      final textDisplayWidth = size.width - padding * 2;
      textSize = layoutChild(
        #statusText,
        BoxConstraints(
          minWidth: textDisplayWidth,
          maxWidth: textDisplayWidth,
          maxHeight: size.height - minPreviewSize - padding,
        ),
      );

      final maxPreviewDisplaySize = min(
        size.height - textSize.height - padding,
        maxPreviewSize,
      );

      previewSize = layoutChild(
        #preview,
        BoxConstraints(
          minWidth: minPreviewSize,
          maxWidth: maxPreviewDisplaySize,
          minHeight: minPreviewSize,
          maxHeight: maxPreviewDisplaySize,
        ),
      );

      textOffset = Offset(
        (size.width - textSize.width) / 2,
        padding + (size.height - textSize.height - previewSize.height) * 0.8,
      );

      previewOffset = Offset(
        (size.width - previewSize.width) / 2,
        textSize.height + textOffset.dy,
      );
    } else {
      previewSize = layoutChild(
        #preview,
        BoxConstraints.tightFor(
          width: maxPreviewSize,
          height: maxPreviewSize,
        ),
      );

      final textDisplayWidth = (size.width - previewSize.width) / 2 - padding;
      textSize = layoutChild(
        #statusText,
        BoxConstraints(
          minWidth: textDisplayWidth,
          maxWidth: textDisplayWidth,
          maxHeight: size.height - padding * 2,
        ),
      );

      previewOffset = Offset((size.width - previewSize.width) / 2, 0);

      textOffset = Offset(
        previewOffset.dx - textSize.width - padding,
        (size.height - textSize.height) / 2,
      );
    }

    positionChild(#statusText, textOffset);
    positionChild(#preview, previewOffset);
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}

enum FaceProcessingMode {
  registration,
  recognition,
}
