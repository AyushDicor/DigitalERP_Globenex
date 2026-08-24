import 'dart:convert';
import 'dart:developer';

import 'package:digitalerp/model/response_model.dart';
import 'package:http/http.dart' as http;

import 'base_api_helper.dart';
import 'base_url.dart';

/// Employee Master API surface.
///
/// The save endpoint is NOT live yet — the backend team is building it. Until
/// it is deployed [saveEmployeeMaster] returns a 404; the controller reports
/// that as "endpoint not live yet" rather than a generic failure, so a tester
/// can tell a missing API apart from a broken form.
///
/// The dropdowns this screen needs (designation, department, state, city) are
/// already live and are served by the existing Api class, not from here.
class EmployeeMasterRepo {
  /// POST the completed Employee Master form.
  static Future<ResponseItem> saveEmployeeMaster(
      Map<String, dynamic> requestData) async {
    try {
      final url = AppUrls.baseUrl + MethodName.saveEmployeeMaster;
      log('SaveEmployeeMaster → $url');
      log('SaveEmployeeMaster body: ${jsonEncode(requestData)}');
      return await BaseApiHelper.postRequest(url, requestData);
    } catch (e) {
      return ResponseItem(
        status: false,
        message: 'saveEmployeeMaster: ${e.toString()}',
      );
    }
  }

  /// Uploads one attachment (photo / Aadhar / PAN) and returns the response.
  ///
  /// Deliberately reuses the shared upload endpoint the Reimbursement and
  /// Payment Request modules already post to — it is a generic file sink that
  /// answers with the stored file name, so Employee Master does not need a
  /// second upload API from the backend.
  static Future<ResponseItem> uploadEmployeeFile(String filePath) async {
    try {
      final url = AppUrls.baseUrl + MethodName.uploadReimbursementFile;
      log('UploadEmployeeFile → $filePath');

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      log('UploadEmployeeFile response [${streamed.statusCode}]: $body');

      if (streamed.statusCode == 200) {
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        return ResponseItem(
          status: true,
          statusCode: 200,
          data: jsonMap,
          message: jsonMap['message']?.toString(),
        );
      }
      return ResponseItem(
        status: false,
        statusCode: streamed.statusCode,
        message: 'Upload failed: HTTP ${streamed.statusCode}',
      );
    } catch (e, s) {
      log('uploadEmployeeFile exception: $e', stackTrace: s);
      return ResponseItem(
        status: false,
        message: 'uploadEmployeeFile: ${e.toString()}',
      );
    }
  }
}
