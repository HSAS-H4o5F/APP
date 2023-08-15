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

part of '../app_state.dart';

class AppFeedState extends AppState<AppFeed?> {
  const AppFeedState({
    super.key,
    required super.value,
    required super.child,
  });

  static AppStateBuilder<AppFeed?, AppFeedState> builder(AppFeed? value) {
    return AppStateBuilder(
      builder: AppFeedState.new,
      value: value,
    );
  }

  static AppFeed? of(BuildContext context) {
    return AppState.of<AppFeed?, AppFeedState>(context);
  }
}

class AppFeed {
  const AppFeed({
    this.feed,
    this.origins,
  });

  final Feed? feed;
  final Map<String, FeedOriginInfo>? origins;

  static Map<String, FeedOriginInfo> parseFeedOrigins(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    final Map<String, FeedOriginInfo> origins = {};
    map.forEach((key, value) {
      origins[key] = FeedOriginInfo(
        name: value['name'],
        url: Uri.parse(value['url']),
      );
    });
    return origins;
  }
}

class FeedOriginInfo {
  const FeedOriginInfo({
    required this.name,
    required this.url,
  });

  final String name;
  final Uri url;
}
