import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/invoice_detail_model.dart';
import '../repository/base_invoices_repo.dart';

class IssueInvoiceUc
    extends BaseUseCase<InvoiceDetailModel, IssueInvoiceParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  IssueInvoiceUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      IssueInvoiceParameters parameters) async {
    return await baseInvoicesRepo.issueInvoice(parameters);
  }
}

class IssueInvoiceParameters {
  final String invoiceId;
  final bool allowEarlyIssue;
  final String? overrideReason;

  const IssueInvoiceParameters({
    required this.invoiceId,
    this.allowEarlyIssue = false,
    this.overrideReason,
  });
}
