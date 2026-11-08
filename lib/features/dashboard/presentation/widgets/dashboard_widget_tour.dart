import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/general_widgets/g_widget_tour.dart';

/// Marks the dashboard's sections so the tour can spotlight them.
class DashboardTourKeys {
  final header = GlobalKey();
  final period = GlobalKey();
  final newVisit = GlobalKey();
  final attention = GlobalKey();
  final scores = GlobalKey();
  final today = GlobalKey();
  final trend = GlobalKey();
  final technicians = GlobalKey();
  final links = GlobalKey();
}

/// The dashboard's guided tour. Sections that are not on the screen (for
/// example with no visits yet) are left out.
class DashboardTour {
  DashboardTour._();

  static void start(BuildContext context, DashboardTourKeys keys) {
    GWidgetTour.start(
      context,
      mission: 'Master your dashboard'.tr,
      badge: 'Dashboard expert'.tr,
      steps: [
        GTourStep(
          target: keys.header,
          icon: Icons.dashboard_rounded,
          title: 'Your command center'.tr,
          text: 'The whole company on one screen. The line under the title shows the dates you are viewing and when the numbers were last updated.'.tr,
          tip: 'Tap refresh any time to get the newest numbers.'.tr,
        ),
        GTourStep(
          target: keys.period,
          icon: Icons.date_range_rounded,
          title: 'Choose your time range'.tr,
          text: 'Every number on this screen follows the range you pick here: today, 7 days, 30 days, this month, or your own dates.'.tr,
          tip: 'Each number is compared with the period just before it.'.tr,
        ),
        GTourStep(
          target: keys.newVisit,
          icon: Icons.add_circle_rounded,
          title: 'Book new work'.tr,
          text: 'The fastest way to start a visit. Choose the client, the service and the time, then send a technician.'.tr,
        ),
        GTourStep(
          target: keys.attention,
          icon: Icons.notification_important_rounded,
          title: 'Handle problems first'.tr,
          text: 'Late visits, visits with no technician, work not invoiced yet and overdue invoices. Only real problems appear here.'.tr,
          tip: 'Tap a row to see exactly which ones.'.tr,
        ),
        GTourStep(
          target: keys.scores,
          icon: Icons.emoji_events_rounded,
          title: 'Your four scores'.tr,
          text: 'Visits, completion, money collected and items needing attention. The small arrow shows if you are doing better or worse than before.'.tr,
          tip: 'Tap any score to see the details behind it.'.tr,
        ),
        GTourStep(
          target: keys.today,
          icon: Icons.today_rounded,
          title: 'Today, live'.tr,
          text: "Where each of today's visits stands right now, from scheduled to completed.".tr,
          tip: 'Tap a number to open those visits.'.tr,
        ),
        GTourStep(
          target: keys.trend,
          icon: Icons.bar_chart_rounded,
          title: 'See the rhythm'.tr,
          text: 'Each bar is a slice of time. Green is completed work and blue is work not completed yet.'.tr,
          tip: 'Tap a bar to open the visits behind it.'.tr,
        ),
        GTourStep(
          target: keys.technicians,
          icon: Icons.groups_rounded,
          title: 'Meet your team'.tr,
          text: 'Who finished how much in this period. A bar fills up as a technician completes the visits assigned to them.'.tr,
          tip: 'Tap a name to see their full results.'.tr,
        ),
        GTourStep(
          target: keys.links,
          icon: Icons.rocket_launch_rounded,
          title: 'Jump anywhere'.tr,
          text: 'Shortcuts to dispatch, visits, clients, technicians, services and invoices, all from here.'.tr,
        ),
      ],
    );
  }
}
