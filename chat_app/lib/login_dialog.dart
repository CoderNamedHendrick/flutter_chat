import 'dart:io';

import 'package:app_models/models.dart' show UserDescriptor;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:scoped_model/scoped_model.dart';
import 'connector.dart' as connector;
import 'model.dart';

class LoginDialog extends StatelessWidget {
  static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  static String? _userName;
  static String? _password;

  const LoginDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return AlertDialog(
            content: SizedBox(
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
                    connector.connectToServer(() {
                      connector.validate(
                          UserDescriptor(
                              userName: _userName!,
                              password: _password!), (inStatus) async {
                        if (inStatus == 'ok') {
                          model.setUserName = _userName!;
                          Navigator.of(model.rootBuildContext).pop();
                          model.setGreeting = 'Welcome back, $_userName!';
                        } else if (inStatus == 'fail') {
                          ScaffoldMessenger.of(model.rootBuildContext)
                              .showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                              content:
                                  Text('Sorry, that username is already taken'),
                            ),
                          );
                        } else if (inStatus == 'created') {
                          var credentialsFile =
                              File(p.join(model.docDir.path, 'credentials'));

                          await credentialsFile.writeAsString(
                              '$_userName============$_password');
                          model.setUserName = _userName!;
                          Navigator.of(model.rootBuildContext).pop();
                          model.setGreeting =
                              'Welcome to the server, $_userName!';
                        }
                      });
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void validateWithStoredCredentials(String inUserName, String inPassword) {
    connector.connectToServer(() {
      connector.validate(
          UserDescriptor(userName: inUserName, password: inPassword), //
          (inStatus) {
        if (inStatus == 'ok' || inStatus == 'created') {
          model.setUserName = inUserName;
          model.setGreeting = 'Welcome back, $inUserName!';
        } else if (inStatus == 'fail') {
          showDialog(
            context: model.rootBuildContext,
            barrierDismissible: false,
            builder: (inDialogContext) => AlertDialog(
              title: const Text('Validation failed'),
              content: const Text(
                'It appears that the server has restarted'
                'and the username you last used was subsequently taken by someone else.'
                '\n\nPlease re-start FlutterChat and choose a different username.',
              ),
              actions: [
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    var credentialsFile =
                        File(p.join(model.docDir.path, 'credentials'));
                    credentialsFile.deleteSync();
                    exit(0);
                  },
                ),
              ],
            ),
          );
        }
      });
    });
  }
}
