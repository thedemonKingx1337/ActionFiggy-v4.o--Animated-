import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/httpException.dart';
import 'package:provider/provider.dart';

import '../providers/authentication.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(117, 188, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(158, 117, 255, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-8.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blueGrey,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Action\n Figgy',
                        style: GoogleFonts.blackOpsOne(
                            fontSize: 36,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animecontroller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animecontroller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animecontroller, curve: Curves.fastOutSlowIn));
    // _heightAnimation.addListener(() {return setState(() {});});
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animecontroller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animecontroller.dispose();
  }

  void _showErrorDialogBox(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Error Occured"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Authentication>(context, listen: false)
            .login(_authData["email"]!, _authData["password"]!);
      } else {
        await Provider.of<Authentication>(context, listen: false)
            .signup(_authData["email"]!, _authData["password"]!);
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentication failed ";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = errorMessage + "Email already exists";
      } else if (error.toString().contains("INVALID_LOGIN_CREDENTIALS")) {
        errorMessage = "Enter a valid e-mail / password.";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "Password is not strong.";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Password don't match.";
      }
      _showErrorDialogBox(errorMessage);
    } catch (error) {
      var errorMessage = "Could not authenticate Something went wrong.";
      _showErrorDialogBox(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animecontroller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animecontroller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child:
          // AnimatedBuilder(
          //   animation:
          // _heightAnimation,
          // builder: (context, child_ch) =>
          AnimatedContainer(
        duration: Duration(milliseconds: 300), curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 350 : 280,
        // height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 350 : 290),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child:
            //   child_ch,
            // ),
            // child:
            Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                // if (_authMode == AuthMode.Signup)

                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 150 : 0),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _submit,
                  ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
