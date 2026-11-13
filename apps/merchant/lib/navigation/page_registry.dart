// 既有页面注册表；生产覆盖页与一期不用的前端已移除，剩余页面按业务迁移。
import 'package:flutter/widgets.dart';

import '../pages/account/about_app_page.dart';
import '../pages/catalog/card_tier_edit_page.dart';
import '../pages/account/change_password_page.dart';
import '../pages/account/change_phone_page.dart';
import '../pages/shared/changelog_page.dart';
import '../pages/account/delete_account_page.dart';
import '../pages/account/feedback_page.dart';
import '../pages/account/forgot_done_page.dart';
import '../pages/account/forgot_reset_page.dart';
import '../pages/account/forgot_verify_page.dart';
import '../pages/orders/hold_list_page.dart';
import '../pages/members/member_add_done_page.dart';
import '../pages/members/member_adjust_page.dart';
import '../pages/members/member_edit_page.dart';
import '../pages/members/member_follow_up_page.dart';
import '../pages/members/member_visit_page.dart';
import '../pages/members/packages/package_detail_page.dart';
import '../pages/catalog/package_edit_page.dart';
import '../pages/members/packages/package_sold_page.dart';
import '../pages/orders/pay_success_page.dart';
import '../pages/account/privacy_page.dart';
import '../pages/account/profile_edit_page.dart';
import '../pages/members/recharge_page.dart';
import '../pages/members/recharge_card_page.dart';
import '../pages/members/recharge_empty_page.dart';
import '../pages/members/recharge_success_page.dart';
import '../pages/account/reg_done_page.dart';
import '../pages/account/reg_phone_page.dart';
import '../pages/account/reg_shop_page.dart';
import '../pages/account/security_page.dart';
import '../pages/catalog/service_edit_page.dart';
import '../pages/account/store_edit_page.dart';
import '../pages/account/store_info_page.dart';
import '../pages/account/terms_page.dart';
import '../pages/members/vehicle_add_page.dart';
import '../pages/account/clear_cache_sheet.dart';
import '../pages/scan/find_result_sheet.dart';
import '../pages/orders/hold_sheet_sheet.dart';
import '../pages/members/member_delete_sheet.dart';
import '../pages/members/member_filter_sheet.dart';
import '../pages/members/member_more_sheet.dart';
import '../pages/members/member_picker_sheet.dart';
import '../pages/members/packages/package_extend_sheet.dart';
import '../pages/members/recharge_pick_sheet.dart';
import '../pages/scan/find_not_found_sheet.dart';
import '../pages/members/recharge_empty_card_page.dart';

final Map<String, WidgetBuilder> pageBuilders = {
  'RechargeEmptyCard': (_) => const RechargeEmptyCardPage(),
  'AboutApp': (_) => const AboutAppPage(),
  'CardTierEdit': (_) => const CardTierEditPage(),
  'ChangePassword': (_) => const ChangePasswordPage(),
  'ChangePhone': (_) => const ChangePhonePage(),
  'Changelog': (_) => const ChangelogPage(),
  'DeleteAccount': (_) => const DeleteAccountPage(),
  'Feedback': (_) => const FeedbackPage(),
  'ForgotDone': (_) => const ForgotDonePage(),
  'ForgotReset': (_) => const ForgotResetPage(),
  'ForgotVerify': (_) => const ForgotVerifyPage(),
  'HoldList': (_) => const HoldListPage(),
  'MemberAddDone': (_) => const MemberAddDonePage(),
  'MemberAdjust': (_) => const MemberAdjustPage(),
  'MemberEdit': (_) => const MemberEditPage(),
  'MemberFollowUp': (_) => const MemberFollowUpPage(),
  'MemberVisit': (_) => const MemberVisitPage(),
  'PackageDetail': (_) => const PackageDetailPage(),
  'PackageEdit': (_) => const PackageEditPage(),
  'PackageSold': (_) => const PackageSoldPage(),
  'PaySuccess': (_) => const PaySuccessPage(),
  'Privacy': (_) => const PrivacyPage(),
  'ProfileEdit': (_) => const ProfileEditPage(),
  'Recharge': (_) => const RechargePage(),
  'RechargeCard': (_) => const RechargeCardPage(),
  'RechargeEmpty': (_) => const RechargeEmptyPage(),
  'RechargeSuccess': (_) => const RechargeSuccessPage(),
  'RegDone': (_) => const RegDonePage(),
  'RegPhone': (_) => const RegPhonePage(),
  'RegShop': (_) => const RegShopPage(),
  'Security': (_) => const SecurityPage(),
  'ServiceEdit': (_) => const ServiceEditPage(),
  'StoreEdit': (_) => const StoreEditPage(),
  'StoreInfo': (_) => const StoreInfoPage(),
  'Terms': (_) => const TermsPage(),
  'VehicleAdd': (_) => const VehicleAddPage(),
};

/// 底部弹层（设计稿中叠在其他页面上的界面）。
final Map<String, WidgetBuilder> sheetBuilders = {
  'FindNotFound': (_) => const FindNotFoundSheet(),
  'ClearCache': (_) => const ClearCacheSheet(),
  'FindResult': (_) => const FindResultSheet(),
  'HoldSheet': (_) => const HoldSheetSheet(),
  'MemberDelete': (_) => const MemberDeleteSheet(),
  'MemberFilter': (_) => const MemberFilterSheet(),
  'MemberMore': (_) => const MemberMoreSheet(),
  'MemberPicker': (_) => const MemberPickerSheet(),
  'PackageExtend': (_) => const PackageExtendSheet(),
  'RechargePick': (_) => const RechargePickSheet(),
};

/// 弹层所属的页面（设计稿里的遮罩点击目标）。
const Map<String, String> sheetParents = {
  'ProductPicker': 'StockIn',
  'ScanProductNotFound': 'ScanProduct',
  'ScanProductResult': 'ScanProduct',
  'StockCheckInput': 'StockCheck',
  'StockOutShort': 'StockOut',
  'StockVoid': 'StockInDetail',
  'SupplierPicker': 'StockIn',
  'OrderFilter': 'OrderList',
  'FindNotFound': 'FindScanPlate',
  'AppointmentReschedule': 'AppointmentDetail',
  'BudgetAdjust': 'ExpenseBudget',
  'ClearCache': 'AboutApp',
  'DisableStaff': 'StaffDetail',
  'FindResult': 'FindScanPlate',
  'HoldSheet': 'Order',
  'MemberDelete': 'MemberMore',
  'MemberFilter': 'Members',
  'MemberMore': 'MemberDetail',
  'MemberPicker': '',
  'PackageExtend': 'PackageDetail',
  'PackageSvcPick': 'PackageEdit',
  'RechargePick': 'RechargeCard',
  'ScanPlateResult': 'ScanPlate',
  'StaffEnable': 'StaffDetailOff',
  'StaffTransfer': 'DisableStaff',
};
