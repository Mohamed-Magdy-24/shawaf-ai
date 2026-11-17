import '../../../../models/models.dart';

abstract class IEmployeeRepository {
  Future<List<Employee>> getEmployees(String siteId);
  Future<Employee> registerEmployee(String siteId, Map<String, dynamic> empPayload);
  Future<int> importEmployees(String siteId, String csvOrJson);
  Future<List<EmployeePresence>> getEmployeePresence(String siteId);
}
