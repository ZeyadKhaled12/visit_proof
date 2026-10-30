import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/invoice_detail_model.dart';
import '../repository/base_invoices_repo.dart';

class UpdateDraftInvoiceUc
    extends BaseUseCase<InvoiceDetailModel, UpdateDraftInvoiceParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  UpdateDraftInvoiceUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      UpdateDraftInvoiceParameters parameters) async {
    return await baseInvoicesRepo.updateDraftInvoice(parameters);
  }
}

class UpdateDraftInvoiceParameters {
  final String invoiceId;
  final num discountAmount;
  final num taxAmount;
  final String notes;
  final bool allowPriceOverride;
  final String? overrideReason;

  const UpdateDraftInvoiceParameters({
    required this.invoiceId,
    required this.discountAmount,
    required this.taxAmount,
    required this.notes,
    this.allowPriceOverride = false,
    this.overrideReason,
  });
}
