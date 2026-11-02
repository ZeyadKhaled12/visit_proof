import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/payment_method_enum.dart';
import '../../../../core/utils/general_models/g_model_geo_point.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';
import '../../data/models/invoice_detail_model.dart';
import '../repository/base_invoices_repo.dart';

class RecordPaymentUc
    extends BaseUseCase<InvoiceDetailModel, RecordPaymentParameters> {
  final BaseInvoicesRepo baseInvoicesRepo;

  RecordPaymentUc(this.baseInvoicesRepo);

  @override
  Future<Either<Failure, InvoiceDetailModel>> call(
      RecordPaymentParameters parameters) async {
    return await baseInvoicesRepo.recordPayment(parameters);
  }
}

class RecordPaymentParameters {
  final String invoiceId;
  final num amount;
  final PaymentMethod paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final VisitHistoryActorModel? collectedBy;

  /// A technician's collection: their live location and receipt photos.
  /// It is saved as pending until the admin confirms it.
  final GModelGeoPoint? location;
  final List<String> photoPaths;

  const RecordPaymentParameters({
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.collectedBy,
    this.location,
    this.photoPaths = const [],
  });
}
