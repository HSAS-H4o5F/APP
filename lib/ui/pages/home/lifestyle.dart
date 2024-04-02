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

class HomePageLifestyle extends StatefulWidget {
  const HomePageLifestyle({super.key});

  @override
  State<HomePageLifestyle> createState() => _HomePageLifestyleState();
}

class _HomePageLifestyleState extends State<HomePageLifestyle> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverBlurredLargeAppBar(
          title: Text(AppLocalizations.of(context)!.lifestyle),
        ),
        SliverToBoxAdapter(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    LifeStyleCard(
                      icon: Icons.medical_services,
                      title: AppLocalizations.of(context)!.medicalCare,
                      subhead:
                          AppLocalizations.of(context)!.medicalCareCardSubhead,
                      onTap: _onMedicalCareTap,
                    ),
                    LifeStyleCard(
                      icon: Icons.pets,
                      title: AppLocalizations.of(context)!.guideDogs,
                      subhead:
                          AppLocalizations.of(context)!.guideDogsCardSubhead,
                      actions: [
                        FilledButton(
                          onPressed: _onGuideDogsHelpTap,
                          child: Text(
                              AppLocalizations.of(context)!.showHelpMessage),
                        ),
                      ],
                      onTap: _onGuideDogsTap,
                    ),
                    LifeStyleCard(
                      icon: Icons.people,
                      title: AppLocalizations.of(context)!.mutualAid,
                      subhead:
                          AppLocalizations.of(context)!.mutualAidCardSubhead,
                      onTap: _onMutualAidTap,
                    ),
                    LifeStyleCard(
                      icon: Icons.fitness_center,
                      title: AppLocalizations.of(context)!.fitnessEquipments,
                      subhead: AppLocalizations.of(context)!
                          .fitnessEquipmentsCardSubhead,
                      onTap: _onFitnessEquipmentsTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // TODO: 更改此处 UI 布局
        SliverPinnedHeader(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: DirectionalSafeArea(
              start: false,
              top: false,
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.learningResources,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ((List<FeedItem> items) {
          return SliverList.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return DirectionalSafeArea(
                start: false,
                top: false,
                bottom: index == items.length - 1,
                child: EducationFlowItem(
                  articleUrl: item.link,
                  title: item.title,
                  summary: item.summary,
                ),
              );
            },
          );
        })(EducationFeedState.of(context)?.items.toList() ?? []),
      ],
    );
  }

  void _onMedicalCareTap() {
    context.push('/home/medical-care');
  }

  void _onGuideDogsTap() {
    context.push('/home/guide-dogs');
  }

  void _onGuideDogsHelpTap() {
    showAlertDialog(
      context: context,
      title: Text(AppLocalizations.of(context)!.helpMessage),
      content: Text(AppLocalizations.of(context)!.helpMessageContent),
      actions: [
        TextButton(
          onPressed: () => context.popDialog(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            context.popDialog();
            _onGuideDogsTap();
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }

  void _onMutualAidTap() {
    context.push('/home/mutual-aid');
  }

  void _onFitnessEquipmentsTap() {
    context.push('/home/fitness-equipments');
  }
}

class LifeStyleCard extends StatelessWidget {
  const LifeStyleCard({
    super.key,
    required this.icon,
    required this.title,
    this.subhead,
    this.actions = const [],
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subhead;
  final List<Widget> actions;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(icon, size: 48),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (subhead != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subhead!,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (actions.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                        right: 16,
                      ),
                      child: OverflowBar(
                        spacing: 8,
                        alignment: MainAxisAlignment.end,
                        children: actions,
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EducationFlowItem extends StatelessWidget {
  const EducationFlowItem({
    super.key,
    required this.articleUrl,
    required this.title,
    this.summary,
    this.imageUrl,
  });

  final String articleUrl;
  final String title;
  final String? summary;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeLeft: true,
      removeTop: true,
      removeRight: true,
      removeBottom: true,
      context: context,
      child: ListTile(
        leading: imageUrl.ifNotNull((value) {
          return AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              value,
            ),
          );
        }),
        title: Text(title),
        subtitle: summary.ifNotNull((value) {
          return Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }),
        onTap: () => jump(context, articleUrl),
      ),
    );
  }

  void jump(BuildContext context, String url) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}
