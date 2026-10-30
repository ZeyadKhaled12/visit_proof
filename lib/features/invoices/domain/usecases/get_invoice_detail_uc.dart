import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/invoice_detail_model.dart';
import '../repository/base_invoices_repo.dart';

class GetInvoiceDetailUc
    extends BaseUseCase<InvoiceDetailModel, GetInvoiceDetailParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  GetInvoiceDetailUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      GetInvoiceDetailParameters parameters) async {
    return await baseInvoicesRepo.getInvoiceDetail(parameters);
  }
}

class GetInvoiceDetailParameters {
  final String invoiceId;
  const GetInvoiceDetailParameters({required this.invoiceId});
}
