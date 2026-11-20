// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فين ليدجر';

  @override
  String get tagline => 'نظام المحاسبة مزدوجة القيد وتخطيط الموارد';

  @override
  String get save => 'حفظ';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get create => 'إنشاء';

  @override
  String get apply => 'تطبيق';

  @override
  String get filter => 'تصفية';

  @override
  String get search => 'بحث';

  @override
  String get searchPlaceholder => 'البحث بالرمز، العميل، المرجع...';

  @override
  String get status => 'الحالة';

  @override
  String get action => 'الإجراء';

  @override
  String get actions => 'الإجراءات';

  @override
  String get export => 'تصدير';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get print => 'طباعة';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noData => 'لا توجد سجلات';

  @override
  String get success => 'نجاح';

  @override
  String get error => 'خطأ';

  @override
  String get refresh => 'تحديث';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get confirm => 'تأكيد';

  @override
  String get view => 'عرض';

  @override
  String get all => 'الكل';

  @override
  String get total => 'الإجمالي';

  @override
  String get date => 'التاريخ';

  @override
  String get notes => 'الملاحظات';

  @override
  String get amount => 'المبلغ';

  @override
  String get currencyAed => 'د.إ';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get crm => 'إدارة علاقات العملاء';

  @override
  String get leads => 'العملاء المحتملون';

  @override
  String get pipeline => 'المسار البيعي';

  @override
  String get quotations => 'عروض الأسعار';

  @override
  String get sales => 'المبيعات';

  @override
  String get customers => 'العملاء';

  @override
  String get invoices => 'الفواتير الضريبية';

  @override
  String get receipts => 'الإيصالات';

  @override
  String get purchases => 'المشتريات';

  @override
  String get vendors => 'الموردون';

  @override
  String get bills => 'فواتير الموردين';

  @override
  String get payments => 'المدفوعات';

  @override
  String get inventory => 'المخزون';

  @override
  String get itemsAndStock => 'الأصناف والمخزون';

  @override
  String get adjustments => 'تسويات المخزون';

  @override
  String get transfers => 'المناقلات';

  @override
  String get expenses => 'المصروفات';

  @override
  String get expensesSection => 'المصروفات';

  @override
  String get approvals => 'الموافقات';

  @override
  String get accounting => 'المحاسبة';

  @override
  String get chartOfAccounts => 'شجرة الحسابات (دليل الحسابات)';

  @override
  String get journalEntries => 'قيود اليومية';

  @override
  String get banking => 'الخدمات المصرفية';

  @override
  String get bankAccounts => 'الحسابات البنكية';

  @override
  String get reconciliation => 'التسوية البنكية';

  @override
  String get reports => 'التقارير المالية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get companySettings => 'إعدادات الشركة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle =>
      'أدخل بيانات الاعتماد للمؤسسة لتسجيل الدخول إلى فين ليدجر';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'admin@finledger.com';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get securedWithJwt => 'محمي بمصادقة JWT الآمنة';

  @override
  String get accountLocked => 'تم قفل الحساب مؤقتًا بعد 5 محاولات فاشلة.';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get connectionError => 'تعذر الاتصال بالخادم. تحقق من اتصال الشبكة.';

  @override
  String get financialOverview => 'نظرة عامة مالية';

  @override
  String get operationalKpis => 'مؤشرات الأداء التشغيلية';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get ytdExpenses => 'المصروفات التراكمية';

  @override
  String get receivables => 'الذمم المدينة (العملاء)';

  @override
  String get cashAndBank => 'النقد والبنوك';

  @override
  String get openInvoices => 'فواتير غير مسددة';

  @override
  String get bankAccountsCount => 'حسابات بنكية';

  @override
  String get openPipelineCrm => 'المسار البيعي المفتوح';

  @override
  String get opportunities => 'فرص بيعية';

  @override
  String get weightedProbability => 'الاحتمالية المرجحة';

  @override
  String get inventoryValue => 'قيمة المخزون';

  @override
  String get lowStockAlert => 'تنبيهات انخفاض المخزون';

  @override
  String get expensesAwaitingApproval => 'مصروفات بانتظار الاعتماد';

  @override
  String get pendingClaims => 'مطالبات معلقة';

  @override
  String get accountsPayable => 'الذمم الدائنة (الموردون)';

  @override
  String get openBills => 'فواتير موردين غير مسددة';

  @override
  String get revenueVsExpenses => 'الإيرادات مقابل المصروفات (6 أشهر)';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get newInvoice => 'فاتورة جديدة';

  @override
  String get recordReceipt => 'سند قبض';

  @override
  String get enterBill => 'تسجيل فاتورة مورد';

  @override
  String get newExpense => 'مصروف جديد';

  @override
  String get recentActivity => 'النشاط المالي الأخير';

  @override
  String get crmPipeline => 'مسار الفرص البيعية';

  @override
  String get newDeal => 'صفقة جديدة';

  @override
  String get wonThisQuarter => 'تم الفوز بها هذا الربع';

  @override
  String get winRate => 'معدل الفوز (90 يوماً)';

  @override
  String get stageLead => 'محتمل';

  @override
  String get stageQualified => 'مؤهل';

  @override
  String get stageProposal => 'تقديم عرض';

  @override
  String get stageNegotiation => 'تفاوض';

  @override
  String get stageWon => 'ناجحة';

  @override
  String get stageLost => 'خاسرة';

  @override
  String get convertCustomer => 'تحويل إلى حساب عميل';

  @override
  String get markWon => 'تحديد كناجحة';

  @override
  String get markLost => 'تحديد كمفقود';

  @override
  String get opportunityDetails => 'تفاصيل الفرصة';

  @override
  String get expectedClose => 'الإغلاق المتوقع';

  @override
  String get probability => 'الاحتمالية';

  @override
  String get dealValue => 'قيمة الصفقة';

  @override
  String get contactPerson => 'الشخص المسؤول';

  @override
  String get phone => 'الهاتف';

  @override
  String get taxInvoices => 'الفواتير الضريبية';

  @override
  String get createInvoice => 'إنشاء فاتورة';

  @override
  String get newTaxInvoice => 'فاتورة ضريبية جديدة';

  @override
  String get customerReceipts => 'إيصالات قبض العملاء';

  @override
  String get recordCustomerReceipt => 'تسجيل سند قبض عميل';

  @override
  String get invoiceNumber => 'رقم الفاتورة';

  @override
  String get customer => 'العميل';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get issueDate => 'تاريخ الإصدار';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get vat => 'ضريبة القيمة المضافة';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get paidAmount => 'المبلغ المدفوع';

  @override
  String get balanceDue => 'الرصيد المتبقي';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusSent => 'مرسلة';

  @override
  String get statusPaid => 'مدفوعة';

  @override
  String get statusPartiallyPaid => 'مدفوعة جزئيًا';

  @override
  String get statusOverdue => 'متأخرة';

  @override
  String get statusVoid => 'ملغاة';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get reference => 'المرجع';

  @override
  String get lineItems => 'بنود الفاتورة';

  @override
  String get addItem => 'إضافة بند';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get quantity => 'الكمية';

  @override
  String get vendorBills => 'فواتير الموردين';

  @override
  String get enterVendorBill => 'إدخال فاتورة مورد';

  @override
  String get vendor => 'المورد';

  @override
  String get billNumber => 'رقم الفاتورة';

  @override
  String get vendorPayments => 'مدفوعات الموردين';

  @override
  String get recordPayment => 'تسجيل الدفعة';

  @override
  String get itemsStock => 'الأصناف والمخزون';

  @override
  String get newItem => 'صنف جديد';

  @override
  String get sku => 'رمز الصنف (SKU)';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get category => 'الفئة';

  @override
  String get unitCost => 'تكلفة الوحدة';

  @override
  String get sellingPrice => 'سعر البيع';

  @override
  String get onHand => 'المتوفر';

  @override
  String get reorderPoint => 'نقطة إعادة الطلب';

  @override
  String get warehouse => 'المستودع';

  @override
  String get stockAdjustment => 'تسوية كميات المخزون';

  @override
  String get stockTransfer => 'مناقلة مخزنية';

  @override
  String get reason => 'السبب';

  @override
  String get expenseClaims => 'مطالبات المصروفات';

  @override
  String get newExpenseClaim => 'مطالبة مصروفات جديدة';

  @override
  String get expenseApprovals => 'اعتمادات المصروفات';

  @override
  String get claimNumber => 'رقم المطالبة';

  @override
  String get claimant => 'مقدم الطلب';

  @override
  String get approve => 'اعتماد';

  @override
  String get reject => 'رفض';

  @override
  String get reimburse => 'صرف التعويض';

  @override
  String get coa => 'دليل الحسابات (شجرة الحسابات)';

  @override
  String get newAccount => 'حساب جديد';

  @override
  String get accountCode => 'رمز الحساب';

  @override
  String get accountName => 'اسم الحساب';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get normalBalance => 'طبيعة الرصيد';

  @override
  String get debit => 'مدين';

  @override
  String get credit => 'دائن';

  @override
  String get balanced => 'متزن';

  @override
  String get unbalanced => 'غير متزن';

  @override
  String get postJournal => 'ترحيل القيد';

  @override
  String get saveDraft => 'حفظ كمسودة';

  @override
  String get journalNo => 'رقم القيد';

  @override
  String get description => 'البيان / الوصف';

  @override
  String get bankingOverview => 'العمليات المصرفية والحسابات';

  @override
  String get bankReconciliation => 'التسوية والمطابقة البنكية';

  @override
  String get statementBalance => 'رصيد نهاية كشف الحساب';

  @override
  String get bookBalance => 'رصيد الدفاتر المحاسبية';

  @override
  String get difference => 'فرق التسوية';

  @override
  String get reconciled => 'مطابق';

  @override
  String get unreconciled => 'غير مطابق';

  @override
  String get match => 'مطابقة';

  @override
  String get importCsv => 'استيراد كشف حساب (CSV)';

  @override
  String get finishReconciliation => 'إنهاء التسوية';

  @override
  String get financialReports => 'التقارير المالية';

  @override
  String get profitLoss => 'قائمة الأرباح والخسائر (الدخل)';

  @override
  String get balanceSheet => 'الميزانية العمومية (المركز المالي)';

  @override
  String get trialBalance => 'ميزان المراجعة';

  @override
  String get generalLedger => 'دفتر الأستاذ العام';

  @override
  String get vatReturn => 'إقرار ضريبة القيمة المضافة 201';

  @override
  String get arAgeing => 'أعمار الديون (العملاء)';

  @override
  String get apAgeing => 'أعمار الذمم (الموردون)';

  @override
  String get systemSettings => 'إعدادات الشركة والنظام';

  @override
  String get home => 'الرئيسية';

  @override
  String get switchCompany => 'تبديل الشركة';

  @override
  String get switchLanguage => 'تبديل اللغة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get languageSelection => 'اختيار اللغة';

  @override
  String get englishLang => 'English';

  @override
  String get hindiLang => 'हिन्दी (Hindi)';

  @override
  String get arabicRtl => 'العربية (Arabic - RTL)';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختيار اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी (Hindi)';

  @override
  String get languageArabic => 'العربية (Arabic - RTL)';

  @override
  String get companyProfile => 'ملف الشركة';

  @override
  String get fiscalYears => 'السنوات المالية';

  @override
  String get taxRates => 'النسب الضريبية';

  @override
  String get currencies => 'العملات';

  @override
  String get numberSeries => 'سلاسل الترقيم';

  @override
  String get usersRoles => 'المستخدمون والأدوار';

  @override
  String get auditLog => 'سجل التدقيق والمراجعة';

  @override
  String get languageChanged => 'تم تحديث لغة التطبيق بنجاح';

  @override
  String get salesPipelineCrm => 'مسار المبيعات وإدارة علاقات العملاء';

  @override
  String get crmSubtitle =>
      'مراحل تقدم الصفقات: المراحل، وقيم الصفقات، والتوقعات المرجحة';

  @override
  String get importLeads => 'استيراد العملاء المحتملين';

  @override
  String get importLeadsAndDeals => 'استيراد العملاء والصفقات';

  @override
  String get leadsImportSuccess =>
      'اكتمل استيراد العملاء المحتملين. تمت إضافة 6 فرص جديدة.';

  @override
  String get newOpportunity => 'فرصة جديدة';

  @override
  String get createDeal => 'إنشاء صفقة';

  @override
  String get createOpportunity => 'إنشاء فرصة جديدة';

  @override
  String get openPipeline => 'المسار المفتوح';

  @override
  String get weightedForecast => 'التوقعات الموزونة';

  @override
  String get boardView => 'لوحة';

  @override
  String get listView => 'قائمة';

  @override
  String get dealTitle => 'عنوان الصفقة / الفرصة';

  @override
  String get prospectCustomerName => 'اسم العميل المتوقع / العميل';

  @override
  String get salesOwner => 'مسؤول المبيعات';

  @override
  String get expectedValueAed => 'القيمة المتوقعة (درهم)';

  @override
  String get winProbability => 'احتمالية النجاح';

  @override
  String get initialStage => 'المرحلة الأولية';

  @override
  String get dealCannotBeWonWithoutCustomer =>
      'لا يمكن تحديد الصفقة كرابحة بدون ربط عميل.';

  @override
  String get dealCannotBeLostWithoutReason =>
      'لا يمكن تحديد الصفقة كخاسرة بدون سبب إلزامي.';

  @override
  String get primaryReason => 'السبب الرئيسي';

  @override
  String get additionalNotes => 'ملاحظات إضافية (اختياري)';

  @override
  String get confirmMarkLost => 'تأكيد وتحديد كخاسرة';

  @override
  String get companyOrgName => 'اسم الشركة / المؤسسة';

  @override
  String get billingEmail => 'البريد الإلكتروني للفوترة';

  @override
  String get trnTaxNumber => 'الرقم الضريبي / TRN';

  @override
  String get backToPipeline => 'العودة إلى مسار الصفقات';

  @override
  String get dealDetails => 'تفاصيل الصفقة';

  @override
  String get activities => 'الأنشطة';

  @override
  String get quotationsList => 'عروض الأسعار';

  @override
  String get generateQuotation => 'إنشاء عرض أسعار';

  @override
  String get activeDealsCount => 'صفقات نشطة';

  @override
  String get closedDealsCount => 'صفقات مغلقة';

  @override
  String get markOpportunityLost => 'تحديد الفرصة كخاسرة';

  @override
  String get lostReasonPrompt => 'يرجى تحديد سبب خسارة هذه الصفقة.';

  @override
  String get lostReasonHint =>
      'أدخل تفاصيل عن المنافس أو الفارق السعري أو ملاحظات العميل...';

  @override
  String get filterByOwner => 'المسؤول';

  @override
  String get filterByPeriod => 'فترة الإغلاق';

  @override
  String get closeAll => 'الإغلاق: الكل';

  @override
  String get closeThisMonth => 'الإغلاق: هذا الشهر';

  @override
  String get closeThisQuarter => 'الإغلاق: هذا الربع';

  @override
  String get closeNextQuarter => 'الإغلاق: الربع القادم';

  @override
  String get salesInvoicesTitle => 'فواتير المبيعات';

  @override
  String get salesInvoicesSubtitle =>
      'إدارة الفواتिर الضريبية المعتمدة لضريبة القيمة المضافة في الإمارات';

  @override
  String get createTaxInvoice => 'إنشاء فاتورة ضريبية';

  @override
  String get downloadTaxPdf => 'تنزيل الفاتورة الضريبية PDF';

  @override
  String get sendToCustomer => 'إرسال إلى العميل';

  @override
  String get invoiceExportSuccess => 'تم تصدير الفواتير إلى CSV بنجاح.';

  @override
  String get paymentTerms => 'شروط الدفع';

  @override
  String get dueOnReceipt => 'مستحق عند الاستلام';

  @override
  String get net15 => 'صافي 15 يوماً';

  @override
  String get net30 => 'صافي 30 يوماً';

  @override
  String get net60 => 'صافي 60 يوماً';

  @override
  String get itemDescription => 'الصنف / الوصف';

  @override
  String get taxRate => 'نسبة الضريبة';

  @override
  String get discount => 'الخصم';

  @override
  String get discountPct => 'نسبة الخصم %';

  @override
  String get deleteLine => 'حذف البند';

  @override
  String get saveAndApprove => 'حفظ واعتماد';

  @override
  String get billTo => 'فاتورة إلى:';

  @override
  String get closePreview => 'إغلاق المعاينة';

  @override
  String get downloadPrintPdf => 'تنزيل / طباعة PDF';

  @override
  String get bankTransfer => 'تحويل بنكي';

  @override
  String get cash => 'نقداً';

  @override
  String get cheque => 'شيك';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get depositToAccount => 'الإيداع في الحساب';

  @override
  String get applyToOutstanding => 'تطبيق على الفواتير المستحقة';

  @override
  String get customerReceiptRecorded =>
      'تم تسجيل إيصال العميل وترحيله إلى دفتر الأستاذ!';

  @override
  String get amountGreaterThanZero =>
      'يجب أن يكون المبلغ المستلم أكبر من الصفر';

  @override
  String get autoJournal => 'قيد يومية تلقائي:';

  @override
  String get purchasesTitle => 'المشتريات والحسابات الدائنة';

  @override
  String get purchasesSubtitle =>
      'إدارة فواتير الموردين، وإشعارات الخصم، ومطابقة المدفوعات';

  @override
  String get openPayables => 'الذمم الدائنة القائمة';

  @override
  String get activeVendors => 'الموردون المعتمدون';

  @override
  String get billDate => 'تاريخ الفاتورة';

  @override
  String get againstBill => 'مقابل الفاتورة';

  @override
  String get disbursementMethod => 'طريقة الصرف';

  @override
  String get vendorBillRecorded => 'تم حفظ فاتورة المورد بنजاح';

  @override
  String get inventoryTitle => 'المخزون وتقييم البضاعة';

  @override
  String get inventorySubtitle =>
      'التكلفة المرجحة المستمرة، وحركات المخزون، وتنبيهات نقص المخزون';

  @override
  String get activeWarehouses => 'المستودعات النشطة';

  @override
  String get lowStockAlerts => 'تنبيهات نقص المخزون';

  @override
  String get stockMovementLog => 'سجل حركات المخزون';

  @override
  String get barcodeScanner => 'ماسح الباركود';

  @override
  String get stockLedger => 'دفتر الأستاذ للمخزون';

  @override
  String get sourceWarehouse => 'المستودع المصدر';

  @override
  String get destinationWarehouse => 'المستودع الوجهة';

  @override
  String get adjustmentType => 'نوع التسوية';

  @override
  String get increaseStock => 'زيادة المخزون (فائض)';

  @override
  String get decreaseStock => 'نقص المخزون (تالف/مفقود)';

  @override
  String get initialStock => 'جرد المخزون الأولي';

  @override
  String get postAdjustment => 'ترحيل التسوية';

  @override
  String get postTransfer => 'ترحيل التحويل';

  @override
  String get expensesTitle => 'إدارة النفقات والمطالبات';

  @override
  String get expensesSubtitle =>
      'مطالبات نفقات الموظفين، والامتثال، والموافقات، والتعويضات';

  @override
  String get claimsAwaitingApproval => 'بانتظار الموافقة';

  @override
  String get reimbursedYtd => 'المصروفات المستردة منذ بداية العام';

  @override
  String get expenseCategory => 'فئة النفقة';

  @override
  String get merchant => 'التاجر / المستفيد';

  @override
  String get receiptAttached => 'الإيصال مرفق';

  @override
  String get scanReceipt => 'مسح الإيصال';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get uploadReceipt => 'رفع الإيصال';

  @override
  String get approveClaim => 'اعتماد المطالبة';

  @override
  String get rejectClaim => 'رفض المطالبة';

  @override
  String get approvalStepManager => 'مراجعة المدير المباشر';

  @override
  String get approvalStepFinance => 'تدقيق المالية';

  @override
  String get approvalStepPayment => 'صرف المستحقات';

  @override
  String get accountingTitle => 'دفتر الأستاذ العام والمحاسبة';

  @override
  String get accountingSubtitle =>
      'دليل الحسابات، قيود اليومية اليدوية، وسجل التدقيق';

  @override
  String get newJournalEntry => 'قيد يومية جديد';

  @override
  String get newGlAccount => 'حساب جديد في دفتر الأستاذ';

  @override
  String get parentAccount => 'الحساب الرئيسي';

  @override
  String get isGroupAccount => 'حساب رئيسي / تجميعي';

  @override
  String get groupAccountNote =>
      'حساب تجميعي للعرض فقط؛ لا يمكن الترحيل إليه مباشرة.';

  @override
  String get costCenter => 'مركز التكلفة';

  @override
  String get narration => 'البيان / الشرح';

  @override
  String get entryNumber => 'رقم القيد';

  @override
  String get minTwoLinesRequired =>
      'يتطلب قيد اليومية المزدوج سطرين على الأقل.';

  @override
  String get debitsMustEqualCredits =>
      'يجب أن يتساوى إجمالي المدين مع إجمالي الدائن.';

  @override
  String get postingAccount => 'حساب الترحيل';

  @override
  String get bankingTitle => 'الخدمات المصرفية والخزينة';

  @override
  String get bankingSubtitle => 'مطابقة كشوف الحسابات البنكية والتسوية الآلية';

  @override
  String get bankStatementLines => 'بنود كشف الحساب البنكي';

  @override
  String get bookTransactions => 'معاملات الدفاتر (غير المسواة)';

  @override
  String get createBankEntry => 'إنشاء قيد مصرفي';

  @override
  String get importBankStatement => 'استيراد كشف حساب (CSV)';

  @override
  String get autoMatch => 'مطابقة تلقائية';

  @override
  String get matched => 'تمت المطابقة';

  @override
  String get clearTransaction => 'تسوية';

  @override
  String get reconciliationDifferenceError =>
      'يجب أن يكون الفارق 0.00 درهم لإنهاء التسوية المصرفية.';

  @override
  String get reportsTitle => 'التقارير المالية وإقرار ضريبة القيمة المضافة';

  @override
  String get reportsSubtitle =>
      'تقارير مالية معتمدة وإقرارات ضريبية متوافقة مع الهيئة الاتحادية للضرائب';

  @override
  String get glDrilldownTitle => 'تفاصيل دفتر الأستاذ العام';

  @override
  String get exportBoardPackPdf => 'تصدير تقرير مجلس الإدارة PDF';

  @override
  String get comparePeriod => 'مقارنة: الفترة السابقة';

  @override
  String get compareYear => 'مقارنة: العام السابق';

  @override
  String get allCostCenters => 'جميع مراكز التكلفة';

  @override
  String get companyProfileTitle => 'الملف التعريفي للشركة والكيان القانوني';

  @override
  String get companyProfileSubtitle =>
      'معلومات الكيان التجاري الرئيسي لترويسات الفواتير الرسمية والإيصالات والتقارير الضريبية الإماراتية';

  @override
  String get trnNumberLabel => 'رقم التسجيل الضريبي (TRN)';

  @override
  String get lockBooksPriorTo => 'إقفال الدفاتر قبل تاريخ:';

  @override
  String get saveSettingsSuccess => 'تم حفظ الإعدادات بنجاح';

  @override
  String get runReport => 'عرض التقرير';

  @override
  String get batchApprove => 'اعتماد جماعي';

  @override
  String get saveBill => 'حفظ الفاتورة';

  @override
  String get saveAccount => 'حفظ الحساب';

  @override
  String get optimalStock => 'مثالي';

  @override
  String get lowStock => 'منخفض';

  @override
  String get generalLedgerTrail => 'مسار دفتر الأستاذ العام';

  @override
  String get selectCsvFile => 'اختيار ملف CSV';

  @override
  String get uploadReceiptPrompt =>
      'قم برفع ملف CSV يحتوي على بيانات العملاء وقيم الصفقات المتوقعة ليتم استيرادها تلقائيًا.';

  @override
  String get inStock => 'متوفر بالمخزون';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String get statusSubmitted => 'تم التقديم';

  @override
  String get statusReimbursed => 'تم التعويض';

  @override
  String get statusPosted => 'تم الترحيل';

  @override
  String get salesPipeline => 'مسار المبيعات';

  @override
  String get searchOpportunity => 'البحث عن فرصة...';

  @override
  String get totalStockValue => 'إجمالي قيمة المخزون';

  @override
  String get statusApproved => 'معتمد';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get invoicePdfPreview => 'معاينة الفاتورة الضريبية PDF';

  @override
  String get statusUnpaid => 'غير مدفوع';

  @override
  String get paidThisMonth => 'مدفوع (هذا الشهر)';

  @override
  String get activeSkus => 'الوحدات النشطة (SKUs)';

  @override
  String get belowReorderLevel => 'أقل من مستوى إعادة الطلب';

  @override
  String get weightedAverageCost => 'متوسط التكلفة المرجح';

  @override
  String get suggestedPoValue => 'قيمة أمر الشراء المقترحة';

  @override
  String get withOpenQuotations => 'مع عروض أسعار مفتوحة';

  @override
  String get warehouses => 'مستودعات';

  @override
  String get statusPartial => 'جزئي';

  @override
  String get statusLow => 'منخفض';

  @override
  String get allExpenses => 'جميع المصروفات';

  @override
  String get myExpenses => 'مصروفاتي';

  @override
  String get awaitingMyApproval => 'في انتظار موافقتي';

  @override
  String get toReimburse => 'للتعويض';

  @override
  String get topCategory => 'الفئة الأعلى';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get approveSelected => 'الموافقة على المحدد';

  @override
  String get reimburseSelected => 'تعويض المحدد';

  @override
  String get newStockAdjustment => 'تعديل مخزون جديد';

  @override
  String get newStockTransfer => 'تحويل مخزون جديد';

  @override
  String get scanItemBarcode => 'مسح باركود العنصر';

  @override
  String get mobileReceiptCamera => 'كاميرا إيصالات الهاتف';

  @override
  String get vsLastYear => 'مقارنة بالعام الماضي';

  @override
  String get revenueVsExpenses6Months =>
      'الإيرادات مقابل المصروفات (آخر 6 أشهر)';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get receivablesAgeing => 'تقادم الذمم المدينة';

  @override
  String get ageingCurrent => 'الحالي';

  @override
  String get ageing1to30Days => '1-30 يوم';

  @override
  String get ageing31to60Days => '31-60 يوم';

  @override
  String get ageing61to90Days => '61-90 يوم';

  @override
  String get ageing90PlusDays => '+90 يوم';

  @override
  String get typeInvoice => 'فاتورة';

  @override
  String get typeReceipt => 'إيصال';

  @override
  String get typeBill => 'فاتورة شراء';

  @override
  String get statusPending => 'معلق';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusMatched => 'مطابق';

  @override
  String get statusUnreconciled => 'غير مسوّى';

  @override
  String get statusInStock => 'متوفر بالمخزون';

  @override
  String get statusOutOfStock => 'نفذ من المخزون';

  @override
  String get statusOpen => 'مفتوح';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get colCode => 'الرمز';

  @override
  String get colVendorName => 'اسم المورد';

  @override
  String get colTrn => 'الرقم الضريبي';

  @override
  String get colPaymentTerms => 'شروط الدفع';

  @override
  String get colOpenPayables => 'المستحقات المفتوحة';

  @override
  String get colActions => 'الإجراءات';

  @override
  String get colBillNo => 'رقم الفاتورة';

  @override
  String get colBillDate => 'تاريخ الفاتورة';

  @override
  String get colDueDate => 'تاريخ الاستحقاق';

  @override
  String get colPaymentNo => 'رقم الدفعة';

  @override
  String get colMethod => 'الطريقة';

  @override
  String get colClaimNo => 'رقم المطالبة';

  @override
  String get colCategory => 'الفئة';

  @override
  String get colReceipt => 'الإيصال';

  @override
  String get colItem => 'الصنف';

  @override
  String get colOnHand => 'في اليد';

  @override
  String get colReorderLevel => 'حد إعادة الطلب';

  @override
  String get colAccountName => 'اسم الحساب';

  @override
  String get colParent => 'الحساب الرئيسي';

  @override
  String get colBalanceAed => 'الرصيد (درهم)';

  @override
  String get searchAccount => 'البحث عن حساب...';

  @override
  String get termsDueOnReceipt => 'مستحق عند الاستلام';

  @override
  String get termsNet15 => 'صافي 15';

  @override
  String get termsNet30 => 'صافي 30';

  @override
  String get termsNet60 => 'صافي 60';

  @override
  String get previewPdf => 'معاينة PDF';

  @override
  String get saveAndSend => 'حفظ وإرسال';

  @override
  String get importAndAutoMatch => 'استيراد ومطابقة تلقائية';

  @override
  String get loadSampleCsv => 'تحميل نموذج CSV';

  @override
  String get quickQuotation => 'عرض أسعار سريع';

  @override
  String get menuTooltip => 'القائمة';

  @override
  String get exportCoaXlsxPrompt =>
      'جارٍ تصدير شجرة الحسابات إلى Excel (.xlsx)';

  @override
  String get importCoaXlsxPrompt =>
      'جارٍ استيراد شجرة الحسابات من قالب Excel (.xlsx)';

  @override
  String get importAction => 'استيراد';

  @override
  String get colEmployee => 'الموظف';

  @override
  String get whDubai => 'مستودع دبي';

  @override
  String get whRiyadh => 'مستودع الرياض';

  @override
  String get colAvgCost => 'متوسط التكلفة';

  @override
  String get colValueAed => 'القيمة (درهم)';

  @override
  String get newInventorySku => 'رمز صنف مخزون جديد';

  @override
  String get saveSku => 'حفظ رمز الصنف';

  @override
  String get collapseSidebar => 'طي الشريط الجانبي';

  @override
  String get expandSidebar => 'توسيع الشريط الجانبي';

  @override
  String get languageAndRegion => 'اللغة والمنطقة';

  @override
  String get usersAndRoles => 'المستخدمون والأدوار';

  @override
  String get companyAndSystemSettings => 'إعدادات الشركة والنظام';

  @override
  String get companyProfileUpdated => 'تم تحديث ملف تعريف الشركة بنجاح';

  @override
  String get companyLogoUploaded => 'تم تحميل شعار الشركة بنجاح';

  @override
  String get companyLogoRemoved => 'تمت إزالة شعار الشركة';

  @override
  String get uploadNewLogo => 'تحميل شعار جديد';

  @override
  String get removeLogo => 'إزالة الشعار';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get validationRequired => 'مطلوب';

  @override
  String get validationTrn15Digits =>
      'يجب أن يتكون الرقم الضريبي الإماراتي من 15 رقماً';

  @override
  String get emirateDubai => 'دبي';

  @override
  String get emirateAbuDhabi => 'أبو ظبي';

  @override
  String get emirateSharjah => 'الشارقة';

  @override
  String get emirateAjman => 'عجمان';

  @override
  String get emirateRasAlKhaimah => 'رأس الخيمة';

  @override
  String get emirateFujairah => 'الفجيرة';

  @override
  String get emirateUmmAlQuwain => 'أم القيوين';

  @override
  String get currencyAedFull => 'درهم - درهم الإمارات العربية المتحدة';

  @override
  String get currencyUsdFull => 'دولار - دولار أمريكي';

  @override
  String get currencyAedParen => 'درهم (درهم إماراتي)';

  @override
  String get currencySarParen => 'ريال (ريال سعودي)';

  @override
  String get currencyUsdParen => 'دولار (دولار أمريكي)';

  @override
  String get fiscalYearsAndLocking => 'السنوات المالية وإغلاق الفترات';

  @override
  String get fiscalYearsSubtitle =>
      'تهيئة الفترات المالية المحاسبية ومواعيد إقفال الدفاتر';

  @override
  String get fiscalYear => 'السنة المالية';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get uaeVatRatesRegs =>
      'نسب ولوائح ضريبة القيمة المضافة للهيئة الاتحادية للضرائب';

  @override
  String get uaeVatSubtitle =>
      'النسب القانونية للهيئة الاتحادية للضرائب لتقديم إقرار ضريبة القيمة المضافة 201';

  @override
  String get currenciesAndRates => 'العملات وأسعار الصرف';

  @override
  String get currenciesSubtitle =>
      'أسعار تحويل العملات المتعددة مع الدرهم كعملة أساسية';

  @override
  String get updateRates => 'تحديث الأسعار';

  @override
  String get ratesSynced => 'تمت مزامنة أسعار صرف مصرف الإمارات المركزي';

  @override
  String get rateToAed => 'السعر (مقابل 1.00 درهم)';

  @override
  String get docNumberSeries => 'سلاسل أرقام المستندات';

  @override
  String get docNumberSeriesSubtitle =>
      'أنماط الترقيم التسلسلي والبادئات عبر جميع الوحدات';

  @override
  String get docType => 'نوع المستند';

  @override
  String get prefix => 'البادئة';

  @override
  String get nextSequential => 'التسلسل التالي';

  @override
  String get sampleDocNumber => 'رقم مستند تجريبي';

  @override
  String get usersAndPermissions => 'المستخدمون والأذونات المستندة إلى الأدوار';

  @override
  String get usersAndPermissionsSubtitle =>
      'إدارة المستخدمين المصرح لهم، الفصل بين المهام، وحقوق الوحدات';

  @override
  String get inviteUserBtn => '+ دعوة مستخدم';

  @override
  String get inviteTeamMember => 'دعوة عضو فريق';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get roleDirective => 'توجيه الدور';

  @override
  String get roleAccountant => 'محاسب';

  @override
  String get roleSalesRepresentative => 'مندوب مبيعات';

  @override
  String get roleWarehouseManager => 'مدير مستودع';

  @override
  String get roleController => 'المراقب المالي';

  @override
  String get sendInvite => 'إرسال الدعوة';

  @override
  String get securityAuditTrail => 'سجل التدقيق والأمان';

  @override
  String get securityAuditSubtitle =>
      'تتبع زمني غير قابل للتعديل لعمليات المستخدم وترحيل النظام';

  @override
  String get colTimestamp => 'الطابع الزمني';

  @override
  String get colUser => 'المستخدم';

  @override
  String get colAction => 'الإجراء';

  @override
  String get colDetails => 'التفاصيل';

  @override
  String get colIpAddress => 'عنوان IP';

  @override
  String get adjustmentNo => 'رقم التسوية';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get reasonStockCount => 'جرد المخزون';

  @override
  String get reasonDamagedGoods => 'بضائع تالفة';

  @override
  String get reasonSurplus => 'فائض';

  @override
  String get reasonWriteOff => 'شطب';

  @override
  String get reasonInternalConsumption => 'استهلاك داخلي';

  @override
  String get reasonTheftLoss => 'سرقة / خسارة';

  @override
  String get physicalInventoryCount => 'جرد المخزون الفعلي (تحميل الكل)';

  @override
  String get pleaseAddLineItem => 'يرجى إضافة بند واحد على الأقل.';

  @override
  String get warehousesCannotBeIdentical =>
      'لا يمكن أن يكون مستودع المصدر ومستودع الوجهة متطابقين.';

  @override
  String get fromWarehouse => 'من مستودع';

  @override
  String get toWarehouse => 'إلى مستودع';

  @override
  String get transferNo => 'رقم التحويل';

  @override
  String get dispatchTransfer => 'إرسال التحويل';

  @override
  String get saveProgress => 'حفظ التقدم';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get addLineItem => 'إضافة بند';

  @override
  String get systemQty => 'الكمية بالدفاتر';

  @override
  String get countedQty => 'الكمية الفعلية';

  @override
  String get totalTransferValue => 'إجمالي قيمة التحويل';

  @override
  String get netValueImpact => 'أثر القيمة الصافي';

  @override
  String get searchSkuBarcode => 'البحث عن الرمز / الاسم / الباركود...';

  @override
  String get allWarehouses => 'جميع المستودعات';

  @override
  String get allCategories => 'جميع الفئات';

  @override
  String get allStatus => 'جميع الحالات';

  @override
  String get quickTestBarcodes => 'باركود للاختبار السريع:';

  @override
  String get enterBarcodeSku => 'أدخل الباركود أو الرمز (مثال 629104800130)';

  @override
  String get scanBtn => 'مسح';

  @override
  String get noInventoryItemsFound => 'لم يتم العثور على أصناف تطابق الفلاتر.';

  @override
  String get noStockMovementsRecorded => 'لم تسجل حركات مخزون لهذا الفلتر.';

  @override
  String get exportStockSummaryExcel =>
      'جارٍ تصدير ملخص المخزون إلى Excel/CSV...';

  @override
  String get adjustmentAccount => 'حساب التسوية';

  @override
  String get balanceQty => 'كمية الرصيد';

  @override
  String get transferQty => 'كمية التحويل';

  @override
  String get claimApproved => 'تمت الموافقة على مطالبة المصروفات.';

  @override
  String get claimReimbursedPayroll =>
      'تم صرف المصروف عبر مسير الرواتب / التحويل البنكي.';

  @override
  String get rejectExpenseClaim => 'رفض مطالبة المصروفات';

  @override
  String get enterRejectionReason => 'أدخل سبب الرفض للموظف:';

  @override
  String get postToGl => 'ترحيل إلى دفتر الأستاذ العام';

  @override
  String get selectReceiptDocument => 'حدد وثيقة الإيصال:';

  @override
  String get tapToCaptureAttach => 'انقر للالتقاط والإرفاق';

  @override
  String get noExpensesFoundTab => 'لا توجد مصروفات في هذا التبويب.';

  @override
  String get exportingExpensesExcel => 'جارٍ تصدير المصروفات إلى Excel...';

  @override
  String get employeePayee => 'الموظف / المستفيد';

  @override
  String get paidBy => 'مدفوع من قبل';

  @override
  String get purpose => 'الغرض';

  @override
  String get receiptDate => 'تاريخ الإيصال';

  @override
  String get submitForApproval => 'إرسال للاعتماد';

  @override
  String get expenseAccount => 'حساب المصروفات';

  @override
  String get expenseNo => 'رقم المصروف';

  @override
  String get pleaseSelectCustomer => 'يرجى تحديد عميل';

  @override
  String get exportingInvoicesCsv => 'جارٍ تصدير الفواتير إلى CSV...';

  @override
  String get noInvoicesFound => 'لم يتم العثور على فواتير تطابق المعايير';

  @override
  String get noOpenInvoicesCustomer => 'لا توجد فواتير مفتوحة لهذا العميل.';

  @override
  String get searchInvoiceCustomer => 'البحث عن فاتورة / عميل...';

  @override
  String get amountReceivedGreaterZero =>
      'يجب أن يكون المبلغ المستلم أكبر من الصفر';

  @override
  String get appliedExceedsReceived =>
      'إجمالي المبلغ المطبق يتجاوز المبلغ المستلم.';

  @override
  String get depositTo => 'إيداع في';

  @override
  String get amountReceived => 'المبلغ المستلم';

  @override
  String get referenceChequeNo => 'رقم المرجع / الشيك';

  @override
  String get invoiceDate => 'تاريخ الفاتورة';

  @override
  String get notesToCustomer => 'ملاحظات للعميل';

  @override
  String get discPct => 'خصم %';

  @override
  String get vatRate => 'ض.ق.م %';

  @override
  String get lineTotal => 'الإجمالي';

  @override
  String get taxInvoiceTitle => 'فاتورة ضريبية';

  @override
  String get invoiceTo => 'فاتورة إلى:';

  @override
  String get notesAndBankDetails => 'الملاحظات وتفاصيل الحساب البنكي:';

  @override
  String get paymentTermsHeader => 'شروط الدفع:';

  @override
  String get stageChangedTo => 'تم تغيير المرحلة إلى';

  @override
  String get oppMarkedLost => 'تم تحديد الفرصة كخاسرة';

  @override
  String get logCallMeetingNote => 'تسجيل مكالمة، اجتماع أو ملاحظة...';

  @override
  String get noQuotationsGenerated => 'لم يتم إنشاء أي عروض أسعار بعد.';

  @override
  String get noPrimaryContactLinked => 'لا يوجد جهة اتصال رئيسية مرتبطة.';

  @override
  String get createQuotation => '+ عرض أسعار';

  @override
  String get winProbabilityLabel => 'احتمالية الفوز';

  @override
  String get journalReference => 'مرجع اليومية';

  @override
  String get noJournalTransactionsFound =>
      'لم يتم العثور على حركات يومية لهذا الحساب.';

  @override
  String get reconciliationComplete => 'اكتملت التسوية البنكية';

  @override
  String get reconciliationProgressSaved => 'تم حفظ تقدم التسوية بنجاح';

  @override
  String get postAndClearEntry => 'ترحيل وتصفية القيد';

  @override
  String get card => 'بطاقة';

  @override
  String get topLevelGroup => '— لا يوجد (مجموعة رئيسية) —';

  @override
  String get accountTypeLabel => 'نوع الحساب';

  @override
  String get selectPeriod => 'تحديد الفترة';

  @override
  String get periodYtd =>
      'من بداية العام حتى تاريخه (01-يناير إلى 31-أكتوبر 2026)';

  @override
  String get periodThisMonth => 'هذا الشهر (أكتوبر 2026)';

  @override
  String get periodQ3 => 'الربع الثالث 2026 (01-يوليو إلى 30-سبتمبر 2026)';

  @override
  String get comparePriorYear => 'مقارنة: العام السابق';

  @override
  String get comparePriorPeriod => 'مقارنة: الفترة السابقة';

  @override
  String get compareBudget => 'مقارنة: الميزانية';

  @override
  String get compareNone => 'مقارنة: لا شيء';

  @override
  String get costCenterSales => 'المبيعات';

  @override
  String get costCenterOperations => 'العمليات';

  @override
  String get costCenterAdmin => 'الإدارة';

  @override
  String get run => 'تشغيل';

  @override
  String get colAccount => 'الحساب';

  @override
  String get colChangePct => 'نسبة التغير %';

  @override
  String get entryNo => 'رقم القيد';

  @override
  String get boardPackSuccess =>
      'تم إنشاء وتحميل ملف PDF لحزمة مجلس الإدارة بنجاح.';

  @override
  String get financialStatements => 'القوائم المالية';

  @override
  String get taxCompliance => 'الضرائب والامتثال';

  @override
  String get pnlDesc =>
      'إيرادات التداول، تكلفة البضائع المباعة (COGS)، المصروفات التشغيلية، وهامش صافي الربح';

  @override
  String get balanceSheetDesc =>
      'الأصول والخصوم وملخص حقوق الملكية للأرباح المحتجزة';

  @override
  String get trialBalanceDesc =>
      'قائمة كاملة بجميع أرصدة الحسابات المدينة والدائنة للتحقق من توازن دفتر الأستاذ';

  @override
  String get vatReturnDesc =>
      'تفصيل خانة بخانة للمبيعات بنسبة 5% القياسية، التوريدات الصفرية، وضريبة القيمة المضافة القابلة للاسترداد';

  @override
  String get bankStatementImportedSuccess =>
      'تم استيراد كشف الحساب البنكي بنجاح.';

  @override
  String get companyLegalName => 'الاسم القانوني للشركة *';

  @override
  String get taxRegistrationNumberTrn => 'رقم التسجيل الضريبي (TRN) *';

  @override
  String get tradeLicenseCommercialReg => 'الرخصة التجارية / السجل التجاري *';

  @override
  String get corporateTaxTrn => 'الرقم الضريبي لضريبة الشركات';

  @override
  String get registeredAddress => 'العنوان المسجل *';

  @override
  String get emirateLabel => 'الإمارة *';

  @override
  String get primaryEmailLabel => 'البريد الإلكتروني الرئيسي *';

  @override
  String get validEmailRequired => 'مطلوب بريد إلكتروني صالح';

  @override
  String get phoneNumberLabel => 'رقم الهاتف *';

  @override
  String get websiteLabel => 'الموقع الإلكتروني';

  @override
  String get functionalBaseCurrency => 'العملة الوظيفية الأساسية *';

  @override
  String get companyLogo => 'شعار الشركة';

  @override
  String get companyLogoHint =>
      'يُعرض على الفواتير الضريبية المطبوعة وعروض الأسعار وإيصالات العملاء والتقارير المالية. الحجم الموصى به: 300×100 بكسل. تنسيق PNG أو JPG أو SVG.';

  @override
  String get ftaActive => 'نشط في الهيئة الاتحادية للضرائب';

  @override
  String get booksLockedPriorTo => 'الدفاتر مقفلة قبل: 31-ديسمبر-2025';

  @override
  String get booksLockedDesc =>
      'لا يمكن تعديل أو حذف سندات قيد دفتر الأستاذ العام والفواتير المؤرخة في هذا التاريخ أو قبله دون إذن المراقب المالي.';

  @override
  String get openCurrentStatus => 'مفتوح (الحالي)';

  @override
  String get activeRate => 'سعر نشط';

  @override
  String get baseCurrency => 'العملة الأساسية';

  @override
  String get colRateAed => 'السعر (إلى 1.00 درهم)';

  @override
  String get invitationSent => 'تم إرسال الدعوة إلى';

  @override
  String get asRole => 'بصفة';

  @override
  String get immutableAuditTrace =>
      'تتبع زمني غير قابل للتغيير لعمليات المستخدم ونظام القيود';

  @override
  String get currency => 'العملة';

  @override
  String get currencyName => 'الاسم';

  @override
  String get colCurrency => 'العملة';

  @override
  String get colCurrencyName => 'الاسم';

  @override
  String get reasonExpired => 'منتهي الصلاحية';

  @override
  String get reasonOpeningBalance => 'الرصيد الافتتاحي';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get valueImpactAed => 'تأثير القيمة (درهم)';

  @override
  String get removeLineTooltip => 'حذف البند';

  @override
  String get deleteLineTooltip => 'حذف البند';

  @override
  String get journalPreviewOnPost => 'معاينة القيد (عند الترحيل)';

  @override
  String get stockEffect => 'تأثير المخزون';

  @override
  String get availableQty => 'الكمية المتاحة';

  @override
  String get transferValueAed => 'قيمة التحويل (درهم)';

  @override
  String get stockTransferImpact => 'تأثير تحويل المخزون';

  @override
  String get billableTo => 'قابل للفوترة إلى';

  @override
  String get totalAed => 'الإجمالي (درهم)';

  @override
  String get receipt => 'الإيصال';

  @override
  String get expenseNumber => 'رقم المصروف #';

  @override
  String get net => 'الصافي';

  @override
  String get amountAed => 'المبلغ (درهم)';

  @override
  String get vat5Pct => 'ضريبة 5%';

  @override
  String get vat0Pct => 'ضريبة 0%';

  @override
  String get outstanding => 'المتبقي';

  @override
  String get payment => 'الدفعة';

  @override
  String get convertToCustomer => 'تحويل إلى عميل';

  @override
  String get allTasksCompleted => 'تم إكمال جميع المهام! عمل رائع.';

  @override
  String get standardAvgCostAed => 'التكلفة القياسية / المتوسطة (درهم) *';

  @override
  String get reorderLevelLabel => 'مستوى إعادة الطلب *';

  @override
  String get subTypeOptional => 'النوع الفرعي (اختياري)';

  @override
  String get operations => 'العمليات';

  @override
  String get admin => 'الإدارة';

  @override
  String get invoiceNo => 'رقم الفاتورة';

  @override
  String get tax => 'الضريبة';

  @override
  String get statementDate => 'تاريخ الكشف';

  @override
  String get statementEndingBalance => 'الرصيد الختامي للكشف';

  @override
  String get importStatementCsv => 'استيراد كشف الحساب (CSV)';

  @override
  String get bankAccount => 'حساب بنكي';

  @override
  String get balanceAed => 'الرصيد (درهم)';

  @override
  String get qtyInOut => 'الكمية وارد/صادر';

  @override
  String get totalCostAed => 'التكلفة الإجمالية (درهم)';

  @override
  String get balance => 'الرصيد';

  @override
  String get reorderLevel => 'مستوى إعادة الطلب';

  @override
  String get weightedAvgCost => 'متوسط التكلفة المرجح';

  @override
  String get type => 'النوع';

  @override
  String get stockStatus => 'حالة المخزون';
}
