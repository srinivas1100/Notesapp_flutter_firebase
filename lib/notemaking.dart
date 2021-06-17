import 'package:flutter/material.dart';
import 'package:flutter_notes_firebase/serveses/database.dart';
import 'package:provider/provider.dart';

import 'note.dart';

class NoteMaking extends StatefulWidget {
  final Database database;
  final String id;

  const NoteMaking({
    Key key,
    @required this.database,
    @required this.id,
  }) : super(key: key);

  static Future<void> show({BuildContext context, String id}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteMaking(
          id: id,
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _NoteMakingState createState() => _NoteMakingState();
}

class _NoteMakingState extends State<NoteMaking> {
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final _form = GlobalKey<FormState>();

  final FocusNode _title = FocusNode();
  final FocusNode _description = FocusNode();
  void _titleEditing() {
    FocusScope.of(context).requestFocus(_description);
  }

  bool _validateAndSave() {
    final form = _form.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _trySubmit() async {
    if (_validateAndSave()) {
      final note = Notes(
          id: documentIdFromCurrentDate(),
          title: title.text,
          description: description.text);
      await widget.database.setNote(note);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notes'),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: _trySubmit,
                child: Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ))
          ],
        ),
        body: SingleChildScrollView(
                  child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _form,
              child: Column(children: [
                TextFormField(
                  key: ValueKey('Title'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'plese write Title.';
                    }
                    return null;
                  },
                  controller: title,
                  focusNode: _title,
                  autocorrect: true,
                  onEditingComplete: _titleEditing,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  key: ValueKey('description'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'plese write description.';
                    }
                    return null;
                  },
                  maxLines: 6,
                  controller: description,
                  focusNode: _description,
                  autocorrect: true,
                  onEditingComplete: _trySubmit,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ]),
            ),
          ),
        ));
  }
}
