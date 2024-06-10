import 'package:cygnus/core/network/base_api_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../../../core/di/configure_injection.dart';
import '../../../core/managers/assets_manager.dart';
import '../../../core/managers/session_manager.dart';
import '../../../core/network/response/api_status.dart';
import '../../utils/Textstyle.dart';
import '../../utils/constants/AppConstants.dart';
import '../../utils/constants/ColorConstants.dart';
import '../../utils/constants/LanguageConstants.dart';
import '../../utils/wrappers/my_button.dart';
import '../my_profile/my_profile.dart';
import '../otp_verification/otp_verification_screen.dart';
import 'login_view_controller.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '712793395246-8nfjmi17jt8bl2ds8hueugjj3hb0oiam.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;
  final _sessionManager = locator<SessionManager>();
  final isLoading = false.obs;
  bool enableBtn = false;
  bool isAPIcallProcess = false;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _selectedCountryISOCode = '';
  String? _selectedCountryCode = "";
  String? _selectedMobileNumber = "";
  String? _deviceId = "";

  late LoginController controller = Get.put(LoginController(
    useCase: locator(),
  ));

  final assetManager = locator<AssetManager>();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //cake image
                  SizedBox(
                    height: screenHeight * 0.4,
                    width: double.infinity,
                    child: Center(
                      child: Image(
                        image: AssetImage(
                          assetManager.getPngImageFilePath(AppConstants.cake),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      LanguageConstants.logintitle.tr(),
                      textAlign: TextAlign.left,
                      style: header24Black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 35),
                    child: Text(
                      LanguageConstants.proceedmobilenumber.tr(),
                      textAlign: TextAlign.left,
                      style: subContent14Black,
                    ),
                  ),
                  //country code picker
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorConstants.greyTwo,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: countryPicker,
                          ),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              onChanged: (value) {
                                _selectedMobileNumber = value;
                                _checkFormValidity();
                              },
                              autovalidateMode: _autovalidateMode,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return LanguageConstants.entermobilenumber
                                      .tr();
                                } else if (value.length < 10) {
                                  return LanguageConstants
                                      .entervalidmobilenumber
                                      .tr();
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText:
                                    LanguageConstants.enteryourmobile.tr(),
                                hintStyle: inputText14Grey,
                                contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Obx(
                    () => MyButton(
                      text: LanguageConstants.continuetext.tr(),
                      color: enableBtn ? Colors.orangeAccent : Colors.grey,
                      onPressed: enableBtn
                          ? () async {
                              setState(() {
                                isAPIcallProcess = true;
                              });

                              // Fetching Device ID
                              try {
                                _deviceId = await PlatformDeviceId.getDeviceId;
                              } on PlatformException {
                                _deviceId = 'Failed to get device id.';
                              }

                              final status = await controller.loginApi(
                                countryCode: countryPicker.selectedCountryCode,
                                mobileNumber: _selectedMobileNumber,
                                deviceId: _deviceId,
                              );

                              setState(() {
                                isAPIcallProcess = false;
                              });

                              if (status is ApiStatus) {
                                if (status.isSuccess) {
                                  Get.off(
                                    () => OTPVerificationScreen(
                                      mobileNumber: _selectedMobileNumber!,
                                      countryCode:
                                          countryPicker.selectedCountryCode,
                                    ),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: status.message,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.redAccent,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LanguageConstants.orconnectwith.tr(),
                        style: subContent14Grey,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _loginWithFacebook();
                            },
                            icon: Image(
                              image: AssetImage(
                                assetManager.getPngImageFilePath(
                                    AppConstants.facebookLogo),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _loginWithGoogle();
                            },
                            icon: Image(
                              image: AssetImage(
                                assetManager.getPngImageFilePath(
                                    AppConstants.googleLogo),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              width: screenHeight < 600 ? double.infinity : 500,
            ),
          ),
        ),
      ),
    );
  }

  void _loginWithFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(
      permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ],
    );

    switch (response.status) {
      case FacebookLoginStatus.success:
        final accessToken = response.accessToken!.token;
        final graphResponse = await fb.getUserProfile();
        final profile = graphResponse!.asMap();

        final user = {
          'id': profile['id'],
          'name': profile['name'],
          'email': profile['email'],
          'imageUrl':
              'https://graph.facebook.com/${profile['id']}/picture?type=normal',
          'token': accessToken,
        };

        _handleSignIn(user);
        break;

      case FacebookLoginStatus.cancel:
        print('Login canceled by the user.');
        break;

      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${response.error}');
        break;
    }
  }

  void _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final user = {
        'id': googleUser.id,
        'name': googleUser.displayName,
        'email': googleUser.email,
        'imageUrl': googleUser.photoUrl,
        'token': googleAuth.accessToken,
      };

      _handleSignIn(user);
    } catch (error) {
      print('Login with Google failed: $error');
    }
  }

  void _handleSignIn(Map<String, dynamic> user) async {
    final status = await controller.socialLoginApi(
      countryCode: countryPicker.selectedCountryCode,
      mobileNumber: _selectedMobileNumber,
      deviceId: _deviceId,
      socialData: user,
    );

    if (status is ApiStatus) {
      if (status.isSuccess) {
        Get.off(
          () => MyProfileScreen(),
        );
      } else {
        Fluttertoast.showToast(
          msg: status.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  void _checkFormValidity() {
    setState(() {
      if (_formKey.currentState!.validate()) {
        enableBtn = true;
      } else {
        enableBtn = false;
      }
    });
  }
}
