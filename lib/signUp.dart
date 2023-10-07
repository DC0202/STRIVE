import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strive/homePage.dart';
import 'package:strive/transitionAnimation.dart';
import 'package:strive/values.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool initialize = true;
  bool change = false;
  bool submitDone = false;
  bool step1Done = false;
  bool step2Done = false;
  bool isError = false;

  TextEditingController userpid = TextEditingController();
  TextEditingController imeiNo = TextEditingController();

  String dropdownvalue = '';

  List<dynamic> items = [];

  funCall() async {
    try {
      Dio dio = Dio();
      await dio
          .get(
        "$url/polar_accounts",
      )
          .then((response) {
        debugPrint(response.toString());
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              var data = response.data["polar_accounts"]
                  .map((value) => value["email"])
                  .toList();
              items = data;
              initialize = false;
            });
          }
        }
      });
    } on DioException {
      alertDialogCall("Error",
          "We are facing some issues Sorry Please try again after sometime");
    }
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          change = !change;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await funCall();
    });
  }

  @override
  void dispose() {
    super.dispose();
    userpid.dispose();
    imeiNo.dispose();
  }

  Widget fieldNameData(
      String text, TextEditingController textEditingController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 5.0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 17.0),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
            ),
            child: TextField(
              maxLines: 1,
              textInputAction: TextInputAction.done,
              controller: textEditingController,
              keyboardType:
                  text == "PID" ? TextInputType.number : TextInputType.name,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: "Enter $text",
                hintStyle: const TextStyle(
                  color: Color(0xFFA3A3A3),
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget disabledFieldNameData(
      String text, TextEditingController textEditingController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 5.0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20.0,
              0.0,
              20.0,
              text == "IMEI Number"
                  ? step1Done
                      ? 17.0
                      : 0.0
                  : 17.0),
          child: text == "IMEI Number"
              ? Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          controller: textEditingController,
                          enabled: step1Done ? false : true,
                          keyboardType: text == "IMEI Number"
                              ? TextInputType.number
                              : TextInputType.name,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            hintText: "Enter $text",
                            hintStyle: const TextStyle(
                              color: Color(0xFFA3A3A3),
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.white,
                      ),
                      child: Material(
                        color: Colors.white,
                        elevation: 4.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          onTap: () async {
                            await OpenSettings.openDeviceInfoSetting();
                          },
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Icon(
                                Icons.settings,
                                size: 28.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : step1Done
                  ? Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.white,
                      ),
                      child: TextField(
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        controller: textEditingController,
                        enabled: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          hintText: "Enter $text",
                          hintStyle: const TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    )
                  : DropdownButtonFormField(
                      menuMaxHeight: 200.0,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Select Email-ID",
                      ),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((dynamic items) {
                        return DropdownMenuItem(
                          enabled: true,
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (dynamic newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                        });
                      },
                    ),
        ),
        text == "IMEI Number"
            ? step1Done
                ? const SizedBox()
                : const Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 17.0),
                    child: Text(
                      "Copy the IMEI Number after clicking the settings button\nand paste it here below",
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
            : const SizedBox(),
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
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: submitDone ? () {} : call,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 21.0),
            child: Center(
              child: submitDone
                  ? const SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      text1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
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
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Text(
          content,
          style: const TextStyle(fontSize: 14.0),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                isError = false;
              });
              Navigator.of(ctx).pop();
            },
            child: Container(
              color: Colors.white,
              // padding: const EdgeInsets.all(14),
              child: const Text(
                "Okay",
                style: TextStyle(
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
      backgroundColor: const Color(0xFFD7F3F9),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFD7F3F9),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: initialize
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AnimatedContainer(
                    //   curve: Curves.ease,
                    //   height: change
                    //       ? step1Done
                    //           ? 60.0
                    //           : 100.0
                    //       : MediaQuery.of(context).size.height / 2.0 - 20.0,
                    //   duration: const Duration(seconds: 1),
                    // ),
                    const Text(
                      'S.T.R.I.V.E.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40.0,
                      ),
                    ),
                    AnimatedContainer(
                      curve: Curves.linear,
                      height: change
                          ? step1Done
                              ? 60.0
                              : 120.0
                          : 0.0,
                      duration: const Duration(seconds: 1),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox(),
                      secondChild: AnimatedOpacity(
                        opacity: change ? 1.0 : 0.0,
                        duration: const Duration(seconds: 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: step1Done
                              ? [
                                  fieldNameData("PID", userpid),
                                  disabledFieldNameData("IMEI Number", imeiNo),
                                  disabledFieldNameData("Email-ID",
                                      TextEditingController(text: email)),
                                ]
                              : [
                                  disabledFieldNameData("IMEI Number", imeiNo),
                                  disabledFieldNameData(
                                      "Email-ID", TextEditingController()),
                                ],
                        ),
                      ),
                      secondCurve: Curves.ease,
                      crossFadeState: change
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(seconds: 1),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox(),
                      secondChild: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                        child: endButtons(
                          "Submit",
                          () async {
                            if (!step1Done) {
                              // Step 1 for INITIALIZE PHONE:
                              setState(() {
                                submitDone = true;
                              });
                              if (imeiNo.text == "" || dropdownvalue == "") {
                                alertDialogCall("Error",
                                    "All the fields are required to be entered. Please enter all data on this screen.");
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  prefs.setString(spImeiNo, imeiNo.text);
                                  prefs.setString(spEmail, dropdownvalue);
                                  imei = imeiNo.text;
                                  email = dropdownvalue;
                                });
                                Map<String, dynamic> formData = {
                                  "imei": int.parse(imeiNo.text),
                                  "email": dropdownvalue,
                                };
                                try {
                                  await Dio().post("$url/init_phone",
                                      data: formData,
                                      options: Options(
                                          contentType: "application/json"));
                                } on DioException {
                                  setState(() {
                                    isError = true;
                                  });
                                  alertDialogCall("Error",
                                      "We are facing some issues Sorry Please try again after sometime");
                                }
                                if (!isError) {
                                  setState(() {
                                    step1Done = true;
                                  });
                                }
                              }

                              setState(() {
                                submitDone = false;
                              });
                            } else {
                              // Step 2 for USER Data:
                              setState(() {
                                submitDone = true;
                              });
                              if (userpid.text == "") {
                                alertDialogCall("Error",
                                    "All the fields are required to be entered. Please enter all data on this screen.");
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                Map<String, dynamic> formData = {
                                  "pid": int.parse(userpid.text),
                                  "email": dropdownvalue,
                                };
                                try {
                                  await Dio()
                                      .post("$url/signup",
                                          data: formData,
                                          options: Options(
                                              contentType: "application/json"))
                                      .then((value) {
                                    Map<String, dynamic> userData =
                                        value.data["user"];

                                    debugPrint(userData.toString());
                                    debugPrint("${userData["id"]}");

                                    setState(() {
                                      prefs.setInt(spUserId, userData["id"]);
                                      userid = userData["id"] as int;
                                      debugPrint("USERIDDDDD: $userid");
                                    });
                                    service.startService();
                                  });
                                } on DioException {
                                  setState(() {
                                    isError = true;
                                  });
                                  alertDialogCall("Error",
                                      "We are facing some issues Sorry Please try again after sometime");
                                }
                                if (!isError) {
                                  setState(() {
                                    step2Done = true;
                                  });

                                  Navigator.of(context).pushReplacement(
                                      FadeRoute(page: const HomePage()));
                                }
                              }
                              setState(() {
                                submitDone = false;
                              });
                            }
                          },
                        ),
                      ),
                      secondCurve: Curves.ease,
                      crossFadeState: change
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(seconds: 1),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
