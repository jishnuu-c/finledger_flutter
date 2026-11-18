import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FinLedger'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Double-Entry Accounting & ERP'**
  String get tagline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by code, customer, reference...'**
  String get searchPlaceholder;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noData;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @currencyAed.
  ///
  /// In en, this message translates to:
  /// **'AED'**
  String get currencyAed;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @crm.
  ///
  /// In en, this message translates to:
  /// **'CRM'**
  String get crm;

  /// No description provided for @leads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leads;

  /// No description provided for @pipeline.
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get pipeline;

  /// No description provided for @quotations.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get quotations;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @vendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendors;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @itemsAndStock.
  ///
  /// In en, this message translates to:
  /// **'Items & Stock'**
  String get itemsAndStock;

  /// No description provided for @adjustments.
  ///
  /// In en, this message translates to:
  /// **'Adjustments'**
  String get adjustments;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @expensesSection.
  ///
  /// In en, this message translates to:
  /// **'EXPENSES'**
  String get expensesSection;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accounting;

  /// No description provided for @chartOfAccounts.
  ///
  /// In en, this message translates to:
  /// **'Chart of Accounts'**
  String get chartOfAccounts;

  /// No description provided for @journalEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal Entries'**
  String get journalEntries;

  /// No description provided for @banking.
  ///
  /// In en, this message translates to:
  /// **'Banking'**
  String get banking;

  /// No description provided for @bankAccounts.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get bankAccounts;

  /// No description provided for @reconciliation.
  ///
  /// In en, this message translates to:
  /// **'Reconciliation'**
  String get reconciliation;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @companySettings.
  ///
  /// In en, this message translates to:
  /// **'Company Settings'**
  String get companySettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your enterprise credentials to access FinLedger'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@finledger.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @securedWithJwt.
  ///
  /// In en, this message translates to:
  /// **'Secured with JWT authentication'**
  String get securedWithJwt;

  /// No description provided for @accountLocked.
  ///
  /// In en, this message translates to:
  /// **'Account temporarily locked after 5 failed attempts.'**
  String get accountLocked;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Check your network.'**
  String get connectionError;

  /// No description provided for @financialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get financialOverview;

  /// No description provided for @operationalKpis.
  ///
  /// In en, this message translates to:
  /// **'Operational KPIs'**
  String get operationalKpis;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @ytdExpenses.
  ///
  /// In en, this message translates to:
  /// **'YTD Expenses'**
  String get ytdExpenses;

  /// No description provided for @receivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get receivables;

  /// No description provided for @cashAndBank.
  ///
  /// In en, this message translates to:
  /// **'Cash & Bank'**
  String get cashAndBank;

  /// No description provided for @openInvoices.
  ///
  /// In en, this message translates to:
  /// **'open invoices'**
  String get openInvoices;

  /// No description provided for @bankAccountsCount.
  ///
  /// In en, this message translates to:
  /// **'bank accounts'**
  String get bankAccountsCount;

  /// No description provided for @openPipelineCrm.
  ///
  /// In en, this message translates to:
  /// **'Open Pipeline CRM'**
  String get openPipelineCrm;

  /// No description provided for @opportunities.
  ///
  /// In en, this message translates to:
  /// **'opportunities'**
  String get opportunities;

  /// No description provided for @weightedProbability.
  ///
  /// In en, this message translates to:
  /// **'Weighted Probability'**
  String get weightedProbability;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'low stock alerts'**
  String get lowStockAlert;

  /// No description provided for @expensesAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Expenses Awaiting Approval'**
  String get expensesAwaitingApproval;

  /// No description provided for @pendingClaims.
  ///
  /// In en, this message translates to:
  /// **'pending claims'**
  String get pendingClaims;

  /// No description provided for @accountsPayable.
  ///
  /// In en, this message translates to:
  /// **'Accounts Payable'**
  String get accountsPayable;

  /// No description provided for @openBills.
  ///
  /// In en, this message translates to:
  /// **'open bills'**
  String get openBills;

  /// No description provided for @revenueVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'6-Month Revenue vs Expenses'**
  String get revenueVsExpenses;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @recordReceipt.
  ///
  /// In en, this message translates to:
  /// **'Record Receipt'**
  String get recordReceipt;

  /// No description provided for @enterBill.
  ///
  /// In en, this message translates to:
  /// **'Enter Bill'**
  String get enterBill;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Financial Activity'**
  String get recentActivity;

  /// No description provided for @crmPipeline.
  ///
  /// In en, this message translates to:
  /// **'CRM Deal Pipeline'**
  String get crmPipeline;

  /// No description provided for @newDeal.
  ///
  /// In en, this message translates to:
  /// **'New Deal'**
  String get newDeal;

  /// No description provided for @wonThisQuarter.
  ///
  /// In en, this message translates to:
  /// **'Won this quarter'**
  String get wonThisQuarter;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate (90 days)'**
  String get winRate;

  /// No description provided for @stageLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get stageLead;

  /// No description provided for @stageQualified.
  ///
  /// In en, this message translates to:
  /// **'Qualified'**
  String get stageQualified;

  /// No description provided for @stageProposal.
  ///
  /// In en, this message translates to:
  /// **'Proposal'**
  String get stageProposal;

  /// No description provided for @stageNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get stageNegotiation;

  /// No description provided for @stageWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get stageWon;

  /// No description provided for @stageLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get stageLost;

  /// No description provided for @convertCustomer.
  ///
  /// In en, this message translates to:
  /// **'Convert to Customer Account'**
  String get convertCustomer;

  /// No description provided for @markWon.
  ///
  /// In en, this message translates to:
  /// **'Mark as Won'**
  String get markWon;

  /// No description provided for @markLost.
  ///
  /// In en, this message translates to:
  /// **'Mark as Lost'**
  String get markLost;

  /// No description provided for @opportunityDetails.
  ///
  /// In en, this message translates to:
  /// **'Opportunity Details'**
  String get opportunityDetails;

  /// No description provided for @expectedClose.
  ///
  /// In en, this message translates to:
  /// **'Expected Close'**
  String get expectedClose;

  /// No description provided for @probability.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get probability;

  /// No description provided for @dealValue.
  ///
  /// In en, this message translates to:
  /// **'Deal Value'**
  String get dealValue;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @taxInvoices.
  ///
  /// In en, this message translates to:
  /// **'Tax Invoices'**
  String get taxInvoices;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @newTaxInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Tax Invoice'**
  String get newTaxInvoice;

  /// No description provided for @customerReceipts.
  ///
  /// In en, this message translates to:
  /// **'Customer Receipts'**
  String get customerReceipts;

  /// No description provided for @recordCustomerReceipt.
  ///
  /// In en, this message translates to:
  /// **'Record Customer Receipt'**
  String get recordCustomerReceipt;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT (5%)'**
  String get vat;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartiallyPaid;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusVoid.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get statusVoid;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @lineItems.
  ///
  /// In en, this message translates to:
  /// **'Line Items'**
  String get lineItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @vendorBills.
  ///
  /// In en, this message translates to:
  /// **'Vendor Bills'**
  String get vendorBills;

  /// No description provided for @enterVendorBill.
  ///
  /// In en, this message translates to:
  /// **'Enter Vendor Bill'**
  String get enterVendorBill;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @billNumber.
  ///
  /// In en, this message translates to:
  /// **'Bill Number'**
  String get billNumber;

  /// No description provided for @vendorPayments.
  ///
  /// In en, this message translates to:
  /// **'Vendor Payments'**
  String get vendorPayments;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @itemsStock.
  ///
  /// In en, this message translates to:
  /// **'Items & Stock'**
  String get itemsStock;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @unitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit Cost'**
  String get unitCost;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'On Hand'**
  String get onHand;

  /// No description provided for @reorderPoint.
  ///
  /// In en, this message translates to:
  /// **'Reorder Point'**
  String get reorderPoint;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @stockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustment'**
  String get stockAdjustment;

  /// No description provided for @stockTransfer.
  ///
  /// In en, this message translates to:
  /// **'Stock Transfer'**
  String get stockTransfer;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @expenseClaims.
  ///
  /// In en, this message translates to:
  /// **'Expense Claims'**
  String get expenseClaims;

  /// No description provided for @newExpenseClaim.
  ///
  /// In en, this message translates to:
  /// **'New Expense Claim'**
  String get newExpenseClaim;

  /// No description provided for @expenseApprovals.
  ///
  /// In en, this message translates to:
  /// **'Expense Approvals'**
  String get expenseApprovals;

  /// No description provided for @claimNumber.
  ///
  /// In en, this message translates to:
  /// **'Claim Number'**
  String get claimNumber;

  /// No description provided for @claimant.
  ///
  /// In en, this message translates to:
  /// **'Claimant'**
  String get claimant;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @reimburse.
  ///
  /// In en, this message translates to:
  /// **'Reimburse'**
  String get reimburse;

  /// No description provided for @coa.
  ///
  /// In en, this message translates to:
  /// **'Chart of Accounts'**
  String get coa;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get newAccount;

  /// No description provided for @accountCode.
  ///
  /// In en, this message translates to:
  /// **'Account Code'**
  String get accountCode;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @normalBalance.
  ///
  /// In en, this message translates to:
  /// **'Normal Balance'**
  String get normalBalance;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @unbalanced.
  ///
  /// In en, this message translates to:
  /// **'Unbalanced'**
  String get unbalanced;

  /// No description provided for @postJournal.
  ///
  /// In en, this message translates to:
  /// **'Post Journal'**
  String get postJournal;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @journalNo.
  ///
  /// In en, this message translates to:
  /// **'Journal Number'**
  String get journalNo;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @bankingOverview.
  ///
  /// In en, this message translates to:
  /// **'Banking & Accounts'**
  String get bankingOverview;

  /// No description provided for @bankReconciliation.
  ///
  /// In en, this message translates to:
  /// **'Bank Reconciliation'**
  String get bankReconciliation;

  /// No description provided for @statementBalance.
  ///
  /// In en, this message translates to:
  /// **'Statement Ending Balance'**
  String get statementBalance;

  /// No description provided for @bookBalance.
  ///
  /// In en, this message translates to:
  /// **'GL Book Balance'**
  String get bookBalance;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @reconciled.
  ///
  /// In en, this message translates to:
  /// **'Reconciled'**
  String get reconciled;

  /// No description provided for @unreconciled.
  ///
  /// In en, this message translates to:
  /// **'Unreconciled'**
  String get unreconciled;

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import Statement (CSV)'**
  String get importCsv;

  /// No description provided for @finishReconciliation.
  ///
  /// In en, this message translates to:
  /// **'Finish Reconciliation'**
  String get finishReconciliation;

  /// No description provided for @financialReports.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get financialReports;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss (P&L)'**
  String get profitLoss;

  /// No description provided for @balanceSheet.
  ///
  /// In en, this message translates to:
  /// **'Balance Sheet'**
  String get balanceSheet;

  /// No description provided for @trialBalance.
  ///
  /// In en, this message translates to:
  /// **'Trial Balance'**
  String get trialBalance;

  /// No description provided for @generalLedger.
  ///
  /// In en, this message translates to:
  /// **'General Ledger'**
  String get generalLedger;

  /// No description provided for @vatReturn.
  ///
  /// In en, this message translates to:
  /// **'UAE VAT 201 Return'**
  String get vatReturn;

  /// No description provided for @arAgeing.
  ///
  /// In en, this message translates to:
  /// **'A/R Ageing'**
  String get arAgeing;

  /// No description provided for @apAgeing.
  ///
  /// In en, this message translates to:
  /// **'A/P Ageing'**
  String get apAgeing;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'Company & System Settings'**
  String get systemSettings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @switchCompany.
  ///
  /// In en, this message translates to:
  /// **'Switch Company'**
  String get switchCompany;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @englishLang.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLang;

  /// No description provided for @hindiLang.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get hindiLang;

  /// No description provided for @arabicRtl.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic - RTL)'**
  String get arabicRtl;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get languageHindi;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic - RTL)'**
  String get languageArabic;

  /// No description provided for @companyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfile;

  /// No description provided for @fiscalYears.
  ///
  /// In en, this message translates to:
  /// **'Fiscal Years'**
  String get fiscalYears;

  /// No description provided for @taxRates.
  ///
  /// In en, this message translates to:
  /// **'Tax Rates'**
  String get taxRates;

  /// No description provided for @currencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies;

  /// No description provided for @numberSeries.
  ///
  /// In en, this message translates to:
  /// **'Number Series'**
  String get numberSeries;

  /// No description provided for @usersRoles.
  ///
  /// In en, this message translates to:
  /// **'Users & Roles'**
  String get usersRoles;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated successfully'**
  String get languageChanged;

  /// No description provided for @salesPipelineCrm.
  ///
  /// In en, this message translates to:
  /// **'Sales Pipeline & CRM'**
  String get salesPipelineCrm;

  /// No description provided for @crmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lead-to-Cash progression: Opportunity stages, deal values, and weighted forecasts'**
  String get crmSubtitle;

  /// No description provided for @importLeads.
  ///
  /// In en, this message translates to:
  /// **'Import Leads'**
  String get importLeads;

  /// No description provided for @importLeadsAndDeals.
  ///
  /// In en, this message translates to:
  /// **'Import Leads & Deals'**
  String get importLeadsAndDeals;

  /// No description provided for @leadsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Leads import completed. 6 new opportunities added to pipeline.'**
  String get leadsImportSuccess;

  /// No description provided for @newOpportunity.
  ///
  /// In en, this message translates to:
  /// **'New Opportunity'**
  String get newOpportunity;

  /// No description provided for @createDeal.
  ///
  /// In en, this message translates to:
  /// **'Create Deal'**
  String get createDeal;

  /// No description provided for @createOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Create New Opportunity'**
  String get createOpportunity;

  /// No description provided for @openPipeline.
  ///
  /// In en, this message translates to:
  /// **'Open pipeline'**
  String get openPipeline;

  /// No description provided for @weightedForecast.
  ///
  /// In en, this message translates to:
  /// **'Weighted forecast'**
  String get weightedForecast;

  /// No description provided for @boardView.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get boardView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @dealTitle.
  ///
  /// In en, this message translates to:
  /// **'Deal / Opportunity Title'**
  String get dealTitle;

  /// No description provided for @prospectCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Prospect / Customer Name'**
  String get prospectCustomerName;

  /// No description provided for @salesOwner.
  ///
  /// In en, this message translates to:
  /// **'Sales Owner'**
  String get salesOwner;

  /// No description provided for @expectedValueAed.
  ///
  /// In en, this message translates to:
  /// **'Expected Value (AED)'**
  String get expectedValueAed;

  /// No description provided for @winProbability.
  ///
  /// In en, this message translates to:
  /// **'Win Probability'**
  String get winProbability;

  /// No description provided for @initialStage.
  ///
  /// In en, this message translates to:
  /// **'Initial Stage'**
  String get initialStage;

  /// No description provided for @dealCannotBeWonWithoutCustomer.
  ///
  /// In en, this message translates to:
  /// **'Deal cannot be marked Won without an associated customer.'**
  String get dealCannotBeWonWithoutCustomer;

  /// No description provided for @dealCannotBeLostWithoutReason.
  ///
  /// In en, this message translates to:
  /// **'Deal cannot be marked Lost without a mandatory lost reason.'**
  String get dealCannotBeLostWithoutReason;

  /// No description provided for @primaryReason.
  ///
  /// In en, this message translates to:
  /// **'Primary Reason'**
  String get primaryReason;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (Optional)'**
  String get additionalNotes;

  /// No description provided for @confirmMarkLost.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Mark Lost'**
  String get confirmMarkLost;

  /// No description provided for @companyOrgName.
  ///
  /// In en, this message translates to:
  /// **'Company / Organization Name'**
  String get companyOrgName;

  /// No description provided for @billingEmail.
  ///
  /// In en, this message translates to:
  /// **'Billing Email'**
  String get billingEmail;

  /// No description provided for @trnTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax / TRN Number'**
  String get trnTaxNumber;

  /// No description provided for @backToPipeline.
  ///
  /// In en, this message translates to:
  /// **'Back to Pipeline'**
  String get backToPipeline;

  /// No description provided for @dealDetails.
  ///
  /// In en, this message translates to:
  /// **'Deal Details'**
  String get dealDetails;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @quotationsList.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get quotationsList;

  /// No description provided for @generateQuotation.
  ///
  /// In en, this message translates to:
  /// **'Generate Quotation'**
  String get generateQuotation;

  /// No description provided for @activeDealsCount.
  ///
  /// In en, this message translates to:
  /// **'active deals'**
  String get activeDealsCount;

  /// No description provided for @closedDealsCount.
  ///
  /// In en, this message translates to:
  /// **'closed deals'**
  String get closedDealsCount;

  /// No description provided for @markOpportunityLost.
  ///
  /// In en, this message translates to:
  /// **'Mark Opportunity as Lost'**
  String get markOpportunityLost;

  /// No description provided for @lostReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please specify the reason why this deal was lost.'**
  String get lostReasonPrompt;

  /// No description provided for @lostReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter details about competitor name, pricing gap, or client feedback...'**
  String get lostReasonHint;

  /// No description provided for @filterByOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get filterByOwner;

  /// No description provided for @filterByPeriod.
  ///
  /// In en, this message translates to:
  /// **'Close Period'**
  String get filterByPeriod;

  /// No description provided for @closeAll.
  ///
  /// In en, this message translates to:
  /// **'Close: All'**
  String get closeAll;

  /// No description provided for @closeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Close: This month'**
  String get closeThisMonth;

  /// No description provided for @closeThisQuarter.
  ///
  /// In en, this message translates to:
  /// **'Close: This quarter'**
  String get closeThisQuarter;

  /// No description provided for @closeNextQuarter.
  ///
  /// In en, this message translates to:
  /// **'Close: Next quarter'**
  String get closeNextQuarter;

  /// No description provided for @salesInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Invoices'**
  String get salesInvoicesTitle;

  /// No description provided for @salesInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage UAE VAT compliant tax invoices, credit notes, and customer receipts'**
  String get salesInvoicesSubtitle;

  /// No description provided for @createTaxInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Tax Invoice'**
  String get createTaxInvoice;

  /// No description provided for @downloadTaxPdf.
  ///
  /// In en, this message translates to:
  /// **'Download Tax PDF'**
  String get downloadTaxPdf;

  /// No description provided for @sendToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Send to Customer'**
  String get sendToCustomer;

  /// No description provided for @invoiceExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoices exported to CSV successfully.'**
  String get invoiceExportSuccess;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get paymentTerms;

  /// No description provided for @dueOnReceipt.
  ///
  /// In en, this message translates to:
  /// **'Due on Receipt'**
  String get dueOnReceipt;

  /// No description provided for @net15.
  ///
  /// In en, this message translates to:
  /// **'Net 15 Days'**
  String get net15;

  /// No description provided for @net30.
  ///
  /// In en, this message translates to:
  /// **'Net 30 Days'**
  String get net30;

  /// No description provided for @net60.
  ///
  /// In en, this message translates to:
  /// **'Net 60 Days'**
  String get net60;

  /// No description provided for @itemDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get itemDescription;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRate;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountPct.
  ///
  /// In en, this message translates to:
  /// **'Disc %'**
  String get discountPct;

  /// No description provided for @deleteLine.
  ///
  /// In en, this message translates to:
  /// **'Delete line'**
  String get deleteLine;

  /// No description provided for @saveAndApprove.
  ///
  /// In en, this message translates to:
  /// **'Save & Approve'**
  String get saveAndApprove;

  /// No description provided for @billTo.
  ///
  /// In en, this message translates to:
  /// **'BILL TO:'**
  String get billTo;

  /// No description provided for @closePreview.
  ///
  /// In en, this message translates to:
  /// **'Close Preview'**
  String get closePreview;

  /// No description provided for @downloadPrintPdf.
  ///
  /// In en, this message translates to:
  /// **'Download / Print PDF'**
  String get downloadPrintPdf;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @cheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get cheque;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get creditCard;

  /// No description provided for @depositToAccount.
  ///
  /// In en, this message translates to:
  /// **'Deposit To Account'**
  String get depositToAccount;

  /// No description provided for @applyToOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Apply to Outstanding Invoices'**
  String get applyToOutstanding;

  /// No description provided for @customerReceiptRecorded.
  ///
  /// In en, this message translates to:
  /// **'Customer receipt recorded and posted to ledger!'**
  String get customerReceiptRecorded;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount received must be greater than zero'**
  String get amountGreaterThanZero;

  /// No description provided for @autoJournal.
  ///
  /// In en, this message translates to:
  /// **'Auto journal entry:'**
  String get autoJournal;

  /// No description provided for @purchasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchases & Accounts Payable'**
  String get purchasesTitle;

  /// No description provided for @purchasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage vendor bills, debit notes, three-way matching, and disbursements'**
  String get purchasesSubtitle;

  /// No description provided for @openPayables.
  ///
  /// In en, this message translates to:
  /// **'Open Payables'**
  String get openPayables;

  /// No description provided for @activeVendors.
  ///
  /// In en, this message translates to:
  /// **'Approved Vendors'**
  String get activeVendors;

  /// No description provided for @billDate.
  ///
  /// In en, this message translates to:
  /// **'Bill Date'**
  String get billDate;

  /// No description provided for @againstBill.
  ///
  /// In en, this message translates to:
  /// **'Against Bill'**
  String get againstBill;

  /// No description provided for @disbursementMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get disbursementMethod;

  /// No description provided for @vendorBillRecorded.
  ///
  /// In en, this message translates to:
  /// **'Vendor bill saved successfully'**
  String get vendorBillRecorded;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Stock Valuation'**
  String get inventoryTitle;

  /// No description provided for @inventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Perpetual weighted-average costing, stock movements, and low stock tracking'**
  String get inventorySubtitle;

  /// No description provided for @activeWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Active Warehouses'**
  String get activeWarehouses;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @stockMovementLog.
  ///
  /// In en, this message translates to:
  /// **'Stock Movement Log'**
  String get stockMovementLog;

  /// No description provided for @barcodeScanner.
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanner'**
  String get barcodeScanner;

  /// No description provided for @stockLedger.
  ///
  /// In en, this message translates to:
  /// **'Stock Ledger'**
  String get stockLedger;

  /// No description provided for @sourceWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Source Warehouse'**
  String get sourceWarehouse;

  /// No description provided for @destinationWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Destination Warehouse'**
  String get destinationWarehouse;

  /// No description provided for @adjustmentType.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Type'**
  String get adjustmentType;

  /// No description provided for @increaseStock.
  ///
  /// In en, this message translates to:
  /// **'Stock Increase (Surplus)'**
  String get increaseStock;

  /// No description provided for @decreaseStock.
  ///
  /// In en, this message translates to:
  /// **'Stock Decrease (Damaged/Lost)'**
  String get decreaseStock;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock Count'**
  String get initialStock;

  /// No description provided for @postAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Post Adjustment'**
  String get postAdjustment;

  /// No description provided for @postTransfer.
  ///
  /// In en, this message translates to:
  /// **'Post Transfer'**
  String get postTransfer;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Management & Claims'**
  String get expensesTitle;

  /// No description provided for @expensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employee expense claims, policy compliance, approvals, and reimbursements'**
  String get expensesSubtitle;

  /// No description provided for @claimsAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get claimsAwaitingApproval;

  /// No description provided for @reimbursedYtd.
  ///
  /// In en, this message translates to:
  /// **'Reimbursed YTD'**
  String get reimbursedYtd;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant / Payee'**
  String get merchant;

  /// No description provided for @receiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt Attached'**
  String get receiptAttached;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @uploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt'**
  String get uploadReceipt;

  /// No description provided for @approveClaim.
  ///
  /// In en, this message translates to:
  /// **'Approve Claim'**
  String get approveClaim;

  /// No description provided for @rejectClaim.
  ///
  /// In en, this message translates to:
  /// **'Reject Claim'**
  String get rejectClaim;

  /// No description provided for @approvalStepManager.
  ///
  /// In en, this message translates to:
  /// **'Line Manager Review'**
  String get approvalStepManager;

  /// No description provided for @approvalStepFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance Audit'**
  String get approvalStepFinance;

  /// No description provided for @approvalStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Disbursement'**
  String get approvalStepPayment;

  /// No description provided for @accountingTitle.
  ///
  /// In en, this message translates to:
  /// **'General Ledger & Accounting'**
  String get accountingTitle;

  /// No description provided for @accountingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chart of accounts hierarchy, manual journal vouchers, and audit trails'**
  String get accountingSubtitle;

  /// No description provided for @newJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'New Journal Entry'**
  String get newJournalEntry;

  /// No description provided for @newGlAccount.
  ///
  /// In en, this message translates to:
  /// **'New General Ledger Account'**
  String get newGlAccount;

  /// No description provided for @parentAccount.
  ///
  /// In en, this message translates to:
  /// **'Parent Account'**
  String get parentAccount;

  /// No description provided for @isGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Header / Group Account'**
  String get isGroupAccount;

  /// No description provided for @groupAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Header account used for grouping; cannot be posted to directly.'**
  String get groupAccountNote;

  /// No description provided for @costCenter.
  ///
  /// In en, this message translates to:
  /// **'Cost Center'**
  String get costCenter;

  /// No description provided for @narration.
  ///
  /// In en, this message translates to:
  /// **'Narration / Memo'**
  String get narration;

  /// No description provided for @entryNumber.
  ///
  /// In en, this message translates to:
  /// **'Entry Number'**
  String get entryNumber;

  /// No description provided for @minTwoLinesRequired.
  ///
  /// In en, this message translates to:
  /// **'A double-entry journal entry requires a minimum of 2 lines.'**
  String get minTwoLinesRequired;

  /// No description provided for @debitsMustEqualCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Debits must equal Total Credits.'**
  String get debitsMustEqualCredits;

  /// No description provided for @postingAccount.
  ///
  /// In en, this message translates to:
  /// **'Posting Account'**
  String get postingAccount;

  /// No description provided for @bankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Banking & Treasury'**
  String get bankingTitle;

  /// No description provided for @bankingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank feeds, statement reconciliation, transaction matching & auto-clearing'**
  String get bankingSubtitle;

  /// No description provided for @bankStatementLines.
  ///
  /// In en, this message translates to:
  /// **'Bank Statement Lines'**
  String get bankStatementLines;

  /// No description provided for @bookTransactions.
  ///
  /// In en, this message translates to:
  /// **'Book Transactions (Unreconciled)'**
  String get bookTransactions;

  /// No description provided for @createBankEntry.
  ///
  /// In en, this message translates to:
  /// **'Create Bank Charge / Entry'**
  String get createBankEntry;

  /// No description provided for @importBankStatement.
  ///
  /// In en, this message translates to:
  /// **'Import Statement (CSV)'**
  String get importBankStatement;

  /// No description provided for @autoMatch.
  ///
  /// In en, this message translates to:
  /// **'Auto-Match'**
  String get autoMatch;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get matched;

  /// No description provided for @clearTransaction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTransaction;

  /// No description provided for @reconciliationDifferenceError.
  ///
  /// In en, this message translates to:
  /// **'Difference must be 0.00 AED before finishing reconciliation.'**
  String get reconciliationDifferenceError;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports & UAE VAT 201'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Certified double-entry reports, UAE VAT 201 statements, and management intelligence'**
  String get reportsSubtitle;

  /// No description provided for @glDrilldownTitle.
  ///
  /// In en, this message translates to:
  /// **'General Ledger Drill-Down'**
  String get glDrilldownTitle;

  /// No description provided for @exportBoardPackPdf.
  ///
  /// In en, this message translates to:
  /// **'Export Board Pack PDF'**
  String get exportBoardPackPdf;

  /// No description provided for @comparePeriod.
  ///
  /// In en, this message translates to:
  /// **'Compare: Prior Period'**
  String get comparePeriod;

  /// No description provided for @compareYear.
  ///
  /// In en, this message translates to:
  /// **'Compare: Prior Year'**
  String get compareYear;

  /// No description provided for @allCostCenters.
  ///
  /// In en, this message translates to:
  /// **'All Cost Centers'**
  String get allCostCenters;

  /// No description provided for @companyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Profile & Legal Entity'**
  String get companyProfileTitle;

  /// No description provided for @companyProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Primary trading entity for invoice headers and official tax documentation'**
  String get companyProfileSubtitle;

  /// No description provided for @trnNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax Registration Number (TRN)'**
  String get trnNumberLabel;

  /// No description provided for @lockBooksPriorTo.
  ///
  /// In en, this message translates to:
  /// **'Books Locked Prior to:'**
  String get lockBooksPriorTo;

  /// No description provided for @saveSettingsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get saveSettingsSuccess;

  /// No description provided for @runReport.
  ///
  /// In en, this message translates to:
  /// **'Run Report'**
  String get runReport;

  /// No description provided for @batchApprove.
  ///
  /// In en, this message translates to:
  /// **'Batch Approve'**
  String get batchApprove;

  /// No description provided for @saveBill.
  ///
  /// In en, this message translates to:
  /// **'Save Bill'**
  String get saveBill;

  /// No description provided for @saveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save Account'**
  String get saveAccount;

  /// No description provided for @optimalStock.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimalStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @generalLedgerTrail.
  ///
  /// In en, this message translates to:
  /// **'General Ledger Trail'**
  String get generalLedgerTrail;

  /// No description provided for @selectCsvFile.
  ///
  /// In en, this message translates to:
  /// **'Select CSV File'**
  String get selectCsvFile;

  /// No description provided for @uploadReceiptPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV file containing lead coordinates, estimated deal amounts, and sales owners. Records will be automatically parsed and mapped into the Sales Pipeline.'**
  String get uploadReceiptPrompt;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusReimbursed.
  ///
  /// In en, this message translates to:
  /// **'Reimbursed'**
  String get statusReimbursed;

  /// No description provided for @statusPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get statusPosted;

  /// No description provided for @salesPipeline.
  ///
  /// In en, this message translates to:
  /// **'Sales Pipeline'**
  String get salesPipeline;

  /// No description provided for @searchOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Search opportunity...'**
  String get searchOpportunity;

  /// No description provided for @totalStockValue.
  ///
  /// In en, this message translates to:
  /// **'Total stock value'**
  String get totalStockValue;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @invoicePdfPreview.
  ///
  /// In en, this message translates to:
  /// **'Tax Invoice PDF Preview'**
  String get invoicePdfPreview;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @paidThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Paid (this month)'**
  String get paidThisMonth;

  /// No description provided for @activeSkus.
  ///
  /// In en, this message translates to:
  /// **'Active SKUs'**
  String get activeSkus;

  /// No description provided for @belowReorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Below reorder level'**
  String get belowReorderLevel;

  /// No description provided for @weightedAverageCost.
  ///
  /// In en, this message translates to:
  /// **'Weighted average cost'**
  String get weightedAverageCost;

  /// No description provided for @suggestedPoValue.
  ///
  /// In en, this message translates to:
  /// **'Suggested PO value'**
  String get suggestedPoValue;

  /// No description provided for @withOpenQuotations.
  ///
  /// In en, this message translates to:
  /// **'with open quotations'**
  String get withOpenQuotations;

  /// No description provided for @warehouses.
  ///
  /// In en, this message translates to:
  /// **'warehouses'**
  String get warehouses;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statusPartial;

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'All Expenses'**
  String get allExpenses;

  /// No description provided for @myExpenses.
  ///
  /// In en, this message translates to:
  /// **'My expenses'**
  String get myExpenses;

  /// No description provided for @awaitingMyApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting my approval'**
  String get awaitingMyApproval;

  /// No description provided for @toReimburse.
  ///
  /// In en, this message translates to:
  /// **'To reimburse'**
  String get toReimburse;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategory;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @approveSelected.
  ///
  /// In en, this message translates to:
  /// **'Approve selected'**
  String get approveSelected;

  /// No description provided for @reimburseSelected.
  ///
  /// In en, this message translates to:
  /// **'Reimburse selected'**
  String get reimburseSelected;

  /// No description provided for @newStockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'New Stock Adjustment'**
  String get newStockAdjustment;

  /// No description provided for @newStockTransfer.
  ///
  /// In en, this message translates to:
  /// **'New Stock Transfer'**
  String get newStockTransfer;

  /// No description provided for @scanItemBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Item Barcode'**
  String get scanItemBarcode;

  /// No description provided for @mobileReceiptCamera.
  ///
  /// In en, this message translates to:
  /// **'Mobile Receipt Camera'**
  String get mobileReceiptCamera;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
