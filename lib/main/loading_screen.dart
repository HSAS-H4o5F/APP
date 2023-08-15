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

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    required this.future,
    required this.onAnimationCompleted,
  });

  final Future<void> future;
  final VoidCallback onAnimationCompleted;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressIndicatorController;
  late final AnimationController _pageTransitionController;
  late final AnimationStatusListener _pageTransitionStatusListener;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: ReverseAnimation(_pageTransitionController)
          .drive(CurveTween(curve: Curves.easeInOut)),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Logo(
                    size:
                        max(constraints.maxWidth, constraints.maxHeight) * 0.15,
                    fill: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.1,
                  ),
                  ClipPath.shape(
                    shape: const StadiumBorder(),
                    child: Container(
                      width: constraints.maxWidth * 0.5,
                      height: constraints.maxWidth * 0.02,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(-1, 0),
                          end: const Offset(0, 0),
                        ).animate(
                          CurvedAnimation(
                            parent: _progressIndicatorController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: ClipPath.shape(
                          shape: const StadiumBorder(),
                          child: Container(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    _pageTransitionStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationCompleted();

        _pageTransitionController
            .removeStatusListener(_pageTransitionStatusListener);

        _progressIndicatorController.dispose();
        _pageTransitionController.dispose();
      }
    };

    _progressIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..animateTo(0.9);
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addStatusListener(_pageTransitionStatusListener);

    widget.future.then((_) => {
          _progressIndicatorController.forward(),
          _pageTransitionController.forward(),
        });

    super.initState();
  }
}
