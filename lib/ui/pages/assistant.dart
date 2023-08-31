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
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';

part 'assistant/face_registration.dart';

/// 引导用户完成一系列步骤的页面。
///
/// 该页面提供了一个顶部标题，一个底部导航栏，以及一个居中的步骤内容。该页面的步骤内容可以通过
/// [AssistantStep] 来定义，每个步骤都可以定义一个过渡动画。
///
/// [title] 为该页面的标题，通常为一个 [Text]。
///
/// [steps] 为该页面的步骤内容，为一个以 [AssistantStep] 为元素的 [List]。
///
/// [onCompleted] 为当用户完成所有步骤时的回调函数。
///
/// [onSkip] 为当用户点击跳过按钮时的回调函数，如果该参数为 `null`，则不会显示跳过按钮。
///
/// 另请参阅：
///
/// * [AssistantStep]
class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    required this.title,
    required this.steps,
    required this.onCompleted,
    this.onSkip,
  });

  final Widget title;
  final List<AssistantStep> steps;
  final void Function() onCompleted;
  final void Function()? onSkip;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage>
    with TickerProviderStateMixin {
  int _currentStepValue = 0;

  int get _currentStep => _currentStepValue;

  set _currentStep(int value) {
    for (final step in _steps) {
      step.exit();
    }
    _currentStepValue = value;
    _steps.add(_builderFrom(widget.steps[_currentStep]));
  }

  final List<_StepBuilder> _steps = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
      ),
      body: Stack(alignment: Alignment.center, children: _steps),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 8,
          children: [
            AnimatedOpacity(
              opacity: _currentStep != 0 ? 1 : 0,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 300),
              child: TextButton.icon(
                onPressed: _currentStep > 0 ? _decreaseStep : null,
                icon: Icon(Icons.adaptive.arrow_back),
                label: Text(AppLocalizations.of(context)!.previous),
              ),
            ),
            if (widget.onSkip != null)
              TextButton.icon(
                onPressed: widget.onSkip,
                icon: const Icon(Icons.skip_next),
                label: Text(AppLocalizations.of(context)!.skip),
              ),
            TextButton.icon(
              onPressed: _increaseStep,
              icon: Icon(Icons.adaptive.arrow_forward),
              label: Text(AppLocalizations.of(context)!.next),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.steps.isEmpty) {
      widget.onCompleted();
      dispose();
      return;
    }
    _steps.add(_builderFrom(widget.steps[_currentStep]));
    super.initState();
  }

  void _decreaseStep() {
    if (_currentStep == 0) return;
    setState(() {
      _currentStep -= 1;
    });
  }

  void _increaseStep() {
    if (_currentStep == widget.steps.length - 1) {
      widget.onCompleted();
      return;
    }
    setState(() {
      _currentStep += 1;
    });
  }

  _StepBuilder _builderFrom(AssistantStep step) {
    return step._builder(
      this,
      (thisStep) {
        setState(() {
          _steps.remove(thisStep);
        });
      },
    );
  }
}

/// [AssistantPage] 的步骤内容。
///
/// [transitionBuilder] 为该步骤的过渡动画，如果该参数为 `null`，则使用默认的过渡动画。
///
/// [animationDuration] 为该步骤的过渡动画的持续时间。
///
/// [reverseAnimationDuration] 为该步骤的反向过渡动画的持续时间。
///
/// [child] 为该步骤的内容。
///
/// 另请参阅：
///
/// * [AssistantPage]
class AssistantStep {
  const AssistantStep({
    this.transitionBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.reverseAnimationDuration = const Duration(milliseconds: 300),
    required this.child,
  });

  final Widget Function(
          BuildContext context, Animation<double> animation, Widget child)?
      transitionBuilder;
  final Duration animationDuration;
  final Duration reverseAnimationDuration;
  final Widget child;

  _StepBuilder _builder(
    TickerProvider vsync,
    void Function(_StepBuilder thisStep) onExitCompleted,
  ) {
    return _StepBuilder(
      this,
      AnimationController(
        vsync: vsync,
        duration: animationDuration,
        reverseDuration: reverseAnimationDuration,
      ),
      onExitCompleted,
    );
  }
}

class _StepBuilder extends StatefulWidget {
  const _StepBuilder(
    this._step,
    this._controller,
    this._onExitCompleted,
  );

  final AssistantStep _step;
  final AnimationController _controller;
  final void Function(_StepBuilder thisStep) _onExitCompleted;

  @override
  State<_StepBuilder> createState() => _StepBuilderState();

  void exit() {
    _controller.reverse();
  }
}

class _StepBuilderState extends State<_StepBuilder>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget._step.transitionBuilder?.call(
          context,
          widget._controller,
          widget._step.child,
        ) ??
        FadeTransition(
          opacity:
              widget._controller.drive(CurveTween(curve: Curves.easeInOut)),
          child: widget._step.child,
        );
  }

  @override
  void initState() {
    widget._controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget._controller.value == 0) {
        widget._onExitCompleted(widget);
      }
    });
    widget._controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }
}
