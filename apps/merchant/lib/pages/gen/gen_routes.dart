// 由 tools/design_to_flutter.py 生成，请勿手工修改。
import 'package:flutter/widgets.dart';

import 'category_manage_page.dart';
import 'product_edit_exist_page.dart';
import 'product_edit_page.dart';
import 'product_picker_sheet.dart';
import 'scan_product_not_found_sheet.dart';
import 'scan_product_page.dart';
import 'scan_product_result_sheet.dart';
import 'stock_alert_settings_page.dart';
import 'stock_check_input_sheet.dart';
import 'stock_check_new_page.dart';
import 'stock_check_result_page.dart';
import 'stock_docs_check_page.dart';
import 'stock_docs_out_page.dart';
import 'stock_docs_page.dart';
import 'stock_in_detail_page.dart';
import 'stock_out_detail_page.dart';
import 'stock_out_short_sheet.dart';
import 'stock_void_sheet.dart';
import 'supplier_edit_page.dart';
import 'supplier_picker_sheet.dart';

import 'store_add_page.dart';

import 'pay_apply_bind_page.dart';
import 'pay_apply_done_page.dart';
import 'pay_apply_intro_page.dart';
import 'pay_apply_rejected_page.dart';
import 'pay_apply_review_page.dart';
import 'pay_apply_reviewing_page.dart';
import 'pay_apply_sign_page.dart';
import 'pay_apply_step1_page.dart';
import 'pay_apply_step2_page.dart';
import 'pay_apply_step3_page.dart';
import 'pay_apply_step4_page.dart';
import 'pay_config_unopened_page.dart';

import 'order_detail_page.dart';
import 'order_list_page.dart';
import 'order_filter_sheet.dart';
import 'order_refund_sheet.dart';

import 'about_app_page.dart';
import 'appointment_detail_page.dart';
import 'appointment_schedule_page.dart';
import 'appointment_settings_page.dart';
import 'backup_content_page.dart';
import 'backup_sent_page.dart';
import 'backup_target_page.dart';
import 'bay_edit_page.dart';
import 'bind_done_page.dart';
import 'bind_h5_page.dart';
import 'budget_edit_page.dart';
import 'budget_total_page.dart';
import 'business_hours_page.dart';
import 'card_packages_page.dart';
import 'card_tier_edit_page.dart';
import 'card_tiers_page.dart';
import 'change_password_page.dart';
import 'change_phone_page.dart';
import 'changelog_page.dart';
import 'channel_config_page.dart';
import 'check_update_page.dart';
import 'data_backup_page.dart';
import 'delete_account_page.dart';
import 'expense_add_page.dart';
import 'expense_budget_page.dart';
import 'expense_detail_page.dart';
import 'expenses_page.dart';
import 'feedback_page.dart';
import 'forgot_done_page.dart';
import 'forgot_reset_page.dart';
import 'forgot_verify_page.dart';
import 'hold_list_page.dart';
import 'holiday_edit_page.dart';
import 'invoices_page.dart';
import 'main_expiring_page.dart';
import 'main_trial_page.dart';
import 'member_add_done_page.dart';
import 'member_adjust_page.dart';
import 'member_edit_page.dart';
import 'member_follow_up_page.dart';
import 'member_records_page.dart';
import 'member_send_msg_page.dart';
import 'member_visit_page.dart';
import 'messages_page.dart';
import 'notify_log_page.dart';
import 'notify_settings_page.dart';
import 'notify_template_page.dart';
import 'package_detail_page.dart';
import 'package_edit_page.dart';
import 'package_sold_page.dart';
import 'pay_config_page.dart';
import 'pay_method_page.dart';
import 'pay_success_page.dart';
import 'pay_unbound_page.dart';
import 'plan_checkout_page.dart';
import 'plan_expired_page.dart';
import 'plan_paid_page.dart';
import 'plans_page.dart';
import 'printer_page.dart';
import 'privacy_page.dart';
import 'product_detail_page.dart';
import 'profile_edit_page.dart';
import 'recharge_page.dart';
import 'recharge_card_page.dart';
import 'recharge_empty_page.dart';
import 'recharge_success_page.dart';
import 'reg_done_page.dart';
import 'reg_phone_page.dart';
import 'reg_shop_page.dart';
import 'renew_paid_page.dart';
import 'role_permission_page.dart';
import 'security_page.dart';
import 'service_edit_page.dart';
import 'staff_page.dart';
import 'staff_add_page.dart';
import 'staff_commission_page.dart';
import 'staff_detail_page.dart';
import 'staff_detail_off_page.dart';
import 'staff_edit_page.dart';
import 'staff_invite_page.dart';
import 'staff_records_page.dart';
import 'stock_check_page.dart';
import 'stock_in_page.dart';
import 'stock_out_page.dart';
import 'store_edit_page.dart';
import 'store_info_page.dart';
import 'store_q_r_page.dart';
import 'subscription_page.dart';
import 'terms_page.dart';
import 'vehicle_add_page.dart';
import 'wechat_bind_page.dart';
import 'appointment_reschedule_sheet.dart';
import 'backup_freq_sheet.dart';
import 'bind_invite_sheet.dart';
import 'budget_adjust_sheet.dart';
import 'clear_cache_sheet.dart';
import 'coupon_sheet_sheet.dart';
import 'default_pay_sheet.dart';
import 'disable_staff_sheet.dart';
import 'export_sheet_sheet.dart';
import 'find_result_sheet.dart';
import 'find_result_code_sheet.dart';
import 'hold_sheet_sheet.dart';
import 'member_delete_sheet.dart';
import 'member_filter_sheet.dart';
import 'member_more_sheet.dart';
import 'member_picker_sheet.dart';
import 'package_extend_sheet.dart';
import 'package_refund_sheet.dart';
import 'package_svc_pick_sheet.dart';
import 'recharge_pick_sheet.dart';
import 'renew_sheet.dart';
import 'scan_plate_result_sheet.dart';
import 'scan_result_sheet.dart';
import 'staff_enable_sheet.dart';
import 'staff_transfer_sheet.dart';
import 'store_switch_sheet.dart';
import 'find_not_found_sheet.dart';
import 'service_picker_sheet.dart';
import 'recharge_empty_card_page.dart';

