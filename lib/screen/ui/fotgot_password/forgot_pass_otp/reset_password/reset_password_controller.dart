import 'package:digitalerp/app_routes/app_routes.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/fotgot_password/forgot_pass_otp/forgot_pass_otp_controller.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ResetPasswordController extends AppBaseController {
  /// Userid returned by the OTP-verify API, captured when this controller is
  /// created. Never hold a `Get.find()` of [ForgotPassOtpController] in a field:
  /// this controller is rebuilt by `GetBuilder(init: ...)` on every rebuild of
  /// the view (e.g. when the keyboard opens), and by then the OTP page may
  /// already be gone, which made `Get.find` throw and blanked the screen.
  final String userId = Get.isRegistered<ForgotPassOtpController>()
      ? (Get.find<ForgotPassOtpController>().responseData ?? '')
      : '';
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  bool isShowPassword = true;

  Future<void> clickOResetPassword() async {
    passwordFocus.unfocus();
    confirmPasswordFocus.unfocus();
    setBusy(true);
    try {
      if (_isValidate()) {
        Map<String, String> body = {};
        body[RequestKeys.userId] = userId;
        body[RequestKeys.newPassword] = confirmPasswordCtrl.text.trim();
        var res = await api.resetPassword(body);
        if (res.status == 200) {
          Get.offAllNamed(AppRoutes.login);
          ShowMessage.showSnackBar('success', res.message.toString());
        } else {
          ShowMessage.showSnackBar('Server Res', res.message.toString());
        }
      }
    } catch (e) {
      ShowMessage.showSnackBar('Server Res', '$e');
    } finally {
      setBusy(false);
    }
  }

  void tapOnShowPassword() {
    isShowPassword = !isShowPassword;
    update();
  }

  bool _isValidate() {
    if (userId.isEmpty) {
      ShowMessage.showSnackBar(
        'Session Expired',
        'Please verify the OTP again.',
      );
      return false;
    }
    if (passwordCtrl.text.isEmpty) {
      ShowMessage.showSnackBar(
        AppString.requiredFieldTxt.tr,
        AppString.pleaseEnterPasswordTxt.tr,
      );
      return false;
    }
    if (passwordCtrl.text.toString() != confirmPasswordCtrl.text.toString()) {
      ShowMessage.showSnackBar(
        AppString.requiredFieldTxt.tr,
        AppString.passAnConPassNotMatchTxt.tr,
      );
      return false;
    }
    return true;
  }
}
