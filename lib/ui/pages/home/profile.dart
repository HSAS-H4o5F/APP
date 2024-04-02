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

part of '../home.dart';

class HomePageProfile extends StatefulWidget {
  const HomePageProfile({super.key});

  @override
  State<HomePageProfile> createState() => _HomePageProfileState();
}

class _HomePageProfileState extends State<HomePageProfile> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverBlurredLargeAppBar(
          title: Text(AppLocalizations.of(context)!.profile),
        ),
        SliverList.list(
          children: [
            const ListTile(
              title: Text(''),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () async {
                try {
                  await (await ParseUser.currentUser() as ParseUser).logout();
                } finally {
                  if (mounted) {
                    context.go('/');
                  }
                }
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                context.push('/settings');
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.about),
              onTap: () {
                context.push('/about');
              },
            ),
          ],
        ),
      ],
    );
  }
}
