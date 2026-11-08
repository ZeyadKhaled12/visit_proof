import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:visit_proof/configs/app_language.dart';

import '../../../app/app.dart';
import '../../../core/demo/demo_seed.dart';
import '../../../core/local/local_pref.dart';
import '../../../core/services/services_locator.dart';
import '../../../core/session/app_session.dart';
import '../../../core/usecase/base_use_case.dart';
import '../../../core/utils/enums/visit_status_enum.dart';
import '../../../core/utils/general_widgets/g_widget_tour.dart';
import '../../auth/domain/usecases/enter_as_admin_uc.dart';
import '../../auth/domain/usecases/login_technician_uc.dart';
import '../../auth/domain/usecases/logout_uc.dart';
import '../../auth/presentation/widgets/auth_widget_account_actions.dart';
import '../../dispatch/presentation/screens/dispatch_scr.dart';
import '../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../data/datasource/website_design_local_data_source.dart';

/// One step of the full cycle the visitor plays: the office creates and
/// dispatches a visit, the technician carries it out, the office sees the
/// proof.
enum StudioStep {
  welcome(
      'Hi, I am Wizpoo',
      'I will walk you through the whole cycle: you book a visit as the admin, carry it out as the technician, then see the proof. Just press what I point at.',
      technician: false,
      action: 'Let us start'),
  helpFlag(
      'Your help is always here',
      'See this small gold flag at the top? It is on every screen. Tap it anytime and I will explain everything on that screen.',
      technician: false,
      action: 'Got it'),
  createVisit(
      'Create a visit',
      'You are the admin. Press "New visit" on the dashboard. The form is already filled with sample data, so just press "Schedule".',
      technician: false),
  assign(
      'Dispatch it to a technician',
      'Open the dispatch board, go to the queue, select your visit and assign it to a technician.',
      technician: false,
      action: 'Open dispatch'),
  becomeTechnician(
      'Now be the technician',
      'The visit is on its way to the technician\'s phone. Sign in as them to see only their work.',
      technician: true,
      action: 'Enter as technician'),
  startTrip('Start the trip',
      'Open your visit and press "Start trip". Your location is recorded.',
      technician: true),
  startWork(
      'Start the work',
      'Press "Start work". The app only allows it near the site; in this demo you count as being there.',
      technician: true),
  complete('Complete the visit',
      'Press "Complete visit". The invoice is issued by itself.',
      technician: true),
  backToAdmin(
      'Back to the office',
      'The work is done. Go back as the admin and open the visit to see its proof, its history and its invoice.',
      technician: false,
      action: 'Back to admin'),
  finished(
      'You ran the whole cycle',
      'From the office to the field and back, with proof at every step. Now make it yours.',
      technician: false,
      action: 'See the offer');

  const StudioStep(this._title, this._hint,
      {required this.technician, this.action});
  final String _title;
  final String _hint;

  /// Whose side of the app this step is played on.
  final bool technician;

  /// The label of the guide's shortcut button; null when the visitor does
  /// the step inside the app.
  final String? action;

  String get title => _title.tr;
  String get hint => _hint.tr;

  /// Wizpoo's introduction, before the cycle starts.
  bool get isIntro => index < StudioStep.createVisit.index;

  /// Position in the cycle, from 1.
  int get number => index - StudioStep.createVisit.index + 1;

  /// Steps to play, not counting the end.
  static int get total =>
      StudioStep.finished.index - StudioStep.createVisit.index;
}

/// Follows the visitor through [StudioStep]s by watching the app's own data,
/// so a step ticks off when it is really done in the app.
class StudioScenario extends ChangeNotifier {
  static const Duration _checkEvery = Duration(milliseconds: 500);

  /// Furthest first: the visit that got furthest sets the step.
  static const List<VisitStatus> _progress = [
    VisitStatus.completed,
    VisitStatus.inProgress,
    VisitStatus.onWay,
    VisitStatus.assigned,
    VisitStatus.scheduled,
  ];

  StudioStep step = StudioStep.welcome;

  /// How far the introduction has got.
  int _intro = 0;
  static const int _introSteps = 2;

  /// The visitor loaded the large sample company: nothing to follow.
  bool exploring = false;

  bool busy = false;
  Timer? _timer;

