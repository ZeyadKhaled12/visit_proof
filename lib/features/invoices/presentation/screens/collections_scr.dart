import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../domain/usecases/get_payments_uc.dart';
import '../widgets/collections_widgets/collections_body.dart';

/// Money technicians collected in the field, waiting for the admin.
class CollectionsScr extends StatelessWidget {
  const CollectionsScr({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InvoicesBloc>()
        ..add(GetInvoicesEvent(noParameters: NoParameters()))
        ..add(const GetPaymentsEvent(
            getPaymentsParameters: GetPaymentsParameters(pendingOnly: true))),
      child: const CollectionsBody(),
    );
  }
}
