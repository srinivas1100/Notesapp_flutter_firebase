import 'package:flutter/material.dart';
import 'package:flutter_notes_firebase/serveses/auth.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  static const routeName = 'loginScreen';
  
  final AuthBase authBase;

  const LoginScreen({Key key,@required this.authBase}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _isLoading = false;
  void _submitAuthForm(
    String email,
    String name,
    String password,
    bool isLogin,
    context,
  ) async {
   final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        await auth.signInWithEmailAndPassword(email, password);
      } else {
        await auth.createUserWithEmailAndPassword(email, password);
        final userId = UserId(email: email, name: name, uid: auth.currentUser.uid);
        await widget.authBase.userData(userId);
      }
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}


class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(
    String email,
    String name,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if(isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _isLogin,
        context,
      );
    }
  }
  final FocusNode _email = FocusNode();
  final FocusNode _name = FocusNode();
  final FocusNode _password = FocusNode();

  void _emailEditing () {
    FocusScope.of(context).requestFocus( _isLogin ? _password : _name);
  }
  void _nameEditing () {
    FocusScope.of(context).requestFocus(_password);
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextFormField(
                key: ValueKey('email'),
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'plese enter valid email adress.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userEmail = value;
                },
                focusNode: _email,
                autocorrect: true,
                onEditingComplete: _emailEditing,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'email addres..'),
                
              ),
              if (!_isLogin)
              TextFormField(
                key: ValueKey('name'),
                validator: (value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'plese enter valid name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userName = value;
                },
                focusNode: _name,
                onEditingComplete: _nameEditing,
                autocorrect: true,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              
              TextFormField(
                key: ValueKey('password'),
                validator: (value) {
                  if (value.isEmpty || value.length < 7) {
                    return 'plese enter valid name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userPassword = value;
                },
                obscureText: true,
                focusNode: _password,
                onEditingComplete: _trySubmit,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 12),
              if(widget.isLoading) CircularProgressIndicator(),
              if(!widget.isLoading)
              ElevatedButton(
                onPressed: _trySubmit, 
                child: Text(_isLogin ? "Login" : "Signup")
                ),
                if(!widget.isLoading)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                }, 
                child: Text(_isLogin ? "Create a new account" : "I already have an account")
                )
            ])),
          ),
        ),
      ),
    );
  }
}
