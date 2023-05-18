/*
 * This file is part of hsas_h4o5f_app.
 * Copyright (c) 2023 HSAS H4o5F Team. All Rights Reserved.
 *
 * hsas_h4o5f_app is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * hsas_h4o5f_app is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class RssFeed {
  RssFeed({
    required this.title,
    required this.description,
    required this.link,
    required this.items,
  });

  final String title;
  final String description;
  final String link;
  final List<RssItem> items;

  static Future<RssFeed> parse(String xmlString) async {
    final document = XmlDocument.parse(xmlString);
    final channel = document.findAllElements('channel').first;
    final items =
        channel.findAllElements('item').map((e) => RssItem.parse(e)).toList();
    return RssFeed(
      title: channel.findElements('title').first.innerText,
      description: channel.findElements('description').first.innerText,
      link: channel.findElements('link').first.innerText,
      items: items,
    );
  }
}

class RssItem {
  RssItem({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
  });

  final String title;
  final String description;
  final String link;
  final DateTime pubDate;

  static RssItem parse(XmlElement element) {
    return RssItem(
      title: element.findElements('title').first.innerText,
      description: element.findElements('description').first.innerText,
      link: element.findElements('link').first.innerText,
      pubDate: DateFormat('E, d MMM yyyy hh:mm:ss Z', 'en_US')
          .parse(element.findElements('pubDate').first.innerText),
    );
  }
}
