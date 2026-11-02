import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/invoice_payment_history_model.dart';
import '../repository/base_invoices_repo.dart';

class GetPaymentsUc extends BaseUseCase<List<InvoicePaymentHistoryModel>,
    GetPaymentsParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  GetPaymentsUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, List<InvoicePaymentHistoryModel>>> call(
      GetPaymentsParameters parameters) async {
    return await baseInvoicesRepo.getPayments(parameters);
  }
}

class GetPaymentsParameters {
  /// Null lists the payments of every invoice.
  final String? invoiceId;

  /// Only field collections still waiting for the admin.
  final bool pendingOnly;

  const GetPaymentsParameters({this.invoiceId, this.pendingOnly = false});
}
