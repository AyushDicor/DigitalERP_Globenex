class AppUrls {
  // static const baseUrl = "http://salewebservice.digitalerp.biz/api/";
  // static const baseUrl = "http://demoservice.digitalerp.biz/api/";
  static const baseUrl = "http://supportapi.digitalerp.biz/api/";
}

class MethodName {
  static const organizationFetchApi = "organisation/orgdropdown";
  static const userNameFetchApi = "UserName/username";
  static const issueTypeFetchApi = "issuetype/issuetypedropdown";
  static const relatedServices = "Service/servicedropdown";
  static const moduleDropdown = "module/moduledropdown";
  static const ticketList = "Ticketentry/saveticketentry";

  static const getAllTicketList = "getComplainlist/getComplainlist";
  static const updateTicketEntry = "UpdateTicketEntry/UpdateTicketEntry";

  /// reimbursement

 // static const reimbursementDropDownType = 'ReimbursementDropdown';
  static const selectCurrency = "Currency/Currencydropdown";
 // static const submitReimbursementRequest = 'SaveReimbursement';
 // static const reimbursementGetList = 'GetExpenseListNew';
 // static const reimbursementGetDetail = 'GetExpenseDetail';
  //new apis
  static const getExpenseDetail = 'GetExpenseDetail';
  //static const getExpenseDesc = "getexpensedesc/getexpensedesc";
  static const getExpenseListNew = "GetExpenseListNew";
 //new apis
  static const reimbursementDropdown     = 'ReimbursementDropdown';
  static const uploadReimbursementFile   = 'UploadReimbursementFile';
  static const saveReimbursement         = 'SaveReimbursement';

  /// Lead Management

  static const businessTypeUrl = "BusinessType/BusinessTypedropdown";
  static const industryTypeUrl = "IndustryType/IndustryTypedropdown";
  static const interestedTypeUrl = "CurrentSoftware/CurrentSoftwaredropdown";
  // static const tagProductTypeUrl = "getitems/getitemslist";
  static const tagProductTypeUrl = "itemwithbranch/itemlistwithbranch";
  static const interestedInApi = "CurrentSoftware/CurrentSoftwaredropdown";
  static const decisionTimelineApi = "DecisionTimeline/DecisionTimelinedropdown";
  static const currentSoftwareApi = "DecisionTimeline/DecisionTimelinedropdown";
  /// Superseded by [saveLeadEntryWithStateCity] — kept because the ported lead
  /// edit screen still posts here. The old endpoint silently discards
  /// state/city/area, designation, priority, lead type and owner name.
  static const saveLeadEntry = "leadentry/saveleadentry";

  /// Lead save/update/read that actually stores the full record.
  /// Verified 2026-08-04 on a throwaway lead: every field below round-trips —
  /// countryid, state/city/area, companyid, DesignationId, Priority, leadtype,
  /// OwnerName. The save mirrors the read key-for-key.
  static const saveLeadEntryWithStateCity = "leadentrywithstatecity";
  static const updateLeadEntryWithStateCity = "updateleadentrywithstatecity";
  static const getLeadDetailWithStateCity = "Leadeditwithstatecity";

  /// Existing-client prefill: takes `partyid` (NOT clientid — that returns
  /// "Client detail Not Available"), returns party detail + contact list.
  static const leadExistingClientDetail = "leadexistingclientdetail";

  ///
  static const getleadentryApi = "getleadentry/getleadentry";
  static const getLeadDetailFromId = "Leadedit/getlead";

  ///15-

  static const deleteLeadMethod = "deletelead/deletelead";
  static const insertLeadNotesAndFollowUpMethod = "/insertleadfollowup/leadfollowup";
  static const getNotesAndFollowupMethod = "/getremarksonlead/getremarks";
  static const deleteNotesMethod = "deleteremarks/deleteremarks";
  static const updateLeadEntry = "/updateleadentry/updateleadentry";

  ///
  static const getQuestionAgainLeads = "Quotation/getleadForQuotation";
  static const insertQuote = "InsertQuotation/saveQuotation";
  static const getQuote = "GetQuotation/getleadForQuotation";
  static const getCallLogs = "GetCalllog/GetCalllogslist";
  static const leadSources = "leadsource/leadsourcedropdown";

  /// Follow-up detail masters — being built by the backend team (Aug 2026).
  /// Until they are deployed both return 404; the loaders below treat that as
  /// "no options yet" and leave the dropdown disabled rather than erroring.
  /// If the team lands different names, only these two lines change.
  static const followupStatus = "FollowupStatus/FollowupStatusdropdown";
  static const followupPurpose = "FollowupPurpose/FollowupPurposedropdown";
  static const String agentParty = 'agentparty';

  /// Employee Master — live as of 2026-08-26. Field names were confirmed by
  /// probing; callers still treat a 404 / non-JSON reply as "not live yet"
  /// rather than as a failure, so a redeploy gap degrades gracefully.
  /// AppUrls.baseUrl already ends in /api/, so these are the bare route names.
  static const saveEmployeeMaster   = "employeeonboarding";
  static const employeeMasterList   = "employeeonboardinglist";
  static const employeeMasterDetail = "employeeonboarddetail";

  /// ID-card payload: company name + logo, employee summary, and a ready-made
  /// `qrdata` string to encode. Keyed on partyid, JSON body.
  static const employeeIdCard       = "employeeidcard";

  /// Shift list for the "Default" work-hours mode.
  static const employeeShiftList    = "shifttiming";

  /// group and main group
  ///
  static const mainGroup = "categorywithbranch/getcategorylistwithbranch";
  static const subGroup = "subcategorywithbranch/subcategorylistwithbranch";


}
// TODO Implement this library.