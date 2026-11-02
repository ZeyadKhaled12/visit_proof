import 'package:visit_proof/core/network/app_latency.dart';
import '../models/website_request_model.dart';

/// Sends a visitor's request to the owner's database.
///
/// There is no backend yet, so nothing is sent: when one exists, post
/// [WebsiteRequestModel.toJson] here (the design includes the uploaded logo
/// as base64).
class WebsiteRequestRemoteDataSource {
  Future<void> submitRequest(WebsiteRequestModel request) async {
    // TODO: save the request in the database.
    await Future.delayed(AppLatency.local);
  }
}
