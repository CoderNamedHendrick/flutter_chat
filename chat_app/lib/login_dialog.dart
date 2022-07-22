import 'package:chat_app/models/user_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'connector.dart' as connector;
import 'model.dart';

class LoginDialog extends StatelessWidget {
  static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  String? _userName;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return AlertDialog(
            content: Container(
              height: 220,
              child: Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    Text(
                      'Enter a username and password to register with the server',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(model.rootBuildContext)
                            .colorScheme
                            .secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty || value.length > 10) {
                          return 'Please enter a username no more than 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (String? value) => {_userName = value},
                      decoration: const InputDecoration(
                          hintText: 'Username', labelText: 'Username'),
                    ),
                    TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      onSaved: (String? value) => {_password = value},
                      decoration: const InputDecoration(
                          hintText: 'Password', labelText: 'Password'),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Log In'),
                onPressed: () {
                  if (_loginFormKey.currentState!.validate()) {
                    _loginFormKey.currentState!.save();
                    connector.connectToServer(
                      () {
                        connector.validate(UserDescriptor(
                            userName: _userName!, password: _password!));
                      },
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
