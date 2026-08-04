import 'package:digitalerp/app_routes/app_routes.dart';
import 'package:digitalerp/response/customer_data_response.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewVisitPlaningController extends AppBaseController {
  final TextEditingController searchController = TextEditingController();
  final HomeController homeController = Get.find<HomeController>();
  final FocusNode searchFocus = FocusNode();

  var defaultDate = 'Select Date'.obs;

  var newVisitnearbyFilterSelectedValue;
  var newVisitStateFilterSelectedValue;
  var newVisitAreaFilterSelectedValue;
  var newVisitCityFilterSelectedValue;

  DateTime? dateTime;
  List<VisitCustomerListData> visitPlanCustomerList = [];
  String? executiveName;

  /// Client name -> the visit-list ROW id returned by previewVisitData.
  ///
  /// The customer list endpoint returns no row id and hardcodes isChecked to
  /// false, so without this the screen has no idea which customers are already
  /// in the plan, and delete has no id to send.
  final Map<String, int> _addedVisitIdByClient = {};

  String _clientKey(String? name) => (name ?? '').trim().toLowerCase();

  /// Pulls the already-added visits and reconciles them with the customer list:
  /// ticks the ones already in the plan and records their row ids for delete.
  Future<void> _syncAlreadyAddedVisits() async {
    try {
      Map<String, String> body = {
        RequestKeys.compId: homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.userId: homeController.currentUserData?.userid.toString() ?? '',
      };
      var res = await api.previewVisitData(body);
      _addedVisitIdByClient.clear();
      if (res.status == 200) {
        for (var v in res.data ?? []) {
          if (v.id != null) _addedVisitIdByClient[_clientKey(v.clientname)] = v.id!;
        }
      }
      for (var c in visitPlanCustomerList) {
        c.isChecked = _addedVisitIdByClient.containsKey(_clientKey(c.customername));
      }
    } catch (_) {
      // Non-fatal: the list still works, the ticks just won't be pre-filled.
    }
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    executiveName = homeController.currentUserData?.name;
    getCustomerList(100);
  }

  void tapOnCard() {
    Get.toNamed(AppRoutes.visitPlanDetail);
  }

  void tapOnChecked(int index) {
    if (dateTime == null) {
      ShowMessage.showSnackBar(
        AppString.pleaseCheckTxt,
        AppString.pleaseSelectDate,
      );
    } else {
      if (visitPlanCustomerList[index].isChecked ?? false) {
        deleteVisit(visitPlanCustomerList[index]);
      } else {
        addInVisit(visitPlanCustomerList[index]);
      }
    }
  }

  void tapOnPreview() {
    int count = 0;
    if (dateTime == null) {
      ShowMessage.showSnackBar(
        'Message',
        'Please select date',
      );
    } else {
      for (var element in visitPlanCustomerList) {
        if (element.isChecked ?? false) {
          count++;
        }
      }
      if (count == 0) {
        ShowMessage.showSnackBar(
          'Message',
          'Please check any customer',
        );
      } else {
        Get.toNamed(AppRoutes.preview)?.then((value) {
          if ((value ?? '').toString().isNotEmpty) {
            Get.back();

            ShowMessage.showSnackBar('Server Res', value.toString());
          }
        });
      }
    }
  }

  void onSearch(String text) {
    if (text.isEmpty) {
      getCustomerList(100);
      update();
    } else {
      final suggestions = visitPlanCustomerList.where((element) {
        final productTitle = element.customername!.toLowerCase();
        final input = searchController.text.toLowerCase();
        return productTitle.contains(input);
      }).toList();
      visitPlanCustomerList = suggestions;
      update();
    }
  }

  /// Best-effort single GPS fix.
  ///
  /// Returns null instead of throwing, so a device with location switched off
  /// or permission denied still gets the customer list.
  Future<Position?> _tryGetPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Low accuracy + a hard timeout: a high-accuracy fix can sit waiting for
      // GPS indefinitely, and this runs before the screen can show anything.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('New Visit Planning: no location fix — $e');
      return null;
    }
  }

  Future<void> getCustomerList(int distanceValue) async {
    setBusy(true);
    try {
      // Location is best-effort and now lives INSIDE the try.
      //
      // This used to run three location calls before the try block:
      // getUserCurrentPosition() (a high-accuracy fix), then a SECOND
      // Geolocator.getCurrentPosition() whose result was only printed, then
      // getUserCurrentAddress() — which takes a THIRD fix and adds a network
      // reverse-geocode, also only printed. Any of them throwing (location off,
      // permission denied, no fix, no network) escaped this method, so the
      // `finally` never ran, isBusy stayed true and the screen sat on a loader
      // forever — the screen simply would not open.
      final Position? location = await _tryGetPosition();

      Map<String, String> body = {};
      body[RequestKeys.compId] = homeController.currentUserData?.compId.toString() ?? '39';
      body[RequestKeys.branchId] = homeController.currentUserData?.branchId.toString() ?? '39';
      body[RequestKeys.userId] = homeController.currentUserData?.userid.toString() ?? '39';
      body[RequestKeys.partyId] = '0';
      body[RequestKeys.nearby] = distanceValue.toString();
      // stateId and cityId were never sent here, so filtering this screen by
      // State (or City) had no effect at all — only Area was applied.
      body[RequestKeys.stateId] =
          newVisitStateFilterSelectedValue == null ? '0' : newVisitStateFilterSelectedValue.stateid.toString();
      body[RequestKeys.cityId] =
          newVisitCityFilterSelectedValue == null ? '0' : newVisitCityFilterSelectedValue.cityid.toString();
      body[RequestKeys.areaId] =
          newVisitAreaFilterSelectedValue == null ? '0' : newVisitAreaFilterSelectedValue.areaid.toString();
      body[RequestKeys.latitude] = (location?.latitude ?? 0).toString();
      body[RequestKeys.longitude] = (location?.longitude ?? 0).toString();

      var res = await api.customerListData(body);
      if (res.status == 200) {
        visitPlanCustomerList = res.data ?? [];
        update();
      } else {
        visitPlanCustomerList = res.data??[];
        update();
        // ShowMessage.showSnackBar('customerListData res.status not 200', res.message.toString());
      }
      // Tick whatever is already in the plan, so the user isn't shown an empty
      // checkbox for a customer the server will reject as "Data Allready Added".
      await _syncAlreadyAddedVisits();
    } catch (e) {
      ShowMessage.showSnackBar('Server Res', '$e');
    } finally {
      // setBusy() also calls update() — plain `isBusy = false` left the loader
      // painted until some other event happened to rebuild the screen.
      setBusy(false);
    }
  }

  Future<void> addInVisit(VisitCustomerListData element) async {
    String date = DateFormat('yyyy-MM-dd').format(dateTime ?? DateTime.now());
    try {
      Map<String, String> body = {};
      body[RequestKeys.compId] = homeController.currentUserData?.compId.toString() ?? '39';
      body[RequestKeys.branchId] = homeController.currentUserData?.branchId.toString() ?? '39';
      body[RequestKeys.userId] = homeController.currentUserData?.userid.toString() ?? '39';
      body[RequestKeys.partyId] = element.partyid.toString();
      body[RequestKeys.clientName] = element.customername ?? '';
      body[RequestKeys.areaId] = element.areaid.toString();
      body[RequestKeys.areaName] = element.area.toString().isEmpty ? 'N/A' : element.area ?? '';
      body[RequestKeys.distance] = element.distance ?? '';
      body[RequestKeys.visitDate] = date;

      var res = await api.addVisitDataToVisit(body);
      if (res.status == 200) {
        for (var e in visitPlanCustomerList) {
          if (e == element) {
            e.isChecked = true;
          }
        }
        // Learn the new row id so this customer can be removed again.
        await _syncAlreadyAddedVisits();
      } else if ((res.message ?? '').toLowerCase().contains('already')) {
        // The server already holds this customer. Previously the tick was left
        // off, so the row looked untouched and the user could neither add nor
        // remove it — it just kept erroring. Reflect the real state instead.
        for (var e in visitPlanCustomerList) {
          if (e == element) {
            e.isChecked = true;
          }
        }
        await _syncAlreadyAddedVisits();
        ShowMessage.showSnackBar(
            'Already in plan', '${element.customername ?? 'This customer'} is already in your visit plan.');
      } else {
        ShowMessage.showSnackBar('Could not add visit', res.message.toString());
      }
    } catch (e) {
      ShowMessage.showSnackBar('Server Res', '$e');
    } finally {
      isBusy = false;
      update();
    }
  }

  Future<void> deleteVisit(VisitCustomerListData element) async {
    try {
      // This used to send `element.partyid`. The endpoint expects the visit-list
      // ROW id (3615, 3616 …), not the party id, so it matched nothing, still
      // replied "Data Deleted", and the visit stayed in the plan — the customer
      // could never be un-ticked.
      final int? rowId = _addedVisitIdByClient[_clientKey(element.customername)];
      if (rowId == null) {
        // Not actually in the plan (or the mapping is stale) — resync and stop
        // rather than firing a delete that silently does nothing.
        await _syncAlreadyAddedVisits();
        return;
      }

      Map<String, String> body = {
        RequestKeys.compId: homeController.currentUserData?.compId.toString() ?? '',
        RequestKeys.userId: homeController.currentUserData?.userid.toString() ?? '',
        RequestKeys.id: rowId.toString(),
      };

      var res = await api.deleteVisitData(body);
      if (res.status == 200) {
        for (var e in visitPlanCustomerList) {
          if (e == element) {
            e.isChecked = false;
          }
        }
        _addedVisitIdByClient.remove(_clientKey(element.customername));
      } else {
        ShowMessage.showSnackBar('Server Res', res.message.toString());
      }
    } catch (e) {
      ShowMessage.showSnackBar('Server Res', '$e');
    } finally {
      isBusy = false;
      update();
    }
  }
}
