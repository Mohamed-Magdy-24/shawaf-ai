import '../../../../core/network/api_client.dart';
import '../../../../models/models.dart';
import '../../domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements IEmployeeRepository {
  final IApiClient _apiClient;

  EmployeeRepositoryImpl({required IApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Employee>> getEmployees(String siteId) async {
    final response = await _apiClient.get('/api/v1/sites/$siteId/employees');
    if (response is List) {
      return response.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid server response for employees');
  }

  @override
  Future<Employee> registerEmployee(String siteId, Map<String, dynamic> empPayload) async {
    final response = await _apiClient.post('/api/v1/sites/$siteId/employees', body: empPayload);
    if (response is Map<String, dynamic>) {
      return Employee.fromJson(response);
    }
    throw Exception('Failed to register employee');
  }

  @override
  Future<int> importEmployees(String siteId, String csvOrJson) async {
    final response = await _apiClient.post('/api/v1/sites/$siteId/employees/import', body: csvOrJson);
    if (response is Map<String, dynamic>) {
      return response['imported'] as int? ?? 0;
    }
    throw Exception('Failed to bulk import employees');
  }

  @override
  Future<List<EmployeePresence>> getEmployeePresence(String siteId) async {
    final response = await _apiClient.get('/api/v1/sites/$siteId/presence');
    if (response is List) {
      return response.map((e) => EmployeePresence.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid server response for employee presence');
  }
}
