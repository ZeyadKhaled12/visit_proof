// =============================================================================
// ARABIC TRANSLATIONS
// =============================================================================
//
// Key   = the English text exactly as written in the app.
// Value = the Arabic text shown when the app is in Arabic.
//
// {0}, {1}, {2}… are values inserted by the app (numbers, names, dates).
// Keep them in the Arabic text, in whatever order reads naturally. A
// placeholder that only carries an English plural ending (e.g. the {1} in
// '{0} visit{1}') can simply be left out of the Arabic text.
//
// A text missing from this list is shown in English.
// =============================================================================

const Map<String, String> arabicTranslations = {
  // --- General ----------------------------------------------------------------
  '+ Add': '+ إضافة',
  '+ Create New Category': '+ إنشاء فئة جديدة',
  '+ {0} more': '+ {0} أخرى',
  '00:00 AM/PM': '00:00 ص/م',
  '30 days': '30 يومًا',
  '7 days': '7 أيام',
  'A draft invoice cannot have payment entries.':
      'لا يمكن أن تحتوي مسودة الفاتورة على مدفوعات.',
  'A draft invoice keeps a copy of the site, so it is updated too. Issued invoices are not changed.':
      'تحتفظ مسودة الفاتورة بنسخة من الموقع لذا تُحدّث أيضًا. لا تتغير الفواتير الصادرة.',
  'A new visit can only be Draft, Scheduled, or Assigned.':
      'يمكن أن تكون الزيارة الجديدة مسودة أو مجدولة أو مُسندة فقط.',
  'A new visit cannot already have an invoice.': 'لا يمكن أن تكون للزيارة الجديدة فاتورة مسبقًا.',
  'A note must be {0}–{1} characters.': 'يجب أن تكون الملاحظة بين {0} و{1} حرفًا.',
  'A valid financial amount is required.': 'يلزم إدخال مبلغ مالي صحيح.',
  'A valid, non-negative amount is required.': 'يلزم إدخال مبلغ صحيح غير سالب.',
  'A visit with an assigned technician must use Assigned status.':
      'الزيارة التي لها فني يجب أن تكون بحالة مُسندة.',
  'A {0} visit cannot move to {1}.': 'لا يمكن نقل زيارة {0} إلى {1}.',
  'Activity': 'النشاط',
  'Add': 'إضافة',
  'Add New Client': 'إضافة عميل جديد',
  'Add New Equipment': 'إضافة معدة جديدة',
  'Add New Service': 'إضافة خدمة جديدة',
  'Add New Site': 'إضافة موقع جديد',
  'Add New Technician': 'إضافة فني جديد',
  'Add New Visit': 'إضافة زيارة جديدة',
  'Add Technician': 'إضافة فني',
  'Add Visit': 'إضافة زيارة',
  'Add a note': 'إضافة ملاحظة',
  'Add an address or pick the site on the map.':
      'أضف عنوانًا أو حدد الموقع على الخريطة.',
  'Add first client': 'أضف أول عميل',
  'Add first service': 'أضف أول خدمة',
  'Add first technician': 'أضف أول فني',
  'Add first visit': 'أضف أول زيارة',
  'Add new Site': 'إضافة موقع جديد',
  'Add new client': 'إضافة عميل جديد',
  'Add new service': 'إضافة خدمة جديدة',
  'Add new site': 'إضافة موقع جديد',
  'Add new technician': 'إضافة فني جديد',
  'Add note': 'إضافة ملاحظة',
  'Add task (e.g., Wash hair)': 'أضف مهمة (مثال: تنظيف الفلتر)',
  'Add technician': 'إضافة فني',
  'Add technicians so you can assign them to visits.':
      'أضف الفنيين لتتمكن من إسنادهم إلى الزيارات.',
  'Add technicians to start dispatching visits.':
      'أضف الفنيين لبدء توزيع الزيارات.',
  'Add the services you offer with their price and checklist.':
      'أضف الخدمات التي تقدمها مع أسعارها وقوائم مهامها.',
  'Add your first client to start booking visits.':
      'أضف أول عميل لتبدأ في حجز الزيارات.',
  'Address Configuration': 'إعداد العنوان',
  'Admin': 'المسؤول',
  'Admin added a note': 'أضاف المسؤول ملاحظة',
  'Admin created this visit at {0}': 'أنشأ المسؤول هذه الزيارة في {0}',
  'Admin created this visit with status {0} at {1}':
      'أنشأ المسؤول هذه الزيارة بحالة {0} في {1}',
  'After photos required': 'صور ما بعد العمل مطلوبة',
  'All': 'الكل',
  'All completed work is invoiced': 'تمت فوترة كل الأعمال المكتملة',
  'All dispatch rules are met.': 'جميع قواعد التوزيع مستوفاة.',
  'All in this period': 'كل ما في هذه الفترة',
  'All on track': 'كل شيء على المسار الصحيح',
  'All visits have a technician 🎉': 'كل الزيارات لها فني 🎉',
  'Always enforced: no double booking, no visits on a day off, and visits must be complete before they are planned.':
      'مطبّق دائمًا: لا حجز مزدوج، ولا زيارات في يوم الإجازة، ويجب اكتمال الزيارة قبل جدولتها.',
  'Amount': 'المبلغ',
  'Amount breakdown': 'تفاصيل المبلغ',
  'Amount cannot be negative': 'لا يمكن أن يكون المبلغ سالبًا',
  'Amount is outside the supported range.': 'المبلغ خارج النطاق المسموح.',
  'Amount must be above zero': 'يجب أن يكون المبلغ أكبر من صفر',
  'Amount must be greater than zero.': 'يجب أن يكون المبلغ أكبر من صفر.',
  'Amount paid': 'المبلغ المدفوع',
  'Amounts must have at most 2 decimal places.':
      'يجب ألا تزيد المبالغ عن منزلتين عشريتين.',
  'An invoice is created automatically with every new visit.':
      'تُنشأ فاتورة تلقائيًا مع كل زيارة جديدة.',
  'Any special requests or details...': 'أي طلبات أو تفاصيل خاصة...',
  'Applied to every assignment on the board':
      'تُطبّق على كل إسناد في لوحة التوزيع',
  'Apply': 'تطبيق',
  'Are you sure you want delete this equipment?':
      'هل أنت متأكد من حذف هذه المعدة؟',
  'Are you sure you want to remove this service? This action cannot be undone.':
      'هل أنت متأكد من حذف هذه الخدمة؟ لا يمكن التراجع عن هذا الإجراء.',
  'Are you sure you want to remove {0}? This action cannot be undone.':
      'هل أنت متأكد من حذف {0}؟ لا يمكن التراجع عن هذا الإجراء.',
  'Assign': 'إسناد',
  'Assign a technician first.': 'أسند فنيًا أولًا.',
  'Assign a technician to dispatch this visit.':
      'أسند فنيًا لإرسال هذه الزيارة.',
  'Assign anyway': 'إسناد على أي حال',
  'Assign in Dispatch': 'الإسناد من التوزيع',
  'Assign technician': 'إسناد فني',
  'Assign visit': 'إسناد الزيارة',
  'Assign {0} of {1}': 'إسناد {0} من {1}',
  'Assign {0} visits': 'إسناد {0} زيارات',
  'Assign {0} visit{1}': 'إسناد {0} زيارة',
  'Assigned': 'مُسندة',
  'Available': 'متاح',
  'Back': 'رجوع',
  'Back to assigned': 'العودة إلى مُسندة',
  'Back to draft': 'العودة إلى مسودة',
  'Back to work': 'العودة للعمل',
  'Bank Transfer': 'تحويل بنكي',
  'Before photos required': 'صور ما قبل العمل مطلوبة',
  'Best for each': 'الأنسب لكل زيارة',
  'Best match': 'الأنسب',
  'Best match first: specialty, free time, distance and status':
      'الأنسب أولًا: التخصص، الوقت المتاح، المسافة والحالة',
  'Brand': 'العلامة التجارية',
  'Brand:': 'العلامة التجارية:',
  'Building, Street, Area...': 'المبنى، الشارع، الحي...',
  'Bulk dispatch: {0}': 'توزيع جماعي: {0}',
  'Busy': 'مشغول',
  'By service category': 'حسب فئة الخدمة',
  'By status': 'حسب الحالة',
  'By technician': 'حسب الفني',
  'Call': 'اتصال',
  'Cancel': 'إلغاء',
  'Cancel visit': 'إلغاء الزيارة',
  'Cancelled': 'ملغاة',
  'Cannot change the visit of an existing invoice.':
      'لا يمكن تغيير زيارة فاتورة موجودة.',
  'Cannot issue an invoice for a cancelled visit.':
      'لا يمكن إصدار فاتورة لزيارة ملغاة.',
  'Card': 'بطاقة',
  'Cash': 'نقدًا',
  'Categories': 'الفئات',
  'Category *': 'الفئة *',
  'Category is required': 'الفئة مطلوبة',
  'Category match': 'تطابق الفئة',
  'Category name is required': 'اسم الفئة مطلوب',
  'Category name must be at least 2 characters long':
      'يجب ألا يقل اسم الفئة عن حرفين',
  'Change': 'تغيير',
  'Change service': 'تغيير الخدمة',
  'Change site': 'تغيير الموقع',
  'Changes are saved locally on this device.':
      'تُحفظ التغييرات محليًا على هذا الجهاز.',
  'Checklist · {0} tasks': 'قائمة المهام · {0} مهام',
  'City is required': 'المدينة مطلوبة',
  'Clear filter': 'مسح التصفية',
  'Clear search': 'مسح البحث',
  'Clear search & filters': 'مسح البحث والتصفية',
  'Client': 'العميل',
  'Client & Site': 'العميل والموقع',
  'Client Details': 'تفاصيل العميل',
  'Client added successfuly': 'تمت إضافة العميل بنجاح',
  'Client removed successfuly': 'تم حذف العميل بنجاح',
  'Client updated successfuly': 'تم تحديث العميل بنجاح',
  'Clients': 'العملاء',
  'Collected': 'المحصّل',
  'Collected = payments minus refunds, by payment date. Outstanding is what customers owe today on issued invoices.':
      'المحصّل = المدفوعات ناقص المبالغ المستردة حسب تاريخ الدفع. المستحق هو ما يدين به العملاء اليوم على الفواتير الصادرة.',
  'Compare': 'مقارنة',
  'Complete client, currency and invoice amounts.':
      'أكمل بيانات العميل والعملة ومبالغ الفاتورة.',
  'Complete the visit first, or provide an approved early-issue override with a reason.':
      'أكمل الزيارة أولًا، أو قدّم موافقة على الإصدار المبكر مع ذكر السبب.',
  'Complete the visit info, then schedule it.':
      'أكمل بيانات الزيارة ثم قم بجدولتها.',
  'Complete these first: {0}.': 'أكمل هذه أولًا: {0}.',
  'Complete visit': 'إكمال الزيارة',
  'Completed': 'مكتملة',
  'Completed or cancelled visits cannot be edited.':
      'لا يمكن تعديل الزيارات المكتملة أو الملغاة.',
  'Completed visits': 'الزيارات المكتملة',
  'Completed visits in this period': 'الزيارات المكتملة في هذه الفترة',
  'Completed visits with an unissued invoice': 'زيارات مكتملة بفاتورة غير صادرة',
  'Completed vs not completed': 'المكتملة مقابل غير المكتملة',
  'Completed, invoice not issued': 'مكتملة، الفاتورة لم تصدر',
  'Completion': 'نسبة الإنجاز',
  'Completion = completed ÷ visits whose start time has passed. Cancelled visits are not counted.':
      'نسبة الإنجاز = المكتملة ÷ الزيارات التي حان وقتها. لا تُحتسب الزيارات الملغاة.',
  'Confirm': 'تأكيد',
  'Confirm Location': 'تأكيد الموقع',
  'Confirm refund': 'تأكيد الاسترداد',
  'Conflicts': 'التعارضات',
  'Conflicts on this day': 'التعارضات في هذا اليوم',
  'Contact Info': 'بيانات التواصل',
  'Continue': 'متابعة',
  'Could not fetch GPS. Search or move the map.':
      'تعذّر تحديد الموقع. ابحث أو حرّك الخريطة.',
  'Could not launch WhatsApp for {0}': 'تعذّر فتح واتساب للرقم {0}',
  'Could not launch {0}': 'تعذّر فتح {0}',
  'Could not open Google Maps': 'تعذّر فتح خرائط جوجل',
  'Could not save invoices.': 'تعذّر حفظ الفواتير.',
  'Could not save payments.': 'تعذّر حفظ المدفوعات.',
  'Could not save the changes locally.': 'تعذّر حفظ التغييرات محليًا.',
  'Could not save visits.': 'تعذّر حفظ الزيارات.',
  'Create New Service': 'إنشاء خدمة جديدة',
  'Create Technician': 'إنشاء فني',
  'Create first visit': 'أنشئ أول زيارة',
  'Create visits and assign technicians to see your operations, completion and revenue here.':
      'أنشئ الزيارات وأسند الفنيين لترى عملياتك ونسبة الإنجاز والإيرادات هنا.',
  'Create your first visit to start tracking field work.':
      'أنشئ أول زيارة لتبدأ متابعة العمل الميداني.',
  'Created {0}': 'أُنشئت {0}',
  'Current: {0}': 'الحالي: {0}',
  'Currently {0}': 'حاليًا {0}',
  'Currently {0} with {1}': 'حاليًا {0} مع {1}',
  'Customer': 'العميل',
  'Customer & visit': 'العميل والزيارة',
  'Customer not selected': 'لم يتم اختيار العميل',
  'Custom…': 'مخصص…',
  'DEMO OPENING BALANCE: imported snapshot, not a verified payment transaction.':
      'رصيد افتتاحي تجريبي: بيانات مستوردة وليست عملية دفع موثقة.',
  'Daily visits must be between 1 and 30.':
      'يجب أن يكون عدد الزيارات اليومية بين 1 و30.',
  'Dark mode': 'الوضع الداكن',
  'Date': 'التاريخ',
  'Date · tap to change': 'التاريخ · اضغط للتغيير',
  'Day ends': 'نهاية الدوام',
  'Day off': 'يوم إجازة',
  'Day starts': 'بداية الدوام',
  'Delete': 'حذف',
  'Delete visit': 'حذف الزيارة',
  'Delete visit?': 'حذف الزيارة؟',
  'Detailed Address': 'العنوان التفصيلي',
  'Detailed address must be at least 10 characters long':
      'يجب ألا يقل العنوان التفصيلي عن 10 أحرف',
  'Details': 'التفاصيل',
  'Directions': 'الاتجاهات',
  'Discount': 'الخصم',
  'Discount cannot exceed the subtotal.': 'لا يمكن أن يتجاوز الخصم المجموع الفرعي.',
  'Dispatch': 'التوزيع',
  'Dispatch rules': 'قواعد التوزيع',
  'Dispatch rules saved': 'تم حفظ قواعد التوزيع',
  'Done': 'تم',
  'Draft': 'مسودة',
  'Draft invoice updated': 'تم تحديث مسودة الفاتورة',
  'Draft invoice updated successfully': 'تم تحديث مسودة الفاتورة بنجاح',
  'Drop to assign at {0}': 'أفلت للإسناد في {0}',
  'Drop to assign at {0} · {1}': 'أفلت للإسناد في {0} · {1}',
  'Due by {0}': 'مستحقة بحلول {0}',
  'Due date': 'تاريخ الاستحقاق',
  'Due date cannot precede issue date.':
      'لا يمكن أن يسبق تاريخ الاستحقاق تاريخ الإصدار.',
  'Due date must not be before issue date.':
      'يجب ألا يكون تاريخ الاستحقاق قبل تاريخ الإصدار.',
  'Due {0}': 'مستحقة {0}',
  'Duplicate visit or invoice relationship.': 'ارتباط مكرر بين زيارة وفاتورة.',
  'Duration': 'المدة',
  'Duration *': 'المدة *',
  'Duration must be grater than 0 minutes': 'يجب أن تكون المدة أكبر من 0 دقيقة',
  'Edit': 'تعديل',
  'Edit Client': 'تعديل العميل',
  'Edit Technician': 'تعديل الفني',
  'Edit draft': 'تعديل المسودة',
  'Edit draft invoice': 'تعديل مسودة الفاتورة',
  'Edit job notes': 'تعديل ملاحظات العمل',
  'Email Address (Optional)': 'البريد الإلكتروني (اختياري)',
  'Email Address *': 'البريد الإلكتروني *',
  'Emergency': 'طارئة',
  'Enter a valid amount (up to 2 decimals)':
      'أدخل مبلغًا صحيحًا (حتى منزلتين عشريتين)',
  'Enter at least 8 characters': 'أدخل 8 أحرف على الأقل',
  'Enter at least {0} characters': 'أدخل {0} أحرف على الأقل',
  'Equipment Name': 'اسم المعدة',
  'Equipment added successfuly': 'تمت إضافة المعدة بنجاح',
  'Equipment name is required': 'اسم المعدة مطلوب',
  'Equipment removed successfuly': 'تم حذف المعدة بنجاح',
  'Equipments': 'المعدات',
  'Error launching WhatsApp: {0}': 'خطأ في فتح واتساب: {0}',
  'Every scheduled visit has a technician': 'كل زيارة مجدولة لها فني',
  'Every visit has a technician': 'كل زيارة لها فني',
  'Everything due is completed': 'تم إنجاز كل ما حان وقته',
  'Everything is on track': 'كل شيء على المسار الصحيح',
  'Expected to finish around {0}': 'متوقع الانتهاء حوالي {0}',
  'Explain other payment method': 'وضّح طريقة الدفع الأخرى',
  'Explain the selected payment method.': 'وضّح طريقة الدفع المختارة.',
  'Extra Info': 'معلومات إضافية',
  'Failed to save invoice locally.': 'فشل حفظ الفاتورة محليًا.',
  'Failed to save visit locally.': 'فشل حفظ الزيارة محليًا.',
  'Fetching address...': 'جارٍ جلب العنوان...',
  'Fill in the details below to add a service': 'أدخل التفاصيل أدناه لإضافة خدمة',
  'Filter invoices': 'تصفية الفواتير',
  'Filter visits': 'تصفية الزيارات',
  'Filtered selection': 'نتائج مصفّاة',
  'Filtered: {0}': 'مصفّاة: {0}',
  'Free all day': 'متاح طوال اليوم',
  'Free at {0}': 'متاح في {0}',
  'From {0}': 'من {0}',
  'Full Name *': 'الاسم الكامل *',
  'Full details': 'كل التفاصيل',
  'Go to': 'انتقل إلى',
  'Good afternoon': 'مساء الخير',
  'Good evening': 'مساء الخير',
  'Good morning': 'صباح الخير',
  'High': 'عالية',
  'In Progress': 'قيد التنفيذ',
  'Invalid phone number': 'رقم هاتف غير صحيح',
  'Invoice': 'الفاتورة',
  'Invoice ID is required.': 'رقم الفاتورة مطلوب.',
  'Invoice and visit IDs are required.': 'رقما الفاتورة والزيارة مطلوبان.',
  'Invoice breakdown does not match the total.':
      'تفاصيل الفاتورة لا تطابق الإجمالي.',
  'Invoice client must be complete.': 'يجب اكتمال بيانات عميل الفاتورة.',
  'Invoice currency is required.': 'عملة الفاتورة مطلوبة.',
  'Invoice data or local storage is unavailable. Financial actions are locked.':
      'بيانات الفاتورة أو التخزين المحلي غير متاحة. الإجراءات المالية مقفلة.',
  'Invoice details': 'تفاصيل الفاتورة',
  'Invoice has no refundable payment status.':
      'حالة دفع الفاتورة لا تسمح بالاسترداد.',
  'Invoice identity cannot be changed.': 'لا يمكن تغيير هوية الفاتورة.',
  'Invoice issued': 'صدرت الفاتورة',
  'Invoice issued successfully': 'تم إصدار الفاتورة بنجاح',
  'Invoice not found or duplicated: {0}': 'الفاتورة غير موجودة أو مكررة: {0}',
  'Invoice notes': 'ملاحظات الفاتورة',
  'Invoice payment recorded: {0}': 'تم تسجيل دفعة للفاتورة: {0}',
  'Invoice payment refunded: {0}': 'تم استرداد دفعة من الفاتورة: {0}',
  'Invoice payment status is missing.': 'حالة دفع الفاتورة غير موجودة.',
  'Invoice pricing is incomplete.': 'تسعير الفاتورة غير مكتمل.',
  'Invoice total': 'إجمالي الفاتورة',
  'Invoice total cannot be negative.': 'لا يمكن أن يكون إجمالي الفاتورة سالبًا.',
  'Invoice total must exceed zero.': 'يجب أن يكون إجمالي الفاتورة أكبر من صفر.',
  'Invoice totals are inconsistent.': 'إجماليات الفاتورة غير متسقة.',
  'Invoiced': 'المفوتر',
  'Invoices': 'الفواتير',
  'Issue invoice': 'إصدار الفاتورة',
  'Issue invoice?': 'إصدار الفاتورة؟',
  'Issue, edit, payments and refunds are managed there.':
      'تُدار هناك عمليات الإصدار والتعديل والمدفوعات والاسترداد.',
  'Issued': 'صادرة',
  'Issued {0}': 'صدرت {0}',
  'Items to handle now': 'مهام تحتاج معالجة الآن',
  'Job Notes': 'ملاحظات العمل',
  'Keep it under {0} characters': 'يجب ألا يتجاوز {0} حرفًا',
  'Last 30 days': 'آخر 30 يومًا',
  'Last 7 days': 'آخر 7 أيام',
  'Language': 'اللغة',
  'Late': 'متأخرة',
  'Late visits': 'الزيارات المتأخرة',
  'Less than {0} min of travel time around {1}.':
      'وقت التنقل أقل من {0} دقيقة حول {1}.',
  'Local Admin': 'المسؤول المحلي',
  'Locating...': 'جارٍ تحديد الموقع...',
  'Location': 'الموقع',
  'Location Details': 'تفاصيل الموقع',
  'Location permission not granted. Search or move the map.':
      'لم يتم منح إذن الموقع. ابحث أو حرّك الخريطة.',
  'Location services are disabled. Select on map or search.':
      'خدمات الموقع معطلة. حدد على الخريطة أو ابحث.',
  'Log out': 'تسجيل الخروج',
  'Log out?': 'تسجيل الخروج؟',
  'Long-press a card and drop it on a technician':
      'اضغط مطولًا على البطاقة ثم أفلتها على فني',
  'Low': 'منخفضة',
  'Map': 'الخريطة',
  'Mark day off': 'تحديد يوم إجازة',
  'Maximum allowed: {0}': 'الحد الأقصى المسموح: {0}',
  'Min': 'دقيقة',
  'Mobile Wallet': 'محفظة إلكترونية',
  'Model': 'الطراز',
  'Model:': 'الطراز:',
  'Money collected': 'المبالغ المحصلة',
  'Money still owed after the due date': 'مبالغ ما زالت مستحقة بعد تاريخ الاستحقاق',
  'Move anyway': 'نقل على أي حال',
  'Move {0} of {1}': 'نقل {0} من {1}',
  'Name must be at least 2 characters long': 'يجب ألا يقل الاسم عن حرفين',
  'Navigation failed: {0}': 'فشل فتح الاتجاهات: {0}',
  'Needs attention': 'يحتاج انتباهك',
  'New Category Name *': 'اسم الفئة الجديدة *',
  'New total cannot be negative or below paid amount.':
      'لا يمكن أن يكون الإجمالي الجديد سالبًا أو أقل من المبلغ المدفوع.',
  'New visit': 'زيارة جديدة',
  'New visits without a technician will wait here.':
      'ستنتظر هنا الزيارات الجديدة التي ليس لها فني.',
  'Next Step': 'الخطوة التالية',
  'No Address': 'لا يوجد عنوان',
  'No Category': 'بدون فئة',
  'No Email': 'لا يوجد بريد إلكتروني',
  'No Phone': 'لا يوجد هاتف',
  'No activity yet': 'لا يوجد نشاط بعد',
  'No assigned visits in this period': 'لا توجد زيارات مسندة في هذه الفترة',
  'No change': 'بدون تغيير',
  'No checklist tasks': 'لا توجد مهام',
  'No client': 'بدون عميل',
  'No client selected': 'لم يتم اختيار عميل',
  'No clients yet': 'لا يوجد عملاء بعد',
  'No completed visits here': 'لا توجد زيارات مكتملة هنا',
  'No date': 'بدون تاريخ',
  'No earlier data': 'لا توجد بيانات سابقة',
  'No equipments assigned to this client yet.':
      'لا توجد معدات مرتبطة بهذا العميل بعد.',
  'No financial actions available for this invoice.':
      'لا توجد إجراءات مالية متاحة لهذه الفاتورة.',
  'No free time left on this day.': 'لا يوجد وقت متاح في هذا اليوم.',
  'No invoice is linked to this visit': 'لا توجد فاتورة مرتبطة بهذه الزيارة',
  'No invoices to show': 'لا توجد فواتير لعرضها',
  'No invoices yet': 'لا توجد فواتير بعد',
  'No late visits, unassigned work or overdue invoices right now.':
      'لا توجد زيارات متأخرة أو أعمال غير مسندة أو فواتير متأخرة حاليًا.',
  'No matching clients': 'لا يوجد عملاء مطابقون',
  'No matching invoices': 'لا توجد فواتير مطابقة',
  'No matching services': 'لا توجد خدمات مطابقة',
  'No matching technicians': 'لا يوجد فنيون مطابقون',
  'No matching visits': 'لا توجد زيارات مطابقة',
  'No other technicians to suggest': 'لا يوجد فنيون آخرون لاقتراحهم',
  'No overdue invoices': 'لا توجد فواتير متأخرة',
  'No payments in this period': 'لا توجد مدفوعات في هذه الفترة',
  'No photo proof required': 'لا يلزم إثبات بالصور',
  'No places found': 'لم يتم العثور على أماكن',
  'No results found': 'لا توجد نتائج',
  'No service': 'بدون خدمة',
  'No service selected': 'لم يتم اختيار خدمة',
  'No services yet': 'لا توجد خدمات بعد',
  'No site': 'بدون موقع',
  'No site selected': 'لم يتم اختيار موقع',
  'No technician': 'بدون فني',
  'No technician assigned yet': 'لم يتم إسناد فني بعد',
  'No technician is available.': 'لا يوجد فني متاح.',
  'No technician was assigned to this visit.': 'لم يُسند فني لهذه الزيارة.',
  'No technicians yet': 'لا يوجد فنيون بعد',
  'No time': 'بدون وقت',
  'No visit number': 'بدون رقم زيارة',
  'No visits in this period': 'لا توجد زيارات في هذه الفترة',
  'No visits match this selection': 'لا توجد زيارات مطابقة لهذا الاختيار',
  'No visits on the map': 'لا توجد زيارات على الخريطة',
  'No visits on this day': 'لا توجد زيارات في هذا اليوم',
  'No visits on this day can be moved': 'لا يمكن نقل أي زيارة في هذا اليوم',
  'No visits planned for today': 'لا توجد زيارات مخططة لليوم',
  'No visits recorded yet': 'لا توجد زيارات مسجلة بعد',
  'No visits to show': 'لا توجد زيارات لعرضها',
  'No visits yet': 'لا توجد زيارات بعد',
  'Nobody is available': 'لا يوجد أحد متاح',
  'None': 'بدون',
  'Normal': 'عادية',
  'Not available on this day': 'غير متاح في هذا اليوم',
  'Not completed': 'غير مكتملة',
  'Not completed yet': 'لم تكتمل بعد',
  'Not done yet': 'لم تُنجز بعد',
  'Not ready to assign': 'غير جاهزة للإسناد',
  'Not set': 'غير محدد',
  'Note': 'ملاحظة',
  'Note added': 'تمت إضافة الملاحظة',
  'Notes': 'ملاحظات',
  'Notes (Optional)': 'ملاحظات (اختياري)',
  'Notes are added to the visit activity log.': 'تُضاف الملاحظات إلى سجل نشاط الزيارة.',
  'Notes cannot exceed 1000 characters.': 'يجب ألا تتجاوز الملاحظات 1000 حرف.',
  'Notes cannot exceed {0} characters.': 'يجب ألا تتجاوز الملاحظات {0} حرفًا.',
  'Notes for the technician': 'ملاحظات للفني',
  'Nothing added yet': 'لم يُضف شيء بعد',
  'Nothing can be assigned': 'لا يمكن إسناد أي زيارة',
  'Nothing due yet': 'لا شيء حان وقته بعد',
  'Nothing here right now': 'لا شيء هنا حاليًا',
  'Nothing is late': 'لا توجد زيارات متأخرة',
  'Number includes WhatsApp': 'الرقم مرتبط بواتساب',
  'Off: a mismatch is only a warning': 'عند الإيقاف: عدم التطابق مجرد تنبيه',
  'Offline': 'غير متصل',
  'On The Way': 'في الطريق',
  'On way': 'في الطريق',
  'Only an assigned visit can release its technician. Move the visit back to Assigned first.':
      'لا يمكن إلغاء إسناد الفني إلا لزيارة مسندة. أعد الزيارة إلى مُسندة أولًا.',
  'Only an issued, collectible invoice can be paid.':
      'لا يمكن الدفع إلا لفاتورة صادرة وقابلة للتحصيل.',
  'Only an unpaid draft can be edited.': 'لا يمكن تعديل إلا مسودة غير مدفوعة.',
  'Only an unpaid draft invoice can be issued.':
      'لا يمكن إصدار إلا مسودة فاتورة غير مدفوعة.',
  'Only draft or cancelled visits with no issued invoice and no payment history can be deleted.':
      'لا يمكن حذف إلا الزيارات المسودة أو الملغاة التي ليس لها فاتورة صادرة ولا سجل مدفوعات.',
  'Only draft, scheduled or assigned visits can be rescheduled.':
      'لا يمكن إعادة جدولة إلا الزيارات المسودة أو المجدولة أو المسندة.',
  'Only one invoice is allowed per visit.': 'يُسمح بفاتورة واحدة فقط لكل زيارة.',
  'Oops a problem occurred, please try again later!':
      'عذرًا، حدثت مشكلة، يرجى المحاولة لاحقًا!',
  'Open Dispatch': 'فتح التوزيع',
  'Open Jobs': 'المهام المفتوحة',
  'Open invoice': 'فتح الفاتورة',
  'Operations overview': 'نظرة عامة على العمليات',
  'Optional for cash': 'اختياري للدفع النقدي',
  'Other': 'أخرى',
  'Outside working hours.': 'خارج ساعات العمل.',
  'Outstanding': 'المستحق',
  'Overdue': 'متأخرة',
  'Overdue invoices': 'الفواتير المتأخرة',
  'Overdue since {0}': 'متأخرة منذ {0}',
  'Overdue · {0}': 'متأخرة · {0}',
  'Overview': 'نظرة عامة',
  'Owed after due date': 'مستحقة بعد تاريخ الاستحقاق',
  'Owed after the due date': 'مستحقة بعد تاريخ الاستحقاق',
  'Paid': 'مدفوعة',
  'Paid {0}': 'المدفوع {0}',
  'Partially Paid': 'مدفوعة جزئيًا',
  'Password *': 'كلمة المرور *',
  'Payment': 'الدفع',
  'Payment entry is missing its identifier.': 'قيد الدفع بدون معرّف.',
  'Payment exceeds the remaining balance.': 'الدفعة تتجاوز الرصيد المتبقي.',
  'Payment history and paid balance are inconsistent.':
      'سجل المدفوعات والرصيد المدفوع غير متسقين.',
  'Payment history does not support this refund. Only locally recorded, unrefunded payments can be refunded.':
      'سجل المدفوعات لا يسمح بهذا الاسترداد. يمكن فقط استرداد المدفوعات المسجلة محليًا وغير المستردة.',
  'Payment method': 'طريقة الدفع',
  'Payment recorded successfully': 'تم تسجيل الدفعة بنجاح',
  'Payment status does not match the paid amount.':
      'حالة الدفع لا تطابق المبلغ المدفوع.',
  'Payments': 'المدفوعات',
  'Pending': 'قيد الانتظار',
  'Per day': 'في اليوم',
  'Personal Info': 'البيانات الشخصية',
  'Phone Number *': 'رقم الهاتف *',
  'Photo requirements are locked once the technician is on the way.':
      'تُقفل متطلبات الصور بمجرد أن يكون الفني في الطريق.',
  'Pick a date and a time': 'اختر التاريخ والوقت',
  'Pick a time different from the current one.': 'اختر وقتًا مختلفًا عن الوقت الحالي.',
  'Pick from map': 'اختر من الخريطة',
  'Pick one or more options in each group': 'اختر خيارًا أو أكثر في كل مجموعة',
  'Plan for': 'خطة يوم',
  'Plan for {0}. Each visit goes to the best available colleague at the closest time.':
      'خطة يوم {0}. كل زيارة تذهب إلى أنسب زميل متاح في أقرب وقت.',
  'Please assign a technician before creating an Assigned visit.':
      'يرجى إسناد فني قبل إنشاء زيارة مسندة.',
  'Please enter a valid email address': 'يرجى إدخال بريد إلكتروني صحيح',
  'Please enter at least one category': 'يرجى إدخال فئة واحدة على الأقل',
  'Please fill in all fields marked with an asterisk (*).':
      'يرجى تعبئة جميع الحقول المميزة بنجمة (*).',
  'Please give a reason of at least {0} characters.':
      'يرجى ذكر سبب لا يقل عن {0} أحرف.',
  'Please provide an address detail or pick a location from the map.':
      'يرجى إدخال تفاصيل العنوان أو تحديد الموقع على الخريطة.',
  'Please select a city for the site.': 'يرجى اختيار مدينة للموقع.',
  'Please select a client before scheduling or assigning the visit.':
      'يرجى اختيار عميل قبل جدولة الزيارة أو إسنادها.',
  'Please select a service.': 'يرجى اختيار خدمة.',
  'Please select a valid service.': 'يرجى اختيار خدمة صحيحة.',
  'Price': 'السعر',
  'Price *': 'السعر *',
  'Price must be grater than 0': 'يجب أن يكون السعر أكبر من 0',
  'Priority': 'الأولوية',
  'Problem': 'المشكلة',
  'Problem description cannot exceed {0} characters.':
      'يجب ألا يتجاوز وصف المشكلة {0} حرفًا.',
  'Profile': 'الملف الشخصي',
  'Queue ({0})': 'قائمة الانتظار ({0})',
  'Ready to invoice': 'جاهزة للفوترة',
  'Reason': 'السبب',
  'Reason (optional)': 'السبب (اختياري)',
  'Reason to continue anyway': 'سبب المتابعة رغم ذلك',
  'Reassign': 'إعادة إسناد',
  'Reassign technician': 'إعادة إسناد الفني',
  'Recenter map': 'إعادة توسيط الخريطة',
  'Record a payment': 'تسجيل دفعة',
  'Record payment': 'تسجيل دفعة',
  'Redistribute': 'إعادة التوزيع',
  'Redistribute visits': 'إعادة توزيع الزيارات',
  'Redistributed from {0}{1}': 'أعيد توزيعها من {0}{1}',
  'Reference is required': 'المرجع مطلوب',
  'Reference or notes are too long.': 'المرجع أو الملاحظات طويلة جدًا.',
  'Refresh': 'تحديث',
  'Refund all payments from the invoice before cancelling.':
      'استرد جميع مدفوعات الفاتورة قبل الإلغاء.',
  'Refund amount': 'مبلغ الاسترداد',
  'Refund completed': 'تم الاسترداد',
  'Refund exceeds net paid amount.': 'مبلغ الاسترداد يتجاوز صافي المدفوع.',
  'Refund payment': 'استرداد دفعة',
  'Refund reason must be 8–1000 characters.': 'يجب أن يكون سبب الاسترداد بين 8 و1000 حرف.',
  'Refund recorded successfully': 'تم تسجيل الاسترداد بنجاح',
  'Refunded': 'مستردة',
  'Refunds require a verified payment ledger.': 'يتطلب الاسترداد سجل مدفوعات موثقًا.',
  'Remaining': 'المتبقي',
  'Remaining balance': 'الرصيد المتبقي',
  'Remaining balance: {0}': 'الرصيد المتبقي: {0}',
  'Remove': 'حذف',
  'Remove Client?': 'حذف العميل؟',
  'Remove Service?': 'حذف الخدمة؟',
  'Remove Technician?': 'حذف الفني؟',
  'Remove the technician or create the visit as Assigned.':
      'أزل الفني أو أنشئ الزيارة كمُسندة.',
  'Reopen as draft': 'إعادة فتح كمسودة',
  'Require After-Work Photos': 'طلب صور ما بعد العمل',
  'Require Before-Work Photos': 'طلب صور ما قبل العمل',
  'Require after-work photos': 'طلب صور ما بعد العمل',
  'Require before-work photos': 'طلب صور ما قبل العمل',
  'Require matching specialty': 'اشتراط تطابق التخصص',
  'Required': 'مطلوب',
  'Reschedule': 'إعادة جدولة',
  'Reschedule visit': 'إعادة جدولة الزيارة',
  'Reset': 'إعادة ضبط',
  'Revenue': 'الإيرادات',
  'Review': 'مراجعة',
  'Review the plan, then confirm': 'راجع الخطة ثم أكّد',
  'Save': 'حفظ',
  'Save Client': 'حفظ العميل',
  'Save Draft': 'حفظ كمسودة',
  'Save Service': 'حفظ الخدمة',
  'Save changes': 'حفظ التغييرات',
  'Save new time': 'حفظ الوقت الجديد',
  'Save payment': 'حفظ الدفعة',
  'Save rules': 'حفظ القواعد',
  'Save site': 'حفظ الموقع',
  'Schedule': 'جدولة',
  'Schedule & Technician': 'الموعد والفني',
  'Schedule visit': 'جدولة الزيارة',
  'Scheduled': 'مجدولة',
  'Scheduled visits without anyone assigned': 'زيارات مجدولة بدون أي فني',
  'Scheduled, nobody assigned': 'مجدولة، بدون فني',
  'Scheduling & Assignment': 'الجدولة والإسناد',
  'Search HTTP {0}': 'خطأ في البحث HTTP {0}',
  'Search country...': 'ابحث عن دولة...',
  'Search for a place...': 'ابحث عن مكان...',
  'Search for a service': 'ابحث عن خدمة',
  'Search for a technician': 'ابحث عن فني',
  'Search for an technician': 'ابحث عن فني',
  'Search for client': 'ابحث عن عميل',
  'Search invoice, visit number, client...': 'ابحث برقم الفاتورة أو الزيارة أو العميل...',
  'Search name, phone, email, city...': 'ابحث بالاسم أو الهاتف أو البريد أو المدينة...',
  'Search name, phone, specialty...': 'ابحث بالاسم أو الهاتف أو التخصص...',
  'Search service, category, task...': 'ابحث بالخدمة أو الفئة أو المهمة...',
  'Search unavailable. Check your connection.': 'البحث غير متاح. تحقق من الاتصال.',
  'Search visit number, client, service...': 'ابحث برقم الزيارة أو العميل أو الخدمة...',
  'Search waiting visits...': 'ابحث في الزيارات المنتظرة...',
  'Search...': 'بحث...',
  'Select': 'تحديد',
  'Select City *': 'اختر المدينة *',
  'Serial Number': 'الرقم التسلسلي',
  'Service': 'الخدمة',
  'Service Checklist (Optional)': 'قائمة مهام الخدمة (اختياري)',
  'Service Name *': 'اسم الخدمة *',
  'Service added successfuly': 'تمت إضافة الخدمة بنجاح',
  'Service changed and invoice repriced': 'تم تغيير الخدمة وإعادة تسعير الفاتورة',
  'Service changed from {0} to {1}': 'تم تغيير الخدمة من {0} إلى {1}',
  'Service name is required': 'اسم الخدمة مطلوب',
  'Service name must be at least 2 characters long': 'يجب ألا يقل اسم الخدمة عن حرفين',
  'Service removed successfuly': 'تم حذف الخدمة بنجاح',
  'Service updated successfuly': 'تم تحديث الخدمة بنجاح',
  'Services': 'الخدمات',
  'Set a start date before assigning a technician.': 'حدد تاريخ البدء قبل إسناد فني.',
  'Show all ({0})': 'عرض الكل ({0})',
  'Show less': 'عرض أقل',
  'Site': 'الموقع',
  'Site changed to {0}': 'تم تغيير الموقع إلى {0}',
  'Some assignments break a warning rule. They will be saved with a note in the visit history.':
      'بعض الإسنادات تخالف قاعدة تنبيه. ستُحفظ مع ملاحظة في سجل الزيارة.',
  'Specialty match': 'تطابق التخصص',
  'Stage': 'المرحلة',
  'Start Date': 'تاريخ البدء',
  'Start Time': 'وقت البدء',
  'Start date': 'تاريخ البدء',
  'Start passed, not started': 'فات الموعد ولم تبدأ',
  'Start time': 'وقت البدء',
  'Start time must be in the future': 'يجب أن يكون وقت البدء في المستقبل',
  'Start time passed, work not started': 'فات موعد البدء ولم يبدأ العمل',
  'Start trip': 'بدء التنقل',
  'Start work': 'بدء العمل',
  'Starts': 'يبدأ',
  'Status changed from {0} to {1}': 'تغيرت الحالة من {0} إلى {1}',
  'Subtotal': 'المجموع الفرعي',
  'Subtotal {0} · only before issue': 'المجموع الفرعي {0} · قبل الإصدار فقط',
  'Subtotal, discount, tax and total do not match.':
      'المجموع الفرعي والخصم والضريبة والإجمالي غير متطابقة.',
  'Suggest technician': 'اقتراح فني',
  'Suggested technicians': 'الفنيون المقترحون',
  'Tap a bar for details': 'اضغط على عمود لعرض التفاصيل',
  'Tap a bar to list its payments': 'اضغط على عمود لعرض مدفوعاته',
  'Tap a bar to list that {0}': 'اضغط على عمود لعرض زيارات ذلك {0}',
  'Tap a bar to list those visits': 'اضغط على عمود لعرض تلك الزيارات',
  'Tap a status to filter the list': 'اضغط على حالة لتصفية القائمة',
  'Tap a technician for their full results': 'اضغط على فني لعرض نتائجه الكاملة',
  'Tasks': 'المهام',
  'Tax': 'الضريبة',
  'Tax amount': 'مبلغ الضريبة',
  'Technician': 'الفني',
  'Technician Detail': 'تفاصيل الفني',
  'Technician added successfuly': 'تمت إضافة الفني بنجاح',
  'Technician assigned successfully': 'تم إسناد الفني بنجاح',
  'Technician changed from {0} to {1}': 'تم تغيير الفني من {0} إلى {1}',
  'Technician is available again': 'الفني متاح مرة أخرى',
  'Technician marked as off for this day': 'تم تحديد الفني في إجازة لهذا اليوم',
  'Technician removed successfuly': 'تم حذف الفني بنجاح',
  'Technician supplies proof during the visit': 'يقدّم الفني الإثبات أثناء الزيارة',
  'Technician unassigned': 'تم إلغاء إسناد الفني',
  'Technician updated successfuly': 'تم تحديث الفني بنجاح',
  'Technician {0} assigned': 'تم إسناد الفني {0}',
  'Technician {0} unassigned': 'تم إلغاء إسناد الفني {0}',
  'Technicians': 'الفنيون',
  'Technicians busy at this time are rejected automatically.':
      'يُستبعد تلقائيًا الفنيون المشغولون في هذا الوقت.',
  'Technicians can only be assigned before the visit starts.':
      'لا يمكن إسناد الفنيين إلا قبل بدء الزيارة.',
  'The dashboard could not load': 'تعذّر تحميل لوحة المعلومات',
  'The draft invoice is repriced: discount and tax stay the same, the total follows the new price.':
      'يُعاد تسعير مسودة الفاتورة: يبقى الخصم والضريبة كما هما ويتغير الإجمالي حسب السعر الجديد.',
  'The invoice discount is higher than the new price. Lower the discount first.':
      'خصم الفاتورة أعلى من السعر الجديد. خفّض الخصم أولًا.',
  'The linked invoice will be marked as cancelled.': 'سيتم تحديد الفاتورة المرتبطة كملغاة.',
  'The linked visit is missing from local storage. Save the VisitDetailModel in the "visits" preference first.':
      'الزيارة المرتبطة غير موجودة في التخزين المحلي.',
  'The new start time must be in the future.': 'يجب أن يكون وقت البدء الجديد في المستقبل.',
  'The new time must be in the future': 'يجب أن يكون الوقت الجديد في المستقبل',
  'The new visit must not already have an ID.': 'يجب ألا يكون للزيارة الجديدة رقم مسبقًا.',
  'The reason cannot exceed {0} characters.': 'يجب ألا يتجاوز السبب {0} حرفًا.',
  'The selected service has no valid duration.': 'الخدمة المختارة ليس لها مدة صحيحة.',
  'The service can only change before dispatch and before the invoice is issued or paid.':
      'لا يمكن تغيير الخدمة إلا قبل الإرسال وقبل إصدار الفاتورة أو دفعها.',
  'The site can only change before the technician leaves.':
      'لا يمكن تغيير الموقع إلا قبل انطلاق الفني.',
  'The start time has already passed.': 'لقد فات وقت البدء.',
  'The start time has already passed. Reschedule the visit first.':
      'لقد فات وقت البدء. أعد جدولة الزيارة أولًا.',
  'The start time must be in the future.': 'يجب أن يكون وقت البدء في المستقبل.',
  'The technician is heading to the site.': 'الفني في طريقه إلى الموقع.',
  'The technician is released and the invoice becomes collectible again.':
      'يُحرر الفني وتصبح الفاتورة قابلة للتحصيل مرة أخرى.',
  'The visit': 'الزيارة',
  'The visit goes back to Scheduled until another technician is assigned.':
      'تعود الزيارة إلى مجدولة حتى يُسند فني آخر.',
  'The visit status does not allow invoice edits.': 'حالة الزيارة لا تسمح بتعديل الفاتورة.',
  'The working day must end after it starts.': 'يجب أن ينتهي يوم العمل بعد بدايته.',
  'There are no changes to save.': 'لا توجد تغييرات لحفظها.',
  'This client cannot be deleted because they have existing visits':
      'لا يمكن حذف هذا العميل لوجود زيارات له',
  'This client has {0} open visit{1}. Complete or cancel {2} before deleting.':
      'لدى هذا العميل {0} زيارات مفتوحة. أكملها أو ألغها قبل الحذف.',
  'This day': 'هذا اليوم',
  'This draft is complete, so assigning a technician moves it straight to Assigned.':
      'هذه المسودة مكتملة، لذا سينقلها إسناد الفني مباشرة إلى مُسندة.',
  'This field is required to {0}': 'هذا الحقل مطلوب لـ{0}',
  'This month': 'هذا الشهر',
  'This permanently removes the visit and its draft invoice.':
      'سيؤدي هذا إلى حذف الزيارة ومسودة فاتورتها نهائيًا.',
  'This technician': 'هذا الفني',
  'This technician cannot be deleted because they have existing visits':
      'لا يمكن حذف هذا الفني لوجود زيارات له',
  'This technician has {0} active visit{1}. Unassign or finish {2} before deleting.':
      'لدى هذا الفني {0} زيارات نشطة. ألغِ إسنادها أو أنهِها قبل الحذف.',
  'This technician no longer exists': 'هذا الفني لم يعد موجودًا',
  'This technician no longer exists.': 'هذا الفني لم يعد موجودًا.',
  'This transaction reference was already recorded.': 'هذا المرجع مسجل مسبقًا.',
  'This visit already has an invoice.': 'هذه الزيارة لها فاتورة بالفعل.',
  'This visit cannot accept payments.': 'هذه الزيارة لا تقبل مدفوعات.',
  'This visit has reached the end of its workflow.': 'وصلت هذه الزيارة إلى نهاية مراحلها.',
  'This visit is already linked to another invoice.': 'هذه الزيارة مرتبطة بفاتورة أخرى.',
  'This visit is cancelled. Reopen it to plan it again.':
      'هذه الزيارة ملغاة. أعد فتحها لتخطيطها من جديد.',
  'This visit is duplicated in storage.': 'هذه الزيارة مكررة في التخزين.',
  'This visit is linked to more than one invoice.': 'هذه الزيارة مرتبطة بأكثر من فاتورة.',
  'This visit is no longer available': 'هذه الزيارة لم تعد متاحة',
  'This visit no longer exists.': 'هذه الزيارة لم تعد موجودة.',
  'This visit was cancelled and is out of the workflow.':
      'تم إلغاء هذه الزيارة وهي خارج مراحل العمل.',
  'Tip: Since you\'ve already chosen a technician, the \'Schedule\' button has updated to \'Assigned\'':
      'تلميح: بما أنك اخترت فنيًا، تغيّر زر "جدولة" إلى "مُسندة"',
  'To {0}': 'إلى {0}',
  'Today': 'اليوم',
  'Today\'s operations': 'عمليات اليوم',
  'Total Orders': 'إجمالي الطلبات',
  'Total Paid': 'إجمالي المدفوع',
  'Total {0}': 'الإجمالي {0}',
  'Total: {0}\nCheck the linked visit before confirming.':
      'الإجمالي: {0}\nتحقق من الزيارة المرتبطة قبل التأكيد.',
  'Transaction reference': 'مرجع العملية',
  'Transaction reference is required.': 'مرجع العملية مطلوب.',
  'Travel time between visits': 'وقت التنقل بين الزيارات',
  'Travel time must be between 0 and 240 minutes.':
      'يجب أن يكون وقت التنقل بين 0 و240 دقيقة.',
  'Try a different name, phone or city.': 'جرّب اسمًا أو هاتفًا أو مدينة مختلفة.',
  'Try a different name, phone or specialty.': 'جرّب اسمًا أو هاتفًا أو تخصصًا مختلفًا.',
  'Try a different service or category name.': 'جرّب اسم خدمة أو فئة مختلفًا.',
  'Try again': 'حاول مرة أخرى',
  'Try another search or clear the filters.': 'جرّب بحثًا آخر أو امسح التصفية.',
  'Try another search.': 'جرّب بحثًا آخر.',
  'Unassign': 'إلغاء الإسناد',
  'Unassign technician': 'إلغاء إسناد الفني',
  'Unassigned': 'غير مسندة',
  'Uncategorized': 'بدون فئة',
  'Unknown': 'غير معروف',
  'Unknown Client': 'عميل غير معروف',
  'Unknown Technician': 'فني غير معروف',
  'Unknown client': 'عميل غير معروف',
  'Unnamed Service': 'خدمة بدون اسم',
  'Unnamed place': 'مكان بدون اسم',
  'Unpaid': 'غير مدفوعة',
  'Until {0}': 'حتى {0}',
  'Update': 'تحديث',
  'Update Client': 'تحديث العميل',
  'Update Service': 'تحديث الخدمة',
  'Update Site': 'تحديث الموقع',
  'Update Technician': 'تحديث الفني',
  'Update status': 'تحديث الحالة',
  'Update\nSite': 'تحديث\nالموقع',
  'Visit': 'زيارة',
  'Visit Details': 'تفاصيل الزيارة',
  'Visit History': 'سجل الزيارات',
  'Visit ID is required.': 'رقم الزيارة مطلوب.',
  'Visit Proof': 'Visit Proof',
  'Visit and invoice added successfully': 'تمت إضافة الزيارة والفاتورة بنجاح',
  'Visit and its invoice were deleted': 'تم حذف الزيارة وفاتورتها',
  'Visit details updated': 'تم تحديث تفاصيل الزيارة',
  'Visit done. Issue the invoice and collect the payment.':
      'اكتملت الزيارة. أصدر الفاتورة وحصّل المبلغ.',
  'Visit duration must be greater than zero.': 'يجب أن تكون مدة الزيارة أكبر من صفر.',
  'Visit location is required.': 'موقع الزيارة مطلوب.',
  'Visit moved to {0}': 'نُقلت الزيارة إلى {0}',
  'Visit number': 'رقم الزيارة',
  'Visit price is required.': 'سعر الزيارة مطلوب.',
  'Visit price must be a valid non-negative amount.':
      'يجب أن يكون سعر الزيارة مبلغًا صحيحًا غير سالب.',
  'Visit price must have at most 2 decimal places.':
      'يجب ألا يزيد سعر الزيارة عن منزلتين عشريتين.',
  'Visit rescheduled': 'تمت إعادة جدولة الزيارة',
  'Visit rescheduled from {0} to {1}': 'أعيدت جدولة الزيارة من {0} إلى {1}',
  'Visit scheduled for {0}': 'جُدولت الزيارة في {0}',
  'Visit site updated': 'تم تحديث موقع الزيارة',
  'Visit start date is required.': 'تاريخ بدء الزيارة مطلوب.',
  'Visit status': 'حالة الزيارة',
  'Visit status is missing.': 'حالة الزيارة غير موجودة.',
  'Visits': 'الزيارات',
  'Visits appear here when their site was picked on a map.':
      'تظهر الزيارات هنا عند تحديد موقعها على الخريطة.',
  'Visits assigned: {0}': 'الزيارات المسندة: {0}',
  'Visits assigned: {0}, not assigned: {1}': 'الزيارات المسندة: {0}، غير المسندة: {1}',
  'Visits on this day': 'زيارات هذا اليوم',
  'Visits over time': 'الزيارات عبر الوقت',
  'Visits per technician per day': 'عدد زيارات الفني في اليوم',
  'Visits trend': 'اتجاه الزيارات',
  'Waiting': 'بانتظار فني',
  'Waiting for a technician': 'بانتظار فني',
  'Waiting for the technician to start the trip.': 'بانتظار بدء الفني للتنقل.',
  'We could not load this visit': 'تعذّر تحميل هذه الزيارة',
  'We will check that {0} is free at the new time.':
      'سنتحقق من أن {0} متاح في الوقت الجديد.',
  'What does the client report?': 'ما المشكلة التي يذكرها العميل؟',
  'WhatsApp': 'واتساب',
  'Why is this change needed?': 'لماذا هذا التغيير مطلوب؟',
  'Work': 'العمل',
  'Work is in progress at the site.': 'العمل جارٍ في الموقع.',
  'Working hours': 'ساعات العمل',
  'Workload over time': 'عبء العمل عبر الوقت',
  'Write at least {0} characters': 'اكتب {0} أحرف على الأقل',
  'You will need to sign in again to use the app.':
      'ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام التطبيق.',
  'Your dashboard starts with a visit': 'لوحة معلوماتك تبدأ بزيارة',
  'Your data is safe. Try again in a moment.': 'بياناتك آمنة. حاول مرة أخرى بعد لحظات.',
  'Your password is not strong enough. Use 8+ characters with uppercase, lowercase, number & symbol.':
      'كلمة المرور ضعيفة. استخدم 8 أحرف أو أكثر تتضمن حرفًا كبيرًا وصغيرًا ورقمًا ورمزًا.',
  'another visit': 'زيارة أخرى',
  'assigned': 'مُسندة',
  'e.g. Zeyad Khaled': 'مثال: زياد خالد',
  'e.g., AC unit in the master bedroom is blowing warm air. The outdoor compressor is making a loud buzzing noise....':
      'مثال: مكيف غرفة النوم الرئيسية يخرج هواءً ساخنًا، والضاغط الخارجي يصدر صوتًا عاليًا....',
  'e.g., Client asked to call 30 minutes before arrival':
      'مثال: طلب العميل الاتصال قبل الوصول بـ30 دقيقة',
  'e.g., Gate code is 1234, call 10 mins before arrival...':
      'مثال: رمز البوابة 1234، اتصل قبل الوصول بـ10 دقائق...',
  'e.g., Gate code, call before arrival...': 'مثال: رمز البوابة، الاتصال قبل الوصول...',
  'e.g., HVAC': 'مثال: تكييف',
  'e.g., Standard AC Tune-Up': 'مثال: صيانة مكيف قياسية',
  'no category': 'بدون فئة',
  'no client': 'بدون عميل',
  'no technician assigned': 'لم يُسند فني',
  'none': 'لا يوجد',
  'required': 'المطلوب',
  'start date': 'تاريخ البدء',
  'technician': 'الفني',
  'the technician': 'الفني',
  'vs previous day': 'مقارنة باليوم السابق',
  'vs previous {0} days': 'مقارنة بالـ{0} أيام السابقة',
  'week': 'الأسبوع',
  '{0} Min': '{0} دقيقة',
  '{0} Open Jobs': '{0} مهام مفتوحة',
  '{0} Task{1}': '{0} مهام',
  '{0} active now': '{0} نشطة الآن',
  '{0} already has {1} visits on this day (limit {2}).':
      'لدى {0} بالفعل {1} زيارات في هذا اليوم (الحد {2}).',
  '{0} at {1}{2}': '{0} في {1}{2}',
  '{0} booked of {1}': '{0} محجوزة من {1}',
  '{0} due so far': '{0} حان وقتها حتى الآن',
  '{0} for {1}': '{0} في {1}',
  '{0} goes back to the queue and {1} is free at {2}.':
      'تعود {0} إلى قائمة الانتظار ويصبح {1} متاحًا في {2}.',
  '{0} h {1} min': '{0} س {1} د',
  '{0} has no "{1}" specialty.': 'ليس لدى {0} تخصص "{1}".',
  '{0} is already assigned to this visit.': '{0} مُسند بالفعل لهذه الزيارة.',
  '{0} is already booked on {1} at {2}.': '{0} محجوز بالفعل في {1} الساعة {2}.',
  '{0} is busy with {1} ({2} – {3}).': '{0} مشغول في {1} ({2} – {3}).',
  '{0} is marked offline.': '{0} غير متصل.',
  '{0} is off on this day.': '{0} في إجازة هذا اليوم.',
  '{0} item{1} to handle': '{0} مهام للمعالجة',
  '{0} km from another job': 'على بعد {0} كم من مهمة أخرى',
  '{0} min': '{0} دقيقة',
  '{0} of {1} done': 'تم إنجاز {0} من {1}',
  '{0} open jobs': '{0} مهام مفتوحة',
  '{0} outstanding': '{0} مستحق',
  '{0} visits': '{0} زيارات',
  '{0} visits today': '{0} زيارات اليوم',
  '{0} visit{1}': '{0} زيارات',
  '{0} visit{1} already under way and stay{2} with {3}.':
      '{0} زيارات جارية بالفعل وتبقى مع {3}.',
  '{0} visit{1} that day': '{0} زيارات في ذلك اليوم',
  '{0} visit{1} today': '{0} زيارات اليوم',
  '{0} visit{1} · {2} completed': '{0} زيارات · {2} مكتملة',
  '{0} warning{1}': '{0} تنبيهات',
  '{0} · due {1}': '{0} · مستحقة {1}',
  '{0} · tap a bar to see those visits': '{0} · اضغط على عمود لعرض الزيارات',

  // --- Roles, sign in & technician app ---------------------------------------
  'A mock location app is active. Turn it off to continue.':
      'تطبيق موقع وهمي مفعّل. أوقفه للمتابعة.',
  'After work': 'بعد العمل',
  'Another technician already signs in with this email.':
      'يوجد فني آخر يسجّل الدخول بهذا البريد الإلكتروني.',
  'Before work': 'قبل العمل',
  'Could not get your GPS location. Move to an open area and try again.':
      'تعذّر تحديد موقعك. انتقل إلى مكان مفتوح وحاول مرة أخرى.',
  'Could not open the camera. Check the camera permission.':
      'تعذّر فتح الكاميرا. تحقق من إذن الكاميرا.',
  'Could not save the photos on this device.':
      'تعذّر حفظ الصور على هذا الجهاز.',
  'Could not save the session on this device.':
      'تعذّر حفظ الجلسة على هذا الجهاز.',
  'Current job · {0}': 'المهمة الحالية · {0}',
  'Email Address': 'البريد الإلكتروني',
  'Every action you take records your current location for the admin.':
      'كل إجراء تقوم به يسجّل موقعك الحالي ليراه المسؤول.',
  'Field visits with proof of work': 'زيارات ميدانية مع إثبات العمل',
  'Finish the work, take the after photos and complete the visit.':
      'أنهِ العمل والتقط صور ما بعد العمل ثم أكمل الزيارة.',
  'Forgot your password? Ask your admin to set a new one.':
      'نسيت كلمة المرور؟ اطلب من المسؤول تعيين كلمة جديدة.',
  'Getting your location…': 'جارٍ تحديد موقعك…',
  'Hi, {0}': 'مرحبًا، {0}',
  'How do you want to continue?': 'كيف تريد المتابعة؟',
  'Location access is blocked. Allow it from the app settings.':
      'الوصول إلى الموقع محظور. اسمح به من إعدادات التطبيق.',
  'Location access is required to record this action.':
      'يلزم الوصول إلى الموقع لتسجيل هذا الإجراء.',
  'My Visits': 'زياراتي',
  'No visits assigned to you yet': 'لا توجد زيارات مسندة إليك بعد',
  'Not taken yet': 'لم تُلتقط بعد',
  'Notes can only be added to your open visits.':
      'يمكن إضافة الملاحظات إلى زياراتك المفتوحة فقط.',
  'Nothing in this list': 'لا يوجد شيء في هذه القائمة',
  'Only technicians can add visit photos.':
      'يمكن للفنيين فقط إضافة صور الزيارة.',
  'Only the admin can do this.': 'هذا الإجراء متاح للمسؤول فقط.',
  'Open settings': 'فتح الإعدادات',
  'Optional': 'اختياري',
  'Password': 'كلمة المرور',
  'Photos cannot be added at this step.':
      'لا يمكن إضافة صور في هذه الخطوة.',
  'Plan visits, dispatch technicians and follow invoices.':
      'خطط الزيارات ووزّع الفنيين وتابع الفواتير.',
  'Please enter your password': 'يرجى إدخال كلمة المرور',
  'Proof Photos': 'صور الإثبات',
  'See your visits, check in on site and add proof photos.':
      'اطّلع على زياراتك وسجّل وصولك للموقع وأضف صور الإثبات.',
  'Sign in': 'تسجيل الدخول',
  'Start the trip when you leave for the site.':
      'ابدأ الرحلة عند انطلاقك إلى الموقع.',
  'Start work once you arrive. You must be within {0} of the site.':
      'ابدأ العمل عند وصولك. يجب أن تكون على بُعد {0} من الموقع أو أقل.',
  'Switch to admin': 'التبديل إلى المسؤول',
  'Switch to technician': 'التبديل إلى فني',
  'Take before and after photos when the visit asks for them.':
      'التقط صور ما قبل العمل وما بعده عندما تطلبها الزيارة.',
  'Technician added a note': 'أضاف الفني ملاحظة',
  'Technician location · site has no map pin':
      'موقع الفني · الموقع بلا إحداثيات على الخريطة',
  'Technician location · {0} from site': 'موقع الفني · على بُعد {0} من الموقع',
  'Technician sign in': 'تسجيل دخول الفني',
  'The admin cancelled this visit.': 'ألغى المسؤول هذه الزيارة.',
  'The admin is still planning this visit.':
      'لا يزال المسؤول يخطط لهذه الزيارة.',
  'This photo is no longer on this device':
      'هذه الصورة لم تعد موجودة على هذا الجهاز',
  'This site has no map location, so your current location is sent to the admin instead.':
      'لا يوجد لهذا الموقع إحداثيات على الخريطة، لذا يُرسل موقعك الحالي إلى المسؤول بدلًا منها.',
  'This visit is not assigned to you.': 'هذه الزيارة غير مسندة إليك.',
  'This visit needs at least one {0} photo.':
      'تتطلب هذه الزيارة صورة واحدة على الأقل ({0}).',
  'Try another filter.': 'جرّب عامل تصفية آخر.',
  'Turn on location services to continue.':
      'شغّل خدمات الموقع للمتابعة.',
  'Use the email and password your admin created for you.':
      'استخدم البريد الإلكتروني وكلمة المرور اللذين أنشأهما لك المسؤول.',
  'View on map': 'عرض على الخريطة',
  'Welcome back': 'مرحبًا بعودتك',
  'Welcome, {0}': 'أهلًا، {0}',
  'Well done. This visit is complete.': 'أحسنت. اكتملت هذه الزيارة.',
  'With a note': 'مع ملاحظة',
  'Wrong email or password.': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
  'You are {0} from the site. Move within {1} to start work.':
      'أنت على بُعد {0} من الموقع. اقترب إلى {1} أو أقل لبدء العمل.',
  'You can add up to {0} photos at a time.':
      'يمكنك إضافة {0} صور كحد أقصى في المرة الواحدة.',
  'You can switch roles later from the app menu.':
      'يمكنك تغيير الدور لاحقًا من قائمة التطبيق.',
  'Your admin assigns visits to you. Pull down to refresh.':
      'يسند إليك المسؤول الزيارات. اسحب للأسفل للتحديث.',
  'Your current location': 'موقعك الحالي',
  'Your current location is required for this action.':
      'يلزم موقعك الحالي لتنفيذ هذا الإجراء.',
  'Your location is out of date. Refresh it and try again.':
      'موقعك قديم. حدّثه وحاول مرة أخرى.',
  'Your location was taken a while ago. Updating it, confirm again.':
      'تم تحديد موقعك منذ فترة. جارٍ تحديثه، أكّد مرة أخرى.',
  'open visits': 'زيارات مفتوحة',
  '{0} ({1})': '{0} ({1})',
  '{0} from the site': 'على بُعد {0} من الموقع',
  '{0} km': '{0} كم',
  '{0} m': '{0} م',
  '{0} of {1}': '{0} من {1}',
  '{0} photos': 'صور {0}',
  '{0} · {1} photo{2}': '{0} · {1} صور',
  '{0}, {1} · ±{2} · {3}': '{0}، {1} · ±{2} · {3}',

  // --- Field collections -----------------------------------------------------
  'Awaiting confirmation': 'بانتظار التأكيد',
  'Awaiting your confirmation': 'بانتظار تأكيدك',
  'Collect payment': 'تحصيل الدفعة',
  'Collection confirmed': 'تم تأكيد التحصيل',
  'Collection rejected': 'تم رفض التحصيل',
  'Collection sent to the admin for confirmation':
      'تم إرسال التحصيل إلى المسؤول لتأكيده',
  'Collections': 'التحصيلات',
  'Confirm this collection?': 'تأكيد هذا التحصيل؟',
  'Confirmed': 'مؤكد',
  'Field collection of {0} confirmed': 'تم تأكيد تحصيل ميداني بقيمة {0}',
  'Field collection of {0} rejected': 'تم رفض تحصيل ميداني بقيمة {0}',
  'Field payments to confirm': 'مدفوعات ميدانية بانتظار التأكيد',
  'Invoice issued automatically': 'صدرت الفاتورة تلقائيًا',
  'Left to collect: {0}': 'المتبقي للتحصيل: {0}',
  'Nothing to confirm': 'لا يوجد ما يحتاج إلى تأكيد',
  'Payment entry not found.': 'لم يتم العثور على قيد الدفع.',
  'Payment exceeds the remaining balance. {0} is already awaiting confirmation.':
      'الدفعة تتجاوز الرصيد المتبقي. يوجد {0} بانتظار التأكيد بالفعل.',
  'Payment receipt': 'إيصال الدفع',
  'Payments ({0} awaiting confirmation)': 'المدفوعات ({0} بانتظار التأكيد)',
  'Payments technicians collect on site appear here until you confirm them.':
      'تظهر هنا المدفوعات التي يحصّلها الفنيون في الموقع حتى تؤكدها.',
  'Reason (at least {0} characters)': 'السبب ({0} أحرف على الأقل)',
  'Reference: {0}': 'المرجع: {0}',
  'Refund {0}': 'استرداد {0}',
  'Reject': 'رفض',
  'Reject this collection?': 'رفض هذا التحصيل؟',
  'Rejected': 'مرفوض',
  'Send to admin': 'إرسال إلى المسؤول',
  'Take at least one photo of the receipt or the payment.':
      'التقط صورة واحدة على الأقل للإيصال أو للدفعة.',
  'Technician collected {0} · awaiting admin confirmation':
      'حصّل الفني {0} · بانتظار تأكيد المسؤول',
  'The admin confirms the payment before it counts as paid.':
      'يؤكد المسؤول الدفعة قبل احتسابها مدفوعة.',
  'The amount stays unpaid on the invoice. Tell the technician why.':
      'يبقى المبلغ غير مدفوع في الفاتورة. وضّح للفني السبب.',
  'The invoice is issued when the visit is completed. You can collect payment then.':
      'تصدر الفاتورة عند اكتمال الزيارة، ويمكنك تحصيل الدفعة حينها.',
  'This collection was already reviewed.': 'تمت مراجعة هذا التحصيل من قبل.',
  'Visit done. The invoice is issued; confirm the collection or record the payment.':
      'اكتملت الزيارة وصدرت الفاتورة؛ أكّد التحصيل أو سجّل الدفعة.',
  'Well done. Collect the payment from the client if they pay now.':
      'أحسنت. حصّل الدفعة من العميل إذا كان سيدفع الآن.',
  'Where it was collected': 'مكان التحصيل',
  'You can collect payment once the work has started.':
      'يمكنك تحصيل الدفعة بعد بدء العمل.',
  '{0} by {1}': '{0} بواسطة {1}',
  '{0} collected by the technician is awaiting your confirmation':
      '{0} حصّلها الفني بانتظار تأكيدك',
  '{0} collected on site is awaiting admin confirmation':
      '{0} محصّلة في الموقع بانتظار تأكيد المسؤول',
  '{0} collections from technicians': '{0} تحصيلات من الفنيين',
  '{0} will be added to the paid amount of the invoice.':
      'ستتم إضافة {0} إلى المبلغ المدفوع في الفاتورة.',
  '{0} · {1}': '{0} · {1}',

  // --- App menu ----------------------------------------------------------------
  'Assign and schedule technicians': 'إسناد الفنيين وجدولتهم',
  'Billing, payments and refunds': 'الفواتير والمدفوعات والاستردادات',
  'Customers, sites and equipment': 'العملاء والمواقع والمعدات',
  'Dashboard': 'لوحة التحكم',
  'Directory': 'الدليل',
  'Every visit and its status': 'كل الزيارات وحالاتها',
  'Finance': 'المالية',
  'Open': 'مفتوحة',
  'Operations': 'العمليات',
  'Overview and what needs attention': 'نظرة عامة وما يحتاج إلى متابعة',
  'Prices, durations and checklists': 'الأسعار والمدد وقوائم التحقق',
  'Your field team': 'فريقك الميداني',

  // --- Small labels -------------------------------------------------------------
  ', ': '، ',
  'N/A': 'غير متوفر',
  'OpenStreetMap contributors': 'مساهمو OpenStreetMap',
  'SN:': 'الرقم التسلسلي:',
  'Week of {0}': 'أسبوع {0}',
  '{0} h': '{0} س',
  'client': 'العميل',
  'duration': 'المدة',
  'price': 'السعر',
  'service': 'الخدمة',
  'site': 'الموقع',

  // --- Service categories (default list) --------------------------------------
  'Carpentry': 'النجارة',
  'Electrical': 'الكهرباء',
  'Networking': 'الشبكات',
  'Plumbing': 'السباكة',
  'Smart Home': 'المنزل الذكي',

  // --- Saudi cities -------------------------------------------------------------
  'Riyadh': 'الرياض',
  'Jeddah': 'جدة',
  'Makkah': 'مكة المكرمة',
  'Madinah': 'المدينة المنورة',
  'Dammam': 'الدمام',
  'Khobar': 'الخبر',
  'Dhahran': 'الظهران',
  'Taif': 'الطائف',
  'Tabuk': 'تبوك',
  'Buraydah': 'بريدة',
  'Unaizah': 'عنيزة',
  'Hail': 'حائل',
  'Abha': 'أبها',
  'Khamis Mushait': 'خميس مشيط',
  'Jazan': 'جازان',
  'Najran': 'نجران',
  'Al Bahah': 'الباحة',
  'Sakaka': 'سكاكا',
  'Arar': 'عرعر',
  'Jubail': 'الجبيل',
  'Yanbu': 'ينبع',
  'Al Ahsa': 'الأحساء',
  'Al Hofuf': 'الهفوف',
  'Qatif': 'القطيف',
  'Hafar Al Batin': 'حفر الباطن',
  'Al Kharj': 'الخرج',
  'Diriyah': 'الدرعية',
  'Al Majmaah': 'المجمعة',
  'Al Zulfi': 'الزلفي',
  'Al Duwadimi': 'الدوادمي',
  'Wadi Al Dawasir': 'وادي الدواسر',
  'Al Qurayyat': 'القريات',
  'Rafha': 'رفحاء',
  'Turaif': 'طريف',
  'Bisha': 'بيشة',
  'Muhayil Asir': 'محايل عسير',
  'Sabya': 'صبيا',
  'Abu Arish': 'أبو عريش',
  'Samtah': 'صامطة',
  'Sharurah': 'شرورة',

  // --- Installed app (PWA) ---------------------------------------------------
  'Install': 'تثبيت',
  'Install {0}': 'تثبيت {0}',
  'Install this app on your device.': 'ثبّت هذا التطبيق على جهازك.',
  'To install, tap Share and then "Add to Home Screen".':
      'للتثبيت، اضغط على زر المشاركة ثم اختر «إضافة إلى الشاشة الرئيسية».',
  'Open your browser menu and choose "Install app" or "Add to Home Screen".':
      'افتح قائمة المتصفح واختر «تثبيت التطبيق» أو «إضافة إلى الشاشة الرئيسية».',
  'OK': 'حسنًا',
  'Close': 'إغلاق',
  '{0} is installed': 'تم تثبيت {0}',
  'Open it from your home screen or your apps. It opens with the design you chose.':
      'افتحه من الشاشة الرئيسية أو من قائمة التطبيقات، وسيظهر بالتصميم الذي اخترته.',
  'Your app opens in a new tab. In Safari, tap Share and then "Add to Home Screen".':
      'سيُفتح تطبيقك في علامة تبويب جديدة. في متصفح سفاري، اضغط على زر المشاركة ثم اختر «إضافة إلى الشاشة الرئيسية».',
  'Your app opens in a new tab. Choose "Install" in the bar at the top, or "Install app" in the browser menu.':
      'سيُفتح تطبيقك في علامة تبويب جديدة. اختر «تثبيت» من الشريط في الأعلى، أو «تثبيت التطبيق» من قائمة المتصفح.',
  'Open my app': 'افتح تطبيقي',

  // --- Website: landing page -------------------------------------------------
  'Apps': 'التطبيقات',
  'Small apps. Big magic.': 'تطبيقات صغيرة، سحر كبير.',
  'Browse the apps': 'تصفّح التطبيقات',
  'Try {0} live': 'جرّب {0} مباشرة',
  'My workspace': 'مساحة عملي',
  'Coming soon': 'قريبًا',
  'The apps': 'التطبيقات',
  'Pick the tools your team needs': 'اختر الأدوات التي يحتاجها فريقك',
  'Each app does one job well. Start with one today and add more as they arrive.':
      'يؤدي كل تطبيق مهمة واحدة بإتقان. ابدأ بتطبيق واحد اليوم، وأضف غيره عند صدوره.',
  'Available now': 'متاح الآن',
  'See the details': 'اطّلع على التفاصيل',
  'More apps are on the way': 'المزيد من التطبيقات في الطريق',
  'We are building more small apps for the everyday work of a business. Each one will join the same workspace, with the same simple pricing.':
      'نعمل على تطوير مزيد من التطبيقات الصغيرة للأعمال اليومية في المنشآت، وسينضم كل منها إلى مساحة العمل نفسها، وبالتسعير البسيط ذاته.',
  '{0} · one plan for every small team': '{0} · باقة واحدة لكل فريق صغير',
  'What is {0}?': 'ما هو {0}؟',
  '{0} is a marketplace of ready-to-use business apps for small teams. You choose the apps you need, try each one live, and we set it up with your colors and your logo.':
      '{0} متجر لتطبيقات الأعمال الجاهزة للفرق الصغيرة. تختار التطبيقات التي تحتاجها، وتجرّب كلًّا منها تجربة مباشرة، ثم نُعدّه لك بألوانك وشعارك.',
  'Which apps can I get today?': 'ما التطبيقات المتاحة اليوم؟',
  '{0} is available now. More apps are coming soon and will join the same workspace.':
      'تطبيق {0} متاح الآن، وستصدر تطبيقات أخرى قريبًا لتنضم إلى مساحة العمل نفسها.',
  'Pricing': 'الأسعار',
  'FAQ': 'الأسئلة الشائعة',
  'Demo': 'تجربة',
  'Light mode': 'الوضع الفاتح',
  'Every technician visit is scheduled, proven with live location and photos, and closed with a clear record — in an app with your colors, your fonts and your logo.':
      'تُجدوَل كل زيارة للفني، وتُوثَّق بالموقع المباشر والصور، وتُغلق بسجل واضح — في تطبيق بألوانك وخطوطك وشعارك.',
  'Try it and design your app': 'جرّبه وصمّم تطبيقك',
  'VIS-000124 · AC periodic maintenance': 'VIS-000124 · صيانة دورية للمكيف',
  'Al Noor Pharmacy · Riyadh': 'صيدلية النور · الرياض',
  'Arrived · 18 m from the site': 'الوصول · على بُعد 18 م من الموقع',
  '3 photos before and after': '3 صور قبل العمل وبعده',
  'Payment collected · receipt photo': 'تم تحصيل الدفعة · صورة الإيصال',
  'Everything a small field team needs, nothing it does not':
      'كل ما يحتاجه فريق ميداني صغير، دون أي تعقيد',
  'One app for the office and one for the technicians, connected live.':
      'تطبيق للمكتب وآخر للفنيين، مترابطان لحظة بلحظة.',
  'Plan and assign visits': 'تخطيط الزيارات وإسنادها',
  'Create a visit in seconds, pick the technician and see the whole day on one dispatch board.':
      'أنشئ زيارة خلال ثوانٍ، واختر الفني، واطّلع على اليوم كاملًا في لوحة توزيع واحدة.',
  'Proof of presence': 'إثبات الحضور',
  'Starting work needs the technician\'s live location near the site. Every step is logged with where it happened.':
      'يتطلب بدء العمل وجود الفني بالقرب من الموقع وفق موقعه المباشر، وتُسجَّل كل خطوة مع مكان حدوثها.',
  'Before and after photos': 'صور قبل العمل وبعده',
  'Camera photos taken on the spot, attached to the visit and shown to you in one place.':
      'صور تُلتقط بالكاميرا في الموقع نفسه، وتُرفق بالزيارة وتُعرض لك في مكان واحد.',
  'A full activity log': 'سجل نشاط كامل',
  'Who did what and when: status changes, notes, payments and locations, all in one timeline.':
      'من فعل ماذا ومتى: تغييرات الحالة والملاحظات والمدفوعات والمواقع، في خط زمني واحد.',
  'Payments collected on site': 'تحصيل المدفوعات في الموقع',
  'The technician records the payment with a receipt photo; you confirm it when you have time.':
      'يسجّل الفني الدفعة مع صورة الإيصال، وتؤكدها أنت في الوقت المناسب لك.',
  'Invoices for every visit': 'فاتورة لكل زيارة',
  'Each visit has its invoice, issued automatically when the work is done.':
      'لكل زيارة فاتورتها، وتصدر تلقائيًا عند انتهاء العمل.',
  'Clients, sites and equipment': 'العملاء والمواقع والمعدات',
  'Your customers, their locations and their machines, ready for the next visit.':
      'عملاؤك ومواقعهم وأجهزتهم، جاهزة للزيارة القادمة.',
  'A real right-to-left Arabic app; each user picks their language.':
      'تطبيق عربي حقيقي من اليمين إلى اليسار، ويختار كل مستخدم لغته.',
  'How it works': 'آلية العمل',
  'From demo to your own app in four steps':
      'من التجربة إلى تطبيقك الخاص في أربع خطوات',
  'Design your version': 'صمّم نسختك',
  'Pick any colors, fonts, text size, icon or logo, and the app name. You see every change instantly.':
      'اختر أي ألوان وخطوط وحجم نص وأيقونة أو شعار واسمًا للتطبيق، وشاهد كل تغيير فورًا.',
  'Send your request': 'أرسل طلبك',
  'One tap sends us your design and your notes.':
      'ضغطة واحدة ترسل إلينا تصميمك وملاحظاتك.',
  'Get your private link': 'استلم رابطك الخاص',
  'We prepare your company\'s app and send you its link. Your team opens it and adds it to the home screen.':
      'نُعدّ تطبيق شركتك ونرسل إليك رابطه، فيفتحه فريقك ويضيفه إلى الشاشة الرئيسية.',
  'Start with step 1': 'ابدأ بالخطوة الأولى',
  'Simple, small and clear': 'بسيط وواضح ومناسب للشركات الصغيرة',
  'We are built for companies at the start of their journey. When you grow past {0} users, you have outgrown us — and that is the goal.':
      'صُمّمنا للشركات في بداية مسيرتها. وعندما يتجاوز فريقك {0} مستخدمين تكون قد كبرت — وهذا هو الهدف.',
  'then {0}': 'ثم {0}',
  'every {0} months': 'كل {0} أشهر',
  'Up to {0} users: admins and technicians':
      'حتى {0} مستخدمين: مسؤولون وفنيون',
  'Unlimited visits, clients and sites': 'زيارات وعملاء ومواقع بلا حدود',
  '{0} GB for photos (compressed automatically)':
      '{0} غيغابايت للصور (تُضغط تلقائيًا)',
  'Your colors, fonts, icon or logo and your app name':
      'ألوانك وخطوطك وأيقونتك أو شعارك واسم تطبيقك',
  'Hosting, daily backups and updates':
      'الاستضافة والنسخ الاحتياطي اليومي والتحديثات',
  'Support on WhatsApp and email': 'دعم عبر واتساب والبريد الإلكتروني',
  'Arabic and English': 'العربية والإنجليزية',
  'Your data is yours: we export it for you whenever you ask':
      'بياناتك ملك لك: نصدّرها لك متى طلبت ذلك',
  'Request my version': 'اطلب نسختي',
  'Nothing to pay today.': 'لا يلزمك الدفع اليوم.',
  'Exactly what you pay': 'ما تدفعه بالتحديد',
  'Months 1 to {0}': 'من الشهر 1 إلى الشهر {0}',
  'Free': 'مجانًا',
  'Every {0} months after that': 'كل {0} أشهر بعد ذلك',
  'Setup, colors and logo': 'الإعداد والألوان والشعار',
  'Extra fees per user': 'رسوم إضافية لكل مستخدم',
  'If a period is not renewed, your app stays readable for {0} days so you can take your data, then it is deleted after a reminder.':
      'إذا لم تُجدَّد الفترة، يبقى تطبيقك متاحًا للقراءة مدة {0} يومًا لتحتفظ ببياناتك، ثم يُحذف بعد إشعارك.',
  'How you receive it': 'طريقة الاستلام',
  'Your app arrives as a link, not a download':
      'يصلك تطبيقك رابطًا لا ملفًا للتنزيل',
  'We deliver it as a PWA (progressive web app): a web app that installs on the phone like a normal app.':
      'نسلّمه بصيغة PWA (تطبيق ويب تقدمي): تطبيق ويب يُثبَّت على الجوال كأي تطبيق عادي.',
  'A private link for your company': 'رابط خاص بشركتك',
  'Your app lives on its own web link. Only your team signs in to it.':
      'يعمل تطبيقك على رابط مستقل، ولا يسجّل الدخول إليه إلا فريقك.',
  'Installs like an app': 'يُثبَّت كتطبيق',
  'Open the link on any phone and choose "Add to Home Screen". It gets your icon and opens full screen.':
      'افتح الرابط على أي جوال واختر "إضافة إلى الشاشة الرئيسية"، فيظهر بأيقونتك ويفتح بملء الشاشة.',
  'iPhone, Android and computers': 'آيفون وأندرويد والحواسيب',
  'No App Store or Google Play needed. The office can use it on a laptop.':
      'لا حاجة إلى App Store أو Google Play، ويمكن للمكتب استخدامه على الحاسوب المحمول.',
  'Always up to date': 'محدّث دائمًا',
  'Updates arrive by themselves. Nobody has to download anything.':
      'تصل التحديثات تلقائيًا، ولا يحتاج أحد إلى تنزيل أي شيء.',
  'Questions': 'أسئلة',
  'Frequently asked questions': 'الأسئلة الشائعة',
  'Do I pay anything now?': 'هل أدفع شيئًا الآن؟',
  '{0} every {1} months for your whole company, up to {2} users. There is no fee per user and no setup fee.':
      '{0} كل {1} أشهر لشركتك كاملة، حتى {2} مستخدمين. لا توجد رسوم لكل مستخدم ولا رسوم إعداد.',
  'Is there a contract?': 'هل يوجد عقد؟',
  'No. You renew every {0} months. If you stop, you keep reading access for {1} days to take your data.':
      'لا. تجدّد كل {0} أشهر، وإذا توقفت يبقى لديك حق الاطلاع مدة {1} يومًا لتحتفظ ببياناتك.',
  'What if I need more than {0} users?': 'ماذا لو احتجت إلى أكثر من {0} مستخدمين؟',
  'That means your company has grown — congratulations. We help you export your data so you can move to a bigger system.':
      'هذا يعني أن شركتك قد نمت — تهانينا. نساعدك على تصدير بياناتك للانتقال إلى نظام أكبر.',
  'Can I change the colors or logo later?': 'هل يمكنني تغيير الألوان أو الشعار لاحقًا؟',
  'Yes, at no cost. Colors, fonts, text size, icon, logo and app name are part of the plan.':
      'نعم، دون أي تكلفة. الألوان والخطوط وحجم النص والأيقونة والشعار واسم التطبيق جزء من الباقة.',
  'What counts as a custom change?': 'ما الذي يُعدّ تعديلًا خاصًا؟',
  'How do my technicians get the app?': 'كيف يحصل الفنيون على التطبيق؟',
  'You send them your app\'s link. They open it on their phone, add it to the home screen and sign in with the email and password you give them.':
      'ترسل إليهم رابط تطبيقك، فيفتحونه على جوالاتهم ويضيفونه إلى الشاشة الرئيسية، ثم يسجّلون الدخول بالبريد الإلكتروني وكلمة المرور اللذين تمنحهم إياهما.',
  'Is my data private?': 'هل بياناتي خاصة؟',
  'Each company has its own separate space. Other companies cannot see your clients, visits or photos.':
      'لكل شركة مساحة مستقلة، ولا يمكن لأي شركة أخرى الاطلاع على عملائك أو زياراتك أو صورك.',
  'Is the demo saving what I type?': 'هل تحفظ التجربة ما أكتبه؟',
  'Every company passes through its first steps.':
      'كل شركة تمر بخطواتها الأولى.',
  'Let us organize yours while you grow.': 'دعنا ننظّم خطواتك بينما تنمو.',
  'Design my app now': 'صمّم تطبيقي الآن',

  // --- Website: design studio ------------------------------------------------
  'Request': 'اطلب',
  'Colors': 'الألوان',
  'Main color': 'اللون الأساسي',
  'Buttons, links and headers': 'الأزرار والروابط والعناوين',
  'Second color': 'اللون الثانوي',
  'Gradients and section icons': 'التدرجات وأيقونات الأقسام',
  'Background': 'الخلفية',
  'Behind every screen (light mode)': 'خلف كل الشاشات (الوضع الفاتح)',
  'Cards and bars': 'البطاقات والأشرطة',
  'Cards, sheets and app bars (light mode)':
      'البطاقات والنوافذ وأشرطة التطبيق (الوضع الفاتح)',
  'Text': 'النص',
  'Titles and main text (light mode)': 'العناوين والنص الرئيسي (الوضع الفاتح)',
  'Success': 'النجاح',
  'Completed and paid': 'المكتمل والمدفوع',
  'Scheduled, pending and in progress': 'المجدول والمعلّق وقيد التنفيذ',
  'Cancelled, overdue and errors': 'الملغى والمتأخر والأخطاء',
  'Back to default': 'استعادة الافتراضي',
  'Mode': 'الوضع',
  'Light': 'فاتح',
  'Dark': 'داكن',
  'Fonts': 'الخطوط',
  'Arabic font': 'الخط العربي',
  'English font': 'الخط الإنجليزي',
  'Text size': 'حجم النص',
  'App name': 'اسم التطبيق',
  'App icon': 'أيقونة التطبيق',
  'Upload your logo': 'ارفع شعارك',
  'Change logo': 'تغيير الشعار',
  'Remove logo': 'إزالة الشعار',
  'Try the demo': 'جرّب التطبيق',
  'Pretend I am at the site': 'افترض أنني في الموقع',
  'Demo: your location is simulated at the site.':
      'تجربة: يُفترض أن موقعك داخل موقع العميل.',
  'Violet': 'بنفسجي',
  'Ocean': 'محيطي',
  'Emerald': 'زمردي',
  'Sunset': 'غروب',
  'Ruby': 'ياقوتي',
  'Graphite': 'رمادي',
  'Royal': 'ملكي',
  'Sky': 'سماوي',
  'Proof badge': 'شارة الإثبات',
  'Air conditioning': 'التكييف',
  'Maintenance': 'الصيانة',
  'Cleaning': 'التنظيف',
  'Pest control': 'مكافحة الحشرات',
  'Solar': 'الطاقة الشمسية',
  'Security & cameras': 'الأمن والكاميرات',
  'Engineering': 'الهندسة',
  'Home services': 'الخدمات المنزلية',
  'Inspection': 'الفحص',

  // --- Website: request ------------------------------------------------------
  'Request your version': 'اطلب نسختك',
  'Send us your design. We will contact you to confirm, then prepare your app and send you its private link.':
      'أرسل إلينا تصميمك، وسنتواصل معك للتأكيد، ثم نُعدّ تطبيقك ونرسل إليك رابطه الخاص.',
  'Your details': 'بياناتك',
  'Your name': 'الاسم',
  'Company name': 'اسم الشركة',
  'Phone / WhatsApp': 'الجوال / واتساب',
  'Email (optional)': 'البريد الإلكتروني (اختياري)',
  'e.g. add a field for the AC model, add my VAT number on the invoice…':
      'مثال: إضافة حقل لطراز المكيف، أو إضافة الرقم الضريبي إلى الفاتورة…',
  'Your design': 'تصميمك',
  'Change the design': 'تعديل التصميم',
  'What you will pay': 'ما ستدفعه',
  'I have read the price and the terms.': 'اطّلعت على السعر والشروط.',
  'Please confirm you have read the price.': 'يرجى تأكيد اطلاعك على السعر.',
  'Send my request': 'إرسال الطلب',
  'Sending…': 'جارٍ الإرسال…',

  // --- Demo data -------------------------------------------------------------
  'updated {0}': 'آخر تحديث {0}',
  '{0} pts': '{0} نقطة',
  'Visit created': 'تم إنشاء الزيارة',
  'Technician assigned: {0}': 'تم إسناد الفني: {0}',
  // --- Website: one price, special requests priced per request ------------
  'Anything the app does not do today: a new field, a new report, a new screen or a connection to another system. We discuss your request with you, agree on its price, and only then start.':
      'كل ما لا يقدمه التطبيق حاليًا: حقل جديد أو تقرير جديد أو شاشة جديدة أو ربط بنظام آخر. نناقش طلبك معك ونتفق على سعره، ثم نبدأ التنفيذ.',

  // --- Calm dashboard, technician home and guided tour ---------------------
  'Book a client and send a technician':
      'احجز موعدًا لعميل وأرسل فنيًا',
  'How this screen works':
      'كيف تعمل هذه الشاشة',
  'Tomorrow':
      'غدًا',
  'Next: {0}':
      'التالي: {0}',
  'Right now':
      'الآن',
  'Open visit details':
      'فتح تفاصيل الزيارة',
  'You have {0} open visits · {1} today':
      'لديك {0} زيارات مفتوحة · {1} اليوم',
  'Start the mission':
      'ابدأ المهمة',
  'Not now':
      'ليس الآن',
  'Stop {0} of {1}':
      'المحطة {0} من {1}',
  'Skip tour':
      'تخطي الجولة',
  'Previous':
      'السابق',
  'Next stop':
      'المحطة التالية',
  'Finish':
      'إنهاء',
  'Mission complete!':
      'اكتملت المهمة!',
  'Play again':
      'إعادة الجولة',
  'Master your dashboard':
      'أتقن لوحة التحكم',
  'Your command center':
      'مركز القيادة الخاص بك',
  'The whole company on one screen. The line under the title shows the dates you are viewing and when the numbers were last updated.':
      'الشركة بأكملها في شاشة واحدة. يوضح السطر أسفل العنوان التواريخ المعروضة وآخر وقت حُدّثت فيه الأرقام.',
  'Tap refresh any time to get the newest numbers.':
      'اضغط زر التحديث في أي وقت للحصول على أحدث الأرقام.',
  'Choose your time range':
      'اختر الفترة الزمنية',
  'Every number on this screen follows the range you pick here: today, 7 days, 30 days, this month, or your own dates.':
      'تتبع كل الأرقام في هذه الشاشة الفترة التي تختارها هنا: اليوم، أو 7 أيام، أو 30 يومًا، أو هذا الشهر، أو تواريخ تحددها بنفسك.',
  'Each number is compared with the period just before it.':
      'يُقارَن كل رقم بالفترة السابقة لها مباشرة.',
  'Book new work':
      'احجز عملًا جديدًا',
  'The fastest way to start a visit. Choose the client, the service and the time, then send a technician.':
      'أسرع طريقة لبدء زيارة. اختر العميل والخدمة والوقت، ثم أرسل فنيًا.',
  'Handle problems first':
      'ابدأ بمعالجة المشكلات',
  'Late visits, visits with no technician, work not invoiced yet and overdue invoices. Only real problems appear here.':
      'الزيارات المتأخرة، والزيارات بلا فني، والأعمال التي لم تصدر فواتيرها، والفواتير المتأخرة. لا يظهر هنا إلا ما يحتاج إلى معالجة فعلية.',
  'Tap a row to see exactly which ones.':
      'اضغط على أي صف لمعرفة التفاصيل.',
  'Your four scores':
      'مؤشراتك الأربعة',
  'Visits, completion, money collected and items needing attention. The small arrow shows if you are doing better or worse than before.':
      'الزيارات، ونسبة الإنجاز، والمبالغ المحصلة، والعناصر التي تحتاج إلى متابعة. يوضح السهم الصغير ما إذا كان الأداء أفضل أم أسوأ من السابق.',
  'Tap any score to see the details behind it.':
      'اضغط على أي مؤشر لعرض تفاصيله.',
  'Today, live':
      'اليوم مباشرة',
  "Where each of today's visits stands right now, from scheduled to completed.":
      'حالة كل زيارة من زيارات اليوم الآن، من الجدولة حتى الإكمال.',
  'Tap a number to open those visits.':
      'اضغط على أي رقم لفتح تلك الزيارات.',
  'See the rhythm':
      'تابع وتيرة العمل',
  'Each bar is a slice of time. Green is completed work and blue is work not completed yet.':
      'يمثل كل عمود فترة زمنية. الأخضر للأعمال المكتملة والأزرق للأعمال غير المكتملة بعد.',
  'Tap a bar to open the visits behind it.':
      'اضغط على أي عمود لفتح زياراته.',
  'Meet your team':
      'تعرّف على فريقك',
  'Who finished how much in this period. A bar fills up as a technician completes the visits assigned to them.':
      'ما أنجزه كل فني في هذه الفترة. يمتلئ الشريط كلما أكمل الفني الزيارات المسندة إليه.',
  'Tap a name to see their full results.':
      'اضغط على أي اسم لعرض نتائجه كاملة.',
  'Jump anywhere':
      'انتقل إلى أي مكان',
  'Shortcuts to dispatch, visits, clients, technicians, services and invoices, all from here.':
      'اختصارات إلى التوزيع والزيارات والعملاء والفنيين والخدمات والفواتير، جميعها من هنا.',

  // --- Guided tours: Wizpoo on every screen and sheet -----------------------
  'Actions':
      'الإجراءات',
  'Client details':
      'تفاصيل العميل',
  'Equipment':
      'المعدات',
  'My visits':
      'زياراتي',
  'Search':
      'بحث',
  'Specialties':
      'التخصصات',
  'Technician details':
      'تفاصيل الفني',
  'Visit details':
      'تفاصيل الزيارة',
  'Visit history':
      'سجل الزيارات',
  'Hi, I am Wizpoo':
      'مرحبًا، أنا ويزبو',
  'Got it':
      'حسنًا',
  'You now know how this screen works.':
      'أصبحت تعرف الآن كيف تعمل هذه الشاشة.',
  'Help flags':
      'أعلام المساعدة',
  'Choose how to enter':
      'اختر طريقة الدخول',
  'This app has two sides. Pick the one that fits you.':
      'للتطبيق جانبان. اختر الجانب المناسب لك.',
  'Runs the whole company: clients, technicians, visits and invoices. No account is needed.':
      'يدير الشركة بأكملها: العملاء والفنيين والزيارات والفواتير. لا يلزم إنشاء حساب.',
  'Signs in with the email and password the admin created, then works on their own visits.':
      'يسجل الدخول بالبريد الإلكتروني وكلمة المرور اللذين أنشأهما المسؤول، ثم يعمل على زياراته.',
  'Your preferences':
      'تفضيلاتك',
  'Change the language, turn dark mode on or off, or hide these help flags.':
      'غيّر اللغة، أو فعّل الوضع الداكن أو أوقفه، أو أخفِ أعلام المساعدة هذه.',
  'Sign in to see the visits assigned to you.':
      'سجّل الدخول لعرض الزيارات المسندة إليك.',
  'Your email':
      'بريدك الإلكتروني',
  'Use the same email your admin saved for you.':
      'استخدم البريد الإلكتروني نفسه الذي حفظه لك المسؤول.',
  'Your password':
      'كلمة المرور',
  'Use the password your admin set. Tap the eye to see what you typed.':
      'استخدم كلمة المرور التي حددها المسؤول. اضغط على رمز العين لرؤية ما كتبته.',
  'Enter the app':
      'ادخل إلى التطبيق',
  'Your visits open right after you sign in.':
      'تظهر زياراتك مباشرة بعد تسجيل الدخول.',
  'App menu':
      'قائمة التطبيق',
  'Every part of the app is one tap away from here.':
      'كل أقسام التطبيق على بُعد ضغطة واحدة من هنا.',
  'All sections':
      'جميع الأقسام',
  'Operations come first, then finance, then your client, technician and service lists.':
      'تأتي العمليات أولًا، ثم المالية، ثم قوائم العملاء والفنيين والخدمات.',
  'Your account':
      'حسابك',
  'Switch between admin and technician from here.':
      'بدّل بين المسؤول والفني من هنا.',
  'Reminders for your work and your preferences.':
      'تذكيرات عملك وتفضيلاتك.',
  'Work reminders':
      'تذكيرات العمل',
  'What the app records while you work, and when photos are needed.':
      'ما يسجله التطبيق أثناء عملك، ومتى تلزم الصور.',
  'Sign out or switch role from here.':
      'سجّل الخروج أو بدّل الدور من هنا.',
  'How the whole company is doing, on one screen.':
      'أداء الشركة بأكملها في شاشة واحدة.',
  'The details behind a number':
      'التفاصيل خلف الرقم',
  'Everything behind the score you tapped, ready to filter.':
      'كل ما يقف خلف المؤشر الذي اخترته، جاهز للتصفية.',
  'Where you are':
      'موقعك الحالي',
  'Shows how you got here. Tap an earlier name to go back to it.':
      'يوضح كيف وصلت إلى هنا. اضغط على اسم سابق للرجوع إليه.',
  'Every number on this screen follows the range you pick here.':
      'تتبع كل الأرقام في هذه الشاشة الفترة التي تختارها هنا.',
  'Key numbers':
      'الأرقام الرئيسية',
  'The main totals for the period you picked.':
      'الإجماليات الرئيسية للفترة التي اخترتها.',
  'Over time':
      'على مدار الوقت',
  'How the numbers moved during the period.':
      'كيف تغيرت الأرقام خلال الفترة.',
  'Tap a bar to filter by it.':
      'اضغط على أي عمود للتصفية بحسبه.',
  'The records':
      'السجلات',
  'The exact visits behind the numbers. Tap one to open it.':
      'الزيارات التي تقف خلف الأرقام. اضغط على أي زيارة لفتحها.',
  'Technician results':
      'نتائج الفني',
  'How one technician performed in the period you picked.':
      'أداء فني واحد خلال الفترة التي اخترتها.',
  'The main results of this technician in the period.':
      'النتائج الرئيسية لهذا الفني خلال الفترة.',
  'How much work this technician had during the period.':
      'حجم العمل الذي تولاه هذا الفني خلال الفترة.',
  'How their visits split between the workflow stages. Tap one to filter the list.':
      'توزيع زياراته على مراحل العمل. اضغط على أي مرحلة لتصفية القائمة.',
  'Dispatch board':
      'لوحة التوزيع',
  'Plan the day: who goes where, and when.':
      'خطط ليومك: من يذهب إلى أين، ومتى.',
  'Pick the day':
      'اختر اليوم',
  'Everything on the board belongs to the day you select here.':
      'كل ما في اللوحة يخص اليوم الذي تختاره هنا.',
  'The day at a glance':
      'اليوم في لمحة',
  'Visits waiting for a technician, conflicts, late visits and the total planned.':
      'الزيارات التي تنتظر فنيًا، والتعارضات، والزيارات المتأخرة، وإجمالي المخطط.',
  'Tap a counter to see those visits.':
      'اضغط على أي عداد لعرض تلك الزيارات.',
  'Change the view':
      'غيّر طريقة العرض',
  'See the work by technician, as a waiting queue, or on the map.':
      'اعرض العمل بحسب الفني، أو كقائمة انتظار، أو على الخريطة.',
  'The board':
      'اللوحة',
  'This is where you assign and arrange the work of the day.':
      'هنا تسند أعمال اليوم وترتبها.',
  'Waiting visits':
      'الزيارات المنتظرة',
  'Visits on this day that still need a technician.':
      'زيارات هذا اليوم التي ما زالت تحتاج إلى فني.',
  'Set what the board checks every time you assign a visit.':
      'حدد ما تتحقق منه اللوحة في كل مرة تسند فيها زيارة.',
  'All visits':
      'جميع الزيارات',
  'Every visit of the company and where it stands.':
      'كل زيارات الشركة وحالة كل منها.',
  'Find a visit':
      'ابحث عن زيارة',
  'Search here, or use the filter button to narrow the list.':
      'ابحث هنا، أو استخدم زر التصفية لتضييق القائمة.',
  'Open dispatch':
      'افتح التوزيع',
  'Jump to the board to plan who does what.':
      'انتقل إلى اللوحة لتحديد مهام كل فني.',
  'One visit':
      'زيارة واحدة',
  'Its status, client, service, time, technician and payment. Tap it to open everything.':
      'حالتها وعميلها وخدمتها ووقتها وفنيها ودفعها. اضغط عليها لعرض كل التفاصيل.',
  'Add a visit':
      'أضف زيارة',
  'Create a new visit. Its invoice is created with it automatically.':
      'أنشئ زيارة جديدة، وتُنشأ فاتورتها معها تلقائيًا.',
  'Fill these parts from top to bottom to book the work.':
      'املأ هذه الأجزاء من الأعلى إلى الأسفل لحجز العمل.',
  'Who is it for':
      'لمن الزيارة',
  'Choose the client and the site where the work happens.':
      'اختر العميل والموقع الذي سيتم فيه العمل.',
  'What is the job':
      'ما العمل المطلوب',
  'Choose the service. Its details can be adjusted for this visit.':
      'اختر الخدمة، ويمكن تعديل تفاصيلها لهذه الزيارة.',
  'When and who':
      'متى ومن',
  'Set the date and time, and choose a technician if you already know who will go.':
      'حدد التاريخ والوقت، واختر فنيًا إذا كنت تعرف من سيذهب.',
  'Save it':
      'احفظها',
  'Save a draft to finish later, or schedule the visit. With a technician selected, it is assigned right away.':
      'احفظ مسودة لإكمالها لاحقًا، أو جدول الزيارة. وعند اختيار فني تُسند إليه مباشرة.',
  'Everything about this visit, from booking to payment.':
      'كل ما يخص هذه الزيارة، من الحجز حتى الدفع.',
  'Where it stands':
      'وضع الزيارة',
  'The service, price, priority and payment, with the visit progress along the bottom.':
      'الخدمة والسعر والأولوية والدفع، مع تقدم الزيارة في الأسفل.',
  'The next step':
      'الخطوة التالية',
  'The action that moves this visit forward is always here. Technician actions record the live location.':
      'الإجراء الذي ينقل الزيارة إلى الأمام موجود هنا دائمًا. وتسجل إجراءات الفني موقعه الحالي.',
  'The client':
      'العميل',
  'Who the visit is for and how to reach them.':
      'لمن هذه الزيارة وكيفية التواصل معه.',
  'Time and technician':
      'الوقت والفني',
  'When the visit happens and who is going.':
      'موعد الزيارة ومن سيذهب إليها.',
  'The job':
      'العمل',
  'The service and what needs to be done.':
      'الخدمة وما يجب إنجازه.',
  'Job notes':
      'ملاحظات العمل',
  'The problem description and the notes for this visit.':
      'وصف المشكلة وملاحظات هذه الزيارة.',
  'Proof photos':
      'صور الإثبات',
  'Before and after pictures taken on site.':
      'صور ما قبل العمل وبعده الملتقطة في الموقع.',
  'The invoice':
      'الفاتورة',
  'What is billed for this visit and what has been paid.':
      'المبلغ المفوتر لهذه الزيارة وما تم دفعه.',
  'Full history':
      'السجل الكامل',
  'Every change to this visit: who did it, when, and from where.':
      'كل تغيير على هذه الزيارة: من أجراه ومتى ومن أين.',
  'Your work: what is happening now and what comes next.':
      'عملك: ما يجري الآن وما يليه.',
  'Your day':
      'يومك',
  'How many visits are open and how many are today.':
      'عدد الزيارات المفتوحة وعدد زيارات اليوم.',
  'The visit you are travelling to or working on. Open it to continue.':
      'الزيارة التي تتجه إليها أو تعمل عليها. افتحها للمتابعة.',
  'Choose a list':
      'اختر قائمة',
  'Switch between open visits, today, completed and all.':
      'بدّل بين الزيارات المفتوحة وزيارات اليوم والمكتملة والجميع.',
  'The client, the job, the time and your next step. Tap it to open.':
      'العميل والعمل والوقت وخطوتك التالية. اضغط عليها لفتحها.',
  'Every invoice and how much of it has been paid.':
      'كل فاتورة والمبلغ المدفوع منها.',
  'Find an invoice':
      'ابحث عن فاتورة',
  'One invoice':
      'فاتورة واحدة',
  'Its client, amount and payment status. Tap it to open.':
      'عميلها ومبلغها وحالة دفعها. اضغط عليها لفتحها.',
  'What was billed, what was paid and what is still owed.':
      'ما تمت فوترته وما تم دفعه وما زال مستحقًا.',
  'Invoice status':
      'حالة الفاتورة',
  'The invoice number and whether it is paid.':
      'رقم الفاتورة وهل تم دفعها.',
  'Customer and visit':
      'العميل والزيارة',
  'Who this invoice is for and the visit it belongs to.':
      'صاحب هذه الفاتورة والزيارة التابعة لها.',
  'The price, discount, tax and the total.':
      'السعر والخصم والضريبة والإجمالي.',
  'Every payment recorded on this invoice.':
      'كل دفعة مسجلة على هذه الفاتورة.',
  'What you can do':
      'ما يمكنك فعله',
  'Only the actions allowed for this invoice right now are shown.':
      'لا تظهر إلا الإجراءات المسموح بها لهذه الفاتورة حاليًا.',
  'Money technicians collected on site, waiting for you to confirm.':
      'المبالغ التي حصلها الفنيون في الموقع بانتظار تأكيدك.',
  'Waiting for you':
      'بانتظارك',
  'How many payments are waiting and their total.':
      'عدد الدفعات المنتظرة وإجماليها.',
  'One payment':
      'دفعة واحدة',
  'Check the amount and the receipt, then confirm or reject it. Rejecting needs a reason.':
      'تحقق من المبلغ والإيصال، ثم أكدها أو ارفضها. ويتطلب الرفض ذكر السبب.',
  'Your customers, their sites and their equipment.':
      'عملاؤك ومواقعهم ومعداتهم.',
  'Find a client':
      'ابحث عن عميل',
  'Search by name, phone or city.':
      'ابحث بالاسم أو الهاتف أو المدينة.',
  'One client':
      'عميل واحد',
  'Tap a client to see their details and visit history.':
      'اضغط على عميل لعرض بياناته وسجل زياراته.',
  'Add a client':
      'أضف عميلًا',
  'Add a new customer before booking their first visit.':
      'أضف عميلًا جديدًا قبل حجز زيارته الأولى.',
  'Client form':
      'بيانات العميل',
  'Save the details you need to reach and visit this client.':
      'احفظ البيانات اللازمة للوصول إلى هذا العميل وزيارته.',
  'Personal info':
      'البيانات الشخصية',
  'The client name. The email is optional.':
      'اسم العميل، والبريد الإلكتروني اختياري.',
  'Contact info':
      'بيانات التواصل',
  'The phone number, and whether it is on WhatsApp.':
      'رقم الهاتف، وهل هو مسجل في واتساب.',
  'The city and the exact place on the map.':
      'المدينة والموقع المحدد على الخريطة.',
  'Anything else your team should know.':
      'أي معلومات أخرى يجب أن يعرفها فريقك.',
  'Saves the client. Fields marked with * are required.':
      'يحفظ العميل. الحقول المميزة بعلامة * إلزامية.',
  'Everything you know about this client.':
      'كل ما تعرفه عن هذا العميل.',
  'Client profile':
      'ملف العميل',
  'Their name and how to contact them.':
      'اسمه وطريقة التواصل معه.',
  'The machines at this client, so the technician knows what to expect.':
      'الأجهزة الموجودة لدى هذا العميل، ليعرف الفني ما سيجده.',
  'Every visit made for this client.':
      'كل الزيارات التي تمت لهذا العميل.',
  'Update this client or remove them.':
      'حدّث بيانات هذا العميل أو احذفه.',
  'Your field team.':
      'فريقك الميداني.',
  'Find a technician':
      'ابحث عن فني',
  'Search by name, phone or specialty.':
      'ابحث بالاسم أو الهاتف أو التخصص.',
  'One technician':
      'فني واحد',
  'Tap a technician to see their details and visit history.':
      'اضغط على فني لعرض بياناته وسجل زياراته.',
  'Add a technician':
      'أضف فنيًا',
  'Create an account for a new member of your team.':
      'أنشئ حسابًا لعضو جديد في فريقك.',
  'Technician form':
      'بيانات الفني',
  'Add a team member and create their sign in.':
      'أضف عضوًا إلى الفريق وأنشئ بيانات دخوله.',
  'Their name':
      'الاسم',
  'The name your team and clients will see.':
      'الاسم الذي سيراه فريقك وعملاؤك.',
  'Their phone':
      'الهاتف',
  'The number used to reach them in the field.':
      'الرقم المستخدم للتواصل معه في الميدان.',
  'Sign in email':
      'بريد تسجيل الدخول',
  'The technician signs in with this email. Each technician needs a different one.':
      'يسجل الفني الدخول بهذا البريد، ولكل فني بريد مختلف.',
  'Sign in password':
      'كلمة مرور الدخول',
  'Share this password with the technician so they can sign in.':
      'شارك كلمة المرور هذه مع الفني ليتمكن من تسجيل الدخول.',
  'The types of work this technician can do.':
      'أنواع العمل التي يستطيع هذا الفني القيام بها.',
  'Saves the technician. Fields marked with * are required.':
      'يحفظ الفني. الحقول المميزة بعلامة * إلزامية.',
  'Everything about this member of your team.':
      'كل ما يخص هذا العضو في فريقك.',
  'Technician profile':
      'ملف الفني',
  'Their name, status and contact details.':
      'اسمه وحالته وبيانات التواصل معه.',
  'Every visit assigned to this technician.':
      'كل الزيارات المسندة إلى هذا الفني.',
  'Update this technician or remove them.':
      'حدّث بيانات هذا الفني أو احذفه.',
  'What you sell, with prices, durations and checklists.':
      'ما تقدمه من خدمات مع الأسعار والمدد وقوائم المهام.',
  'Find a service':
      'ابحث عن خدمة',
  'Search by service or category name.':
      'ابحث باسم الخدمة أو الفئة.',
  'One service':
      'خدمة واحدة',
  'Its category, price and duration.':
      'فئتها وسعرها ومدتها.',
  'Add a service':
      'أضف خدمة',
  'Add a service once, then pick it on any visit.':
      'أضف الخدمة مرة واحدة ثم اخترها في أي زيارة.',
  'Pick a location':
      'اختر موقعًا',
  'Find the exact place, then confirm it.':
      'حدد المكان بدقة ثم أكده.',
  'Type a place name to jump to it.':
      'اكتب اسم مكان للانتقال إليه.',
  'Move the map':
      'حرّك الخريطة',
  'Drag the map until the pin sits on the exact place.':
      'اسحب الخريطة حتى يستقر الدبوس على المكان المحدد.',
  'Check the address shown here, then confirm it.':
      'تحقق من العنوان المعروض هنا ثم أكده.',
  'View location':
      'عرض الموقع',
  'See exactly where this place is.':
      'اعرف مكان هذا الموقع بدقة.',
  'The map':
      'الخريطة',
  'The marker shows the saved place. You can move around freely.':
      'تشير العلامة إلى المكان المحفوظ، ويمكنك التنقل بحرية.',
  'Back to the marker':
      'العودة إلى العلامة',
  'Returns the map to the saved place.':
      'يعيد الخريطة إلى المكان المحفوظ.',
  'The address':
      'العنوان',
  'The address of this place.':
      'عنوان هذا المكان.',
  'Gives this visit to the technician shown here. Any rule it breaks, such as a time clash, is listed before you confirm.':
      'يسند هذه الزيارة إلى الفني المعروض هنا. وتظهر أي قاعدة تخالفها، مثل تعارض الوقت، قبل التأكيد.',
  'Review the plan for all the selected visits, then confirm to assign them together.':
      'راجع خطة جميع الزيارات المحددة، ثم أكد لإسنادها معًا.',
  'Moves the visits of this technician to other technicians.':
      'ينقل زيارات هذا الفني إلى فنيين آخرين.',
  'Pick a new date and time for this visit.':
      'اختر تاريخًا ووقتًا جديدين لهذه الزيارة.',
  'Set the rules the board checks on every assignment, such as matching the specialty.':
      'حدد القواعد التي تتحقق منها اللوحة عند كل إسناد، مثل مطابقة التخصص.',
  'Moves this visit to another status in its workflow.':
      'ينقل هذه الزيارة إلى حالة أخرى في مسار عملها.',
  'Technicians ranked from the best match down. Tap an available one to assign the visit.':
      'الفنيون مرتبون من الأنسب فالأقل. اضغط على فني متاح لإسناد الزيارة إليه.',
  'Takes the technician off this visit so it can be given to someone else.':
      'يزيل الفني من هذه الزيارة لتتمكن من إسنادها إلى غيره.',
  'The visits behind the number you tapped.':
      'الزيارات التي يمثلها الرقم الذي ضغطت عليه.',
  'A quick view of this visit and what you can do with it from the board.':
      'عرض سريع لهذه الزيارة وما يمكنك فعله بها من اللوحة.',
  'Choose the technician for this visit, or replace the current one.':
      'اختر فني هذه الزيارة، أو استبدل الفني الحالي.',
  'Records money received on site. It needs your location and a receipt photo, then the admin confirms it.':
      'يسجل المبلغ المستلم في الموقع. ويتطلب موقعك وصورة الإيصال، ثم يؤكده المسؤول.',
  'Adds a note to the visit activity log.':
      'يضيف ملاحظة إلى سجل نشاط الزيارة.',
  'Edit the job notes, and choose whether before and after photos are required.':
      'عدّل ملاحظات العمل، وحدد هل تلزم صور ما قبل العمل وبعده.',
  'Replaces the service on this visit.':
      'يستبدل الخدمة في هذه الزيارة.',
  'Changes the place where this visit happens.':
      'يغير مكان هذه الزيارة.',
  'Confirms moving this visit to its next status. Some changes ask for a reason.':
      'يؤكد نقل هذه الزيارة إلى حالتها التالية. وتتطلب بعض التغييرات ذكر السبب.',
  'Add or correct the place where the work happens for this client.':
      'أضف أو صحح مكان تنفيذ العمل لهذا العميل.',
  'Narrow the list by choosing one or more options in each group.':
      'ضيّق القائمة باختيار خيار واحد أو أكثر من كل مجموعة.',
  'Change the amounts while this invoice is still a draft.':
      'غيّر المبالغ ما دامت هذه الفاتورة مسودة.',
  'Records money received for this invoice, up to the remaining balance.':
      'يسجل المبلغ المستلم لهذه الفاتورة بحد أقصى الرصيد المتبقي.',
  'Returns money that was already paid on this invoice.':
      'يعيد مبلغًا سبق دفعه على هذه الفاتورة.',
  'Saves the price, duration and checklist, so you can pick this service on any visit.':
      'يحفظ السعر والمدة وقائمة المهام لتتمكن من اختيار هذه الخدمة في أي زيارة.',
  // --- Website: the guided scenario, the offer and the request -------------
  'For managing technicians and maintenance':
      'لإدارة الفنيين والصيانة',
  'Request a copy':
      'طلب نسخة',
  'The offer':
      'العرض',
  'More':
      'المزيد',
  'Details and pricing':
      'التفاصيل والأسعار',
  'Start the scenario again':
      'ابدأ السيناريو من جديد',
  'Explore a large sample company':
      'استكشف شركة تجريبية كبيرة',
  'You are exploring a large sample company. Use the menu to start the scenario again.':
      'أنت تستكشف شركة تجريبية كبيرة. استخدم القائمة لبدء السيناريو من جديد.',
  'Steps':
      'الخطوات',
  'Name and logo':
      'الاسم والشعار',
  'Any color you want':
      'أي لون تريده',
  'Your company or app name':
      'اسم شركتك أو تطبيقك',
  'Your design is back, as you left it.':
      'عاد تصميمك كما تركته.',
  'Clear':
      'مسح',
  'Clear your design':
      'مسح تصميمك',
  'Clear your design?':
      'هل تريد مسح تصميمك؟',
  'The app goes back to its original look.':
      'سيعود التطبيق إلى شكله الأصلي.',
  'Create a visit':
      'أنشئ زيارة',
  'Dispatch it to a technician':
      'أسندها إلى فني',
  'Open the dispatch board, go to the queue, select your visit and assign it to a technician.':
      'افتح لوحة التوزيع، وانتقل إلى قائمة الانتظار، وحدد زيارتك وأسندها إلى فني.',
  'Now be the technician':
      'كن الآن الفني',
  'The visit is on its way to the technician\'s phone. Sign in as them to see only their work.':
      'وصلت الزيارة إلى هاتف الفني. ادخل بحسابه لترى عمله فقط.',
  'Enter as technician':
      'ادخل كفني',
  'Start the trip':
      'ابدأ التنقل',
  'Open your visit and press "Start trip". Your location is recorded.':
      'افتح زيارتك واضغط «بدء التنقل». سيُسجَّل موقعك.',
  'Start the work':
      'ابدأ العمل',
  'Press "Start work". The app only allows it near the site; in this demo you count as being there.':
      'اضغط «بدء العمل». لا يسمح التطبيق بذلك إلا قرب الموقع، وفي هذه التجربة تُعد موجودًا فيه.',
  'Complete the visit':
      'أكمل الزيارة',
  'Press "Complete visit". The invoice is issued by itself.':
      'اضغط «إكمال الزيارة». ستصدر الفاتورة تلقائيًا.',
  'Back to the office':
      'عُد إلى المكتب',
  'The work is done. Go back as the admin and open the visit to see its proof, its history and its invoice.':
      'انتهى العمل. عُد بصفتك المسؤول وافتح الزيارة لترى إثباتها وسجلها وفاتورتها.',
  'Back to admin':
      'عودة إلى المسؤول',
  'You ran the whole cycle':
      'أتممت الدورة كاملة',
  'From the office to the field and back, with proof at every step. Now make it yours.':
      'من المكتب إلى الميدان ثم العودة، مع إثبات في كل خطوة. والآن اجعله تطبيقك.',
  'See the offer':
      'شاهد العرض',
  'First month free':
      'الشهر الأول مجانًا',
  'First {0} months free':
      'أول {0} أشهر مجانًا',
  'The first month':
      'الشهر الأول',
  'You have seen it work. Now make it yours.':
      'رأيته يعمل بنفسك، والآن اجعله تطبيقك.',
  'Less than a cup of coffee a month':
      'أقل من ثمن فنجان قهوة شهريًا',
  'No card and nothing to pay today':
      'بلا بطاقة، ولا شيء تدفعه اليوم',
  'Up to {0} users, with no fee per user':
      'حتى {0} مستخدمين، دون رسوم لكل مستخدم',
  'Setup, your colors and your logo are free':
      'الإعداد وألوانك وشعارك مجانًا',
  'Changes to your version are free within a limit':
      'التعديلات على نسختك مجانية ضمن حد معين',
  'Not convinced after the free month? Leave and pay nothing':
      'لم تقتنع بعد الشهر المجاني؟ غادر دون أن تدفع شيئًا',
  'Request your version now':
      'اطلب نسختك الآن',
  'Manage your technicians and maintenance from one app.':
      'أدِر الفنيين والصيانة من تطبيق واحد.',
  'Schedule visits, dispatch your technicians and get proof of every job: live location, photos and a clear record, in an app with your colors and your logo.':
      'جدول الزيارات، ووزّع فنييك، واحصل على إثبات لكل مهمة: موقع مباشر وصور وسجل واضح، في تطبيق بألوانك وشعارك.',
  'No sign-up and no card. Your design stays saved in this browser.':
      'بلا تسجيل ولا بطاقة. يبقى تصميمك محفوظًا في هذا المتصفح.',
  'Try the full cycle':
      'جرّب الدورة كاملة',
  'Follow one visit from start to finish, as the admin and then as the technician.':
      'تابع زيارة واحدة من بدايتها إلى نهايتها، بصفتك المسؤول ثم بصفتك الفني.',
  'Changes to your version':
      'التعديلات على نسختك',
  'Want something changed in your version? Write it in your request. Changes are free within a limit. If we find that what you ask for goes beyond it, it becomes a paid feature, and we agree on its price with you before any work starts.':
      'هل تريد تعديل شيء في نسختك؟ اكتبه في طلبك. التعديلات مجانية ضمن حد معين، وإذا وجدنا أن ما تطلبه يتجاوز هذا الحد فإنه يصبح ميزة مدفوعة، ونتفق معك على سعرها قبل بدء أي عمل.',
  'Changes to your version are free within a limit. If we find that what you ask for goes beyond it, it becomes a paid feature, and we agree on its price with you before any work starts.':
      'التعديلات على نسختك مجانية ضمن حد معين. وإذا وجدنا أن ما تطلبه يتجاوز هذا الحد فإنه يصبح ميزة مدفوعة، ونتفق معك على سعرها قبل بدء أي عمل.',
  'Free within a limit':
      'مجانًا ضمن حد معين',
  'Larger features':
      'الميزات الأكبر',
  'Paid, agreed first':
      'مدفوعة بعد الاتفاق',
  'No. {0}. We only ask for payment after that.':
      'لا. {0}، ولا نطلب الدفع إلا بعد ذلك.',
  'What do I pay after the free period?':
      'كم أدفع بعد الفترة المجانية؟',
  'Anything the app does not do today: a new field, a new report, a new screen or a connection to another system. Small changes are free within a limit; anything beyond it is a paid feature, and nothing is built before you agree on its price.':
      'كل ما لا يقوم به التطبيق اليوم: حقل جديد أو تقرير جديد أو شاشة جديدة أو ربط بنظام آخر. التعديلات الصغيرة مجانية ضمن حد معين، وما يتجاوزه يصبح ميزة مدفوعة، ولا ننفذ شيئًا قبل الاتفاق على سعره.',
  'The demo data starts again every time you open the page. Only your design is kept, in this browser, until you clear it. Nothing is sent until you press send on your request.':
      'تبدأ بيانات التجربة من جديد في كل مرة تفتح فيها الصفحة. ولا يُحفظ إلا تصميمك، في هذا المتصفح، إلى أن تمسحه. ولا يُرسل شيء حتى تضغط إرسال في طلبك.',
  'We have received your request':
      'استلمنا طلبك',
  'We are preparing your version and will deliver it to you. We will contact you very soon on {0}.':
      'نعمل على تجهيز نسختك وسنسلّمها لك، وسنتواصل معك قريبًا جدًا على {0}.',
  'Back to the app':
      'العودة إلى التطبيق',
  'What do you want changed in your version? (optional)':
      'ما الذي تريد تعديله في نسختك؟ (اختياري)',
  // --- Website: Wizpoo's guide ------------------------------------------------
  'Let us start':
      'لنبدأ',
  'Your help is always here':
      'مساعدتك دائمًا هنا',
  'I will walk you through the whole cycle: you book a visit as the admin, carry it out as the technician, then see the proof. Just press what I point at.':
      'سأرافقك في الدورة كاملة: تحجز زيارة بصفتك المسؤول، وتنفذها بصفتك الفني، ثم ترى الإثبات. ما عليك إلا الضغط على ما أشير إليه.',
  'See this small gold flag at the top? It is on every screen. Tap it anytime and I will explain everything on that screen.':
      'هل ترى هذا العلم الذهبي الصغير في الأعلى؟ إنه موجود في كل شاشة. اضغطه في أي وقت وسأشرح لك كل ما في تلك الشاشة.',
  'You are the admin. Press "New visit" on the dashboard. The form is already filled with sample data, so just press "Schedule".':
      'أنت الآن المسؤول. اضغط «زيارة جديدة» في لوحة التحكم. النموذج معبأ ببيانات تجريبية، فما عليك إلا الضغط على «جدولة».',
  'Press "New visit" to book a job.':
      'اضغط «زيارة جديدة» لحجز مهمة.',
  'I filled this in with sample data. Change anything you like, then press "Schedule".':
      'عبأت النموذج ببيانات تجريبية. غيّر ما تشاء، ثم اضغط «جدولة».',
  'Your new visit is waiting in the queue. Open the queue.':
      'زيارتك الجديدة تنتظر في قائمة الانتظار. افتح القائمة.',
  'Let the app pick: press "Suggest technician".':
      'دع التطبيق يختار: اضغط «اقتراح فني».',
  'This technician fits best. Tap their name.':
      'هذا الفني هو الأنسب. اضغط على اسمه.',
  'Press "Assign" to send it to their phone.':
      'اضغط «إسناد» لإرسالها إلى هاتفه.',
  'Open your visit.':
      'افتح زيارتك.',
  'Press "Start trip".':
      'اضغط «بدء التنقل».',
  'Press "Start work".':
      'اضغط «بدء العمل».',
  'Press "Complete visit".':
      'اضغط «إكمال الزيارة».',
  'Press "Confirm". The time and your location are saved as proof.':
      'اضغط «تأكيد». سيُحفظ الوقت وموقعك كإثبات.',
  'Great job!':
      'أحسنت!',
  'Step {0} of {1}':
      'الخطوة {0} من {1}',
  'Hide':
      'إخفاء',
  'Design your app':
      'صمّم تطبيقك',
  // --- Website: the review round ----------------------------------------------
  'Collect the payment':
      'تحصيل الدفعة في الموقع',
  'If the client pays now, the technician records it with a receipt photo and it waits for the admin to confirm. Open your visit and press "Collect payment".':
      'إذا دفع العميل الآن، يسجل الفني الدفعة مع صورة الإيصال، وتنتظر تأكيد المسؤول. افتح زيارتك واضغط «تحصيل الدفعة».',
  'Skip this step':
      'تخطي هذه الخطوة',
  'The work is done. Go back as the admin and I will open this visit, so you can see its proof and its invoice.':
      'انتهى العمل. عُد بصفتك المسؤول وسأفتح لك هذه الزيارة لترى إثباتها وفاتورتها.',
  'The proof reaches the office':
      'الإثبات يصل إلى المكتب',
  'This is what you get with every visit: who did the work, at what time and how far from the site.':
      'هذا ما يصلك مع كل زيارة: من نفذ العمل، وفي أي وقت، وعلى أي بُعد من الموقع.',
  'See the invoice':
      'عرض الفاتورة',
  'The invoice is ready':
      'الفاتورة جاهزة',
  'The invoice was issued by itself when the work ended. Money the technician collected waits here for your confirmation.':
      'صدرت الفاتورة تلقائيًا عند انتهاء العمل، وما حصّله الفني ينتظر تأكيدك هنا.',
  'Open the visit':
      'فتح الزيارة',
  'Tick this box to share your location. I will ask you only this once.':
      'حدد هذا المربع لمشاركة موقعك. لن أطلب منك ذلك إلا هذه المرة.',
  'The client is paying now. Press "Collect payment".':
      'العميل يدفع الآن. اضغط «تحصيل الدفعة».',
  'I attached a sample receipt. Press "Send to admin".':
      'أرفقت إيصالًا تجريبيًا. اضغط «إرسال إلى المسؤول».',
  'I agree to share my live location with the admin on every visit action.':
      'أوافق على مشاركة موقعي المباشر مع المسؤول عند كل إجراء في الزيارة.',
  'You agreed to share your location.':
      'وافقت على مشاركة موقعك.',
  'Withdraw':
      'سحب الموافقة',
  'Always require before-work photos':
      'صور قبل العمل إلزامية دائمًا',
  'Always require after-work photos':
      'صور بعد العمل إلزامية دائمًا',
  '{0} SAR':
      '{0} ر.س',
  'every {0} months for the whole company':
      'كل {0} أشهر للشركة كاملة',
  'For the whole company, not per user.':
      'للشركة كاملة، لا لكل مستخدم.',
  '{0}, then {1} every {2} months for the whole company. Up to {3} users and {4} GB of photos. Delivered as a PWA on a private link. Changes to your version are free within a limit; anything beyond it is a paid feature we agree on first.':
      '{0}، ثم {1} كل {2} أشهر للشركة كاملة. حتى {3} مستخدمين و{4} جيجابايت للصور. يصلك التطبيق على رابط خاص ويُثبَّت على الهاتف. التعديلات على نسختك مجانية في حدود معينة، وما زاد عليها يكون ميزة مدفوعة نتفق عليها أولًا.',
  'Prices in Saudi riyals. The demo runs only in your browser.':
      'الأسعار بالريال السعودي. تعمل النسخة التجريبية في متصفحك فقط.',
  'Font: {0}':
      'الخط: {0}',
  'Send it to us on WhatsApp too':
      'أرسله إلينا عبر واتساب أيضًا',
  'I requested my version of Visit Proof.\nName: {0}\nCompany: {1}\nPhone: {2}':
      'طلبت نسختي من Visit Proof.\nالاسم: {0}\nالشركة: {1}\nالهاتف: {2}',
  'Privacy policy':
      'سياسة الخصوصية',
  'Terms of service':
      'شروط الاستخدام',
  'What we collect':
      'البيانات التي نجمعها',
  'When you request your version, we receive your name, company, phone number, email if you give it, the changes you ask for and the design you made. The website asks for nothing else.':
      'عند طلب نسختك نتلقى اسمك وشركتك ورقم هاتفك وبريدك الإلكتروني إن أدخلته والتعديلات التي تطلبها والتصميم الذي أعددته. ولا يطلب الموقع شيئًا غير ذلك.',
  'The demo':
      'النسخة التجريبية',
  'What you type in the demo stays in your browser and starts again when you reopen the page. Your design is kept in this browser until you clear it.':
      'ما تكتبه في النسخة التجريبية يبقى في متصفحك ويبدأ من جديد عند إعادة فتح الصفحة. ويُحفظ تصميمك في هذا المتصفح حتى تمسحه.',
  'Why we use it':
      'الغرض من استخدامها',
  'Only to contact you, prepare your version and support you. We do not sell it or share it for advertising.':
      'نستخدمها فقط للتواصل معك وإعداد نسختك ودعمك، ولا نبيعها ولا نشاركها لأغراض الإعلان.',
  'Inside the app':
      'داخل التطبيق',
  'Each technician agrees once before the app shares their location. After that, their location and proof photos are recorded with each action on a visit, for their company only. A technician can withdraw this from any action screen, but actions that need a location will wait until they agree again.':
      'يوافق كل فني مرة واحدة قبل أن يشارك التطبيق موقعه. وبعد ذلك يُسجَّل موقعه وصور الإثبات مع كل إجراء في الزيارة، ولا تطلع عليها إلا شركته. ويمكن للفني سحب موافقته من أي شاشة إجراء، على أن تتوقف الإجراءات التي تتطلب الموقع حتى يوافق مجددًا.',
  'How long we keep it':
      'مدة الاحتفاظ بها',
  'We keep your details while we serve you. If a period is not renewed, your app stays readable for {0} days so you can take your data, then it is deleted after a reminder.':
      'نحتفظ ببياناتك ما دمنا نقدم لك الخدمة. وإذا لم تُجدَّد المدة يبقى تطبيقك متاحًا للقراءة {0} يومًا لتأخذ بياناتك، ثم تُحذف بعد تذكيرك.',
  'Your rights':
      'حقوقك',
  'You can ask us at any time to show, correct, export or delete your data.':
      'يمكنك أن تطلب منا في أي وقت عرض بياناتك أو تصحيحها أو تصديرها أو حذفها.',
  'Contact us':
      'تواصل معنا',
  'Reach us on WhatsApp or through the contact details you received from us.':
      'تواصل معنا عبر واتساب أو عبر بيانات التواصل التي وصلتك منا.',
  'The service':
      'الخدمة',
  'Visit Proof is an app for managing technicians and maintenance visits, delivered on a private web link with your design.':
      'Visit Proof تطبيق لإدارة الفنيين وزيارات الصيانة، يصلك على رابط خاص بتصميمك.',
  'Price and payment':
      'السعر والدفع',
  '{0}, then {1} every {2} months for the whole company, up to {3} users and {4} GB of photos. Nothing is charged before you agree.':
      '{0}، ثم {1} كل {2} أشهر للشركة كاملة، حتى {3} مستخدمين و{4} جيجابايت للصور. ولا يُحصَّل أي مبلغ قبل موافقتك.',
  'Renewing and stopping':
      'التجديد والإيقاف',
  'There is no long contract. You renew every {0} months. If you stop, the app stays readable for {1} days so you can take your data, then it is deleted after a reminder.':
      'لا يوجد عقد طويل، وتجدد كل {0} أشهر. وإذا توقفت يبقى التطبيق متاحًا للقراءة {1} يومًا لتأخذ بياناتك، ثم تُحذف بعد تذكيرك.',
  'Changes are free within a limit. Anything beyond it is a paid feature, and nothing is built before you agree on its price.':
      'التعديلات مجانية في حدود معينة، وما زاد عليها يكون ميزة مدفوعة، ولا يُنفَّذ شيء قبل موافقتك على سعره.',
  'Your data':
      'بياناتك',
  'Your data stays yours, and we export it for you whenever you ask. You are responsible for telling your technicians that their location and photos are recorded.':
      'بياناتك ملك لك، ونصدّرها لك متى طلبت. وتقع عليك مسؤولية إبلاغ فنييك بأن مواقعهم وصورهم تُسجَّل.',
  'Availability':
      'توفر الخدمة',
  'We work to keep the service running and backed up, but we cannot promise it will never be interrupted.':
      'نعمل على استمرار الخدمة وحفظ نسخ احتياطية منها، لكننا لا نضمن عدم انقطاعها مطلقًا.',
  'Updates to these terms':
      'تحديث هذه الشروط',
  'We may update these terms, and we will tell you before any change that affects your price.':
      'قد نحدّث هذه الشروط، وسنخبرك قبل أي تغيير يؤثر في سعرك.',
};
