// =============================================================================
// APP TOURS — what Wizpoo says on every screen.
// =============================================================================
//
// Each getter is one screen's tour: its name, one sentence about what the
// screen is for, then its stops in order. A stop's first value is the id of a
// GTourTarget placed around that part of the screen. Stops whose part is not
// on the screen right now (an empty list, an admin-only section) are skipped.
//
// Every text needs an entry in app_translations.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../core/utils/general_widgets/g_widget_tour.dart';
import 'app_language.dart';

class AppTours {
  AppTours._();

  // --- Getting in ------------------------------------------------------------

  static GTour get roleSelect => GTour(
        mission: 'Choose how to enter'.tr,
        about: 'This app has two sides. Pick the one that fits you.'.tr,
        steps: [
          GTourStep('admin', Icons.admin_panel_settings_rounded, 'Admin'.tr,
              'Runs the whole company: clients, technicians, visits and invoices. No account is needed.'.tr),
          GTourStep('technician', Icons.engineering_rounded, 'Technician'.tr,
              'Signs in with the email and password the admin created, then works on their own visits.'.tr),
          GTourStep('settings', Icons.tune_rounded, 'Your preferences'.tr,
              'Change the language, turn dark mode on or off, or hide these help flags.'.tr),
        ],
      );

  static GTour get techLogin => GTour(
        mission: 'Technician sign in'.tr,
        about: 'Sign in to see the visits assigned to you.'.tr,
        steps: [
          GTourStep('email', Icons.mail_outline_rounded, 'Your email'.tr,
              'Use the same email your admin saved for you.'.tr),
          GTourStep('password', Icons.lock_outline_rounded, 'Your password'.tr,
              'Use the password your admin set. Tap the eye to see what you typed.'.tr),
          GTourStep('signIn', Icons.login_rounded, 'Enter the app'.tr,
              'Your visits open right after you sign in.'.tr),
        ],
      );

  // --- Menus -----------------------------------------------------------------

  static GTour get adminMenu => GTour(
        mission: 'App menu'.tr,
        about: 'Every part of the app is one tap away from here.'.tr,
        steps: [
          GTourStep('sections', Icons.menu_rounded, 'All sections'.tr,
              'Operations come first, then finance, then your client, technician and service lists.'.tr),
          GTourStep('settings', Icons.tune_rounded, 'Your preferences'.tr,
              'Change the language, turn dark mode on or off, or hide these help flags.'.tr),
          GTourStep('account', Icons.swap_horiz_rounded, 'Your account'.tr,
              'Switch between admin and technician from here.'.tr),
        ],
      );

  static GTour get technicianMenu => GTour(
        mission: 'App menu'.tr,
        about: 'Reminders for your work and your preferences.'.tr,
        steps: [
          GTourStep('tips', Icons.lightbulb_outline_rounded, 'Work reminders'.tr,
              'What the app records while you work, and when photos are needed.'.tr),
          GTourStep('settings', Icons.tune_rounded, 'Your preferences'.tr,
              'Change the language, turn dark mode on or off, or hide these help flags.'.tr),
          GTourStep('account', Icons.logout_rounded, 'Your account'.tr,
              'Sign out or switch role from here.'.tr),
        ],
      );

  // --- Dashboard -------------------------------------------------------------

