import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:auresia/launchScreen.dart';
import 'package:auresia/location_service.dart';
import 'package:auresia/values.dart';
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

  var items = [
    'Logout',
  ];

  Future<void> callBack() async {
    await _getCurrentPosition();
    setState(() {
      initialLat = lat;
      initialLong = long;
    });
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
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                  color: Colors.black,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  alertLogoutCall() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Alert",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Text(
          "Are you sure you want to logout?",
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
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final LocationService _locationService = LocationService();
              SharedPreferences _prefs = await SharedPreferences.getInstance();
              await _prefs.remove(spUserId);
              await _prefs.remove(sppassword);
              userId = 0;
              password = '';
              checkUID = false;
              setState(() {});
              await _prefs.reload();
              if (Platform.isIOS) await _locationService.stopLocationService();
              Navigator.of(context).pushAndRemoveUntil(
                FadeRoute(page: const LaunchScreen()),
                (route) => false,
              );
            },
            child: Container(
              color: Colors.white,
              child: Text(
                "Okay",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10.sp,
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
      width: MediaQuery.of(context).size.width,
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
            padding: EdgeInsets.symmetric(vertical: 3.75.h),
            child: Text(
              text1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: Color(0xFF585858),
                fontWeight: FontWeight.bold,
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
            padding: EdgeInsets.symmetric(vertical: 2.5.h),
            child: Center(
              child: loading && text1 == "SUBMIT"
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
                        fontSize: 11.sp,
                        color: const Color(0xFF585858),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
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
                width: 5.h,
                height: 5.h,
                decoration: BoxDecoration(
                  color: selectedVal == index + 1
                      ? const Color(0xFFC7C7FF)
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF585858),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 0.75.h,
        ),
        if (text1 == "1")
          Text(
            "Low",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: Color(0xFF585858),
              fontWeight: FontWeight.bold,
            ),
          ),
        if (text1 == "7")
          Text(
            "High",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: Color(0xFF585858),
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
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
          color: const Color(0xFFE6E6FA),
          child: Scrollbar(
            thickness: 10.0,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: 2.5.h,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8.w),
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.power_settings_new,
                          color: Colors.transparent,
                          size: 3.5.h,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "AURESIA",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8.w),
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            alertLogoutCall();
                          },
                          child: Icon(
                            Icons.logout,
                            color: Colors.black,
                            size: 3.5.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 1.h, 0, 0.75.h),
                        child: Text(
                          "Please take a picture of the area where you experienced stress",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      !imageSelected
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(0, 0.0, 0, 2.h),
                              child: imageButton("Take Photo", 1),
                            )
                          : Padding(
                              padding:
                                  EdgeInsets.fromLTRB(30.w, 0.0, 30.w, 2.h),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Material(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                opaque: false,
                                                barrierDismissible: true,
                                                pageBuilder:
                                                    (BuildContext context, _,
                                                        __) {
                                                  return Hero(
                                                    tag: "zoom",
                                                    child: Material(
                                                      color: Colors.black
                                                          .withOpacity(0.9),
                                                      child: InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Image.file(
                                                              image!)),
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
                                              fit: BoxFit.cover,
                                              width: 28.w,
                                              height: 16.h,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: 2.5.h,
                                      width: 2.5.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20.0),
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
                                          Radius.circular(20.0),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              image = null;
                                              imageSelected = !imageSelected;
                                            });
                                          },
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 1.5.h,
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0.0, 0, 0.75.h),
                        child: Text(
                          "Select your Stress Level",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0.0, 0, 1.h),
                        child: SizedBox(
                          height: 9.5.h,
                          child: Center(
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 7,
                              separatorBuilder:
                                  (BuildContext context, int index) => SizedBox(
                                width: 1.5.w,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return stressButton(
                                    (index + 1).toString(), index);
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0.0, 0, 0.75.h),
                        child: Text(
                          "Please discuss what is causing you stress",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0.0, 0, 2.h),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            color: Colors.white,
                          ),
                          child: TextField(
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                            controller: q2,
                            style: TextStyle(fontSize: 12.sp),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              hintText: 'Type Here',
                              hintStyle: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0.0, 0, 0.75.h),
                        child: Text(
                          "Please discuss how you are responding to this situation or how you will respond to this situation",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0.0, 0, 2.h),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            color: Colors.white,
                          ),
                          child: TextField(
                            maxLines: 3,
                            controller: q3,
                            style: TextStyle(fontSize: 12.sp),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              hintText: 'Type Here',
                              hintStyle: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // Expanded(
                          //   flex: 10,
                          //   child: endButtons(
                          //     "RESET",
                          //     () async {
                          //       setState(() {
                          //         q2.clear();
                          //         q3.clear();
                          //         selectedVal = 0;
                          //         imageSelected = false;
                          //         image = null;
                          //         imageLat = 0.0;
                          //         imageLong = 0.0;
                          //         startTime =
                          //             (DateTime.now().millisecondsSinceEpoch ~/
                          //                 1000);
                          //       });
                          //       await _getCurrentPosition();
                          //       setState(() {
                          //         initialLat = lat;
                          //         initialLong = long;
                          //       });
                          //     },
                          //   ),
                          // ),
                          // const Expanded(child: SizedBox()),
                          Expanded(
                            // flex: 10,
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
                                      "Please complete all elements of the survey before submitting. Photo is not required.");
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
                                    "user_id": userId,
                                    "stress_lat": initialLat,
                                    "stress_long": initialLong,
                                    "image_lat": imageLat,
                                    "image_long": imageLong,
                                    "submitted_lat": lat,
                                    "submitted_long": long,
                                    "status": "SUBMITTED"
                                  });
                                  await Dio()
                                      .post(
                                    "$url/surveys",
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
                                  }).catchError((error) {
                                    print(error);
                                    setState(() {
                                      loading = false;
                                    });
                                    alertDialogCall("Error",
                                        "We are facing some issues Sorry Please try again after sometime");
                                  });
                                }
                                setState(() {
                                  loading = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.5.h,
                      ),
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
