import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';
import 'package:visit_proof/features/invoices/presentation/widgets/invoices_widgets/invoices_body.dart';

import '../../../../core/services/services_locator.dart';

class InvoicesScr extends StatelessWidget {
  const InvoicesScr({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<InvoicesBloc>()
          ..add(GetInvoicesEvent(noParameters: NoParameters())),
        child: BlocBuilder<InvoicesBloc, InvoicesState>(
          builder: (context, state) {
            return InvoicesBody(
                invoices: state.invoices,
                loading: state.invoicesRequestState == RequestState.loading);
          },
        ));
  }
}
