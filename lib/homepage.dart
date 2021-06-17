
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_firebase/note.dart';
import 'package:flutter_notes_firebase/notemaking.dart';
import 'package:flutter_notes_firebase/serveses/database.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     final database = Provider.of<Database>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () {
            FirebaseAuth.instance.signOut();
          })
        ],
      ),
      body: StreamBuilder<List<Notes>>(
        stream: database.notesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notes = snapshot.data;
            final children = notes
                .map((note) => NoteCard(
                     title: note.title,
                     description: note.description,
                      
                    ))
                .toList();
            return ListView(children: children);
          }
          return Center(child: CircularProgressIndicator());
        }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NoteMaking.show(context: context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({ Key key,@required this.title,@required this.description }) : super(key: key);
  final String title,description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(description),
        ),
      ],),
    );
  }
}