import 'dart:convert';
import 'dart:math';

import 'package:visit_proof/configs/app_language.dart';

import '../../app/app.dart';
import '../../features/clients/data/models/client_detail_model/client_detail_model.dart';
import '../../features/invoices/data/models/invoice_detail_model.dart';
import '../../features/invoices/data/models/invoice_payment_history_model.dart';
import '../../features/services/data/models/service_model.dart';
import '../../features/technicians/data/models/technician_detail_model.dart';
import '../../features/visits/data/models/visit_detail_models/visit_client_model.dart';
import '../../features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../features/visits/data/models/visit_detail_models/visit_history_model.dart';
import '../local/local_pref.dart';
import '../local/company_settings.dart';
import '../utils/enums/payment_entry_status_enum.dart';
import '../utils/enums/payment_method_enum.dart';
import '../utils/enums/payment_status_enum.dart';
import '../utils/enums/priority_enum.dart';
import '../utils/enums/technician_status_enum.dart';
import '../utils/enums/visit_status_enum.dart';
import '../utils/general_dummy_data.dart';
import '../utils/general_models/g_model_catg.dart';
import '../utils/general_models/g_model_equipment.dart';
import '../utils/general_models/g_model_geo_point.dart';
import '../utils/general_models/g_model_site.dart';

/// A large sample HVAC company for testing: 8 technicians, 24 clients and
/// about 200 visits from a month ago to two weeks ahead, in every status,
/// with invoices that are unpaid, paid, partly paid or waiting for the
/// admin to confirm a field collection.
///
/// Written straight to local storage in the JSON the data sources read.
/// Names and texts follow the app language when the data is created. The
/// same random seed gives the same company every time.
class DemoSeed {
  DemoSeed._();

  /// The demo technician's sign-in, shown on the website.
  static const String technicianEmail = 'ahmed@demo.com';
  static const String technicianPassword = '123456';

  static const String _demoTechnicianId = 'demo-tech-1';

  static Future<void> run() =>
      _save(_DemoCompany(Random(7), DateTime.now()).build());

  /// The website's guided scenario: a company with its finished past work,
  /// so the app looks alive, and nothing open, so the visitor's own visit is
  /// the only one waiting.
  static Future<void> runScenario() =>
      _save(_DemoCompany(Random(7), DateTime.now()).buildScenario());

  /// Who "Switch to technician" opens in test builds, with no sign-in: the
  /// technician on the newest open visit, or else the first one.
  static TechnicianDetailModel? technicianToTry() {
    final prefs = LocalPref.sharedPreferences;
    final technicians = (prefs.getStringList('technicians') ?? const [])
        .map((e) => TechnicianDetailModel.fromJson(jsonDecode(e)))
        .where((e) => e.email != null && e.password != null)
        .toList();
    if (technicians.isEmpty) return null;
    const open = {
      VisitStatus.assigned,
      VisitStatus.onWay,
      VisitStatus.inProgress,
    };
    final visits = (prefs.getStringList('visits') ?? const [])
        .map((e) => VisitDetailModel.fromJson(jsonDecode(e)));
    for (final visit in visits) {
      if (!open.contains(visit.status)) continue;
      final person = technicians
          .where((e) => e.id == visit.technicianModel?.id)
          .firstOrNull;
      if (person != null) return person;
    }
    return technicians.first;
  }

  /// A sample number, in the format of a Saudi VAT number.
  static const String _vatNumber = '300000000000003';

  static Future<void> _save(_DemoData data) async {
    await CompanySettings.setVatNumber(_vatNumber);
    final prefs = LocalPref.sharedPreferences;
    String encode(Map<String, dynamic> json) => jsonEncode(json);

    await prefs.setStringList(
        'categories', data.categories.map((e) => encode(e.toJson())).toList());
    await prefs.setStringList(
        'services', data.services.map((e) => encode(e.toJson())).toList());
    await prefs.setStringList(
        'technicians', data.technicians.map((e) => encode(e.toJson())).toList());
    await prefs.setStringList(
        'clients', data.clients.map((e) => encode(e.toJson())).toList());
    // Newest first, as the add-visit flow stores them.
    await prefs.setStringList(
        'visits', data.visits.reversed.map((e) => encode(e.toJson())).toList());
    await prefs.setStringList('invoices',
        data.invoices.reversed.map((e) => encode(e.toJson())).toList());
    await prefs.setStringList('invoice_payments',
        data.payments.map((e) => encode(e.toJson())).toList());
  }
}

