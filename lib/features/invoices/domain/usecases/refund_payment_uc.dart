import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';
import '../../data/models/invoice_detail_model.dart';
import '../repository/base_invoices_repo.dart';

class RefundPaymentUc
    extends BaseUseCase<InvoiceDetailModel, RefundPaymentParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  RefundPaymentUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      RefundPaymentParameters parameters) async {
    return await baseInvoicesRepo.refundPayment(parameters);
  }
}

class RefundPaymentParameters {
  final String invoiceId;
  final num amount;
  final String reason;
  final VisitHistoryActorModel? actor;

  const RefundPaymentParameters({
    required this.invoiceId,
    required this.amount,
    required this.reason,
    this.actor,
  });
}
