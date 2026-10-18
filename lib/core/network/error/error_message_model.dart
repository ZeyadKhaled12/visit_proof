import 'package:equatable/equatable.dart';

class ErrorMessageModel extends Equatable {
  final String statusMessage;

  const ErrorMessageModel({required this.statusMessage});

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    String msg = '';
    if (json.containsKey('errors')) {
      msg = json['errors'][0];
    } else if (json.containsKey('validationErrors')) {
      msg = (json['validationErrors'] as Map).values.toList().firstOrNull.first;
    } else if (json.containsKey('message')) {
      msg = json['message'];
    } else if (json.containsKey('error')) {
      msg = json['error'];
    } else if (json.containsKey('data')) {
      msg = (json['data'] as Map).values.toList().firstOrNull.first;
    } else if (json.containsKey('title')) {
      msg = json['title'];
    }

    return ErrorMessageModel(statusMessage: msg);
  }

  @override
  List<Object> get props => [statusMessage];
}
