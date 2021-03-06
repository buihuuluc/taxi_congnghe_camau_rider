import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/components/progress_dialogue.dart';
import 'package:uber_clone/utils/app.dart';
import 'package:uber_clone/screens/home_screen.dart';

import 'login_screen.dart';

class RegisterationScreen extends StatelessWidget {
  static const String id = 'register';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  RegisterationScreen({Key? key}) : super(key: key);

  buildShowToast({required String message, required BuildContext context}) {
    Fluttertoast.showToast(msg: message);
  }

  void registerNewUSer(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const ProgressDialogue(
            message: 'Registering user, please wait...',
          );
        });

    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
    )
            .catchError((errMsg) {
      Navigator.pop(context);
      buildShowToast(message: 'Error:' + errMsg.toString(), context: context);
    }))
        .user;

    if (firebaseUser != null) // create user
    {
      // save data

      Map userDataMap = {
        'name': nameTextEditingController.text.trim(),
        'email': emailTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
      };

      usersRef!.child(firebaseUser.uid).set(userDataMap);
      buildShowToast(message: 'Account has been created', context: context);
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.id, (route) => false);
    } else {
      // error
      Navigator.pop(context);
      buildShowToast(
          message: 'New user has not been created', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Image.asset(
                'assets/images/Asset_1.png',
                height: 350.0,
                width: 350.0,
                alignment: Alignment.center,
              ),
              const Text(
                '????ng K?? d??nh cho ng?????i d??ng',
                style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'bolt-semibold',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),


                        labelStyle: TextStyle(fontSize: 14.0, color: Colors.black,),
                        hintText: "Nh???p h??? t??n c???a b???n",
                        hintStyle: TextStyle(fontSize: 14.0, color: Colors.black,),
                      ),
                      style: TextStyle(fontSize: 14.0, color: Colors.black),),
                    const SizedBox(
                      height: 15.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        labelStyle: TextStyle(fontSize: 14.0, color: Colors.black,),
                        hintText: "Nh???p email c???a b???n",
                        hintStyle: TextStyle(fontSize: 14.0, color: Colors.black,),),
                        style: TextStyle(fontSize: 14.0, color: Colors.black),),
                    const SizedBox(
                      height: 15.0,
                    ),
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        labelStyle: TextStyle(fontSize: 14.0, color: Colors.black,),
                        hintText: "Nh???p s??? ??i???n tho???i c???a b???n",
                        hintStyle: TextStyle(fontSize: 14.0, color: Colors.black,),),
                      style: TextStyle(fontSize: 14.0, color: Colors.black),),
                    const SizedBox(
                      height: 15.0,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration:  InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        labelStyle: TextStyle(fontSize: 14.0, color: Colors.black,),
                        hintText: "Nh???p m???t kh???u c???a b???n",
                        hintStyle: TextStyle(fontSize: 14.0, color: Colors.black,),),
                        style: TextStyle(fontSize: 14.0, color: Colors.black),),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        textStyle: MaterialStateProperty.all(
                            TextStyle(color: Colors.black)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (nameTextEditingController.text.length < 3) {
                          buildShowToast(
                              message: 'T??n ph???i c?? ??t nh???t 3 k?? t???',
                              context: context);
                        } else if (!emailTextEditingController.text
                            .contains('@')) {
                          buildShowToast(
                              message: 'Email kh??ng h???p l???', context: context);
                        } else if (phoneTextEditingController.text.isEmpty) {
                          buildShowToast(
                              message: 'S??? ??i???n tho???i tr???ng',
                              context: context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          buildShowToast(
                              message: 'M???t kh???u ph???i ??t nh???t 6 k?? t???',
                              context: context);
                        } else {
                          registerNewUSer(context);
                        }
                      },
                      child: const SizedBox(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            '????ng K??',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontFamily: 'bolt-semibold',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.id, (route) => false);
                },
                child: Text(
                  'Ba??n c?? s??n san ?????? ta??o m????t tai khoa??n? ????ng nh???p t???i ????y',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