  static GTour get dashboard => GTour(
        mission: 'Master your dashboard'.tr,
        about: 'How the whole company is doing, on one screen.'.tr,
        steps: [
          GTourStep('header', Icons.dashboard_rounded, 'Your command center'.tr,
              'The whole company on one screen. The line under the title shows the dates you are viewing and when the numbers were last updated.'.tr,
              tip: 'Tap refresh any time to get the newest numbers.'.tr),
          GTourStep('period', Icons.date_range_rounded, 'Choose your time range'.tr,
              'Every number on this screen follows the range you pick here: today, 7 days, 30 days, this month, or your own dates.'.tr,
              tip: 'Each number is compared with the period just before it.'.tr),
          GTourStep('newVisit', Icons.add_circle_rounded, 'Book new work'.tr,
              'The fastest way to start a visit. Choose the client, the service and the time, then send a technician.'.tr),
          GTourStep('attention', Icons.notification_important_rounded, 'Handle problems first'.tr,
              'Late visits, visits with no technician, work not invoiced yet and overdue invoices. Only real problems appear here.'.tr,
              tip: 'Tap a row to see exactly which ones.'.tr),
          GTourStep('scores', Icons.emoji_events_rounded, 'Your four scores'.tr,
              'Visits, completion, money collected and items needing attention. The small arrow shows if you are doing better or worse than before.'.tr,
              tip: 'Tap any score to see the details behind it.'.tr),
          GTourStep('today', Icons.today_rounded, 'Today, live'.tr,
              "Where each of today's visits stands right now, from scheduled to completed.".tr,
              tip: 'Tap a number to open those visits.'.tr),
          GTourStep('trend', Icons.bar_chart_rounded, 'See the rhythm'.tr,
              'Each bar is a slice of time. Green is completed work and blue is work not completed yet.'.tr,
              tip: 'Tap a bar to open the visits behind it.'.tr),
          GTourStep('technicians', Icons.groups_rounded, 'Meet your team'.tr,
              'Who finished how much in this period. A bar fills up as a technician completes the visits assigned to them.'.tr,
              tip: 'Tap a name to see their full results.'.tr),
          GTourStep('links', Icons.rocket_launch_rounded, 'Jump anywhere'.tr,
              'Shortcuts to dispatch, visits, clients, technicians, services and invoices, all from here.'.tr),
        ],
      );

  static GTour get dashboardInsight => GTour(
        mission: 'The details behind a number'.tr,
        about: 'Everything behind the score you tapped, ready to filter.'.tr,
        steps: [
          GTourStep('trail', Icons.route_rounded, 'Where you are'.tr,
              'Shows how you got here. Tap an earlier name to go back to it.'.tr),
          GTourStep('period', Icons.date_range_rounded, 'Choose your time range'.tr,
              'Every number on this screen follows the range you pick here.'.tr),
          GTourStep('stats', Icons.pin_rounded, 'Key numbers'.tr,
              'The main totals for the period you picked.'.tr),
          GTourStep('chart', Icons.bar_chart_rounded, 'Over time'.tr,
              'How the numbers moved during the period.'.tr,
              tip: 'Tap a bar to filter by it.'.tr),
          GTourStep('list', Icons.format_list_bulleted_rounded, 'The records'.tr,
              'The exact visits behind the numbers. Tap one to open it.'.tr),
        ],
      );

  static GTour get dashboardTechnician => GTour(
        mission: 'Technician results'.tr,
        about: 'How one technician performed in the period you picked.'.tr,
        steps: [
          GTourStep('trail', Icons.route_rounded, 'Where you are'.tr,
              'Shows how you got here. Tap an earlier name to go back to it.'.tr),
          GTourStep('period', Icons.date_range_rounded, 'Choose your time range'.tr,
              'Every number on this screen follows the range you pick here.'.tr),
          GTourStep('stats', Icons.pin_rounded, 'Key numbers'.tr,
              'The main results of this technician in the period.'.tr),
          GTourStep('chart', Icons.bar_chart_rounded, 'Workload over time'.tr,
              'How much work this technician had during the period.'.tr,
              tip: 'Tap a bar to filter by it.'.tr),
          GTourStep('status', Icons.donut_small_rounded, 'By status'.tr,
              'How their visits split between the workflow stages. Tap one to filter the list.'.tr),
          GTourStep('list', Icons.format_list_bulleted_rounded, 'The records'.tr,
              'The exact visits behind the numbers. Tap one to open it.'.tr),
        ],
      );

  // --- Operations ------------------------------------------------------------

  static GTour get dispatch => GTour(
        mission: 'Dispatch board'.tr,
        about: 'Plan the day: who goes where, and when.'.tr,
        steps: [
          GTourStep('date', Icons.calendar_month_rounded, 'Pick the day'.tr,
              'Everything on the board belongs to the day you select here.'.tr),
          GTourStep('counters', Icons.pin_rounded, 'The day at a glance'.tr,
              'Visits waiting for a technician, conflicts, late visits and the total planned.'.tr,
              tip: 'Tap a counter to see those visits.'.tr),
          GTourStep('views', Icons.view_carousel_rounded, 'Change the view'.tr,
              'See the work by technician, as a waiting queue, or on the map.'.tr),
          GTourStep('board', Icons.hub_rounded, 'The board'.tr,
              'This is where you assign and arrange the work of the day.'.tr),
          GTourStep('tray', Icons.inbox_rounded, 'Waiting visits'.tr,
              'Visits on this day that still need a technician.'.tr),
          GTourStep('rules', Icons.tune_rounded, 'Dispatch rules'.tr,
              'Set what the board checks every time you assign a visit.'.tr),
        ],
      );