/// English or Arabic, by the language the app starts in.
String _t(String english, String arabic) =>
    AppLanguage.isArabic ? arabic : english;

class _DemoData {
  final categories = <GModelCatg>[];
  final services = <ServiceModel>[];
  final technicians = <TechnicianDetailModel>[];
  final clients = <ClientDetailModel>[];
  final visits = <VisitDetailModel>[];
  final invoices = <InvoiceDetailModel>[];
  final payments = <InvoicePaymentHistoryModel>[];
}

class _DemoCompany {
  _DemoCompany(this.random, DateTime now)
      : today = DateTime(now.year, now.month, now.day);

  final Random random;
  final DateTime today;
  final data = _DemoData();
  int _number = 0;

  late final VisitHistoryActorModel admin = VisitHistoryActorModel(
      id: 'local-admin', name: 'Local Admin'.tr, role: 'admin');

  static const int _scenarioVisits = 30;

  bool chance(double probability) => random.nextDouble() < probability;
  T pick<T>(List<T> items) => items[random.nextInt(items.length)];

  _DemoData build() {
    _categoriesAndServices();
    _technicians();
    _clients();
    _visits();
    return data;
  }

  _DemoData buildScenario() {
    build();
    final past = data.visits
        .where((visit) =>
            (visit.status == VisitStatus.completed ||
                visit.status == VisitStatus.cancel) &&
            visit.startDate != null &&
            visit.startDate!.isBefore(today))
        .toList();
    final kept = past.sublist(max(0, past.length - _scenarioVisits));
    final invoiceIds = kept.map((visit) => visit.invoiceID).toSet();
    data.visits
      ..clear()
      ..addAll(kept);
    data.invoices.retainWhere((invoice) => invoiceIds.contains(invoice.id));
    data.payments
        .retainWhere((payment) => invoiceIds.contains(payment.invoiceId));
    return data;
  }

  // ===========================================================================
  // CATALOG
  // ===========================================================================

  // Category names stay in English: the app translates them when shown.
  static const _hvac = GModelCatg(id: 'demo-cat-hvac', name: 'HVAC');
  static const _electrical =
      GModelCatg(id: 'demo-cat-elec', name: 'Electrical');
  static const _plumbing = GModelCatg(id: 'demo-cat-plumb', name: 'Plumbing');
  static const _carpentry =
      GModelCatg(id: 'demo-cat-carp', name: 'Carpentry');
  static const _networking =
      GModelCatg(id: 'demo-cat-net', name: 'Networking');
  static const _smartHome =
      GModelCatg(id: 'demo-cat-smart', name: 'Smart Home');

