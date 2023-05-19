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
import 'package:hsas_h4o5f_app/ui/widgets/dialog.dart';
import 'package:hsas_h4o5f_app/ui/widgets/text_form_field.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({
    Key? key,
    required this.type,
  }) : super(key: key);

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
          SliverAppBar.large(
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
          SliverToBoxAdapter(
            child: SafeArea(
              minimum: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    if (widget.type == LoginRegisterPageType.register) ...[
                      MyTextFormField(
                        controller: _invitationCodeController,
                        labelText: AppLocalizations.of(context)!.invitationCode,
                        onFieldSubmitted: _submit,
                        keyboardType: TextInputType.text,
                        enabled: !_submitting,
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: _emailController,
                        labelText: AppLocalizations.of(context)!.email,
                        onFieldSubmitted: _submit,
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_submitting,
                      ),
                      const SizedBox(height: 16),
                    ],
                    MyTextFormField(
                      controller: _userNameController,
                      labelText: AppLocalizations.of(context)!.username,
                      onFieldSubmitted: _submit,
                      autofillHints: const [AutofillHints.username],
                      keyboardType: TextInputType.text,
                      enabled: !_submitting,
                    ),
                    const SizedBox(height: 16),
                    MyTextFormField(
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
                            : AppLocalizations.of(context)!.showPassword,
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

    if (response.success) {
      if (widget.type == LoginRegisterPageType.login) {
        context.go('/home');
        return;
      }

      response = await user.login();

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerSuccess),
          ),
        );

        context.go('/home');
        return;
      }
    }

    if (!mounted) return;

    showAlertDialog(
      context: context,
      title: Text(AppLocalizations.of(context)!.error),
      content: Text(response.error!.message),
      actions: [
        TextButton(
          onPressed: () => popDialog(context),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

enum LoginRegisterPageType { login, register }
