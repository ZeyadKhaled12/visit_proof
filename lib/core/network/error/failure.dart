import 'package:equatable/equatable.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'error_message_model.dart';

abstract class Failure extends Equatable {
  final ErrorMessageModel errorMessageModel;
  const Failure(this.errorMessageModel);

  @override
  List<Object?> get props => [errorMessageModel];
}

class ServerFailure extends Failure {
  const ServerFailure(super.errorMessageModel);
  ServerFailure.openFun(super.message) {
    AppToasts.showMessage(errorMessageModel.statusMessage, isError: true);
  }
}

class DataBaseFailure extends Failure {
  const DataBaseFailure(super.errorMessageModel);
}
