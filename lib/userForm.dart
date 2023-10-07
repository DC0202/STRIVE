import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strive/values.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool submitDone = false;
  bool isError = false;

  late TextEditingController userpid;
  late TextEditingController imeiNo;
  late TextEditingController eMail;

  String dropdownvalue = '';

  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        userpid = TextEditingController(text: userid.toString());
        imeiNo = TextEditingController(text: imei);
        eMail = TextEditingController(text: email);
        userid = userid;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    userpid.dispose();
    imeiNo.dispose();
    eMail.dispose();
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
              keyboardType:
                  text == "PID" ? TextInputType.number : TextInputType.name,
              textInputAction: TextInputAction.done,
              controller: textEditingController,
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
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 17.0),
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
              : Container(
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
        const SizedBox(),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: const Color(0xFFD7F3F9),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    "User Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36.0,
                    ),
                  ),
                  const SizedBox(
                    height: 60.0,
                  ),
                  fieldNameData("PID", userpid),
                  disabledFieldNameData("IMEI Number", imeiNo),
                  disabledFieldNameData("Email-ID", eMail),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                    child: endButtons(
                      "Submit",
                      () async {
                        setState(() {
                          submitDone = true;
                        });
                        if (userpid.text == "") {
                          alertDialogCall("Error",
                              "All the fields are required to be entered. Please enter all data on this screen.");
                        } else {
                          Map<String, dynamic> formData = {
                            "pid": int.parse(userpid.text),
                            "email": email,
                          };
                          try {
                            Dio dio = Dio();
                            await dio
                                .post("$url/signup",
                                    data: formData,
                                    options: Options(
                                        contentType: "application/json"))
                                .then((value) async {
                              debugPrint(value.toString());
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              debugPrint(value.data["user"].toString());
                              Map<dynamic, dynamic> userData =
                                  value.data["user"];
                              setState(() {
                                prefs.setInt(spUserId, userData["id"]);
                                userid = userData["id"];
                              });
                              debugPrint("DATA SENT1");
                              Navigator.of(context).pop();
                            });
                          } on DioException catch (e) {
                            debugPrint(e.error.toString());
                            setState(() {
                              isError = true;
                            });
                            alertDialogCall("Error",
                                "We are facing some issues Sorry Please try again after sometime");
                          }
                          if (!isError) {
                            setState(() {
                              submitDone = false;
                            });
                            debugPrint("DATA SENT");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 30.0,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
