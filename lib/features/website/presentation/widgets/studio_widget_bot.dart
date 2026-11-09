import 'dart:async';
import 'dart:math' as math;

import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../core/utils/general_widgets/g_widget_tour.dart';
import '../studio_scenario.dart';
import '../website_theme.dart';

/// What Wizpoo says when pointing at something (English keys).
class StudioBotLines {
  StudioBotLines._();

  static const newVisit = 'Press "New visit" to book a job.';
  static const schedule =
      'I filled this in with sample data. Change anything you like, then press "Schedule".';
  static const queue = 'Your new visit is waiting in the queue. Open the queue.';
  static const suggest = 'Let the app pick: press "Suggest technician".';
  static const bestMatch = 'This technician fits best. Tap their name.';
  static const assign = 'Press "Assign" to send it to their phone.';
  static const openVisit = 'Open your visit.';
  static const trip = 'Press "Start trip".';
  static const work = 'Press "Start work".';
  static const complete = 'Press "Complete visit".';
  static const tick =
      'Tick this box to share your location. I will ask you only this once.';
  static const collect = 'The client is paying now. Press "Collect payment".';
  static const sendReceipt =
      'I attached a sample receipt. Press "Send to admin".';
  static const openInvoice = 'Press "Open invoice".';
  static const confirmPayment =
      'Press "Confirm". The money is added to the invoice.';
  static const confirm =
      'Press "Confirm". The time and your location are saved as proof.';

  static const all = [
    newVisit,
    schedule,
    queue,
    suggest,
    bestMatch,
    assign,
    openVisit,
    trip,
    work,
    complete,
    tick,
    confirm,
    collect,
    sendReceipt,
    openInvoice,
    confirmPayment,
  ];
}

/// Something to point at, found by what the app shows on the screen.
class _Cue {
  const _Cue(this.say,
      {this.text, this.tooltip, this.prefix = false, this.unticked = false});
  final String say;
  final String? text;
  final String? tooltip;

  /// [text] is only the start of the label, as in "Queue (3)".
  final bool prefix;

  /// A box still to be ticked.
  final bool unticked;

  bool matches(Widget widget) {
    if (unticked) {
      return (widget is Checkbox && widget.value == false) ||
          (widget is CheckboxListTile && widget.value == false);
    }
    if (tooltip != null) return widget is Tooltip && widget.message == tooltip;
    if (widget is! Text || widget.data == null) return false;
    return prefix ? widget.data!.startsWith(text!) : widget.data == text;
  }

  /// The topmost match on the screen the visitor is looking at.
  Element? find() {
    final root = App.navigatorKey.currentContext as Element?;
    if (root == null) return null;
    Element? found;
    void visit(Element element) {
      final widget = element.widget;
      if (widget is Offstage && widget.offstage) return;
      if (matches(widget) && (ModalRoute.of(element)?.isCurrent ?? true)) {
        found = element;
      }
      element.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found;
  }
}

/// Wizpoo walks the visitor through the full cycle over the live app: it
/// flies to the next thing to press, rings it and says what to do. It follows
/// the app's own screens, so it keeps up with whatever the visitor taps.
class StudioWidgetBot extends StatefulWidget {
  const StudioWidgetBot(
      {super.key, required this.scenario, required this.onOffer});

  final StudioScenario scenario;
  final VoidCallback onOffer;

  @override
  State<StudioWidgetBot> createState() => _StudioWidgetBotState();
}

class _StudioWidgetBotState extends State<StudioWidgetBot>
    with SingleTickerProviderStateMixin {
  static const double _robot = 44;
  static const double _bubbleMargin = 10;
  static const double _bubbleMaxWidth = 440;
  static const Duration _trackEvery = Duration(milliseconds: 300);
  static const Duration _cheerFor = Duration(milliseconds: 1800);

  /// How long it stays by a new target before going back to its bubble.
  static const Duration _visitFor = Duration(milliseconds: 1400);

  late final _idle =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  final _stage = GlobalKey();
  final _bubble = GlobalKey();

  Timer? _tracker;
  Timer? _cheerTimer;
  Timer? _visitTimer;
  Rect? _target;
  String? _say;
  double _bubbleHeight = 130;
  bool _minimized = false;
  bool _cheering = false;

  /// Flying to a new target. The rest of the time it sits in its bubble, so
  /// it never stays on top of something the visitor wants to read.
  bool _visiting = false;

  /// No visit or invoice is open behind the guide.
  bool _atHome = true;

  /// The app's menu is open: the guide steps aside so all of it shows.
  bool _menuOpen = false;
  late StudioStep _step = widget.scenario.step;

  @override
  void initState() {
    super.initState();
    widget.scenario.addListener(_onScenario);
    GWidgetTour.playing.addListener(_redraw);
    _tracker = Timer.periodic(_trackEvery, (_) => _track());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }
  }

