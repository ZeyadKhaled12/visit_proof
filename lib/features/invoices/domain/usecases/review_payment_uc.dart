import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/invoice_detail_model.dart';
import '../repository/base_invoices_repo.dart';

/// The admin confirms or rejects money a technician collected in the field.
class ReviewPaymentUc
    extends BaseUseCase<InvoiceDetailModel, ReviewPaymentParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  ReviewPaymentUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      ReviewPaymentParameters parameters) async {
    return await baseInvoicesRepo.reviewPayment(parameters);
  }
}

class ReviewPaymentParameters {
  final String invoiceId;
  final String paymentId;
  final bool approve;

  /// Required (at least 8 characters) when rejecting.
  final String? note;

  const ReviewPaymentParameters({
    required this.invoiceId,
    required this.paymentId,
    required this.approve,
    this.note,
  });
}
