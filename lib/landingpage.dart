import 'package:flutter/material.dart';
import 'package:flutter_notes_firebase/homepage.dart';
import 'package:flutter_notes_firebase/loginpage.dart';
import 'package:flutter_notes_firebase/serveses/auth.dart';
import 'package:flutter_notes_firebase/serveses/database.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    //  final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<UserId>(
        stream: auth.authStateChanged(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final UserId user = snapshot.data;
            if (user == null) {
              return LoginScreen(authBase: auth);
            }
            return Provider<Database>(
              create: (_) => FirestoreDatabase(uid: user.uid),
              child: MyHomePage(),
            );
          }
          return Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        });
  }
}