final Map<String, WidgetBuilder> genRoutes = {
  'CategoryManage': (_) => const CategoryManagePage(),
  'ProductEditExist': (_) => const ProductEditExistPage(),
  'ProductEdit': (_) => const ProductEditPage(),
  'ScanProduct': (_) => const ScanProductPage(),
  'StockAlertSettings': (_) => const StockAlertSettingsPage(),
  'StockCheckNew': (_) => const StockCheckNewPage(),
  'StockCheckResult': (_) => const StockCheckResultPage(),
  'StockDocsCheck': (_) => const StockDocsCheckPage(),
  'StockDocsOut': (_) => const StockDocsOutPage(),
  'StockDocs': (_) => const StockDocsPage(),
  'StockInDetail': (_) => const StockInDetailPage(),
  'StockOutDetail': (_) => const StockOutDetailPage(),
  'SupplierEdit': (_) => const SupplierEditPage(),
  'StoreAdd': (_) => const StoreAddPage(),
  'PayApplyBind': (_) => const PayApplyBindPage(),
  'PayApplyDone': (_) => const PayApplyDonePage(),
  'PayApplyIntro': (_) => const PayApplyIntroPage(),
  'PayApplyRejected': (_) => const PayApplyRejectedPage(),
  'PayApplyReview': (_) => const PayApplyReviewPage(),
  'PayApplyReviewing': (_) => const PayApplyReviewingPage(),
  'PayApplySign': (_) => const PayApplySignPage(),
  'PayApplyStep1': (_) => const PayApplyStep1Page(),
  'PayApplyStep2': (_) => const PayApplyStep2Page(),
  'PayApplyStep3': (_) => const PayApplyStep3Page(),
  'PayApplyStep4': (_) => const PayApplyStep4Page(),
  'PayConfigUnopened': (_) => const PayConfigUnopenedPage(),
  'OrderDetail': (_) => const OrderDetailPage(),
  'OrderList': (_) => const OrderListPage(),
  'RechargeEmptyCard': (_) => const RechargeEmptyCardPage(),
  'AboutApp': (_) => const AboutAppPage(),
  'AppointmentDetail': (_) => const AppointmentDetailPage(),
  'AppointmentSchedule': (_) => const AppointmentSchedulePage(),
  'AppointmentSettings': (_) => const AppointmentSettingsPage(),
  'BackupContent': (_) => const BackupContentPage(),
  'BackupSent': (_) => const BackupSentPage(),
  'BackupTarget': (_) => const BackupTargetPage(),
  'BayEdit': (_) => const BayEditPage(),
  'BindDone': (_) => const BindDonePage(),
  'BindH5': (_) => const BindH5Page(),
  'BudgetEdit': (_) => const BudgetEditPage(),
  'BudgetTotal': (_) => const BudgetTotalPage(),
  'BusinessHours': (_) => const BusinessHoursPage(),
  'CardPackages': (_) => const CardPackagesPage(),
  'CardTierEdit': (_) => const CardTierEditPage(),
  'CardTiers': (_) => const CardTiersPage(),
  'ChangePassword': (_) => const ChangePasswordPage(),
  'ChangePhone': (_) => const ChangePhonePage(),
  'Changelog': (_) => const ChangelogPage(),
  'ChannelConfig': (_) => const ChannelConfigPage(),
  'CheckUpdate': (_) => const CheckUpdatePage(),
  'DataBackup': (_) => const DataBackupPage(),
  'DeleteAccount': (_) => const DeleteAccountPage(),
  'ExpenseAdd': (_) => const ExpenseAddPage(),
  'ExpenseBudget': (_) => const ExpenseBudgetPage(),
  'ExpenseDetail': (_) => const ExpenseDetailPage(),
  'Expenses': (_) => const ExpensesPage(),
  'Feedback': (_) => const FeedbackPage(),
  'ForgotDone': (_) => const ForgotDonePage(),
  'ForgotReset': (_) => const ForgotResetPage(),
  'ForgotVerify': (_) => const ForgotVerifyPage(),
  'HoldList': (_) => const HoldListPage(),
  'HolidayEdit': (_) => const HolidayEditPage(),
  'Invoices': (_) => const InvoicesPage(),
  'MainExpiring': (_) => const MainExpiringPage(),
  'MainTrial': (_) => const MainTrialPage(),
  'MemberAddDone': (_) => const MemberAddDonePage(),
  'MemberAdjust': (_) => const MemberAdjustPage(),
  'MemberEdit': (_) => const MemberEditPage(),
  'MemberFollowUp': (_) => const MemberFollowUpPage(),
  'MemberRecords': (_) => const MemberRecordsPage(),
  'MemberSendMsg': (_) => const MemberSendMsgPage(),
  'MemberVisit': (_) => const MemberVisitPage(),
  'Messages': (_) => const MessagesPage(),
  'NotifyLog': (_) => const NotifyLogPage(),
  'NotifySettings': (_) => const NotifySettingsPage(),
  'NotifyTemplate': (_) => const NotifyTemplatePage(),
  'PackageDetail': (_) => const PackageDetailPage(),
  'PackageEdit': (_) => const PackageEditPage(),
  'PackageSold': (_) => const PackageSoldPage(),
  'PayConfig': (_) => const PayConfigPage(),
  'PayMethod': (_) => const PayMethodPage(),
  'PaySuccess': (_) => const PaySuccessPage(),
  'PayUnbound': (_) => const PayUnboundPage(),
  'PlanCheckout': (_) => const PlanCheckoutPage(),
  'PlanExpired': (_) => const PlanExpiredPage(),
  'PlanPaid': (_) => const PlanPaidPage(),
  'Plans': (_) => const PlansPage(),
  'Printer': (_) => const PrinterPage(),
  'Privacy': (_) => const PrivacyPage(),
  'ProductDetail': (_) => const ProductDetailPage(),
  'ProfileEdit': (_) => const ProfileEditPage(),
  'Recharge': (_) => const RechargePage(),
  'RechargeCard': (_) => const RechargeCardPage(),
  'RechargeEmpty': (_) => const RechargeEmptyPage(),
  'RechargeSuccess': (_) => const RechargeSuccessPage(),
  'RegDone': (_) => const RegDonePage(),
  'RegPhone': (_) => const RegPhonePage(),
  'RegShop': (_) => const RegShopPage(),
  'RenewPaid': (_) => const RenewPaidPage(),
  'RolePermission': (_) => const RolePermissionPage(),
  'Security': (_) => const SecurityPage(),
  'ServiceEdit': (_) => const ServiceEditPage(),
  'Staff': (_) => const StaffPage(),
  'StaffAdd': (_) => const StaffAddPage(),
  'StaffCommission': (_) => const StaffCommissionPage(),
  'StaffDetail': (_) => const StaffDetailPage(),
  'StaffDetailOff': (_) => const StaffDetailOffPage(),
  'StaffEdit': (_) => const StaffEditPage(),
  'StaffInvite': (_) => const StaffInvitePage(),
  'StaffRecords': (_) => const StaffRecordsPage(),
  'StockCheck': (_) => const StockCheckPage(),
  'StockIn': (_) => const StockInPage(),
  'StockOut': (_) => const StockOutPage(),
  'StoreEdit': (_) => const StoreEditPage(),
  'StoreInfo': (_) => const StoreInfoPage(),
  'StoreQR': (_) => const StoreQRPage(),
  'Subscription': (_) => const SubscriptionPage(),
  'Terms': (_) => const TermsPage(),
  'VehicleAdd': (_) => const VehicleAddPage(),
  'WechatBind': (_) => const WechatBindPage(),
};

