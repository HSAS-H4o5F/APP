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

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/widgets.dart';
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
    _initFuture = _initCamera();
    super.initState();
  }

  Future<void> _initCamera() async {
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

    if (!mounted) {
      return;
    }

    final client = io(
      PreferencesProvider.of(context).preferences.serverUrl!.value,
      OptionBuilder().setPath('/face').setExtraHeaders({
        'api-version': '1',
        'accept-language': Localizations.localeOf(context).languageCode,
      }).setTransports(['websocket']).build(),
    );

    client.on('success', (data) {
      _controller.startImageStream((image) {
        switch (image.format.group) {
          case ImageFormatGroup.yuv420:
            client.emit("detection", image.planes[0].bytes);
            break;
          case ImageFormatGroup.bgra8888:
            break;
          case ImageFormatGroup.jpeg:
            break;
          case ImageFormatGroup.nv21:
            break;
          case ImageFormatGroup.unknown:
            break;
        }
      });
    });

    client.emit("request", "detection");

    await _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
