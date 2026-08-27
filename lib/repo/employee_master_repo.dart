import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:digitalerp/model/response_model.dart';
import 'package:http/http.dart' as http;

import 'base_api_helper.dart';
import 'base_url.dart';

/// Employee Master API surface.
///
/// The backend has named the routes but has NOT deployed them yet. Use
/// [isNotDeployed] on any failed [ResponseItem] to tell "the API does not exist
/// yet" apart from "the API rejected this" — the screens report those very
/// differently, so a tester is never left guessing which one they hit.
class EmployeeMasterRepo {
  /// True when a failure looks like a missing route rather than a real error.
  ///
  /// IIS answers an undeployed route with an HTML 404 page, which
  /// [BaseApiHelper] cannot json-decode — that surfaces as "Bad response
  /// format" with no status code, never as a clean 404. A live JSON API always
  /// answers with JSON, so both signals mean the same thing here.
  static bool isNotDeployed(ResponseItem res) {
    if (res.status == true) return false;
    if (res.statusCode == 404) return true;
    final msg = (res.message ?? '').toLowerCase();
    return msg.contains('bad response format');
  }

  /// Whether the CALL succeeded, as opposed to merely reaching the server.
  ///
  /// [BaseApiHelper] marks any HTTP 200 as `status: true`, but this API answers
  /// 200 even when it rejects the request — a JSON save came back 200 with
  /// "Please send data as multipart/form-data" and nothing was written. So the
  /// body's own success/status fields are the authority here, not the HTTP code.
  static bool succeeded(ResponseItem res) {
    if (res.status != true) return false;
    final body = res.data;
    if (body is Map) {
      final ok = body['success'] ?? body['Success'];
      if (ok is bool) return ok;
      if (ok is String) return ok.toLowerCase() == 'true';
      final st = body['status'] ?? body['Status'];
      if (st is num) return st == 200;
      if (st is String) return st == '200';
    }
    return true;
  }

  /// POST the completed Employee Master form.
  ///
  /// Sent as multipart/form-data, not JSON: the endpoint rejects a JSON body
  /// with "Please send data as multipart/form-data" — while still answering
  /// HTTP 200, so the rejection is invisible unless the body is read.
  /// [files] maps a form part name to a local file path — the ERP takes the
  /// scans as real file parts (`photo`, `aadharfile`, `panfile`) and answers
  /// with the stored `photourl` / `aadharfileurl` / `panfileurl`.
  static Future<ResponseItem> saveEmployeeMaster(
    Map<String, dynamic> requestData, {
    Map<String, String> files = const {},
  }) async {
    try {
      final url = AppUrls.baseUrl + MethodName.saveEmployeeMaster;
      log('SaveEmployeeMaster → $url');
      log('SaveEmployeeMaster fields: ${jsonEncode(requestData)}');
      if (files.isNotEmpty) log('SaveEmployeeMaster files: $files');
      return await _postForm(url, requestData, files: files);
    } catch (e) {
      return ResponseItem(
        status: false,
        message: 'saveEmployeeMaster: ${e.toString()}',
      );
    }
  }

  /// Posts [fields] as multipart/form-data and decodes the JSON reply.
  ///
  /// Every value is flattened to a string — multipart has no types, and the
  /// ERP reads these as form values.
  static Future<ResponseItem> _postForm(
    String url,
    Map<String, dynamic> fields, {
    Map<String, String> files = const {},
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    fields.forEach((k, v) => request.fields[k] = v?.toString() ?? '');

    for (final entry in files.entries) {
      if (entry.value.isEmpty) continue;
      // A file the user removed, or a path the OS has since cleaned up,
      // should not sink the whole save.
      if (!File(entry.value).existsSync()) {
        log('skipping missing attachment ${entry.key}: ${entry.value}');
        continue;
      }
      request.files
          .add(await http.MultipartFile.fromPath(entry.key, entry.value));
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    log('POST(form) $url [${streamed.statusCode}]: $body');

    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      // A non-JSON reply from a route that should serve JSON means the route
      // is not there — same signal [isNotDeployed] looks for.
      return ResponseItem(
        status: false,
        statusCode: streamed.statusCode,
        message: 'Bad response format',
      );
    }

    return ResponseItem(
      status: streamed.statusCode == 200 || streamed.statusCode == 201,
      statusCode: streamed.statusCode,
      data: decoded,
      message: decoded is Map ? decoded['message']?.toString() : null,
    );
  }

  /// The employee list behind the module's landing screen.
  static Future<ResponseItem> getEmployeeList(
      Map<String, dynamic> requestData) async {
    try {
      final url = AppUrls.baseUrl + MethodName.employeeMasterList;
      log('EmployeeOnboardingList → $url');
      log('EmployeeOnboardingList body: ${jsonEncode(requestData)}');
      final res = await BaseApiHelper.postRequest(url, requestData);
      // BaseApiHelper does not log bodies, and these routes answer 200 even
      // when they reject the request — so log what actually came back.
      log('reply from $url: ${jsonEncode(res.data)}');
      return res;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: 'getEmployeeList: ${e.toString()}',
      );
    }
  }

  /// One employee's full record, for the read-only detail screen.
  static Future<ResponseItem> getEmployeeDetail(
      Map<String, dynamic> requestData) async {
    try {
      final url = AppUrls.baseUrl + MethodName.employeeMasterDetail;
      log('EmployeeOnboardDetail → $url');
      log('EmployeeOnboardDetail body: ${jsonEncode(requestData)}');
      final res = await BaseApiHelper.postRequest(url, requestData);
      // BaseApiHelper does not log bodies, and these routes answer 200 even
      // when they reject the request — so log what actually came back.
      log('reply from $url: ${jsonEncode(res.data)}');
      return res;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: 'getEmployeeDetail: ${e.toString()}',
      );
    }
  }

  /// Everything printed on the ID card, straight from the ERP — company name
  /// and logo, the employee summary, and the `qrdata` string to encode.
  /// Keyed on partyid.
  static Future<ResponseItem> getEmployeeIdCard(
      Map<String, dynamic> requestData) async {
    try {
      final url = AppUrls.baseUrl + MethodName.employeeIdCard;
      log('EmployeeIdCard → $url');
      log('EmployeeIdCard body: ${jsonEncode(requestData)}');
      final res = await BaseApiHelper.postRequest(url, requestData);
      log('reply from $url: ${jsonEncode(res.data)}');
      return res;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: 'getEmployeeIdCard: ${e.toString()}',
      );
    }
  }

  /// Shift options for the "Default" work-hours mode.
  static Future<ResponseItem> getShiftList(
      Map<String, dynamic> requestData) async {
    try {
      final url = AppUrls.baseUrl + MethodName.employeeShiftList;
      log('EmployeeShiftList → $url');
      final res = await BaseApiHelper.postRequest(url, requestData);
      // BaseApiHelper does not log bodies, and these routes answer 200 even
      // when they reject the request — so log what actually came back.
      log('reply from $url: ${jsonEncode(res.data)}');
      return res;
    } catch (e) {
      return ResponseItem(
        status: false,
        message: 'getShiftList: ${e.toString()}',
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
