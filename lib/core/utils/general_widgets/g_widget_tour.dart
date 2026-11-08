import 'dart:math' as math;

import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../configs/app_theme.dart';
import 'g_widget_button.dart';

/// One stop of a guided tour: the part of the screen to spotlight and what
/// to say about it.
class GTourStep {
  const GTourStep({
    required this.target,
    required this.icon,
    required this.title,
    required this.text,
    this.tip,
  });

  /// Put this key on the widget to spotlight (a [KeyedSubtree] is enough).
  final GlobalKey target;
  final IconData icon;
  final String title;
  final String text;
  final String? tip;
}

/// A guided tour played like a game level: a spotlight flies from stop to
/// stop, the guide types its explanation, and every stop earns a star, up to
/// a medal and confetti at the end. Reusable on any screen.
class GWidgetTour extends StatefulWidget {
  const GWidgetTour._({
    required this.mission,
    required this.badge,
    required this.steps,
  });

  final String mission;
  final String badge;
  final List<GTourStep> steps;

  /// Plays the tour over the current screen. Stops whose target is not on
  /// the screen are skipped.
  static Future<void> start(
    BuildContext context, {
    required String mission,
    required String badge,
    required List<GTourStep> steps,
  }) async {
    final ready = steps.where((s) => s.target.currentContext != null).toList();
    if (ready.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) =>
          GWidgetTour._(mission: mission, badge: badge, steps: ready),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  State<GWidgetTour> createState() => _GWidgetTourState();
}

enum _Stage { intro, playing, finished }

class _GWidgetTourState extends State<GWidgetTour>
    with TickerProviderStateMixin {
  static const int _xpPerStop = 10;

  /// Keeps the guide bobbing and the spotlight breathing.
  late final AnimationController _idle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));

  /// Spotlight flying to the next stop.
  late final AnimationController _move = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560));

  /// Panel coming in and out.
  late final AnimationController _panel = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 130));

  /// The guide typing its explanation.
  late final AnimationController _type = AnimationController(vsync: this);

  /// Stars bursting out of a finished stop.
  late final AnimationController _reward = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 820));

  /// Medal, stars and confetti at the end.
  late final AnimationController _finale = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200));

  _Stage _stage = _Stage.intro;
  int _index = 0;
  final Set<int> _collected = {};
  Rect? _from;
  Rect? _to;
  Rect? _rewardAt;
  bool _busy = false;
  bool _reduceMotion = false;
  Size? _size;

  GTourStep get _step => widget.steps[_index];
  bool get _last => _index == widget.steps.length - 1;
  int get _xp => _collected.length * _xpPerStop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }

    // Keeps the spotlight on its target when the screen turns or resizes.
    final size = MediaQuery.sizeOf(context);
    if (_size != null && _size != size && _stage == _Stage.playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final rect = _measure(_step);
        if (rect != null) setState(() => _from = _to = rect);
      });
    }
    _size = size;
  }

  @override
  void dispose() {
    _idle.dispose();
    _move.dispose();
    _panel.dispose();
    _type.dispose();
    _reward.dispose();
    _finale.dispose();
    super.dispose();
  }

  void _play(AnimationController controller) {
    if (_reduceMotion) {
      controller.value = 1;
    } else {
      controller.forward(from: 0);
    }
  }

  Future<void> _hidePanel() async {
    if (_reduceMotion) {
      _panel.value = 0;
    } else {
      await _panel.reverse();
    }
  }

  /// Where a step's target is, in this overlay's coordinates.
  Rect? _measure(GTourStep step) {
    final target = step.target.currentContext?.findRenderObject();
    final self = context.findRenderObject();
    if (target is! RenderBox || self is! RenderBox || !target.attached) {
      return null;
    }
    final topLeft = self.globalToLocal(target.localToGlobal(Offset.zero));
    final rect = (topLeft & target.size).inflate(6);
    final visible = rect.intersect(Offset.zero & self.size);
    return visible.isEmpty ? rect : visible;
  }

  void _begin() {
    setState(() => _stage = _Stage.playing);
    _go(0);
  }

  Future<void> _go(int index) async {
    if (_busy) return;
    _busy = true;
    HapticFeedback.selectionClick();
    await _hidePanel();
    if (!mounted) return;

    final target = widget.steps[index].target.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: .1,
        duration: _reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final rect = _measure(widget.steps[index]);
    if (rect == null) {
      _busy = false;
      if (index < widget.steps.length - 1) {
        _go(index + 1);
      } else {
        _finish();
      }
      return;
    }

    setState(() {
      _index = index;
      _from = _to ?? Rect.fromCenter(center: rect.center, width: 0, height: 0);
      _to = rect;
    });
    _type.duration = Duration(
        milliseconds: (_step.text.length * 20).clamp(500, 2600).toInt());
    _play(_move);
    _play(_panel);
    _play(_type);
    _busy = false;
  }

  void _next() {
    if (_busy) return;
    if (_collected.add(_index)) {
      HapticFeedback.lightImpact();
      setState(() => _rewardAt = _to);
      if (!_reduceMotion) _reward.forward(from: 0);
    }
    if (_last) {
      _finish();
    } else {
      _go(_index + 1);
    }
  }

  void _previous() {
    if (_index > 0) _go(_index - 1);
  }

  /// Tapping the dark area finishes the typing first, then moves on.
  void _tapScrim() {
    if (_stage != _Stage.playing || _busy) return;
    if (_type.isAnimating) {
      _type.value = 1;
    } else {
      _next();
    }
  }

  Future<void> _finish() async {
    _busy = true;
    await _hidePanel();
    if (!mounted) return;
    final center = _to?.center;
    setState(() {
      _stage = _Stage.finished;
      _from = _to;
      if (center != null) {
        _to = Rect.fromCenter(center: center, width: 0, height: 0);
      }
    });
    HapticFeedback.heavyImpact();
    _play(_move);
    _play(_finale);
    _busy = false;
  }

  void _replay() {
    setState(() {
      _collected.clear();
      _to = null;
      _from = null;
      _stage = _Stage.playing;
    });
    _finale.value = 0;
    _go(0);
  }

  void _close() {
    final first = widget.steps.first.target.currentContext;
    if (first != null) {
      Scrollable.ensureVisible(first,
          duration: _reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 300));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tapScrim,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([_move, _idle]),
                builder: (context, _) => CustomPaint(
                  painter: _SpotlightPainter(
                    hole: _currentHole(),
                    lock: Curves.easeOut.transform(_move.value),
                    pulse: _idle.value,
                    scrim: AppTheme.scrim,
                    ring: AppTheme.reward,
                  ),
                ),
              ),
            ),
          ),
          if (_rewardAt != null) _rewardBurst(),
          ...switch (_stage) {
            _Stage.intro => [_center(_introCard())],
            _Stage.playing => [_dockedPanel()],
            _Stage.finished => [
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _finale,
                    builder: (context, _) => CustomPaint(
                        painter: _ConfettiPainter(progress: _finale.value)),
                  ),
                ),
                _center(_finaleCard()),
              ],
          },
        ],
      ),
    );
  }

  Rect? _currentHole() {
    if (_to == null) return null;
    final t = _stage == _Stage.finished
        ? Curves.easeIn.transform(_move.value)
        : Curves.easeOutBack.transform(_move.value);
    return Rect.lerp(_from ?? _to, _to, t);
  }

  Widget _center(Widget child) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  // --- Stars flying out of a finished stop -----------------------------------

  Widget _rewardBurst() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _reward,
        builder: (context, _) {
          final t = _reward.value;
          if (t == 0 || t == 1) return const SizedBox.shrink();
          final center = _rewardAt!.center;
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                  painter: _BurstPainter(
                      center: center, progress: t, color: AppTheme.reward)),
              Positioned(
                left: center.dx - 70,
                top: center.dy - 20 - 70 * Curves.easeOut.transform(t),
                width: 140,
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Text('+{0} XP'.trArgs([_xpPerStop]),
                      textAlign: TextAlign.center,
                      style: AppTheme.font(
                          color: AppTheme.reward,
                          fontSize: AppTheme.textTitleLarge,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Intro -----------------------------------------------------------------

  Widget _introCard() {
    return _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Mascot(size: 96, idle: _idle),
          const SizedBox(height: 16),
          Text('New mission'.tr,
              style: AppTheme.font(
                  color: AppTheme.primary,
                  fontSize: AppTheme.textSmall,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(widget.mission,
              textAlign: TextAlign.center,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textHeadline,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
              'I am Proofy, your guide. {0} stops, about one minute, and a star at every stop.'
                  .trArgs([widget.steps.length]),
              textAlign: TextAlign.center,
              style: AppTheme.font(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.textBody,
                  height: 1.4)),
          const SizedBox(height: 20),
          GWidgetButton(
            text: 'Start the mission'.tr,
            fontSize: AppTheme.textSubtitle,
            height: 56,
            paddingTopBottom: 0,
            onPressed: _begin,
          ),
          const SizedBox(height: 4),
          _QuietButton(label: 'Not now'.tr, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  // --- A stop ----------------------------------------------------------------

  Widget _dockedPanel() {
    final height = MediaQuery.sizeOf(context).height;
    // The panel sits on the side away from the spotlight.
    final dockBottom = (_to?.center.dy ?? 0) < height / 2;

    return SafeArea(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: dockBottom ? Alignment.bottomCenter : Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 460, maxHeight: height * .56),
            child: AnimatedBuilder(
              animation: _panel,
              builder: (context, child) {
                final t = _panel.value;
                final slide = Curves.easeOutBack.transform(t);
                return Transform.translate(
                  offset: Offset(0, (1 - slide) * (dockBottom ? 48 : -48)),
                  child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                );
              },
              child: _stopCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stopCard() {
    final step = _step;
    final total = widget.steps.length;
    final stop = 'Stop {0} of {1}'.trArgs([_index + 1, total]);

    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: '$stop. ${step.title}. ${step.text} ${step.tip ?? ''}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Row(
                children: [
                  for (var i = 0; i < total; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        decoration: BoxDecoration(
                          color: _collected.contains(i)
                              ? AppTheme.reward
                              : i == _index
                                  ? AppTheme.primary
                                  : AppTheme.iconLightGrey,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            ExcludeSemantics(
              child: Row(
                children: [
                  _Mascot(size: 52, idle: _idle),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stop,
                            style: AppTheme.font(
                                color: AppTheme.primary,
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.w800)),
                        Text(step.title,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textTitle,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  _XpPill(xp: _xp),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ExcludeSemantics(child: _typedText(step)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: _QuietButton(label: 'Skip tour'.tr, onTap: _close),
                ),
                if (_index > 0)
                  IconButton(
                    tooltip: 'Previous'.tr,
                    onPressed: _previous,
                    icon: Icon(Icons.arrow_back_rounded,
                        color: AppTheme.iconGrey),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 3,
                  child: GWidgetButton(
                    text: _last ? 'Finish'.tr : 'Next stop'.tr,
                    fontSize: AppTheme.textBody,
                    height: 48,
                    paddingTopBottom: 0,
                    onPressed: _next,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The rest of the sentence is laid out but invisible, so the card does
  /// not grow while the guide types.
  Widget _typedText(GTourStep step) {
    final style = AppTheme.font(
        color: AppTheme.textSecondary,
        fontSize: AppTheme.textBody,
        height: 1.45);

    return AnimatedBuilder(
      animation: _type,
      builder: (context, _) {
        final count = (step.text.length * _type.value).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(TextSpan(style: style, children: [
              TextSpan(text: step.text.substring(0, count)),
              TextSpan(
                  text: step.text.substring(count),
                  style: style.copyWith(color: Colors.transparent)),
            ])),
            if (step.tip != null) ...[
              const SizedBox(height: 10),
              Opacity(
                opacity: ((_type.value - .8) / .2).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(step.icon, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(step.tip!,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // --- Finale ----------------------------------------------------------------

  Widget _finaleCard() {
    final total = _xp;

    return AnimatedBuilder(
      animation: _finale,
      builder: (context, _) {
        double pop(double from, double to) => CurvedAnimation(
                parent: _finale,
                curve: Interval(from, to, curve: Curves.elasticOut))
            .value;
        final counted = (total *
                Curves.easeOut
                    .transform(((_finale.value - .2) / .3).clamp(0.0, 1.0)))
            .round();

        return _Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(scale: pop(0, .35), child: const _Medal()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Transform.scale(
                      scale: pop(.18 + i * .09, .5 + i * .09),
                      child: Icon(Icons.star_rounded,
                          size: i == 1 ? 46 : 36, color: AppTheme.reward),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Mission complete!'.tr,
                  style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textHeadline,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('You earned the badge: {0}'.trArgs([widget.badge]),
                  textAlign: TextAlign.center,
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textBody)),
              const SizedBox(height: 12),
              Text('+{0} XP'.trArgs([counted]),
                  style: AppTheme.font(
                      color: AppTheme.primary,
                      fontSize: AppTheme.textDisplay,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              GWidgetButton(
                text: 'Back to work'.tr,
                fontSize: AppTheme.textSubtitle,
                height: 56,
                paddingTopBottom: 0,
                onPressed: _close,
              ),
              const SizedBox(height: 4),
              _QuietButton(label: 'Play again'.tr, onTap: _replay),
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _QuietButton extends StatelessWidget {
  const _QuietButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppTheme.textSecondary),
      child: Text(label,
          style: AppTheme.font(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.textBody,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.locationChipBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 18, color: AppTheme.reward),
          const SizedBox(width: 3),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text('$xp',
                key: ValueKey(xp),
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _Medal extends StatelessWidget {
  const _Medal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary,
        border: Border.all(color: AppTheme.reward, width: 5),
      ),
      child: Icon(Icons.emoji_events_rounded,
          size: 54, color: AppTheme.onPrimary),
    );
  }
}

/// Proofy, the guide: the app's map pin with a face.
class _Mascot extends StatelessWidget {
  const _Mascot({required this.size, required this.idle});
  final double size;
  final Animation<double> idle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: idle,
      builder: (context, _) => Transform.translate(
        offset: Offset(0, math.sin(idle.value * 2 * math.pi) * size * .05),
        child: CustomPaint(
          size: Size.square(size),
          painter: _MascotPainter(
            time: idle.value,
            body: AppTheme.primary,
            face: AppTheme.surface,
            spark: AppTheme.reward,
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.time,
    required this.body,
    required this.face,
    required this.spark,
  });

  final double time;
  final Color body;
  final Color face;
  final Color spark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s * .5, s * .45);
    final fill = Paint()..color = body;

    canvas.drawPath(
      Path()
        ..moveTo(s * .5, s * .98)
        ..quadraticBezierTo(s * .15, s * .68, s * .16, s * .45)
        ..arcToPoint(Offset(s * .84, s * .45),
            radius: Radius.circular(s * .34))
        ..quadraticBezierTo(s * .85, s * .68, s * .5, s * .98)
        ..close(),
      fill,
    );

    // Antenna with a spark that breathes.
    canvas.drawLine(
      Offset(s * .5, s * .13),
      Offset(s * .5, s * .06),
      Paint()
        ..color = body
        ..strokeWidth = s * .035
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(s * .5, s * .05),
        s * (.045 + .012 * math.sin(time * 4 * math.pi)), Paint()..color = spark);

    canvas.drawCircle(center, s * .24, Paint()..color = face);

    // Blinks briefly once per cycle.
    final blink = time > .46 && time < .52 ? .15 : 1.0;
    for (final side in [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(side * s * .09, -s * .04),
            width: s * .07,
            height: s * .11 * blink),
        fill,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
          center: center.translate(0, s * .03), width: s * .2, height: s * .17),
      .25,
      math.pi - .5,
      false,
      Paint()
        ..color = body
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .03
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.time != time || old.body != body || old.face != face;
}

/// Darkens everything except [hole], with lock-on brackets around it.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.hole,
    required this.lock,
    required this.pulse,
    required this.scrim,
    required this.ring,
  });

  final Rect? hole;

  /// 0 while flying, 1 once locked on the target.
  final double lock;
  final double pulse;
  final Color scrim;
  final Color ring;

  static const double _radius = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Offset.zero & size;
    final rect = hole;
    if (rect == null || rect.width < 4 || rect.height < 4) {
      canvas.drawRect(screen, Paint()..color = scrim);
      return;
    }

    final hollow = RRect.fromRectAndRadius(
        rect, const Radius.circular(_radius));
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(screen)
        ..addRRect(hollow),
      Paint()..color = scrim,
    );

    canvas.drawRRect(
      hollow,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // A wave leaves the edge of the spotlight over and over.
    final spread = pulse * 14;
    canvas.drawRRect(
      hollow.inflate(spread),
      Paint()
        ..color = ring.withValues(alpha: (1 - pulse) * .5 * lock)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // The brackets close in as the spotlight arrives.
    final gap = 6 + (1 - lock) * 26 + math.sin(pulse * 2 * math.pi) * 1.5;
    final box = rect.inflate(gap);
    final arm = math.min(22.0, box.shortestSide / 3);
    final bracket = Paint()
      ..color = ring.withValues(alpha: lock)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final (corner, dx, dy) in [
      (box.topLeft, 1.0, 1.0),
      (box.topRight, -1.0, 1.0),
      (box.bottomLeft, 1.0, -1.0),
      (box.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx * arm, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy * arm),
        bracket,
      );
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.lock != lock || old.pulse != pulse;
}

Path _starPath(Offset center, double radius, double rotation) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? radius : radius * .45;
    final angle = rotation + i * math.pi / 5 - math.pi / 2;
    final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  final Offset center;
  final double progress;
  final Color color;

  static const int _count = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final travel = Curves.easeOutCubic.transform(progress);
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
    for (var i = 0; i < _count; i++) {
      final angle = i * 2 * math.pi / _count;
      final distance = 30 + travel * (i.isEven ? 120 : 84);
      canvas.drawPath(
        _starPath(
          center + Offset(math.cos(angle) * distance, math.sin(angle) * distance),
          (i.isEven ? 11 : 7) * (1 - progress * .5),
          progress * 3,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static final List<_Bit> _bits = () {
    final random = math.Random(7);
    return List.generate(
      90,
      (_) => _Bit(
        x: random.nextDouble(),
        delay: random.nextDouble() * .35,
        fall: .55 + random.nextDouble() * .45,
        sway: 12 + random.nextDouble() * 30,
        spin: 2 + random.nextDouble() * 8,
        size: 6 + random.nextDouble() * 7,
        tone: random.nextInt(6),
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;
    final tones = [
      AppTheme.reward,
      AppTheme.primary,
      AppTheme.statGreen,
      AppTheme.progress,
      AppTheme.secondary,
      AppTheme.statOrange,
    ];

    for (final bit in _bits) {
      final t = ((progress - bit.delay) / (1 - bit.delay)).clamp(0.0, 1.0);
      if (t == 0) continue;
      final y = -20 + (size.height + 40) * (t * t) / bit.fall;
      if (y > size.height + 20) continue;
      final x = size.width * bit.x + math.sin(t * bit.spin) * bit.sway;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * bit.spin * 2);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: bit.size, height: bit.size * .55),
        Paint()
          ..color = tones[bit.tone]
              .withValues(alpha: ((1 - t) * 3).clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Bit {
  const _Bit({
    required this.x,
    required this.delay,
    required this.fall,
    required this.sway,
    required this.spin,
    required this.size,
    required this.tone,
  });

  final double x;
  final double delay;
  final double fall;
  final double sway;
  final double spin;
  final double size;
  final int tone;
}
