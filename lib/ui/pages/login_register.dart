/*
 * This file is part of hsas_h4o5f_app.
 * Copyright (c) 2023-2024 HSAS H4o5F Team. All Rights Reserved.
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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hsas_h4o5f_app/ext.dart';
import 'package:hsas_h4o5f_app/ui/widgets.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({
    super.key,
    required this.type,
  });

  final LoginRegisterPageType type;

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _invitationCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _submitting = false;
  var _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverBlurredLargeAppBar(
            title: Text(widget.type == LoginRegisterPageType.login
                ? AppLocalizations.of(context)!.login
                : AppLocalizations.of(context)!.register),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                tooltip: AppLocalizations.of(context)!.settings,
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          children: [
                            if (widget.type ==
                                LoginRegisterPageType.register) ...[
                              AppTextFormField(
                                controller: _invitationCodeController,
                                labelText: AppLocalizations.of(context)!
                                    .invitationCode,
                                onFieldSubmitted: _submit,
                                autofillHints: const ['invitationCode'],
                                keyboardType: TextInputType.text,
                                enabled: !_submitting,
                              ),
                              const SizedBox(height: 16),
                              AppTextFormField(
                                controller: _emailController,
                                labelText: AppLocalizations.of(context)!.email,
                                onFieldSubmitted: _submit,
                                autofillHints: const [AutofillHints.email],
                                keyboardType: TextInputType.emailAddress,
                                enabled: !_submitting,
                              ),
                              const SizedBox(height: 16),
                            ],
                            AppTextFormField(
                              controller: _userNameController,
                              labelText: AppLocalizations.of(context)!.username,
                              onFieldSubmitted: _submit,
                              autofillHints: const [AutofillHints.username],
                              keyboardType: TextInputType.text,
                              enabled: !_submitting,
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _passwordController,
                              labelText: AppLocalizations.of(context)!.password,
                              onFieldSubmitted: _submit,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip: _showPassword
                                    ? AppLocalizations.of(context)!.hidePassword
                                    : AppLocalizations.of(context)!
                                        .showPassword,
                                onPressed: () => setState(() {
                                  _showPassword = !_showPassword;
                                }),
                              ),
                              autofillHints: const [AutofillHints.password],
                              obscureText: !_showPassword,
                              enabled: !_submitting,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              child: Text(
                                widget.type == LoginRegisterPageType.login
                                    ? AppLocalizations.of(context)!.login
                                    : AppLocalizations.of(context)!.register,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (!kIsWeb &&
                        (Platform.isAndroid || Platform.isIOS) &&
                        widget.type == LoginRegisterPageType.login)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.face),
                            label: Text(AppLocalizations.of(context)!
                                .useFaceRecognition),
                            onPressed: () {
                              context.push('/face-recognition');
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.type == LoginRegisterPageType.login
          ? FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.register,
              onPressed: () => context.go('/register'),
              child: const Icon(Icons.person_add),
            )
          : FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.login,
              onPressed: () => context.go('/login'),
              child: const Icon(Icons.login),
            ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    ParseResponse response;

    final user = ParseUser(
      _userNameController.text,
      _passwordController.text,
      widget.type == LoginRegisterPageType.register
          ? _emailController.text
          : null,
    );

    response = widget.type == LoginRegisterPageType.login
        ? await user.login()
        : await user.signUp();

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    void goToHome() {
      if (!mounted) return;
      TextInput.finishAutofillContext();
      // TODO
      context.go('/face-registration-guide');
    }

    if (response.success) {
      if (widget.type == LoginRegisterPageType.login) {
        return goToHome();
      }

      response = await user.login();

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerSuccess),
          ),
        );

        return goToHome();
      }
    }

    if (!mounted) return;

    showAlertDialog(
      context: context,
      title: Text(AppLocalizations.of(context)!.error),
      content: Text(response.error!.message),
      actions: [
        TextButton(
          onPressed: () => context.popDialog(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

enum LoginRegisterPageType { login, register }