  static GTour get visits => GTour(
        mission: 'All visits'.tr,
        about: 'Every visit of the company and where it stands.'.tr,
        steps: [
          GTourStep('filters', Icons.manage_search_rounded, 'Find a visit'.tr,
              'Search here, or use the filter button to narrow the list.'.tr),
          GTourStep('dispatch', Icons.hub_rounded, 'Open dispatch'.tr,
              'Jump to the board to plan who does what.'.tr),
          GTourStep('card_0', Icons.fact_check_rounded, 'One visit'.tr,
              'Its status, client, service, time, technician and payment. Tap it to open everything.'.tr),
          GTourStep('add', Icons.add_circle_rounded, 'Add a visit'.tr,
              'Create a new visit. Its invoice is created with it automatically.'.tr),
        ],
      );

  static GTour get addVisit => GTour(
        mission: 'New visit'.tr,
        about: 'Fill these parts from top to bottom to book the work.'.tr,
        steps: [
          GTourStep('client', Icons.person_rounded, 'Who is it for'.tr,
              'Choose the client and the site where the work happens.'.tr),
          GTourStep('service', Icons.build_circle_rounded, 'What is the job'.tr,
              'Choose the service. Its details can be adjusted for this visit.'.tr),
          GTourStep('schedule', Icons.event_rounded, 'When and who'.tr,
              'Set the date and time, and choose a technician if you already know who will go.'.tr),
          GTourStep('actions', Icons.save_rounded, 'Save it'.tr,
              'Save a draft to finish later, or schedule the visit. With a technician selected, it is assigned right away.'.tr),
        ],
      );

  static GTour get visitDetail => GTour(
        mission: 'Visit details'.tr,
        about: 'Everything about this visit, from booking to payment.'.tr,
        steps: [
          GTourStep('hero', Icons.flag_rounded, 'Where it stands'.tr,
              'The service, price, priority and payment, with the visit progress along the bottom.'.tr),
          GTourStep('workflow', Icons.play_circle_rounded, 'The next step'.tr,
              'The action that moves this visit forward is always here. Technician actions record the live location.'.tr),
          GTourStep('client', Icons.person_rounded, 'The client'.tr,
              'Who the visit is for and how to reach them.'.tr),
          GTourStep('schedule', Icons.event_rounded, 'Time and technician'.tr,
              'When the visit happens and who is going.'.tr),
          GTourStep('service', Icons.build_circle_rounded, 'The job'.tr,
              'The service and what needs to be done.'.tr),
          GTourStep('info', Icons.notes_rounded, 'Job notes'.tr,
              'The problem description and the notes for this visit.'.tr),
          GTourStep('photos', Icons.photo_camera_rounded, 'Proof photos'.tr,
              'Before and after pictures taken on site.'.tr),
          GTourStep('invoice', Icons.receipt_long_rounded, 'The invoice'.tr,
              'What is billed for this visit and what has been paid.'.tr),
          GTourStep('history', Icons.history_rounded, 'Full history'.tr,
              'Every change to this visit: who did it, when, and from where.'.tr),
        ],
      );

  static GTour get technicianHome => GTour(
        mission: 'My visits'.tr,
        about: 'Your work: what is happening now and what comes next.'.tr,
        steps: [
          GTourStep('greeting', Icons.waving_hand_rounded, 'Your day'.tr,
              'How many visits are open and how many are today.'.tr),
          GTourStep('active', Icons.play_circle_rounded, 'Right now'.tr,
              'The visit you are travelling to or working on. Open it to continue.'.tr),
          GTourStep('filters', Icons.filter_list_rounded, 'Choose a list'.tr,
              'Switch between open visits, today, completed and all.'.tr),
          GTourStep('card_0', Icons.fact_check_rounded, 'One visit'.tr,
              'The client, the job, the time and your next step. Tap it to open.'.tr),
        ],
      );

