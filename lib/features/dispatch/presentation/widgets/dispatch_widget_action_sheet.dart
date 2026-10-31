import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/general_widgets/g_widget_bottom_sheet.dart';
import '../controller/dispatch_bloc.dart';

/// Bottom sheet bound to one dispatch operation: it shows that operation's
/// loading state and closes itself as soon as the operation succeeds.
class DispatchWidgetActionSheet extends StatelessWidget {
  const DispatchWidgetActionSheet({
    super.key,
    required this.title,
    required this.builder,
    this.requestState,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  /// The operation that closes the sheet; null keeps it open.
  final RequestState Function(DispatchState state)? requestState;
  final Widget Function(
      BuildContext context, DispatchState state, bool loading) builder;

  /// Opens [sheet] with access to the screen's [DispatchBloc].
  static Future<void> show(BuildContext context, Widget sheet) {
    return AppToasts.showBottomSheet(
      context,
      BlocProvider.value(value: context.read<DispatchBloc>(), child: sheet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestState = this.requestState;

    return BlocConsumer<DispatchBloc, DispatchState>(
      listenWhen: (previous, current) =>
          requestState != null &&
          requestState(previous) == RequestState.loading &&
          requestState(current) == RequestState.loaded,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) => GWidgetBottomSheet(
        title: title,
        subtitle: subtitle,
        body: builder(context, state,
            requestState != null && requestState(state) == RequestState.loading),
      ),
    );
  }
}
