import 'package:app_models/models.dart' show Room;
import 'package:chat_app/connector.dart' as connector;
import 'package:chat_app/model.dart';
import 'package:chat_app/screens/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  String? _title;
  String? _description;
  bool _private = false;
  double _maxPeople = 25;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, inChild, inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text('Crate Room')),
            drawer: const AppDrawer(),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.of(context).pop();
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        int maxPeople = _maxPeople.truncate();
                        connector.create(
                          Room(
                              roomName: _title!,
                              description: _description!,
                              maxPeople: maxPeople,
                              private: _private,
                              creator: model.userName),
                          (inStatus, inRoomList) {
                            if (inStatus == 'created') {
                              model.setRoomList = inRoomList;
                              FocusScope.of(context).requestFocus(FocusNode());
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        'Sorry, that room already exists')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.subject),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      validator: (value) {
                        if (value!.isEmpty || value.length > 14) {
                          return 'Please enter a name no more than 14 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() => _title = value);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                      onSaved: (value) => setState(() => _description = value),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        const Text('Max\nPeople'),
                        Slider(
                          min: 0,
                          max: 99,
                          value: _maxPeople,
                          onChanged: (value) {
                            setState(() => _maxPeople = value);
                          },
                        ),
                      ],
                    ),
                    trailing: Text(_maxPeople.toStringAsFixed(0)),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        const Text('Private'),
                        Switch(
                          value: _private,
                          onChanged: (value) {
                            setState(() => _private = value);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
