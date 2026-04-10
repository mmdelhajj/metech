import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'dart:convert';

import '../../main.dart';

class Otp extends StatefulWidget {
  final String? title;
  const Otp({super.key, this.title});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String? _verificationId;
  int? _resendToken;
  bool _codeSent = false;
  bool _isVerifying = false;
  bool _isSendingCode = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    super.initState();
    _sendFirebaseOTP();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  void _sendFirebaseOTP() async {
    String phone = user_phone.$ ?? "";
    if (phone.isEmpty) {
      ToastComponent.showDialog("Phone number not available");
      return;
    }

    if (!phone.startsWith("+")) {
      phone = "+$phone";
    }

    setState(() {
      _isSendingCode = true;
    });

    try {
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          _verificationCodeController.text = credential.smsCode ?? "";
          _verifyWithFirebase(credential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _isSendingCode = false;
            });
          }
          _showErrorDialog(
            "Firebase Verification Failed",
            "CODE: ${e.code}\n\nMESSAGE: ${e.message}\n\nPLUGIN: ${e.plugin}\n\nTENANT: ${e.tenantId}",
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
              _codeSent = true;
              _isSendingCode = false;
            });
          }
          ToastComponent.showDialog("Verification code sent!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
            });
          }
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
      String type = e.runtimeType.toString();
      String details = e.toString();
      if (e is firebase_auth.FirebaseAuthException) {
        details = "CODE: ${e.code}\n\nMESSAGE: ${e.message}\n\nPLUGIN: ${e.plugin}";
      }
      _showErrorDialog(
        "Exception caught ($type)",
        "$details\n\nSTACK:\n${stackTrace.toString().substring(0, stackTrace.toString().length > 500 ? 500 : stackTrace.toString().length)}",
      );
    }
  }

  void _showErrorDialog(String title, String body) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: SelectableText(body, style: TextStyle(fontSize: 12)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _verifyWithFirebase(firebase_auth.PhoneAuthCredential credential) async {
    setState(() {
      _isVerifying = true;
    });

    try {
      await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      await _confirmOnServer();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
      if (e.code == "invalid-verification-code") {
        ToastComponent.showDialog("Invalid verification code");
      } else {
        ToastComponent.showDialog(e.message ?? "Verification failed");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
      ToastComponent.showDialog("Error: $e");
    }
  }

  Future<void> _confirmOnServer() async {
    try {
      String url = "${AppConfig.BASE_URL}/auth/confirm_firebase_phone";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
          ...commonHeader,
        },
        body: jsonEncode({}),
      );

      final data = jsonDecode(response.body);

      if (data["result"] == true) {
        ToastComponent.showDialog(data["message"] ?? "Account verified!");
        if (SystemConfig.systemUser != null) {
          SystemConfig.systemUser!.emailVerified = true;
        }
        try {
          await firebase_auth.FirebaseAuth.instance.signOut();
        } catch (_) {}
        if (mounted) {
          context.go("/");
        }
      } else {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
        ToastComponent.showDialog(
            data["message"] ?? "Server verification failed");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
      ToastComponent.showDialog("Server error: $e");
    }
  }

  void onPressConfirm() {
    var code = _verificationCodeController.text.toString().trim();

    if (code.isEmpty) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_verification_code,
      );
      return;
    }

    if (_verificationId == null) {
      ToastComponent.showDialog("Please wait for code to be sent");
      return;
    }

    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );
    _verifyWithFirebase(credential);
  }

  void onTapResend() {
    _sendFirebaseOTP();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              color: Colors.red,
              width: screenWidth,
              height: 200,
              child: Image.asset(
                'assets/splash_login_registration_background_image.png',
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 25,
                          color: MyTheme.font_grey,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                      child: SizedBox(
                        width: 75,
                        height: 75,
                        child: Image.asset(
                          'assets/login_registration_form_logo.png',
                        ),
                      ),
                    ),
                    if (_isSendingCode)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: MyTheme.accent_color,
                            ),
                            SizedBox(height: 10),
                            Text("Sending verification code...",
                                style: TextStyle(color: MyTheme.font_grey)),
                          ],
                        ),
                      ),
                    if (_isVerifying)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: MyTheme.accent_color,
                            ),
                            SizedBox(height: 10),
                            Text("Verifying...",
                                style: TextStyle(color: MyTheme.font_grey)),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: screenWidth * (3 / 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 36,
                                  child: TextField(
                                    controller: _verificationCodeController,
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecorations
                                        .buildInputDecoration_1(
                                      hintText: "Enter 6-digit code",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: MyTheme.textfield_grey,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              child: Btn.basic(
                                minWidth: MediaQuery.of(context).size.width,
                                color: MyTheme.accent_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.confirm_ucf,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  onPressConfirm();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: InkWell(
                        onTap: () {
                          onTapResend();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.resend_code_ucf,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: InkWell(
                        onTap: () {
                          onTapLogout(context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.logout_ucf,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onTapLogout(context) {
    try {
      firebase_auth.FirebaseAuth.instance.signOut();
      AuthHelper().clearUserData();
      routes.push("/");
    } catch (e) {
      // ignore
    }
  }
}