  void _categoriesAndServices() {
    data.categories.addAll(
        [_hvac, _electrical, _plumbing, _carpentry, _networking, _smartHome]);

    ServiceModel service(String id, GModelCatg category, String en, String ar,
            num price, int minutes, List<(String, String)> checklist) =>
        ServiceModel(
          id: id,
          category: category,
          serviceName: _t(en, ar),
          defaultPrice: price,
          duration: minutes,
          checkList: [for (final item in checklist) _t(item.$1, item.$2)],
        );

    data.services.addAll([
      service('demo-srv-1', _hvac, 'AC periodic maintenance',
          'صيانة دورية للمكيف', 250, 60, [
        ('Clean filters', 'تنظيف الفلاتر'),
        ('Check refrigerant pressure', 'فحص ضغط غاز التبريد'),
        ('Clean drain line', 'تنظيف خط التصريف'),
        ('Test thermostat', 'اختبار منظم الحرارة'),
      ]),
      service('demo-srv-2', _hvac, 'AC fault repair', 'إصلاح عطل مكيف', 400,
          90, [
        ('Diagnose the fault', 'تشخيص العطل'),
        ('Replace faulty part', 'استبدال القطعة التالفة'),
        ('Test cooling', 'اختبار التبريد'),
      ]),
      service('demo-srv-3', _hvac, 'Split AC installation',
          'تركيب مكيف سبليت', 650, 180, [
        ('Mount indoor unit', 'تثبيت الوحدة الداخلية'),
        ('Mount outdoor unit', 'تثبيت الوحدة الخارجية'),
        ('Vacuum and charge', 'تفريغ الهواء وشحن الغاز'),
        ('Commissioning test', 'اختبار التشغيل'),
      ]),
      service('demo-srv-4', _hvac, 'AC deep cleaning', 'تنظيف عميق للمكيف',
          300, 90, [
        ('Wash the coil', 'غسيل الملف'),
        ('Clean the fan', 'تنظيف المروحة'),
        ('Sanitize the unit', 'تعقيم الوحدة'),
      ]),
      service('demo-srv-5', _hvac, 'Central AC inspection',
          'فحص التكييف المركزي', 500, 120, [
        ('Check ducts', 'فحص مجاري الهواء'),
        ('Measure airflow', 'قياس تدفق الهواء'),
        ('Check the compressor', 'فحص الضاغط'),
      ]),
      service('demo-srv-6', _electrical, 'Electrical panel inspection',
          'فحص اللوحة الكهربائية', 300, 60, [
        ('Check breakers', 'فحص القواطع'),
        ('Thermal check', 'الفحص الحراري'),
        ('Tighten terminals', 'شد أطراف التوصيل'),
      ]),
      service('demo-srv-7', _electrical, 'Lighting installation',
          'تركيب الإنارة', 220, 90, [
        ('Install fixtures', 'تركيب وحدات الإنارة'),
        ('Test circuits', 'اختبار الدوائر'),
      ]),
      service('demo-srv-8', _plumbing, 'Water leak repair', 'إصلاح تسريب مياه',
          200, 60, [
        ('Locate the leak', 'تحديد مكان التسريب'),
        ('Repair', 'الإصلاح'),
        ('Pressure test', 'اختبار الضغط'),
      ]),
      service('demo-srv-9', _plumbing, 'Water heater service',
          'صيانة سخان المياه', 180, 60, [
        ('Check the element', 'فحص عنصر التسخين'),
        ('Flush the tank', 'تنظيف الخزان'),
      ]),
      service('demo-srv-10', _carpentry, 'Door and cabinet repair',
          'إصلاح الأبواب والخزائن', 150, 60, [
        ('Fix hinges', 'إصلاح المفصلات'),
        ('Adjust doors', 'ضبط الأبواب'),
      ]),
      service('demo-srv-11', _networking, 'Network cabling', 'تمديد شبكة',
          450, 150, [
        ('Run cables', 'تمديد الكابلات'),
        ('Terminate and label', 'تركيب الأطراف والترقيم'),
        ('Speed test', 'اختبار السرعة'),
      ]),
      service('demo-srv-12', _smartHome, 'Smart thermostat setup',
          'تركيب منظم حرارة ذكي', 350, 60, [
        ('Install the device', 'تركيب الجهاز'),
        ('Connect to the app', 'الربط بالتطبيق'),
      ]),
    ]);
  }

  // ===========================================================================
  // PEOPLE
  // ===========================================================================

  void _technicians() {
    const people = [
      ('Ahmed Saleh', 'أحمد صالح', DemoSeed.technicianEmail, [_hvac]),
      ('Omar Khalid', 'عمر خالد', 'omar@demo.com', [_hvac, _electrical]),
      ('Youssef Ali', 'يوسف علي', 'youssef@demo.com', [_plumbing]),
      ('Fahad Alqahtani', 'فهد القحطاني', 'fahad@demo.com', [_hvac]),
      ('Khalid Alharbi', 'خالد الحربي', 'khalid@demo.com', [_electrical, _smartHome]),
      ('Saad Alotaibi', 'سعد العتيبي', 'saad@demo.com', [_hvac, _plumbing]),
      ('Majed Alzahrani', 'ماجد الزهراني', 'majed@demo.com', [_networking, _electrical]),
      ('Nasser Alshehri', 'ناصر الشهري', 'nasser@demo.com', [_carpentry, _plumbing]),
    ];
    for (var i = 0; i < people.length; i++) {
      final person = people[i];
      data.technicians.add(TechnicianDetailModel(
        id: 'demo-tech-${i + 1}',
        name: _t(person.$1, person.$2),
        phone: '96650${(1234567 + i * 111111).toString().padLeft(7, '0')}',
        email: person.$3,
        password: DemoSeed.technicianPassword,
        status: i == 7 ? TechnicianStatus.offline : TechnicianStatus.available,
        categories: person.$4,
      ));
    }
  }

