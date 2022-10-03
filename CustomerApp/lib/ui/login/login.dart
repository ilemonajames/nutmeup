import 'dart:io';
import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerEmail = TextEditingController();
  final _editControllerPassword = TextEditingController();

  @override
  void dispose() {
    _editControllerEmail.dispose();
    _editControllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
      backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            ListView(
              children: [

                ClipPath(
                    clipper: ClipPathClass23(20),
                    child: Container(
                      color: (theme.darkMode) ? theme.blackColorTitleBkg : theme.colorBackground,
                      width: windowWidth,
                      height: windowHeight/2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: windowHeight*0.1,),
                          Container(
                            width: windowWidth*0.3,
                            height: windowWidth*0.3,
                            child: theme.loginLogoAsset ? Image.asset("assets/ondemands/ondemand1.png", fit: BoxFit.contain) :
                            CachedNetworkImage(
                                imageUrl: theme.loginLogo,
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text("Welcome back", // "SERVICE",
                              style: theme.style16W800Grey),
                          SizedBox(height: 20,),

                        ],
                      ),
                    )),

                Container(
                  color: (theme.darkMode) ? Colors.black : Colors.white,
                  child: Column(
                      children: [
                        Center(
                          child: Text("Please enter your details", // "Sign in now",
                            style: theme.style16W800,
                          ),
                        ),

                        SizedBox(height: 20,),

                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: edit42(strings.get(23), /// "Email",
                              _editControllerEmail,
                              strings.get(24), // "Enter your Email",
                              type: TextInputType.emailAddress
                              ),
                        ),

                        SizedBox(height: 20,),

                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Edit43(
                              text: strings.get(44), // "Password",
                              controller: _editControllerPassword,
                              hint: strings.get(45), // "Enter your Password",
                              ),
                        ),

                        SizedBox(height: 20,),

                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: button2("Login", // "CONTINUE",
                              theme.mainColor, (){_login();}, style: theme.style16W800White, radius: 50),
                        ),
                        SizedBox(height: 10,),
                        button134( "Forgot password?", /// "Forgot password?",
                                (){
                                  route("forgot");
                            }, style: theme.style14W400),
                        SizedBox(height: 10,),
                        Container(
                          //alignment: Alignment.bottomCenter,
                          margin: EdgeInsets.only(left: 27, right: 0),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(child: Text( "Don't have an account?", // "Sign in now",
                                style: theme.style11W600Grey,

                              )),
                              SizedBox(width: 1,),
                              Expanded(child: button134( "Sign up here", /// "Forgot password?",
                                      (){
                                        route("register");
                                  }, style: theme.style14W800),),
                            ],
                          ),
                        ),
                        SizedBox(height: 30,),
/*
                        Center(
                          child: Text(strings.get(48), // "or continue with",
                              style: theme.style14W600Grey),
                        ),

                        SizedBox(height: 10,),
                        if (Platform.isIOS)
                          buttonIOS("assets/apple.png", _appleLogin, windowWidth * 0.9, "Sign in with Apple"),
                        SizedBox(height: 10,),

                        Container(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(child: button195("Facebook", theme.mainColor, _facebookLogin, style: theme.style16W800White, )),
                                SizedBox(width: 1,),
                                Flexible(child: button196("Google", theme.mainColor, _googleLogin, style: theme.style16W800White)),
                              ],
                            )
                        ) */
                      ],
                  ),
                ),

              ],
            ),


            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                "", context, () {
                  goBack();
                  route("home");
            }),

            if (_wait)
              Center(child: Container(child: Loader7v1(color: theme.mainColor,))),

          ],
        )

    ));
  }

  bool _wait = false;
  _waits(bool value){
    _wait = value;
    _redraw();
  }
  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _login() async {
    if (_editControllerEmail.text.isEmpty)
      return messageError(context, strings.get(135)); /// "Please Enter Email",

    if (_editControllerPassword.text.isEmpty)
      return messageError(context, strings.get(136)); /// "Please Enter Password",

    if (getProviderByEmail(_editControllerEmail.text) != null)
      return messageError(context, strings.get(288)); /// "Provider can't enter to customer app. Please use another credentials.",

    _waits(true);
    var ret = await login(_editControllerEmail.text, _editControllerPassword.text, true,
        strings.get(137), // User not found
        strings.get(173) // "User is disabled. Connect to Administrator for more information.",
        );
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }

  _googleLogin() async {
    _waits(true);
    var ret = await googleLogin();
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }

  _facebookLogin() async {
    _waits(true);
    var ret = await facebookLogin();
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }

  //
  // Apple
  //


  _appleLogin() async {
    _waits(true);
    var ret = await appleLogin();
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }
}


