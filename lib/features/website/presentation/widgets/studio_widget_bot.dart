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
  static const tick = 'Tick this box to confirm your location.';
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
  static const double _robot = 48;
  static const Duration _trackEvery = Duration(milliseconds: 300);
  static const Duration _cheerFor = Duration(milliseconds: 1800);

  late final _idle =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  final _stage = GlobalKey();
  final _bubble = GlobalKey();

  Timer? _tracker;
  Timer? _cheerTimer;
  Rect? _target;
  String? _say;
  double _bubbleHeight = 130;
  bool _minimized = false;
  bool _cheering = false;

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
      if (say != _say && !visible.overlaps(rect)) {
        Scrollable.ensureVisible(element!,
            alignment: .5, duration: const Duration(milliseconds: 300));
      }
    }

    if (rect != _target ||
        say != _say ||
        menuOpen != _menuOpen ||
        (height != null && height != _bubbleHeight)) {
      setState(() {
        _target = rect;
        _say = say;
        _menuOpen = menuOpen;
        if (height != null) _bubbleHeight = height;
      });
    }
  }

  void _act() {
    if (widget.scenario.step == StudioStep.finished) {
      widget.onOffer();
    } else {
      widget.scenario.runAction();
    }
  }

  Offset _robotAt(Size stage, bool bubbleOnTop, bool rtl) {
    final start = rtl ? stage.width - _robot - 12 : 12.0;
    final end = rtl ? 12.0 : stage.width - _robot - 12;
    // The menu opens from the start side, so wait beside it.
    if (_menuOpen) return Offset(end, stage.height - _robot - 16);
    if (_minimized) return Offset(start, stage.height - _robot - 16);
    final target = _target;
    if (target != null) {
      final above = target.top - _robot - 8;
      final y = above >= 4 ? above : target.bottom + 8;
      return Offset(
        (target.center.dx - _robot / 2)
            .clamp(4.0, math.max(4.0, stage.width - _robot - 4)),
        y.clamp(4.0, math.max(4.0, stage.height - _robot - 4)),
      );
    }
    return Offset(
        start,
        bubbleOnTop
            ? _bubbleHeight + 18
            : stage.height - _bubbleHeight - _robot - 16);
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
      final robot = _robotAt(stage, bubbleOnTop, rtl);

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
                padding: const EdgeInsets.all(10),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  alignment: bubbleOnTop
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _Bubble(
                      key: _bubble,
                      step: scenario.step,
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
    required this.say,
    required this.cheering,
    required this.busy,
    required this.onAction,
    required this.onHide,
  });

  final StudioStep step;
  final String say;
  final bool cheering;
  final bool busy;
  final VoidCallback onAction;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final action = step.action;
    final calm = MediaQuery.disableAnimationsOf(context);

    return Material(
      color: WebTheme.primary,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 12),
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

  static const int _msPerLetter = 18;

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
        duration: Duration(milliseconds: instant ? 0 : text.length * _msPerLetter),
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