  void _clients() {
    final cities = GeneralDummyData.getSaudiCities();
    GModelCatg city(String name) =>
        cities.firstWhere((e) => e.name == name, orElse: () => cities.first);

    const places = [
      ('Riyadh', 24.7136, 46.6753),
      ('Riyadh', 24.7743, 46.7386),
      ('Riyadh', 24.6408, 46.7728),
      ('Jeddah', 21.5433, 39.1728),
      ('Dammam', 26.4207, 50.0888),
      ('Khobar', 26.2172, 50.1971),
      ('Makkah', 21.3891, 39.8579),
      ('Madinah', 24.5247, 39.5692),
    ];
    const streets = [
      ('King Fahd Rd', 'طريق الملك فهد'),
      ('Olaya St', 'شارع العليا'),
      ('Prince Sultan St', 'شارع الأمير سلطان'),
      ('Tahlia St', 'شارع التحلية'),
      ('King Abdulaziz Rd', 'طريق الملك عبدالعزيز'),
      ('Al Imam Saud St', 'شارع الإمام سعود'),
    ];
    const names = [
      ('Al Noor Pharmacy', 'صيدلية النور'),
      ('Green Valley Restaurant', 'مطعم الوادي الأخضر'),
      ('Sara Villa', 'فيلا سارة'),
      ('Bright Office Tower', 'برج المكاتب المضيء'),
      ('Al Safa Clinic', 'عيادة الصفا'),
      ('Riyadh Gate Mall', 'مول بوابة الرياض'),
      ('Al Yamamah School', 'مدارس اليمامة'),
      ('Najd Bakery', 'مخبز نجد'),
      ('Al Rawda Apartments', 'شقق الروضة'),
      ('Coastal Hotel', 'فندق الساحل'),
      ('Al Hamra Gym', 'نادي الحمراء الرياضي'),
      ('Faisal Residence', 'منزل فيصل'),
      ('Desert Rose Café', 'مقهى وردة الصحراء'),
      ('Al Qimma Warehouse', 'مستودع القمة'),
      ('Sunrise Dental Center', 'مركز الشروق لطب الأسنان'),
      ('Al Madina Bookstore', 'مكتبة المدينة'),
      ('Golden Palm Compound', 'مجمع النخلة الذهبية'),
      ('Al Fursan Car Service', 'مركز الفرسان لصيانة السيارات'),
      ('Al Amal Kindergarten', 'روضة الأمل'),
      ('Noura Apartment', 'شقة نورة'),
      ('Eastern Steel Workshop', 'ورشة الحديد الشرقية'),
      ('Al Bayan Office', 'مكتب البيان'),
      ('Lotus Beauty Salon', 'صالون اللوتس'),
      ('Al Waha Supermarket', 'سوبرماركت الواحة'),
    ];
    const machines = [
      ('Split AC 24,000 BTU', 'Gree', 'GWH24'),
      ('Split AC 18,000 BTU', 'LG', 'S4-Q18'),
      ('Window AC', 'Carrier', 'QCW-18'),
      ('Water heater 80 L', 'Ariston', 'PRO-80'),
      ('Central AC unit', 'York', 'YC-60'),
    ];

    for (var i = 0; i < names.length; i++) {
      final place = places[i % places.length];
      // Every fifth client has no map pin, to show the "no coordinates" case.
      final pinned = i % 5 != 2;
      final street = streets[i % streets.length];
      data.clients.add(ClientDetailModel(
        id: 'demo-client-${i + 1}',
        name: _t(names[i].$1, names[i].$2),
        phone: '96655${(1000000 + i * 37373).toString().padLeft(7, '0')}',
        isWhatsAppPhone: i % 3 != 1,
        email: i % 2 == 0 ? 'contact${i + 1}@client.demo' : null,
        site: GModelSite(
          city: city(place.$1),
          addressDetail:
              '${_t(street.$1, street.$2)}, ${_t('Building', 'مبنى')} ${10 + i * 3}',
          latitude: pinned
              ? place.$2 + (random.nextDouble() - .5) * .08
              : null,
          longitude: pinned
              ? place.$3 + (random.nextDouble() - .5) * .08
              : null,
        ),
        notes: i % 4 == 0
            ? _t('Call before arriving.', 'يرجى الاتصال قبل الوصول.')
            : null,
        equipments: [
          for (var e = 0; e < 1 + i % 3; e++)
            GModelEquipment(
              id: 'demo-eq-$i-$e',
              name: machines[(i + e) % machines.length].$1,
              brand: machines[(i + e) % machines.length].$2,
              model: machines[(i + e) % machines.length].$3,
              serialNumber: 'SN-${2400 + i * 13 + e}',
            ),
        ],
      ));
    }
  }

