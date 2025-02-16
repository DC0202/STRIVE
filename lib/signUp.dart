import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:auresia/homePage.dart';
import 'package:auresia/transitionAnimation.dart';
import 'package:auresia/values.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool initialize = true;
  bool change = false;
  bool change1 = false;
  bool submitDone = false;

  TextEditingController _userid = TextEditingController();
  TextEditingController _password = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(const Duration(seconds: 2), () {
        setState(() {
          initialize = false;
        });
        Timer(const Duration(seconds: 2), () {
          setState(() {
            change = !change;
          });
          Timer(const Duration(seconds: 1), () {
            setState(() {
              change1 = !change1;
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userid.dispose();
    _password.dispose();
  }

  Widget fieldNameData(
      String text, TextEditingController textEditingController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          maxLines: 1,
          textInputAction: TextInputAction.done,
          controller: textEditingController,
          style: TextStyle(fontSize: 11.sp),
          keyboardType:
              text == "User-ID" ? TextInputType.number : TextInputType.name,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(4.w, 0.0, 4.w, 2.h),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            hintText: "Enter your $text",
            hintStyle: TextStyle(
              color: Color(0xFFA3A3A3),
              fontSize: 11.sp,
            ),
          ),
          validator: (value) {
            if (value == "" || value!.isEmpty) {
              return "Enter $text";
            }
            return null;
          },
        ),
        SizedBox(
          height: 2.h,
        ),
      ],
    );
  }

  Widget endButtons(String text1, call) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFF0),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Material(
        color: Colors.white,
        elevation: 4.0,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          onTap: submitDone ? () {} : call,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.5.h),
            child: Center(
              child: submitDone
                  ? SizedBox(
                      height: 6.3.w,
                      width: 6.3.w,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      text1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF585858),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  alertDialogCall(String title, String content) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 11.sp),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              color: Colors.white,
              child: Text(
                "Okay",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6FA),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFE6E6FA),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: initialize
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : Form(
                  key: _formKey,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        left: 10.w,
                        right: 10.w,
                        top: change
                            ? 10.h
                            : (MediaQuery.of(context).size.height / 2) -
                                kToolbarHeight,
                        child: Center(
                          child: Text(
                            'AURESIA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 36.sp,
                            ),
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(6.3.w, 0.0, 6.3.w, 2.5.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            AnimatedContainer(
                              curve: Curves.linear,
                              height: change1 ? 15.h : 0.0,
                              duration: const Duration(seconds: 1),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox(),
                              secondChild: AnimatedOpacity(
                                opacity: change1 ? 1.0 : 0.0,
                                duration: const Duration(seconds: 1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    fieldNameData("User-ID", _userid),
                                    fieldNameData("Password", _password),
                                  ],
                                ),
                              ),
                              secondCurve: Curves.ease,
                              crossFadeState: change1
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(seconds: 1),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            // AnimatedCrossFade(
                            //   firstChild: const SizedBox(),
                            //   secondChild: AnimatedOpacity(
                            //     opacity: change1 ? 1.0 : 0.0,
                            //     duration: const Duration(seconds: 1),
                            //     child: Text(
                            //       "This is a research app. For more information email ejjordan@iu.edu",
                            //       style: TextStyle(
                            //         fontSize: 12.sp,
                            //       ),
                            //       textAlign: TextAlign.justify,
                            //     ),
                            //   ),
                            //   secondCurve: Curves.ease,
                            //   crossFadeState: change1
                            //       ? CrossFadeState.showSecond
                            //       : CrossFadeState.showFirst,
                            //   duration: const Duration(seconds: 1),
                            // ),
                            AnimatedOpacity(
                              opacity: change1 ? 1.0 : 0.0,
                              duration: const Duration(seconds: 1),
                              child: Text(
                                "This is a research app. For more information email auresia@iu.edu",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox(),
                              secondChild: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.5.h),
                                child: endButtons(
                                  "Submit",
                                  () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        submitDone = true;
                                      });
                                      Map<String, dynamic> formData = {
                                        "user_id":
                                            int.parse(_userid.text.trim()),
                                        "password": _password.text.trim(),
                                      };
                                      try {
                                        var val = await Dio().post(
                                          "$url/login",
                                          data: formData,
                                        );
                                        if (val.data == "True") {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          setState(() {
                                            prefs.setInt(spUserId,
                                                int.parse(_userid.text));
                                            userId = int.parse(_userid.text);
                                            submitDone = false;
                                          });
                                          setState(() {});
                                          // if (Platform.isAndroid) {
                                          //   await initializeService();
                                          // }
                                          await service.startService();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            FadeRoute(page: const HomePage()),
                                            (route) => false,
                                          );
                                        } else {
                                          alertDialogCall("Sorry!",
                                              "You entered wrong credentials");
                                        }
                                      } on DioException {
                                        alertDialogCall("Error",
                                            "We are facing some issues Sorry Please try again after sometime");
                                      }
                                      setState(() {
                                        submitDone = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              secondCurve: Curves.ease,
                              crossFadeState: change1
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(seconds: 1),
                            ),
                            // ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
