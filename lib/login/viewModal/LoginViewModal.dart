import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rxdart/rxdart.dart';
import '../models/model/login_model.dart';
import '../models/model/user_model.dart';
import '../models/service/auth_api.dart';
import '../view/Page.dart';

class LoginViewModel extends ChangeNotifier {
  final api = AuthApi(Dio(BaseOptions(
      contentType: 'application/json', validateStatus: ((status) => true)))
    ..interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90)));

  final BehaviorSubject<bool> isLoading = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> isLoadingResend =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> modal = BehaviorSubject<String?>();
  final BehaviorSubject<String?> userModel = BehaviorSubject<String?>();
  final BehaviorSubject<int> count = BehaviorSubject<int>.seeded(60);
  final BehaviorSubject<String?> errorText = BehaviorSubject<String?>();

  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (count.value != 0) {
        count.add(count.value - 1);
      } else {
        timer?.cancel();
      }
    });
  }

  void resetTimer() {
    count.add(60);
    startTimer();
  }

  void disposeTimer() {
    timer?.cancel();
    count.add(60);
  }

  Future<void> loginUser({required String mobileNumber}) async {
    isLoading.add(true);
    try {
      final res = await api.loginUser({'phone_number': mobileNumber});
      if (res.response.statusCode == 200) {
        LoginModel model = LoginModel.fromJson(res.data);
        modal.add(model.identificationToken);
      }
      else {
        String msg = "";
        try {
          msg = res.data["message"].toString();
        } catch (e) {
          msg = "${res.response.statusCode} ${res.response.statusMessage}";
        }
      }
    } finally {
      isLoading.add(false);
    }
  }

  Future<void> resendOTP() async {
    isLoadingResend.add(true);
    try {
      String token = modal.value ?? '';
      final res = await api.resendOtp({'identification_token': token});
      if (res.response.statusCode == 200) {
        LoginModel model = LoginModel.fromJson(res.data);
      } else {}
    } finally {
      isLoadingResend.add(false);
    }
  }

  Future<void> submitOTP(
      {required String otp, required BuildContext context}) async {
    isLoading.add(true);
    try {
      String token = modal.value ?? '';
      final res = await api.submitOtp(
        {
          'identification_token': token,
          'otp': otp,
        },
        'Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D)',
      );

      if (res.response.statusCode == 200) {
        UserDetails userData = UserDetails.fromJson(res.data);
        userModel.add(userData.user?.name);
        if (userData.user?.onboarding == "started") {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: ((context) {
              return Container(
                  height: 100,
                  color: Colors.white,
                  width: 100,
                  child: Center(child: Text('New User')));
            }),
          );
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PageOne()));
        }
      } else {
        String msg = "";


        if (res.response.statusCode == 401) {
          try {
            msg = res.data["message"].toString();
            errorText.add(msg);
          } catch (e) {
            msg = "${res.response.statusMessage}";
          }
        } else {
          try {
            msg = res.data["message"].toString();
          } catch (e) {
            msg = "${res.response.statusCode} ${res.response.statusMessage}";
          }
        }
      }
    } on Error catch (e) {
      // Handle Dio errors
    } finally {
      isLoading.add(false);
    }
  }

  @override
  void dispose() {
    isLoadingResend.close();
    count.close();
    errorText.close();
    super.dispose();
  }
}
