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

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:hsas_h4o5f_app/data/serializers.dart';

// Generated using `dart run build_runner build`.
part 'feed.g.dart';

abstract class Feed implements Built<Feed, FeedBuilder> {
  static Serializer<Feed> get serializer => _$feedSerializer;

  int get version;
  BuiltList<FeedItem> get items;
  BuiltList<FeedError>? get error;

  Feed._();
  factory Feed([void Function(FeedBuilder b) updates]) = _$Feed;

  factory Feed.fromJson(String json) =>
      serializers.deserializeWith(serializer, jsonDecode(json))!;

  String toJson() => jsonEncode(serializers.serializeWith(serializer, this)!);
}

abstract class FeedItem implements Built<FeedItem, FeedItemBuilder> {
  static Serializer<FeedItem> get serializer => _$feedItemSerializer;

  String get title;
  String get summary;
  String? get author;
  String? get img;
  String get link;
  int get published;
  String get origin;

  FeedItem._();
  factory FeedItem([void Function(FeedItemBuilder) updates]) = _$FeedItem;
}

abstract class FeedError implements Built<FeedError, FeedErrorBuilder> {
  static Serializer<FeedError> get serializer => _$feedErrorSerializer;

  String get origin;
  String get message;

  FeedError._();
  factory FeedError([void Function(FeedErrorBuilder) updates]) = _$FeedError;
}