  // ===========================================================================
  // VISITS
  // ===========================================================================

  static const _problems = [
    ('The AC is not cooling.', 'المكيف لا يبرد.'),
    ('Water is dripping from the indoor unit.',
        'تسريب مياه من الوحدة الداخلية.'),
    ('Strange noise from the outdoor unit.',
        'صوت غير طبيعي من الوحدة الخارجية.'),
    ('The breaker trips often.', 'القاطع يفصل باستمرار.'),
    ('Leak under the kitchen sink.', 'تسريب تحت مغسلة المطبخ.'),
    ('No hot water.', 'لا توجد مياه ساخنة.'),
    ('Slow internet in the office.', 'بطء الإنترنت في المكتب.'),
  ];

  static const _slots = [8, 10, 12, 14, 16];

  void _visits() {
    final techs = data.technicians.where((t) => t.status != TechnicianStatus.offline).toList();
    final ahmed = data.technicians.first;

    // The demo technician's day: one visit at each step he can take.
    _visit(
        start: _at(0, 15),
        status: VisitStatus.assigned,
        technician: ahmed,
        client: data.clients[0],
        service: data.services[0],
        afterPhotos: true);
    _visit(
        start: _at(0, 11),
        status: VisitStatus.onWay,
        technician: ahmed,
        client: data.clients[1],
        service: data.services[1],
        priority: Priority.high);
    _visit(
        start: _at(0, 9),
        status: VisitStatus.inProgress,
        technician: ahmed,
        client: data.clients[3],
        service: data.services[0]);
    _visit(
        start: _at(-1, 10),
        status: VisitStatus.completed,
        technician: ahmed,
        client: data.clients[0],
        service: data.services[1],
        payment: _Payment.unpaid);

    for (var day = -30; day <= 14; day++) {
      final date = today.add(Duration(days: day));
      final weekend = date.weekday == DateTime.friday;
      final count = weekend ? 1 + random.nextInt(2) : 3 + random.nextInt(4);
      // Each technician takes a different slot so nobody is double booked.
      final freeSlots = <String, List<int>>{
        for (final tech in techs)
          tech.id!: [
            for (final hour in _slots)
              // Ahmed's fixed visits above keep their hours today.
              if (!(tech.id == DemoSeed._demoTechnicianId &&
                  (day == 0 || day == -1)))
                hour
          ],
      };

      for (var n = 0; n < count; n++) {
        final client = pick(data.clients);
        final service = pick(data.services);
        final tech = pick(techs);
        final slots = freeSlots[tech.id]!;
        final hour = slots.isEmpty ? 8 + random.nextInt(9) : slots.removeAt(random.nextInt(slots.length));
        final start = _at(day, hour);

        final status = _statusFor(day, hour);
        final assigned = status != VisitStatus.draft &&
            status != VisitStatus.scheduled &&
            !(status == VisitStatus.cancel && chance(.5));

        _visit(
          start: start,
          status: status,
          technician: assigned ? tech : null,
          client: client,
          service: service,
          priority: chance(.08)
              ? Priority.emergency
              : chance(.2)
                  ? Priority.high
                  : chance(.2)
                      ? Priority.low
                      : Priority.normal,
          afterPhotos: chance(.25),
          payment: status == VisitStatus.completed ? _paymentFor() : _Payment.unpaid,
        );
      }
    }
  }

  VisitStatus _statusFor(int day, int hour) {
    if (day < 0) {
      if (chance(.08)) return VisitStatus.cancel;
      return VisitStatus.completed;
    }
    if (day == 0) {
      final now = DateTime.now().hour;
      if (hour + 2 <= now) return chance(.85) ? VisitStatus.completed : VisitStatus.inProgress;
      if (hour <= now) return chance(.5) ? VisitStatus.inProgress : VisitStatus.onWay;
      return chance(.8) ? VisitStatus.assigned : VisitStatus.scheduled;
    }
    if (chance(.05)) return VisitStatus.cancel;
    if (day <= 3) return chance(.7) ? VisitStatus.assigned : VisitStatus.scheduled;
    final roll = random.nextDouble();
    if (roll < .45) return VisitStatus.assigned;
    if (roll < .8) return VisitStatus.scheduled;
    return VisitStatus.draft;
  }

