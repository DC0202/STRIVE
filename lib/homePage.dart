import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:strive/userForm.dart';
import 'package:strive/values.dart';
import 'transitionAnimation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedVal = 0;

  TextEditingController q2 = TextEditingController();
  TextEditingController q3 = TextEditingController();
  TextEditingController pass = TextEditingController();

  Position? _currentPosition;

  File? image;
  bool imageSelected = false;
  String fileName = "";

  double lat = 0.0;
  double long = 0.0;

  double initialLat = 0.0;
  double initialLong = 0.0;

  double imageLat = 0.0;
  double imageLong = 0.0;

  int startTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  int endTime = 0;

  bool loading = false;

  Future<void> callBack() async {
    await _getCurrentPosition();
    setState(() {
      initialLat = lat;
      initialLong = long;
    });
    // AndroidBatteryInfo? batteryData =
    //     await BatteryInfoPlugin().androidBatteryInfo;
    // Map<String, dynamic> formData = {
    //   "user_id": userid,
    //   "battery_percentage": batteryData!.batteryLevel,
    //   "battery_status": batteryData.health.toString(),
    //   "lat": lat,
    //   "long": long,
    //   "sample_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    // };

    // try {
    //   await Dio().post("$url/location",
    //       data: formData, options: Options(contentType: "application/json"));
    // } on DioException {
    //   alertDialogCall("Error",
    //       "We are facing some issues Sorry Please try again after sometime");
    // }
    // debugPrint("Hello World");
    // Workmanager()
    //     .registerOneOffTask("uniqueName", "Back-UP")
    //     .then((value) => Timer(const Duration(seconds: 18), () async {
    //           callBack();
    //         }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await callBack();
    });
  }

  @override
  void dispose() {
    super.dispose();
    q2.dispose();
    q3.dispose();
    pass.dispose();
  }

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        lat = _currentPosition!.latitude;
        long = _currentPosition!.longitude;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future pickImage(int val) async {
    try {
      final image = await ImagePicker().pickImage(
          source: val == 1 ? ImageSource.camera : ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      var dataVal = await getLocationDataFromImage(image.path);
      setState(() {
        this.image = imageTemp;
        imageSelected = !imageSelected;
        fileName = image.path.split('/').last;
        imageLat = dataVal!.latitude;
        imageLong = dataVal.longitude;
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<GeoPoint?> getLocationDataFromImage(String filePath) async {
    GeoPoint? preciseLocation;
    final exif = await Exif.fromPath(filePath);
    final latLong = await exif.getLatLong();
    await exif.close();
    if (latLong != null) {
      preciseLocation =
          GeoPoint(latitude: latLong.latitude, longitude: latLong.longitude);
      return preciseLocation;
    }
    return GeoPoint(latitude: 0, longitude: 0);
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

  Widget imageButton(String text1, int val) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFF0),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Material(
        color: Colors.white,
        elevation: 4.0,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: () => val == 0 ? pickImage(0) : pickImage(1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Text(
              text1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF585858),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget endButtons(String text1, call) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFF0),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Material(
        color: Colors.white,
        elevation: 4.0,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: loading && text1 == "SUBMIT" ? () {} : call,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 21.0),
            child: Center(
              child: loading && text1 == "SUBMIT"
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

  Widget stressButton(String text1, int index) {
    return FittedBox(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          border: Border.all(
            width: 1.0,
            color: Colors.black,
          ),
        ),
        child: Material(
          elevation: 4.0,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () {
              setState(() {
                selectedVal = index + 1;
              });
            },
            child: Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: selectedVal == index + 1
                    ? const Color(0xFF89E3F0).withOpacity(0.39)
                    : Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF585858),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  text1 == "1"
                      ? const Text(
                          "Low",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF585858),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox(),
                  text1 == "7"
                      ? const Text(
                          "High",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF585858),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  passAlertDialog(String title) {
    var formKey = GlobalKey<FormState>();
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
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: pass,
            validator: (text) {
              if (text != password) {
                return "Wrong Password";
              }
              return null;
            },
            decoration: const InputDecoration(hintText: "Enter Password"),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                pass.clear();
              });
              Navigator.of(ctx).pop();
            },
            child: Container(
              color: Colors.white,
              // padding: const EdgeInsets.all(14),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final form = formKey.currentState;
              if (form!.validate()) {
                if (pass.text == password) {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(FadeRoute(page: const UserForm()));
                }
              }
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFFD7F3F9),
          child: Scrollbar(
            thickness: 10.0,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                    child: Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        color: Colors.white,
                      ),
                      child: Material(
                        color: Colors.white,
                        elevation: 4.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50.0)),
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          onTap: () {
                            passAlertDialog("Password");
                          },
                          child: const Icon(
                            Icons.settings,
                            size: 28.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "Stress Journal",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 5.0),
                  child: Text(
                    "Please take a picture of the area where you experienced stress",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                !imageSelected
                    ? Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 17.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: imageButton("Choose From\nGallery", 0),
                            ),
                            const Expanded(child: SizedBox()),
                            Expanded(
                                flex: 10, child: imageButton("Take\nPhoto", 1)),
                          ],
                        ),
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.fromLTRB(120.0, 0.0, 120.0, 17.0),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Material(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          opaque: false,
                                          barrierDismissible: true,
                                          pageBuilder:
                                              (BuildContext context, _, __) {
                                            return Hero(
                                              tag: "zoom",
                                              child: Material(
                                                color: Colors.black
                                                    .withOpacity(0.9),
                                                child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Image.file(image!)),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: "zoom",
                                      child: Image.file(
                                        image!,
                                        fit: BoxFit.fitWidth,
                                        width: 100.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  elevation: 4.0,
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        image = null;
                                        imageSelected = !imageSelected;
                                      });
                                    },
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0)),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close,
                                        size: 20.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                  child: Text(
                    "Select your Stress Level",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 17.0),
                  child: SizedBox(
                    height: 40.0,
                    child: Center(
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          width: 5.0,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return stressButton((index + 1).toString(), index);
                        },
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                  child: Text(
                    "Please discuss what is causing you stress",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 17.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Colors.white,
                    ),
                    child: TextField(
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      controller: q2,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        hintText: 'Type Here',
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                  child: Text(
                    "Please discuss how you are responding to this situation or how you will respond to this situation",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 17.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Colors.white,
                    ),
                    child: TextField(
                      maxLines: 3,
                      controller: q3,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        hintText: 'Type Here',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: endButtons(
                          "RESET",
                          () async {
                            setState(() {
                              q2.clear();
                              q3.clear();
                              selectedVal = 0;
                              imageSelected = false;
                              image = null;
                              imageLat = 0.0;
                              imageLong = 0.0;
                              startTime =
                                  (DateTime.now().millisecondsSinceEpoch ~/
                                      1000);
                            });
                            await _getCurrentPosition();
                            setState(() {
                              initialLat = lat;
                              initialLong = long;
                            });
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        flex: 10,
                        child: endButtons(
                          "SUBMIT",
                          () async {
                            setState(() {
                              loading = true;
                            });
                            if (q2.text == "" ||
                                q3.text == "" ||
                                selectedVal == 0) {
                              alertDialogCall("Error",
                                  "Please complete all elements of the survey before submitting. Image/Photo is not required.");
                            } else {
                              await _getCurrentPosition();
                              FormData formData = FormData.fromMap({
                                "stress_level": selectedVal,
                                "cause": q2.text,
                                "situation": q3.text,
                                "image": image == null
                                    ? MultipartFile.fromString(
                                        "",
                                        filename: "",
                                      )
                                    : await MultipartFile.fromFile(
                                        image!.path,
                                        filename: fileName,
                                      ),
                                "start_time": startTime,
                                "end_time":
                                    DateTime.now().millisecondsSinceEpoch ~/
                                        1000,
                                "user_id": userid,
                                "stress_lat": initialLat,
                                "stress_long": initialLong,
                                "image_lat": imageLat,
                                "image_long": imageLong,
                                "submitted_lat": lat,
                                "submitted_long": long,
                                "status": "SUBMITTED"
                              });
                              Dio dio = Dio();
                              await dio
                                  .post(
                                "$url/survey",
                                data: formData,
                              )
                                  .then((response) {
                                alertDialogCall("Success",
                                        "You have successfully submitted the form")
                                    .then((value) async {
                                  setState(() {
                                    q2.clear();
                                    q3.clear();
                                    selectedVal = 0;
                                    imageSelected = false;
                                    image = null;
                                    imageLat = 0.0;
                                    imageLong = 0.0;
                                    startTime = (DateTime.now()
                                            .millisecondsSinceEpoch ~/
                                        1000);
                                  });
                                  await _getCurrentPosition();
                                  setState(() {
                                    initialLat = lat;
                                    initialLong = long;
                                  });
                                });
                              }).catchError((error) => alertDialogCall("Error",
                                      "We are facing some issues Sorry Please try again after sometime"));
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
