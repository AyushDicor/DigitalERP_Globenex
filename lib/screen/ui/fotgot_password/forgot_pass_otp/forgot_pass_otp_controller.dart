import 'dart:async';

import 'package:digitalerp/app_routes/app_routes.dart';
import 'package:digitalerp/response/forgot_pass_response.dart';
import 'package:digitalerp/response/login_response.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/fotgot_password/forgot_password_controller.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ForgotPassOtpController extends AppBaseController {
  /// Values carried over from the Forgot Password screen, captured at creation
  /// time instead of keeping a `Get.find()` reference: this controller is
  /// re-created by `GetBuilder(init: ...)` on every rebuild of the view, so a
  /// hard `Get.find` would throw once that page is disposed.
  final ForgotPassResData? _forgotData =
      Get.isRegistered<ForgotPasswordController>()
          ? Get.find<ForgotPasswordController>().responseData
          : null;

  String get mobileNo => _forgotData?.mobileNo?.toString() ?? '';

  String get otpHint => _forgotData?.otp?.toString() ?? '';

  int secondsRemaining = 59;
  bool enableResend = false;
  Timer? timer;
  String? responseData;

  final TextEditingController otpController = TextEditingController();

  bool isOneMinuteDone = false;
  UserData? userData;




  void tapOnVerify() async {
    setBusy(true);
    try {
      if (_validate()) {
      forgotOtpVerifyAPI();
      }
    } catch (e) {
      ShowMessage.showSnackBar('Catch', 'Something went wrong');
    } finally {
      setBusy(false);
    }
  }

  void forgotOtpVerifyAPI() async {
    try {
      Map<String, String> body = {};
      body[RequestKeys.mobileNo] = mobileNo;
      body[RequestKeys.otp] = otpController.value.text;
      var res = await api.forgotOtpVerifyAPI(body);
      if (res.status == 200) {
        responseData = res.data?.userid.toString();
        // Push instead of `offAndToNamed`: the Reset Password screen reads the
        // userid from this controller, so this page must stay on the stack.
        // It also makes Back return here rather than to Forgot Password.
        Get.toNamed(AppRoutes.resetPassword);
      } else {
        ShowMessage.showSnackBar('Failed Server Res', res.message.toString());
      }
    } catch (e) {
      ShowMessage.showSnackBar('Catch Server Res', '$e');
    } finally {}
  }

  bool _validate() {
    if (otpController.value.text.isEmpty) {
      ShowMessage.showSnackBar('Field Empty', 'Please Enter OTP');
      return false;
    }
    return true;
  }
}