  _Payment _paymentFor() {
    final roll = random.nextDouble();
    if (roll < .55) return _Payment.paid;
    if (roll < .70) return _Payment.partial;
    if (roll < .80) return _Payment.fieldCollection;
    return _Payment.unpaid;
  }

  DateTime _at(int day, int hour) =>
      today.add(Duration(days: day, hours: hour));

  /// A point a little way from the site, as a technician's GPS would read.
  GModelGeoPoint? _near(GModelSite? site, DateTime at, {double meters = 30}) {
    if (site?.latitude == null || site?.longitude == null) return null;
    final offset = meters / 111000;
    return GModelGeoPoint(
      latitude: site!.latitude! + (random.nextDouble() - .5) * offset,
      longitude: site.longitude! + (random.nextDouble() - .5) * offset,
      accuracy: 6 + random.nextInt(15).toDouble(),
      capturedAt: at,
    );
  }

  void _visit({
    required DateTime start,
    required VisitStatus status,
    required ClientDetailModel client,
    required ServiceModel service,
    TechnicianDetailModel? technician,
    Priority priority = Priority.normal,
    bool afterPhotos = false,
    _Payment payment = _Payment.unpaid,
  }) {
    _number++;
    final id = 'demo-visit-$_number';
    final invoiceId = 'demo-invoice-$_number';
    final visitNumber = 'VIS-${_number.toString().padLeft(6, '0')}';
    final invoiceNumber = 'INV-${_number.toString().padLeft(6, '0')}';
    final price = service.defaultPrice ?? 0;
    final netCents = (price * 100).round();
    final taxCents = CompanySettings.vatCents(netCents);
    final cents = netCents + taxCents;
    final created = start.subtract(Duration(days: 2 + random.nextInt(5)));
    final site = client.site;
    final techActor = technician == null
        ? null
        : VisitHistoryActorModel(
            id: technician.id, name: technician.name, role: 'technician');

    final history = <VisitHistoryModel>[];
    void log(String text, DateTime at, VisitHistoryActorModel actor,
        {GModelGeoPoint? location, String? reason}) {
      history.add(VisitHistoryModel(
        id: '$id-h${history.length + 1}',
        visitId: id,
        recordedAt: at,
        actor: actor,
        description: text,
        reason: reason,
        location: location,
      ));
    }

    log('Visit created'.tr, created, admin);

    const steps = [
      VisitStatus.assigned,
      VisitStatus.onWay,
      VisitStatus.inProgress,
      VisitStatus.completed,
    ];
    String statusText(VisitStatus s) =>
        VisitStatusSwitch(visitStatusEnum: s).getText();

    if (status == VisitStatus.cancel) {
      if (technician != null) {
        log('Technician assigned: {0}'.trArgs([technician.name]), created, admin);
      }
      log(
          'Status changed from {0} to {1}'.trArgs([
            statusText(technician == null ? VisitStatus.scheduled : VisitStatus.assigned),
            statusText(VisitStatus.cancel)
          ]),
          start.subtract(const Duration(hours: 20)),
          admin,
          reason: _t('The client asked to cancel the appointment.',
              'طلب العميل إلغاء الموعد.'));
    } else if (technician != null) {
      log('Technician assigned: {0}'.trArgs([technician.name]), created, admin);
      final reached = steps.indexOf(status);
      for (var i = 1; i <= reached; i++) {
        final at = start.add(Duration(minutes: i == 1 ? -30 : 25 * i));
        log(
            'Status changed from {0} to {1}'
                .trArgs([statusText(steps[i - 1]), statusText(steps[i])]),
            at,
            techActor!,
            location: i == 1
                ? _near(site, at, meters: 4000)
                : _near(site, at));
      }
    }

    // --- Invoice -------------------------------------------------------------
    final issued = status == VisitStatus.completed;
    var paid = 0;
    var pending = 0;
    final ledger = <InvoicePaymentHistoryModel>[];
    final paidAt = start.add(const Duration(hours: 2));

    if (issued) {
      switch (payment) {
        case _Payment.paid:
          paid = cents;
        case _Payment.partial:
          paid = (cents / 2).round();
        case _Payment.fieldCollection:
          pending = cents;
        case _Payment.unpaid:
          break;
      }
      if (paid > 0) {
        ledger.add(InvoicePaymentHistoryModel(
          id: '$invoiceId-p1',
          invoiceId: invoiceId,
          paymentDate: paidAt,
          paymentAmount: paid / 100,
          paymentMethod: chance(.6) ? PaymentMethod.cash : PaymentMethod.bankTransfer,
          referenceNumber: null,
          collectedBy: admin,
          notes: '',
          status: PaymentEntryStatus.confirmed,
        ));
        log('Invoice payment recorded: {0}'
            .trArgs([(paid / 100).toStringAsFixed(2)]), paidAt, admin);
      }
      if (pending > 0 && techActor != null) {
        ledger.add(InvoicePaymentHistoryModel(
          id: '$invoiceId-p2',
          invoiceId: invoiceId,
          paymentDate: paidAt,
          paymentAmount: pending / 100,
          paymentMethod: PaymentMethod.cash,
          collectedBy: techActor,
          notes: '',
          status: PaymentEntryStatus.pending,
          location: _near(site, paidAt),
        ));
        log(
            'Technician collected {0} · awaiting admin confirmation'
                .trArgs([(pending / 100).toStringAsFixed(2)]),
            paidAt,
            techActor,
            location: _near(site, paidAt));
      } else {
        pending = 0;
      }
    }

    final PaymentStatus paymentStatus;
    if (status == VisitStatus.cancel) {
      paymentStatus = PaymentStatus.cancelled;
    } else if (pending > 0) {
      paymentStatus = PaymentStatus.pending;
    } else if (paid == 0) {
      paymentStatus = PaymentStatus.unpaid;
    } else if (paid == cents) {
      paymentStatus = PaymentStatus.paid;
    } else {
      paymentStatus = PaymentStatus.partiallyPaid;
    }

    final problem = service.serviceName!.contains(_t('repair', 'إصلاح')) ||
            chance(.3)
        ? _problemText()
        : null;

    data.visits.add(VisitDetailModel(
      id: id,
      visitNumber: visitNumber,
      status: status,
      serviceName: service.serviceName,
      client: VisitClientModel(
        id: client.id,
        name: client.name,
        phone: client.phone,
        isWhatsAppPhone: client.isWhatsAppPhone,
        email: client.email,
        sites: site == null ? null : [site],
        equipments: client.equipments,
      ),
      site: site,
      category: service.category,
      price: price,
      durationInMin: service.duration,
      checkList: service.checkList,
      problemDescription: problem,
      notes: chance(.15)
          ? _t('Bring a ladder.', 'إحضار سلم.')
          : null,
      priority: priority,
      startDate: start,
      technicianModel: technician?.convertToTechnicianModel(),
      history: history,
      paymentStatus: paymentStatus,
      invoiceID: invoiceId,
      requireBeforeWorkPhotos: false,
      requireAfterWorkPhotos: afterPhotos,
    ));

    data.invoices.add(InvoiceDetailModel(
      id: invoiceId,
      invoiceNumber: invoiceNumber,
      visitId: id,
      visitNumber: visitNumber,
      client:
          VisitClientModel(id: client.id, name: client.name, phone: client.phone),
      site: site,
      paymentStatus: paymentStatus,
      createdAt: created,
      issueDate: issued ? start.add(const Duration(hours: 1)) : null,
      dueDate: issued
          ? DateTime(start.year, start.month, start.day)
              .add(Duration(days: App.invoicePaymentTermDays))
          : null,
      subtotal: price,
      discountAmount: 0,
      taxAmount: taxCents / 100,
      totalAmount: cents / 100,
      paidAmount: paid / 100,
      remainingAmount: (cents - paid) / 100,
      pendingAmount: pending / 100,
      currency: App.currency,
    ));

    data.payments.addAll(ledger);
  }

  String _problemText() {
    final problem = pick(_problems);
    return _t(problem.$1, problem.$2);
  }
}

enum _Payment { unpaid, paid, partial, fieldCollection }