/// 底部弹层（设计稿中叠在其他页面上的界面）。
final Map<String, WidgetBuilder> genSheets = {
  'ProductPicker': (_) => const ProductPickerSheet(),
  'ScanProductNotFound': (_) => const ScanProductNotFoundSheet(),
  'ScanProductResult': (_) => const ScanProductResultSheet(),
  'StockCheckInput': (_) => const StockCheckInputSheet(),
  'StockOutShort': (_) => const StockOutShortSheet(),
  'StockVoid': (_) => const StockVoidSheet(),
  'SupplierPicker': (_) => const SupplierPickerSheet(),
  'OrderFilter': (_) => const OrderFilterSheet(),
  'OrderRefund': (_) => const OrderRefundSheet(),
  'FindNotFound': (_) => const FindNotFoundSheet(),
  'ServicePicker': (_) => const ServicePickerSheet(),
  'AppointmentReschedule': (_) => const AppointmentRescheduleSheet(),
  'BackupFreq': (_) => const BackupFreqSheet(),
  'BindInvite': (_) => const BindInviteSheet(),
  'BudgetAdjust': (_) => const BudgetAdjustSheet(),
  'ClearCache': (_) => const ClearCacheSheet(),
  'CouponSheet': (_) => const CouponSheetSheet(),
  'DefaultPay': (_) => const DefaultPaySheet(),
  'DisableStaff': (_) => const DisableStaffSheet(),
  'ExportSheet': (_) => const ExportSheetSheet(),
  'FindResult': (_) => const FindResultSheet(),
  'FindResultCode': (_) => const FindResultCodeSheet(),
  'HoldSheet': (_) => const HoldSheetSheet(),
  'MemberDelete': (_) => const MemberDeleteSheet(),
  'MemberFilter': (_) => const MemberFilterSheet(),
  'MemberMore': (_) => const MemberMoreSheet(),
  'MemberPicker': (_) => const MemberPickerSheet(),
  'PackageExtend': (_) => const PackageExtendSheet(),
  'PackageRefund': (_) => const PackageRefundSheet(),
  'PackageSvcPick': (_) => const PackageSvcPickSheet(),
  'RechargePick': (_) => const RechargePickSheet(),
  'Renew': (_) => const RenewSheet(),
  'ScanPlateResult': (_) => const ScanPlateResultSheet(),
  'ScanResult': (_) => const ScanResultSheet(),
  'StaffEnable': (_) => const StaffEnableSheet(),
  'StaffTransfer': (_) => const StaffTransferSheet(),
  'StoreSwitch': (_) => const StoreSwitchSheet(),
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
  'OrderRefund': 'OrderDetail',
  'FindNotFound': 'FindScanPlate',
  'ServicePicker': 'Order',
  'AppointmentReschedule': 'AppointmentDetail',
  'BackupFreq': 'DataBackup',
  'BindInvite': 'PayUnbound',
  'BudgetAdjust': 'ExpenseBudget',
  'ClearCache': 'AboutApp',
  'CouponSheet': 'PlanCheckout',
  'DefaultPay': 'PayConfig',
  'DisableStaff': 'StaffDetail',
  'ExportSheet': 'Stats',
  'FindResult': 'FindScanPlate',
  'FindResultCode': 'FindScanCode',
  'HoldSheet': 'Order',
  'MemberDelete': 'MemberMore',
  'MemberFilter': 'Members',
  'MemberMore': 'MemberDetail',
  'MemberPicker': '',
  'PackageExtend': 'PackageDetail',
  'PackageRefund': 'PackageDetail',
  'PackageSvcPick': 'PackageEdit',
  'RechargePick': 'RechargeCard',
  'Renew': 'Subscription',
  'ScanPlateResult': 'ScanPlate',
  'ScanResult': 'ScanLicense',
  'StaffEnable': 'StaffDetailOff',
  'StaffTransfer': 'DisableStaff',
  'StoreSwitch': 'Main',
};
