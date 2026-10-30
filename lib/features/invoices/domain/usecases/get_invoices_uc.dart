import 'package:either_dart/either.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';

import '../../../../core/network/error/failure.dart';
import '../repository/base_invoices_repo.dart';

class GetInvoicesUc
    extends BaseUseCase<List<InvoiceDetailModel>, NoParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  GetInvoicesUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, List<InvoiceDetailModel>>> call(
      NoParameters parameters) async {
    return await baseInvoicesRepo.getInvoices(parameters);
  }
}