  void start() {
    AppSession.current.addListener(_check);
    GWidgetTour.playing.addListener(_onTourChanged);
    _timer = Timer.periodic(_checkEvery, (_) => _check());
    _check();
  }

  void skipIntro() {
    _intro = _introSteps;
    _check();
  }

  /// Trying the flag is the best way to finish its introduction.
  void _onTourChanged() {
    if (step == StudioStep.helpFlag && !GWidgetTour.playing.value) skipIntro();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AppSession.current.removeListener(_check);
    GWidgetTour.playing.removeListener(_onTourChanged);
    super.dispose();
  }

  /// The visitor's visit that got furthest; null before there is one. The
  /// sample company's own visits do not count.
  static VisitDetailModel? leadingVisit(Iterable<VisitDetailModel> visits) {
    final own = visits.where((e) => !(e.id ?? '').startsWith('demo-')).toList();
    for (final status in _progress) {
      for (final visit in own) {
        if (visit.status == status) return visit;
      }
    }
    return null;
  }

  /// Where the visitor is, given the leading visit and who is signed in.
  static StudioStep stepFor(VisitStatus? status, {required bool technician}) {
    switch (status) {
      case VisitStatus.scheduled:
        return StudioStep.assign;
      case VisitStatus.assigned:
        return technician ? StudioStep.startTrip : StudioStep.becomeTechnician;
      case VisitStatus.onWay:
        return technician ? StudioStep.startWork : StudioStep.becomeTechnician;
      case VisitStatus.inProgress:
        return technician ? StudioStep.complete : StudioStep.becomeTechnician;
      case VisitStatus.completed:
        return technician ? StudioStep.backToAdmin : StudioStep.finished;
      default:
        return StudioStep.createVisit;
    }
  }

  void _check() {
    if (exploring) return;
    final visits =
        (LocalPref.sharedPreferences.getStringList('visits') ?? const [])
            .map((e) => VisitDetailModel.fromJson(jsonDecode(e)));
    final visit = leadingVisit(visits);
    if (visit != null) _intro = _introSteps;
    final next = _intro < _introSteps
        ? StudioStep.values[_intro]
        : stepFor(visit?.status, technician: AppSession.isTechnician);
    if (next == step) return;
    step = next;
    notifyListeners();
  }

  /// The guide's shortcut for the current step. The end of the scenario is
  /// handled by the page, which owns the offer.
  Future<void> runAction() async {
    switch (step) {
      case StudioStep.welcome:
      case StudioStep.helpFlag:
        _intro++;
        _check();
      case StudioStep.assign:
        await App.navigatorKey.currentState?.pushNamed(DispatchScr.route);
      case StudioStep.becomeTechnician:
        await _run(() => viewAs(technician: true));
      case StudioStep.backToAdmin:
        await _run(() => viewAs(technician: false));
      default:
        break;
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    await action();
    busy = false;
    notifyListeners();
  }

  /// Opens the app as the admin, or as the technician who has work waiting.
  static Future<void> viewAs({required bool technician}) async {
    if (technician) {
      final person = DemoSeed.technicianToTry();
      await sl<LoginTechnicianUc>().call(LoginTechnicianParameters(
          email: person?.email ?? DemoSeed.technicianEmail,
          password: person?.password ?? DemoSeed.technicianPassword));
    } else {
      await sl<EnterAsAdminUc>().call(const NoParameters());
    }
    AuthWidgetAccountActions.backToHome();
  }

  /// Starts the scenario again from nothing, or loads the large sample
  /// company to look around in. The visitor's design stays.
  Future<void> restart({bool fullCompany = false}) => _run(() async {
        // Leaving the app first makes every screen load the new data.
        await sl<LogoutUc>().call(const NoParameters());
        AuthWidgetAccountActions.backToHome();
        await SchedulerBinding.instance.endOfFrame;

        final prefs = LocalPref.sharedPreferences;
        const keep = {
          WebsiteDesignLocalDataSource.key,
          GWidgetTour.flagsKey,
        };
        for (final key in prefs.getKeys().toList()) {
          if (!keep.contains(key)) await prefs.remove(key);
        }
        exploring = fullCompany;
        fullCompany ? await DemoSeed.run() : await DemoSeed.runScenario();
        _intro = _introSteps;
        step = StudioStep.createVisit;
        await sl<EnterAsAdminUc>().call(const NoParameters());
      });
}