  // --- Finance ---------------------------------------------------------------

  static GTour get invoices => GTour(
        mission: 'Invoices'.tr,
        about: 'Every invoice and how much of it has been paid.'.tr,
        steps: [
          GTourStep('filters', Icons.manage_search_rounded, 'Find an invoice'.tr,
              'Search here, or use the filter button to narrow the list.'.tr),
          GTourStep('card_0', Icons.receipt_long_rounded, 'One invoice'.tr,
              'Its client, amount and payment status. Tap it to open.'.tr),
        ],
      );

  static GTour get invoiceDetail => GTour(
        mission: 'Invoice details'.tr,
        about: 'What was billed, what was paid and what is still owed.'.tr,
        steps: [
          GTourStep('status', Icons.verified_rounded, 'Invoice status'.tr,
              'The invoice number and whether it is paid.'.tr),
          GTourStep('customer', Icons.home_repair_service_rounded, 'Customer and visit'.tr,
              'Who this invoice is for and the visit it belongs to.'.tr),
          GTourStep('amounts', Icons.calculate_rounded, 'Amount breakdown'.tr,
              'The price, discount, tax and the total.'.tr),
          GTourStep('payments', Icons.payments_rounded, 'Payments'.tr,
              'Every payment recorded on this invoice.'.tr),
          GTourStep('actions', Icons.touch_app_rounded, 'What you can do'.tr,
              'Only the actions allowed for this invoice right now are shown.'.tr),
        ],
      );

  static GTour get collections => GTour(
        mission: 'Collections'.tr,
        about: 'Money technicians collected on site, waiting for you to confirm.'.tr,
        steps: [
          GTourStep('summary', Icons.payments_rounded, 'Waiting for you'.tr,
              'How many payments are waiting and their total.'.tr),
          GTourStep('tile_0', Icons.receipt_rounded, 'One payment'.tr,
              'Check the amount and the receipt, then confirm or reject it. Rejecting needs a reason.'.tr),
        ],
      );

  // --- Lists -----------------------------------------------------------------

  static GTour get clients => GTour(
        mission: 'Clients'.tr,
        about: 'Your customers, their sites and their equipment.'.tr,
        steps: [
          GTourStep('search', Icons.search_rounded, 'Find a client'.tr,
              'Search by name, phone or city.'.tr),
          GTourStep('card_0', Icons.person_rounded, 'One client'.tr,
              'Tap a client to see their details and visit history.'.tr),
          GTourStep('add', Icons.add_circle_rounded, 'Add a client'.tr,
              'Add a new customer before booking their first visit.'.tr),
        ],
      );

  static GTour get addClient => GTour(
        mission: 'Client form'.tr,
        about: 'Save the details you need to reach and visit this client.'.tr,
        steps: [
          GTourStep('personal', Icons.person_rounded, 'Personal info'.tr,
              'The client name. The email is optional.'.tr),
          GTourStep('contact', Icons.phone_rounded, 'Contact info'.tr,
              'The phone number, and whether it is on WhatsApp.'.tr),
          GTourStep('location', Icons.location_on_rounded, 'Location'.tr,
              'The city and the exact place on the map.'.tr),
          GTourStep('extra', Icons.notes_rounded, 'Notes'.tr,
              'Anything else your team should know.'.tr),
          GTourStep('save', Icons.save_rounded, 'Save'.tr,
              'Saves the client. Fields marked with * are required.'.tr),
        ],
      );

  static GTour get clientDetail => GTour(
        mission: 'Client details'.tr,
        about: 'Everything you know about this client.'.tr,
        steps: [
          GTourStep('header', Icons.person_rounded, 'Client profile'.tr,
              'Their name and how to contact them.'.tr),
          GTourStep('equipment', Icons.precision_manufacturing_rounded, 'Equipment'.tr,
              'The machines at this client, so the technician knows what to expect.'.tr),
          GTourStep('history', Icons.history_rounded, 'Visit history'.tr,
              'Every visit made for this client.'.tr),
          GTourStep('actions', Icons.touch_app_rounded, 'Actions'.tr,
              'Update this client or remove them.'.tr),
        ],
      );

