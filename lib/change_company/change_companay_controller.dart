
import 'package:digitalerp/change_company/Company_list_responce.dart';
import 'package:digitalerp/change_company/branch_list_response.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/show_message.dart';
import 'package:get/get.dart';

class ChangeCompanyController extends AppBaseController{
  bool isPageLoading = true;
  HomeController homeController = Get.find<HomeController>();

  List<CompanyListData> companyList = [];
  List<BranchListData> branchList = [];
  CompanyListData? selectCompany;
  BranchListData? selectBranch;


  void setSelectCompanyDropdownValue(CompanyListData? value) {
    selectCompany = value;
    update();
  }
  void setSelectBranchDropdownValue(BranchListData? value) {
    selectBranch = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }


  // Future<void> getChangeCompanyApi() async {
  //   setBusy(true);
  //   try{
  //     Map<String, String> body= {};
  //     body[RequestKeys.compId] =
  //     // '39';
  //         homeController.currentUserData?.compId.toString() ?? '39';
  //    body[RequestKeys.userId] =
  //    // '369622';
  //        homeController.currentUserData?.userid.toString() ?? "369622" ;
  //     var res = await api.getCompanyList(body);
  //      companyList = res.data ?? [];
  //      selectCompany = CompanyListData(companyname:'' ,compid:homeController.currentUserData!.compId);
  //      selectBranch = BranchListData(branchname: '',branchid: homeController.currentUserData!.branchId);
  //
  //
  //     if(res.status == 200){
  //       // ShowMessage.showSnackBar('Company List Success Res', res.message.toString());
  //     } else{
  //       ShowMessage.showSnackBar('Company List res.status not 200', res.message.toString());
  //     }
  //
  //   }catch(e){
  //     ShowMessage.showSnackBar('Company List catch', '$e');
  //
  //   } finally{
  //     setBusy(false);
  //   }
  //
  // }
  // Future<void> getBranchListApi() async {
  //   setBusy(true);
  //   try{
  //     Map<String, String> body= {};
  //     body[RequestKeys.compId] =
  //     // '39';
  //         homeController.currentUserData?.compId.toString() ?? '39';
  //    body[RequestKeys.userId] =
  //    // '369622';
  //        homeController.currentUserData?.userid.toString() ?? "369622" ;
  //     var res = await api.getBranchList(body);
  //      branchList = res.data ?? [];
  //     if(res.status == 200){
  //       // ShowMessage.showSnackBar('BranchList Success Res', res.message.toString());
  //     } else{
  //       ShowMessage.showSnackBar('BranchList res.status not 200', res.message.toString());
  //     }
  //
  //   }catch(e){
  //     ShowMessage.showSnackBar('BranchList catch', '$e');
  //
  //   } finally{
  //     setBusy(false);
  //   }
  //
  // }
  Future<void> _loadData() async {
    isPageLoading = true;
    setBusy(true);
    try {
      await getChangeCompanyApi();
      await getBranchListApi();
    } finally {
      isPageLoading = false;
      update(); // single update at the end
    }
  }

  Future<void> getChangeCompanyApi() async {
    try {
      Map<String, String> body = {};
      body[RequestKeys.compId] = homeController.currentUserData?.compId.toString() ?? '39';
      body[RequestKeys.userId] = homeController.currentUserData?.userid.toString() ?? "369622";

      var res = await api.getCompanyList(body);
      companyList = res.data ?? [];

      // ✅ Only select if a matching company exists in the list
      final currentCompId = homeController.currentUserData!.compId;
      final matchedCompany = companyList.where((e) => e.compid == currentCompId);
      selectCompany = matchedCompany.length == 1 ? matchedCompany.first : null;

      if (res.status == 200) {
        // success
      } else {
        ShowMessage.showSnackBar('Company List res.status not 200', res.message.toString());
      }
    } catch (e) {
      ShowMessage.showSnackBar('Company List catch', '$e');
    }
  }

  Future<void> getBranchListApi() async {
    try {
      Map<String, String> body = {};
      body[RequestKeys.compId] = homeController.currentUserData?.compId.toString() ?? '39';
      body[RequestKeys.userId] = homeController.currentUserData?.userid.toString() ?? "369622";

      var res = await api.getBranchList(body);

      // ✅ Filter out any entries with branchid = 0 (duplicates/placeholders)
      branchList = (res.data ?? []).where((b) => b.branchid != 0).toList();

      // ✅ Only select if a matching branch exists in the filtered list
      final currentBranchId = homeController.currentUserData!.branchId;
      final matchedBranch = branchList.where((e) => e.branchid == currentBranchId);
      selectBranch = matchedBranch.length == 1 ? matchedBranch.first : null;

      if (res.status == 200) {
        // success
      } else {
        ShowMessage.showSnackBar('BranchList res.status not 200', res.message.toString());
      }
    } catch (e) {
      ShowMessage.showSnackBar('BranchList catch', '$e');
    }
  }


}