  @override
  void dispose() {
    _tracker?.cancel();
    _cheerTimer?.cancel();
    _visitTimer?.cancel();
    widget.scenario.removeListener(_onScenario);
    GWidgetTour.playing.removeListener(_redraw);
    _idle.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  /// A finished step earns a cheer, and the guide opens again for the next.
  void _onScenario() {
    final step = widget.scenario.step;
    if (step != _step) {
      final advanced = !_step.isIntro && step.index > _step.index;
      _step = step;
      _target = null;
      _say = null;
      _minimized = false;
      if (advanced) {
        _cheering = true;
        _cheerTimer?.cancel();
        _cheerTimer = Timer(_cheerFor, () {
          _cheering = false;
          _redraw();
        });
      }
    }
    _redraw();
  }

  List<_Cue> get _cues {
    switch (widget.scenario.step) {
      case StudioStep.helpFlag:
        return [
          _Cue(StudioStep.helpFlag.hint, tooltip: 'How this screen works'.tr)
        ];
      case StudioStep.createVisit:
        return [
          _Cue(StudioBotLines.schedule.tr, text: 'Schedule'.tr),
          _Cue(StudioBotLines.newVisit.tr, text: 'New visit'.tr),
          _Cue(StudioBotLines.newVisit.tr, text: 'Add New Visit'.tr),
        ];
      case StudioStep.assign:
        return [
          _Cue(StudioBotLines.assign.tr, text: 'Assign'.tr),
          _Cue(StudioBotLines.assign.tr, text: 'Assign anyway'.tr),
          _Cue(StudioBotLines.bestMatch.tr, text: 'Best match'.tr),
          _Cue(StudioBotLines.suggest.tr, text: 'Suggest technician'.tr),
          _Cue(StudioBotLines.queue.tr,
              text: 'Queue ({0})'.trArgs(['|']).split('|').first, prefix: true),
        ];
      case StudioStep.startTrip:
        return [
          _Cue(StudioBotLines.tick.tr, unticked: true),
          _Cue(StudioBotLines.confirm.tr, text: 'Confirm'.tr),
          _Cue(StudioBotLines.trip.tr, text: 'Start trip'.tr),
          _Cue(StudioBotLines.openVisit.tr, text: 'Next: {0}'.trArgs(['Start trip'.tr])),
        ];
      case StudioStep.startWork:
        return [
          _Cue(StudioBotLines.tick.tr, unticked: true),
          _Cue(StudioBotLines.confirm.tr, text: 'Confirm'.tr),
          _Cue(StudioBotLines.work.tr, text: 'Start work'.tr),
          _Cue(StudioBotLines.openVisit.tr, text: 'Next: {0}'.trArgs(['Start work'.tr])),
        ];
      case StudioStep.complete:
        return [
          _Cue(StudioBotLines.tick.tr, unticked: true),
          _Cue(StudioBotLines.confirm.tr, text: 'Confirm'.tr),
          _Cue(StudioBotLines.complete.tr, text: 'Complete visit'.tr),
          _Cue(StudioBotLines.openVisit.tr, text: 'Next: {0}'.trArgs(['Complete visit'.tr])),
        ];
      case StudioStep.collect:
        return [
          _Cue(StudioBotLines.tick.tr, unticked: true),
          _Cue(StudioBotLines.sendReceipt.tr, text: 'Send to admin'.tr),
          _Cue(StudioBotLines.collect.tr, text: 'Collect payment'.tr),
        ];
      case StudioStep.seeProof:
        return [
          _Cue(StudioStep.seeProof.hint,
              text: 'Technician location · {0} from site'
                  .trArgs(['|'])
                  .split('|')
                  .first,
              prefix: true),
        ];
      case StudioStep.seeInvoice:
        return [
          _Cue(StudioStep.seeInvoice.hint, text: 'Remaining balance'.tr),
          _Cue(StudioStep.seeInvoice.hint, text: 'Amount paid'.tr),
        ];
      case StudioStep.confirmPayment:
        return [
          _Cue(StudioBotLines.confirmPayment.tr, text: 'Confirm'.tr),
          _Cue(StudioBotLines.openInvoice.tr, text: 'Open invoice'.tr),
        ];
      case StudioStep.finished:
        return [_Cue(StudioStep.finished.hint, text: 'Amount paid'.tr)];
      default:
        return const [];
    }
  }

  bool _isMenuOpen() {
    final root = App.navigatorKey.currentContext as Element?;
    var open = false;
    void visit(Element element) {
      if (open) return;
      if (element.widget is Drawer) {
        open = true;
        return;
      }
      element.visitChildren(visit);
    }

    root?.visitChildren(visit);
    return open;
  }

  /// Looks for the next thing to press and where it is now: screens scroll
  /// and change under the guide all the time.
  void _track() {
    if (!mounted || GWidgetTour.playing.value) return;
    final stage = _stage.currentContext?.findRenderObject() as RenderBox?;
    if (stage == null || !stage.hasSize) return;

    final menuOpen = _isMenuOpen();
    final atHome = widget.scenario.atHome;
    final height = _bubble.currentContext?.size?.height;
    Rect? rect;
    String? say;
    Element? element;
    for (final cue in menuOpen ? const <_Cue>[] : _cues) {
      element = cue.find();
      if (element != null) {
        say = cue.say;
        break;
      }
    }

    final box = element?.renderObject;
    if (box is RenderBox && box.attached && box.hasSize) {
      final topLeft = stage.globalToLocal(box.localToGlobal(Offset.zero));
      final bottomRight = stage
          .globalToLocal(box.localToGlobal(box.size.bottomRight(Offset.zero)));
      rect = Rect.fromPoints(topLeft, bottomRight);
      final visible = (Offset.zero & stage.size).deflate(4);
      final inView =
          visible.contains(rect.topLeft) && visible.contains(rect.bottomRight);
      if (say != _say && !inView) {
        Scrollable.ensureVisible(element!,
            alignment: .5, duration: const Duration(milliseconds: 300));
      }
    }

    if (rect != _target ||
        say != _say ||
        menuOpen != _menuOpen ||
        atHome != _atHome ||
        (height != null && height != _bubbleHeight)) {
      setState(() {
        if (say != _say && rect != null && !_showingResult) _visitTarget();
        _atHome = atHome;
        _target = rect;
        _say = say;
        _menuOpen = menuOpen;
        if (height != null) _bubbleHeight = height;
      });
    }
  }

  /// The ring marks something to read here, so nothing may cover it.
  bool get _showingResult =>
      widget.scenario.step == StudioStep.seeProof ||
      widget.scenario.step == StudioStep.seeInvoice ||
      widget.scenario.step == StudioStep.finished;

  void _visitTarget() {
    _visiting = true;
    _visitTimer?.cancel();
    _visitTimer = Timer(_visitFor, () {
      _visiting = false;
      _redraw();
    });
  }

  /// The admin should be looking at the finished visit.
  bool get _reviewing =>
      widget.scenario.step == StudioStep.seeProof ||
      widget.scenario.step == StudioStep.seeInvoice ||
      widget.scenario.step == StudioStep.confirmPayment;

  void _act() {
    if (widget.scenario.step == StudioStep.finished) {
      widget.onOffer();
    } else {
      widget.scenario.runAction();
    }
  }

  /// Where the bubble ends up, worked out rather than measured so it holds
  /// while the bubble is still moving.
  Rect _bubbleRect(Size stage, bool bubbleOnTop) {
    final width = math.min(stage.width - _bubbleMargin * 2, _bubbleMaxWidth);
    final top = bubbleOnTop
        ? _bubbleMargin
        : stage.height - _bubbleMargin - _bubbleHeight;
    return Rect.fromLTWH(
        (stage.width - width) / 2, top, width, _bubbleHeight);
  }

  /// A spot next to the target that hides neither it nor the bubble's text.
  Offset? _spotBeside(Rect target, Rect bubble, Size stage) {
    const gap = 16.0;
    final dx = target.center.dx - _robot / 2;
    final dy = target.center.dy - _robot / 2;
    final ring = target.inflate(gap - 2);
    final room = Offset.zero & stage;
    for (final spot in [
      Offset(dx, target.top - _robot - gap),
      Offset(dx, target.bottom + gap),
      Offset(target.left - _robot - gap, dy),
      Offset(target.right + gap, dy),
    ]) {
      final box = spot & const Size.square(_robot);
      final fits = room.contains(box.topLeft) && room.contains(box.bottomRight);
      if (fits && !box.overlaps(ring) && !box.overlaps(bubble)) return spot;
    }
    return null;
  }

  Offset _robotAt(Size stage, bool bubbleOnTop, bool rtl, bool keyboard) {
    final start = rtl ? stage.width - _robot - 12 : 12.0;
    final end = rtl ? 12.0 : stage.width - _robot - 12;
    // The menu opens from the start side, so wait beside it.
    if (_menuOpen) return Offset(end, stage.height - _robot - 16);
    if (_minimized || keyboard) {
      return Offset(start, stage.height - _robot - 16);
    }
    final bubble = _bubbleRect(stage, bubbleOnTop);
    final target = _target;
    if (_visiting && target != null) {
      final spot = _spotBeside(target, bubble, stage);
      if (spot != null) return spot;
    }
    return Offset(
        rtl ? bubble.right - _robot - 10 : bubble.left + 10, bubble.top + 10);
  }

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenario;
    if (scenario.exploring || GWidgetTour.playing.value) {
      return const SizedBox.shrink();
    }
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(builder: (context, constraints) {
      final stage = constraints.biggest;
      final target = _target;
      final bubbleOnTop = target != null && target.center.dy > stage.height * .55;
      final robot = _robotAt(stage, bubbleOnTop, rtl, keyboard);

      return Stack(
        key: _stage,
        children: [
          if (target != null && !_minimized && !_menuOpen)
            Positioned.fromRect(
              rect: target.inflate(10),
              child: IgnorePointer(child: _Ring(animation: _idle)),
            ),
          if (!_minimized && !keyboard && !_menuOpen)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(_bubbleMargin),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  alignment: bubbleOnTop
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: _bubbleMaxWidth),
                    child: _Bubble(
                      key: _bubble,
                      step: scenario.step,
                      action: _reviewing && _atHome
                          ? 'Open the visit'
                          : scenario.step.action,
                      say: _say ?? scenario.step.hint,
                      cheering: _cheering,
                      busy: scenario.busy,
                      onAction: _act,
                      onHide: () => setState(() => _minimized = true),
                    ),
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOutCubic,
            left: robot.dx,
            top: robot.dy,
            child: Tooltip(
              message: 'Wizpoo',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _minimized = !_minimized),
                child: AnimatedScale(
                  scale: _cheering ? 1.3 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: GWidgetMascot(size: _robot, idle: _idle),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final wave = (math.sin(animation.value * 6 * math.pi) + 1) / 2;
        return Transform.scale(
          scale: 1 + wave * .05,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WebTheme.accent, width: 3),
              boxShadow: [
                BoxShadow(
                    color: WebTheme.accent.withValues(alpha: .25 + wave * .3),
                    blurRadius: 14,
                    spreadRadius: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.step,
    required this.action,
    required this.say,
    required this.cheering,
    required this.busy,
    required this.onAction,
    required this.onHide,
  });

  final StudioStep step;

  /// The label of the shortcut button, when the step has one.
  final String? action;
  final String say;
  final bool cheering;
  final bool busy;
  final VoidCallback onAction;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    final calm = MediaQuery.disableAnimationsOf(context);

    return Material(
      color: WebTheme.primary,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            _StudioWidgetBotState._robot + 18, 6, 6, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                    cheering
                        ? 'Great job!'.tr
                        : step.isIntro || step == StudioStep.finished
                            ? step.title
                            : 'Step {0} of {1}'
                                .trArgs([step.number, StudioStep.total]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WebTheme.font(
                        color: WebTheme.accent,
                        fontSize: WebTheme.textBody,
                        fontWeight: FontWeight.w800)),
              ),
              IconButton(
                tooltip: 'Hide'.tr,
                visualDensity: VisualDensity.compact,
                onPressed: onHide,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: WebTheme.parchment, size: 22),
              ),
            ]),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _Typed(text: say, instant: calm),
            ),
            if (action != null) ...[
              const SizedBox(height: 10),
              FilledButton(
                onPressed: busy ? null : onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: WebTheme.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(action.tr,
                    style: WebTheme.font(
                        color: WebTheme.primary, fontWeight: FontWeight.w800)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Types itself out. The full text is laid out from the start, so the bubble
/// does not grow while it types.
class _Typed extends StatelessWidget {
  const _Typed({required this.text, required this.instant});
  final String text;
  final bool instant;

  /// Short enough that nobody catches a line half written.
  static const int _typeForMs = 600;

  @override
  Widget build(BuildContext context) {
    final style = WebTheme.font(
        color: WebTheme.onPrimary,
        fontSize: WebTheme.textBodyLarge,
        height: 1.45);
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: TweenAnimationBuilder<int>(
        key: ValueKey(text),
        tween: IntTween(begin: instant ? text.length : 0, end: text.length),
        duration: Duration(milliseconds: instant ? 0 : _typeForMs),
        builder: (context, letters, _) => Stack(
          children: [
            Opacity(opacity: 0, child: Text(text, style: style)),
            Text(text.substring(0, letters), style: style),
          ],
        ),
      ),
    );
  }
}
