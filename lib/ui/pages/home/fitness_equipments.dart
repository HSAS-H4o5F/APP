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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:intl/intl.dart';

class FitnessEquipmentsPage extends StatefulWidget {
  const FitnessEquipmentsPage({Key? key}) : super(key: key);

  @override
  State<FitnessEquipmentsPage> createState() => _FitnessEquipmentsPageState();
}

class _FitnessEquipmentsPageState extends State<FitnessEquipmentsPage>
    with TickerProviderStateMixin {
  final _availableEquipmentGroups = [
    _generateEquipmentGroup('篮球场', 2, 0),
    _generateEquipmentGroup('羽毛球场', 6, 0.5),
    _generateEquipmentGroup('乒乓球场', 10, 0),
    _generateEquipmentGroup('网球场', 4, 0.5),
  ];

  late final _GroupTabController _tabControllers;

  @override
  void initState() {
    super.initState();
    _tabControllers = _GroupTabController(
      groups: _availableEquipmentGroups,
      vsync: this,
    );
  }

  // TODO: 提取组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fitnessEquipments),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabControllers.groupsController,
            isScrollable: true,
            padding: MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
            tabs: _availableEquipmentGroups.map((group) {
              return Tab(text: group.name);
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabControllers.groupsController,
              children:
                  _availableEquipmentGroups.mapIndexed((groupIndex, group) {
                final equipmentsController =
                    _tabControllers.equipmentControllers[groupIndex];

                return Column(
                  children: [
                    TabBar(
                      controller: equipmentsController.equipmentsController,
                      isScrollable: true,
                      padding: MediaQuery.of(context)
                          .padding
                          .copyWith(top: 0, bottom: 0),
                      tabs: group.equipments.map((equipment) {
                        return Tab(
                          text: equipment.name,
                        );
                      }).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: equipmentsController.equipmentsController,
                        children: group.equipments
                            .mapIndexed((equipmentIndex, equipment) {
                          final datesController = equipmentsController
                              .dateControllers[equipmentIndex];

                          return Column(
                            children: [
                              TabBar(
                                controller: datesController.datesController,
                                isScrollable: true,
                                padding: MediaQuery.of(context)
                                    .padding
                                    .copyWith(top: 0, bottom: 0),
                                tabs: equipment.dates.map((date) {
                                  return Tab(
                                    text: DateFormat.MEd().format(date.date),
                                  );
                                }).toList(),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: datesController.datesController,
                                  children: equipment.dates.map((date) {
                                    date.fragments.sort((a, b) {
                                      return a.startTime.compareTo(b.startTime);
                                    });

                                    return SingleChildScrollView(
                                      child: SafeArea(
                                        child: Table(
                                          columnWidths: const {
                                            0: IntrinsicColumnWidth(),
                                            1: FlexColumnWidth(1),
                                          },
                                          defaultVerticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          children:
                                              date.fragments.map((fragment) {
                                            return TableRow(
                                              children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      '${fragment.startTime.format(context)}-${fragment.endTime.format(context)}',
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: ListTile(
                                                    leading: fragment.selected
                                                        ? const Icon(
                                                            Icons.check,
                                                          )
                                                        : null,
                                                    title: Text(
                                                      fragment.available
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .available
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .unavailable,
                                                    ),
                                                    subtitle: Text(
                                                      '¥${fragment.price}',
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        fragment.selected =
                                                            !fragment.selected;
                                                      });
                                                    },
                                                    enabled: fragment.available,
                                                    selected: fragment.selected,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTabController {
  late final TabController groupsController;
  late final List<_EquipmentTabController> equipmentControllers;

  _GroupTabController({
    required List<_EquipmentGroup> groups,
    required TickerProvider vsync,
  }) {
    groupsController = TabController(
      length: groups.length,
      vsync: vsync,
    );
    equipmentControllers = List.generate(
      groups.length,
      (index) {
        return _EquipmentTabController(
          equipments: groups[index].equipments,
          vsync: vsync,
        );
      },
    );
  }
}

class _EquipmentTabController {
  late final TabController equipmentsController;
  late final List<_DateTabController> dateControllers;

  _EquipmentTabController({
    required List<_Equipment> equipments,
    required TickerProvider vsync,
  }) {
    equipmentsController = TabController(
      length: equipments.length,
      vsync: vsync,
    );
    dateControllers = List.generate(
      equipments.length,
      (index) {
        return _DateTabController(
          dates: equipments[index].dates,
          vsync: vsync,
        );
      },
    );
  }
}

class _DateTabController {
  late final TabController datesController;

  _DateTabController({
    required List<_EquipmentDate> dates,
    required TickerProvider vsync,
  }) {
    datesController = TabController(
      length: dates.length,
      vsync: vsync,
    );
  }
}

_EquipmentGroup _generateEquipmentGroup(
  String name,
  int count,
  double price,
) {
  return _EquipmentGroup(
    name: name,
    equipments: [
      for (int i = 1; i <= count; i++)
        _Equipment(
          name: '$name $i',
          dates: [
            for (var j = 0; j < 7; j++)
              _EquipmentDate(
                date: DateTime.now().add(Duration(days: j)),
                fragments: _generateFragments(price, j == 0),
              ),
          ],
        ),
    ],
  );
}

List<_EquipmentFragment> _generateFragments(double price, bool today) {
  final fragments = <_EquipmentFragment>[];
  for (var i = today ? TimeOfDay.now().hour + 1 : 0; i < 24; i++) {
    fragments.add(
      _EquipmentFragment(
        startTime: TimeOfDay(hour: i, minute: 0),
        endTime: TimeOfDay(hour: i, minute: 59),
        price: price,
        available: Random().nextInt(3) != 0,
      ),
    );
  }
  return fragments;
}

class _EquipmentGroup {
  const _EquipmentGroup({
    required this.name,
    required this.equipments,
  });

  final String name;
  final List<_Equipment> equipments;
}

class _Equipment {
  const _Equipment({
    required this.name,
    required this.dates,
  });

  final String name;
  final List<_EquipmentDate> dates;
}

class _EquipmentDate {
  const _EquipmentDate({
    required this.date,
    required this.fragments,
  });

  final DateTime date;
  final List<_EquipmentFragment> fragments;
}

class _EquipmentFragment {
  _EquipmentFragment({
    required this.startTime,
    required this.endTime,
    this.price = 0,
    this.available = true,
    this.selected = false,
  });

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double price;
  final bool available;
  bool selected;
}
