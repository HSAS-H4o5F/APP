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
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/widgets.dart';
import 'package:hsas_h4o5f_app/vectors.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _packageInfoFuture = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverBlurredLargeAppBar(
            title: Text(AppLocalizations.of(context)!.about),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 256,
              child: AspectRatio(
                aspectRatio: 1,
                child: LogoWithText(
                  fill: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onBackground
                      : null,
                ),
              ),
            ),
          ),
          SliverList.list(
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.version),
                subtitle: FutureBuilder(
                  future: _packageInfoFuture,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return Text(AppLocalizations.of(context)!.loading);
                      case ConnectionState.done:
                        return Text((snapshot.data as PackageInfo).version);
                      default:
                        return Text(AppLocalizations.of(context)!.unknown);
                    }
                  },
                ),
              ),
              // TODO: 增加更多信息
              ListTile(
                title: Text(AppLocalizations.of(context)!.openSourceLicenses),
                subtitle: Text(AppLocalizations.of(context)!.license),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
