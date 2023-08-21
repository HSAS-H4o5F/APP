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

class BlurredAppBar extends AppBar {
  BlurredAppBar({
    super.key,
    super.leading,
    super.title,
    super.actions,
  }) : super(
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(),
            ),
          ),
        );
}

class SliverBlurredLargeAppBar extends StatelessWidget {
  const SliverBlurredLargeAppBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
  });

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    ScaffoldState? scaffold = Scaffold.maybeOf(context);
    ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    Widget? leading = this.leading;

    if (leading == null && automaticallyImplyLeading) {
      if (scaffold?.hasDrawer == true) {
        leading = const DrawerButton();
      } else if ((scaffold?.hasEndDrawer == false &&
              parentRoute?.canPop == true) ||
          (parentRoute?.impliesAppBarDismissal == true)) {
        leading =
            parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog
                ? const CloseButton()
                : const BackButton();
      }
    }

    return SliverStack(
      children: [
        SliverAppBar.large(
          automaticallyImplyLeading: false,
          flexibleSpace: ClipRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        SliverAppBar.large(
          leading: leading,
          automaticallyImplyLeading: false,
          title: title,
          actions: actions,
          surfaceTintColor: Colors.transparent,
          backgroundColor:
              Theme.of(context).colorScheme.background.withOpacity(0),
        ),
      ],
    );
  }
}