  static GTour get technicians => GTour(
        mission: 'Technicians'.tr,
        about: 'Your field team.'.tr,
        steps: [
          GTourStep('search', Icons.search_rounded, 'Find a technician'.tr,
              'Search by name, phone or specialty.'.tr),
          GTourStep('card_0', Icons.engineering_rounded, 'One technician'.tr,
              'Tap a technician to see their details and visit history.'.tr),
          GTourStep('add', Icons.add_circle_rounded, 'Add a technician'.tr,
              'Create an account for a new member of your team.'.tr),
        ],
      );

  static GTour get addTechnician => GTour(
        mission: 'Technician form'.tr,
        about: 'Add a team member and create their sign in.'.tr,
        steps: [
          GTourStep('name', Icons.badge_rounded, 'Their name'.tr,
              'The name your team and clients will see.'.tr),
          GTourStep('phone', Icons.phone_rounded, 'Their phone'.tr,
              'The number used to reach them in the field.'.tr),
          GTourStep('email', Icons.mail_outline_rounded, 'Sign in email'.tr,
              'The technician signs in with this email. Each technician needs a different one.'.tr),
          GTourStep('password', Icons.lock_outline_rounded, 'Sign in password'.tr,
              'Share this password with the technician so they can sign in.'.tr),
          GTourStep('categories', Icons.category_rounded, 'Specialties'.tr,
              'The types of work this technician can do.'.tr),
          GTourStep('save', Icons.save_rounded, 'Save'.tr,
              'Saves the technician. Fields marked with * are required.'.tr),
        ],
      );

  static GTour get technicianDetail => GTour(
        mission: 'Technician details'.tr,
        about: 'Everything about this member of your team.'.tr,
        steps: [
          GTourStep('header', Icons.engineering_rounded, 'Technician profile'.tr,
              'Their name, status and contact details.'.tr),
          GTourStep('categories', Icons.category_rounded, 'Specialties'.tr,
              'The types of work this technician can do.'.tr),
          GTourStep('history', Icons.history_rounded, 'Visit history'.tr,
              'Every visit assigned to this technician.'.tr),
          GTourStep('actions', Icons.touch_app_rounded, 'Actions'.tr,
              'Update this technician or remove them.'.tr),
        ],
      );

  static GTour get services => GTour(
        mission: 'Services'.tr,
        about: 'What you sell, with prices, durations and checklists.'.tr,
        steps: [
          GTourStep('search', Icons.search_rounded, 'Find a service'.tr,
              'Search by service or category name.'.tr),
          GTourStep('card_0', Icons.build_circle_rounded, 'One service'.tr,
              'Its category, price and duration.'.tr),
          GTourStep('add', Icons.add_circle_rounded, 'Add a service'.tr,
              'Add a service once, then pick it on any visit.'.tr),
        ],
      );

  // --- Maps ------------------------------------------------------------------

  static GTour get locationPicker => GTour(
        mission: 'Pick a location'.tr,
        about: 'Find the exact place, then confirm it.'.tr,
        steps: [
          GTourStep('search', Icons.search_rounded, 'Search'.tr,
              'Type a place name to jump to it.'.tr),
          GTourStep('map', Icons.map_rounded, 'Move the map'.tr,
              'Drag the map until the pin sits on the exact place.'.tr),
          GTourStep('confirm', Icons.check_circle_rounded, 'Confirm'.tr,
              'Check the address shown here, then confirm it.'.tr),
        ],
      );

  static GTour get locationView => GTour(
        mission: 'View location'.tr,
        about: 'See exactly where this place is.'.tr,
        steps: [
          GTourStep('map', Icons.map_rounded, 'The map'.tr,
              'The marker shows the saved place. You can move around freely.'.tr),
          GTourStep('recenter', Icons.center_focus_strong_rounded, 'Back to the marker'.tr,
              'Returns the map to the saved place.'.tr),
          GTourStep('details', Icons.place_rounded, 'The address'.tr,
              'The address of this place.'.tr),
        ],
      );
}
