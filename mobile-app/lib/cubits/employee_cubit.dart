import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/models.dart';
import '../repositories/surveillance_repository.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();
  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  final List<EmployeePresence> presence;

  const EmployeeLoaded({
    required this.employees,
    required this.presence,
  });

  @override
  List<Object?> get props => [employees, presence];
}

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeeCubit extends Cubit<EmployeeState> {
  final SurveillanceRepository _repository;

  EmployeeCubit({required SurveillanceRepository repository})
      : _repository = repository,
        super(EmployeeInitial());

  Future<void> load(String siteId) async {
    emit(EmployeeLoading());
    try {
      final employees = await _repository.getEmployees(siteId);
      final presence = await _repository.getEmployeePresence(siteId);
      emit(EmployeeLoaded(employees: employees, presence: presence));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<Employee> enrollEmployee(String siteId, Map<String, dynamic> payload) async {
    try {
      final emp = await _repository.registerEmployee(siteId, payload);
      await load(siteId);
      return emp;
    } catch (e) {
      emit(EmployeeError(e.toString()));
      rethrow;
    }
  }

  Future<int> bulkImport(String siteId, String csvOrJson) async {
    try {
      final count = await _repository.importEmployees(siteId, csvOrJson);
      await load(siteId);
      return count;
    } catch (e) {
      emit(EmployeeError(e.toString()));
      rethrow;
    }
  }
}
