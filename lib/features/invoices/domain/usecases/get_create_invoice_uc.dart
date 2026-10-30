import 'package:either_dart/either.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/domain/repository/base_invoices_repo.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';

class GetCreateInvoiceUc
    extends BaseUseCase<InvoiceDetailModel, GetCreateInvoiceParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  GetCreateInvoiceUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      GetCreateInvoiceParameters parameters) async {
    return await baseInvoicesRepo.getCreateInvoice(parameters);
  }
}

class GetCreateInvoiceParameters {
  final InvoiceDetailModel invoice;

  const GetCreateInvoiceParameters({required this.invoice});
}
