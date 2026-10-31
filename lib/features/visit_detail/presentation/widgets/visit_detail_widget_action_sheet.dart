import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/general_widgets/g_widget_bottom_sheet.dart';
import '../controller/visit_detail_bloc.dart';

/// Bottom sheet bound to one bloc operation: it shows that operation's
/// loading state and closes itself as soon as the operation succeeds.
class VisitDetailWidgetActionSheet extends StatelessWidget {
  const VisitDetailWidgetActionSheet({
    super.key,
    required this.title,
    required this.requestState,
    required this.builder,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final RequestState Function(VisitDetailState state) requestState;
  final Widget Function(
      BuildContext context, VisitDetailState state, bool loading) builder;

  /// Opens [sheet] with access to the screen's [VisitDetailBloc].
  static Future<void> show(BuildContext context, Widget sheet) {
    return AppToasts.showBottomSheet(
      context,
      BlocProvider.value(
          value: context.read<VisitDetailBloc>(), child: sheet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitDetailBloc, VisitDetailState>(
      listenWhen: (previous, current) =>
          requestState(previous) == RequestState.loading &&
          requestState(current) == RequestState.loaded,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) => GWidgetBottomSheet(
        title: title,
        subtitle: subtitle,
        body: builder(
            context, state, requestState(state) == RequestState.loading),
      ),
    );
  }
}
