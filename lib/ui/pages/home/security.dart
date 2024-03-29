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

class HomePageSecurity extends StatefulWidget {
  const HomePageSecurity({super.key});

  @override
  State<HomePageSecurity> createState() => _HomePageSecurityState();
}

class _HomePageSecurityState extends State<HomePageSecurity> {
  final _records = _generateRecords(10);

  bool _moreRecordsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverBlurredLargeAppBar(
          title: Text(AppLocalizations.of(context)!.security),
        ),
        SliverToBoxAdapter(
          child: DirectionalSafeArea(
            start: false,
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        AppLocalizations.of(context)!.recentRecords,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ListTile(
                      title: Text(_records.first.name),
                      subtitle: Text(
                        '${_records.first.time}\n${_records.first.type == _RecordType.enter ? AppLocalizations.of(context)!.enter : AppLocalizations.of(context)!.exit}',
                      ),
                    ),
                    ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          _moreRecordsExpanded = isExpanded;
                        });
                      },
                      children: [
                        ExpansionPanel(
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              title: Text(AppLocalizations.of(context)!.more),
                            );
                          },
                          body: Column(
                            children: [
                              for (var i = 1; i < _records.length; i++)
                                ListTile(
                                  title: Text(_records[i].name),
                                  subtitle: Text(
                                    '${_records[i].time}\n${_records[i].type == _RecordType.enter ? AppLocalizations.of(context)!.enter : AppLocalizations.of(context)!.exit}',
                                  ),
                                ),
                            ],
                          ),
                          isExpanded: _moreRecordsExpanded,
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// TODO: 合并入服务器
final names = [
  '张三',
  '李四',
  '王五',
  '赵六',
  '孙七',
  '周八',
  '吴九',
  '郑十',
];

List<_Record> _generateRecords(int count) {
  final records = <_Record>[];
  final random = Random();
  DateTime time = DateTime.now();
  for (var i = 0; i < count; i++) {
    final name = names[random.nextInt(names.length)];
    time = time.subtract(Duration(
      days: random.nextInt(3),
      hours: random.nextInt(36),
      minutes: random.nextInt(80),
      seconds: random.nextInt(80),
      milliseconds: random.nextInt(80),
      microseconds: random.nextInt(400),
    ));
    final type = random.nextBool() ? _RecordType.enter : _RecordType.exit;
    records.add(_Record(name, time, type));
  }
  records.sort((a, b) => b.time.compareTo(a.time));
  return records;
}

class _Record {
  _Record(this.name, this.time, this.type);

  final String name;
  final DateTime time;
  final _RecordType type;
}

enum _RecordType {
  enter,
  exit,
}
