import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:active_ecommerce_cms_demo_app/firebase_options.dart';
import 'package:flutter/foundation.dart';

import '../data_model/login_response.dart';
import 'shared_value_helper.dart';

class AuthHelper {
  setUserData(LoginResponse loginResponse) {
    if (loginResponse.result == true) {
      SystemConfig.systemUser = loginResponse.user;
      is_logged_in.$ = true;
      is_logged_in.save();
      access_token.$ = loginResponse.access_token;
      access_token.save();
      user_id.$ = loginResponse.user?.id;
      user_id.save();
      user_name.$ = loginResponse.user?.name;
      user_name.save();
      user_email.$ = loginResponse.user?.email ?? "";
      user_email.save();
      user_phone.$ = loginResponse.user?.phone ?? "";
      user_phone.save();
      avatar_original.$ = loginResponse.user?.avatar_original;
      avatar_original.save();

      // Register FCM device token after login
      _registerDeviceToken();
    }
  }

  static Future<void> _registerDeviceToken() async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Step 1: Get APNS token (iOS only)
      String? apnsToken;
      try {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      } catch (_) {}

      // Step 2: Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        await ProfileRepository().getDeviceTokenUpdateResponse(token);
      } else {
        await Future.delayed(Duration(seconds: 3));
        token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await ProfileRepository().getDeviceTokenUpdateResponse(token);
        }
      }
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  clearUserData() {
    SystemConfig.systemUser = null;
    is_logged_in.$ = false;
    is_logged_in.save();
    access_token.$ = "";
    access_token.save();
    user_id.$ = 0;
    user_id.save();
    user_name.$ = "";
    user_name.save();
    user_email.$ = "";
    user_email.save();
    user_phone.$ = "";
    user_phone.save();
    avatar_original.$ = "";
    avatar_original.save();

    temp_user_id.$ = "";
    temp_user_id.save();
  }

  fetchAndSet() async {
    var userByTokenResponse = await AuthRepository().getUserByTokenResponse();
    if (userByTokenResponse.result == true) {
      setUserData(userByTokenResponse);
    } else {
      clearUserData();
    }
    // Register token on every app start if logged in
    if (is_logged_in.$) {
      _registerDeviceToken();
    }
  }
}
