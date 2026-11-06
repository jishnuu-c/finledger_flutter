import 'package:intl/intl.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/api/dio_client.dart';
import 'dashboard_models.dart';

class DashboardService {
  final DioClient dioClient;

  DashboardService({required this.dioClient});

  /// Fetch dashboard summary for date range
  Future<DashboardSummary> getSummary({DateTime? from, DateTime? to}) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final queryParams = <String, dynamic>{};
    if (from != null) queryParams['from'] = dateFormat.format(from);
    if (to != null) queryParams['to'] = dateFormat.format(to);

    try {
      final response = await dioClient.dio.get(
        Endpoints.dashboardSummary,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback to certified Figure 3 mock data
    }

    return DashboardSummary.defaultMock();
  }
}
