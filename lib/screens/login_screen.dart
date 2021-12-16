import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/components/progress_dialogue.dart';
import 'package:uber_clone/screens/registeration_screen.dart';
import 'package:uber_clone/utils/app.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  buildShowToast({required String message, required BuildContext context}) {
    Fluttertoast.showToast(msg: message);
  }

  void loginUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const ProgressDialogue(
            message: 'Đang kiểm tra tài khoản...',
          );
        });

    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
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

      usersRef!.child(firebaseUser.uid).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomeScreen.id, (route) => false);
          buildShowToast(message: 'Bạn đã đăng nhập', context: context);
        } else {
          // error
          Navigator.pop(context);
          _firebaseAuth.signOut();
          buildShowToast(message: 'Không tìm thấy tài khoản', context: context);
        }
      });
    } else {
      Navigator.pop(context);
      buildShowToast(message: 'Đã có lỗi xảy ra', context: context);
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
                Image.asset(
                  'assets/images/Asset_1.png',
                  height: 350.0,
                  width: 350.0,
                  alignment: Alignment.center,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                const Text(
                  'Đăng Nhập',
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
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(


                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          hintText: "Nhập Email",
                          labelStyle: TextStyle(fontSize: 14.0, color: Colors.black,),
                          hintStyle: TextStyle(fontSize: 14.0, color: Colors.black,)),
                          style: TextStyle(fontSize: 14.0, color: Colors.black),),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          fillColor: Colors.white,
                          filled: true,

                          labelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
                          hintText: "Nhập Mật Khẩu",
                          hintStyle: TextStyle(fontSize: 14.0, color: Colors.black,),),
                          style: TextStyle(fontSize: 14.0, color: Colors.black),),
                      const SizedBox(height: 20.0,),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          textStyle: MaterialStateProperty.all(
                              const TextStyle(color: Colors.white)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (!emailTextEditingController.text.contains('@')) {
                            buildShowToast(
                                message: 'Email không hợp lệ', context: context);
                          } else if (passwordTextEditingController.text.length <
                              6) {
                            buildShowToast(
                                message: 'Mật khẩu có ít nhất 6 kí tự',
                                context: context);
                          } else {
                            loginUser(context);
                          }
                        },
                        child: const SizedBox(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontFamily: 'bolt-semibold',
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
                        context, RegisterationScreen.id, (route) => false);
                  },
                  child: const Text(
                    'Không có tài khoản? Đăng ký ở đây',
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
