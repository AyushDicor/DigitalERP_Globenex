import 'package:digitalerp/app_routes/app_routes.dart';
import 'package:digitalerp/response/account_menu_model.dart';
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/home_controller.dart';
import 'package:digitalerp/services/api_service/request_keys.dart';
import 'package:digitalerp/utils/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountModuleController extends AppBaseController {
  HomeController homeController = Get.find<HomeController>();
  bool? isBackIcon;

  /// Parent menu id of the Accounts module in the ERP menu tree.
  static const int accountsParentMenuId = 2382;

  /// Every tile this screen *can* show. What the user actually sees is
  /// [visibleMenuList], filtered against the menus the backend has granted
  /// them. menuId values match the ids used in `menu_fab.dart`'s route map.
  final List<AccountMenu> menuList = [
    AccountMenu(
        color1: orangeColor,
        color2: red2Color,
        name: 'Payment Entry',
        pageName: AppRoutes.paymentEntry,
        menuId: 2395,
        icon: Icons.payments_outlined),
    AccountMenu(
        color1: purpleColor,
        color2: blueColor,
        name: 'Receipt Entry',
        pageName: AppRoutes.receiptEntry,
        menuId: 2394,
        icon: Icons.receipt_long_outlined),
    AccountMenu(
        color1: greenColor,
        color2: lightGreenColor,
        name: 'Collection',
        pageName: AppRoutes.collection,
        menuId: 2393,
        icon: Icons.account_balance_outlined),
    AccountMenu(
        color1: red3Color,
        color2: red4Color,
        name: 'Expenses',
        pageName: AppRoutes.expense,
        menuId: 2407,
        icon: Icons.money_off_outlined),
    AccountMenu(
        color1: darkBlueColor,
        color2: purpleColor,
        name: 'Party ledger',
        pageName: AppRoutes.outstanding,
        menuId: 2398,
        icon: Icons.swap_horiz_outlined),
    AccountMenu(
        color1: green3Color,
        color2: green4Color,
        name: 'Contra',
        pageName: AppRoutes.contra,
        menuId: 2397,
        icon: Icons.compare_arrows_outlined),
    AccountMenu(
        color1: purple2Color,
        color2: lightOrangeColor,
        name: 'Journal',
        pageName: AppRoutes.journalEntry,
        menuId: 2396,
        icon: Icons.book_outlined),
    AccountMenu(
        color1: chocolateColor,
        color2: fadeGreenColor,
        name: 'Party Transactions',
        pageName: AppRoutes.partyTransactions,
        menuId: 2408,
        icon: Icons.person_search_outlined),
  ];

  /// Leaf menu ids the logged-in user has been granted under Accounts.
  final Set<int> grantedMenuIds = {};
  bool menuAccessLoading = true;

  /// Only the tiles the user is allowed to open. Until the access call
  /// finishes this is empty, so we never briefly flash forbidden tiles.
  List<AccountMenu> get visibleMenuList => menuList
      .where((m) => m.menuId == null || grantedMenuIds.contains(m.menuId))
      .toList();

  @override
  void onInit() {
    var arg = Get.arguments;
    if (arg is bool) {
      isBackIcon = arg;
    }
    loadGrantedMenus();
    super.onInit();
  }

  /// Walks the granted-menu tree under Accounts and collects the leaf ids.
  ///
  /// The tree is nested (e.g. Accounts → Account Reporting → Party Ledger),
  /// so filtering against only the direct children of 2382 would match none
  /// of the tiles above and render an empty grid. `child == 1` means a node
  /// has children and must be expanded; `child == 0` is a leaf we can match.
  Future<void> loadGrantedMenus() async {
    menuAccessLoading = true;
    update();
    try {
      grantedMenuIds.clear();
      await _collectLeafMenuIds(accountsParentMenuId, depth: 0);
    } catch (e) {
      debugPrint('Account menu access load failed: $e');
    } finally {
      menuAccessLoading = false;
      update();
    }
  }

  Future<void> _collectLeafMenuIds(int parentMenuId, {required int depth}) async {
    // Depth guard: the real tree is 2–3 levels; this stops a malformed
    // response (e.g. a node listing itself as its own child) from looping.
    if (depth > 4) return;

    final body = <String, String>{
      RequestKeys.compId: homeController.currentUserData?.compId.toString() ?? '',
      RequestKeys.branchId: homeController.currentUserData?.branchId.toString() ?? '',
      RequestKeys.userId: homeController.currentUserData?.userid.toString() ?? '',
      RequestKeys.menuId: parentMenuId.toString(),
    };

    final res = await api.getNewMenuList(body);
    if (res.status != 200) return;

    for (final node in res.data ?? []) {
      final id = node.menuid;
      if (id == null) continue;
      if (node.child == 1) {
        await _collectLeafMenuIds(id, depth: depth + 1);
      }
      // A parent can also be directly openable, so record it either way.
      grantedMenuIds.add(id);
    }
  }

  /// Routes by menu id rather than list position — the visible list is
  /// filtered, so positional indexes are no longer stable.
  void tapOnMenu(AccountMenu item) {
    switch (item.menuId) {
      case 2395:
        Get.toNamed(AppRoutes.entry, arguments: VoucherType.payment);
        break;
      case 2394:
        Get.toNamed(AppRoutes.entry, arguments: VoucherType.receipt);
        break;
      case 2393:
        Get.toNamed(AppRoutes.entry, arguments: VoucherType.collection);
        break;
      case 2407:
        Get.toNamed(AppRoutes.entry, arguments: VoucherType.expense);
        break;
      case 2397:
        Get.toNamed(AppRoutes.entry, arguments: VoucherType.contra);
        break;
      case 2396:
        Get.toNamed(AppRoutes.entry, arguments: VoucherType.journal);
        break;
      default:
        // Party ledger (2398) and Party Transactions (2408) are plain routes.
        Get.toNamed(item.pageName);
    }
  }

  void tapOnCamera() {}
}
