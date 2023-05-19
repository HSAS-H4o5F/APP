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
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class HomePageProfile extends StatefulWidget {
  const HomePageProfile({Key? key}) : super(key: key);

  @override
  State<HomePageProfile> createState() => _HomePageProfileState();
}

class _HomePageProfileState extends State<HomePageProfile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await (await ParseUser.currentUser() as ParseUser).logout();
              } finally {
                if (mounted) {
                  context.go('/');
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.logout),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.push('/settings');
            },
            child: Text(AppLocalizations.of(context)!.settings),
          )
        ],
      ),
    );
  }
}
