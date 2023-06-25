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

import 'dart:convert';

import 'package:hsas_h4o5f_app/data/feed.dart';
import 'package:redux/redux.dart';

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

AppFeed _setFeed(
  AppFeed feed,
  SetFeedAction action,
) {
  return AppFeed(
    feed: action.feed.feed ?? feed.feed,
    origins: action.feed.origins ?? feed.origins,
  );
}

class SetFeedAction {
  const SetFeedAction(this.feed);

  final AppFeed feed;
}

final feedReducer = combineReducers<AppFeed>([
  TypedReducer<AppFeed, SetFeedAction>(_setFeed),
]);
