import 'package:visit_proof/configs/app_language.dart';
import 'error_message_model.dart';
import 'exception.dart';

class HandleLogicErrors<T> {
  final Future<T> Function() fun;

  HandleLogicErrors({required this.fun});

  Future<T> checkLogicErrors() async {
    try {
      return await fun();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(ErrorMessageModel(
          statusMessage: 'Oops a problem occurred, please try again later!'.tr));
    }
  }
}
