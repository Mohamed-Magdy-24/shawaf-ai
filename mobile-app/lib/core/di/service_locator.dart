import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/ws_client.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/sites/domain/repositories/site_repository.dart';
import '../../features/sites/data/repositories/site_repository_impl.dart';
import '../../features/sites/presentation/cubit/site_cubit.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import '../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../features/alerts/presentation/cubit/alert_inbox_cubit.dart';
import '../../features/cameras/domain/repositories/camera_repository.dart';
import '../../features/cameras/data/repositories/camera_repository_impl.dart';
import '../../features/cameras/presentation/cubit/camera_stream_cubit.dart';
import '../../features/cameras/presentation/cubit/camera_management_cubit.dart';
import '../../features/employees/domain/repositories/employee_repository.dart';
import '../../features/employees/data/repositories/employee_repository_impl.dart';
import '../../features/employees/presentation/cubit/employee_cubit.dart';
import '../../cubits/connectivity_cubit.dart';
import '../../repositories/surveillance_repository.dart';
import '../../services/api_service.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  if (sl.isRegistered<IApiClient>()) return;

  // 1. Core Network & Clients
  final apiClient = ApiClient();
  final wsClient = WsClient();
  sl.registerSingleton<IApiClient>(apiClient);
  sl.registerSingleton<IWsClient>(wsClient);

  // ApiService for backward compatibility
  final apiService = ApiService();
  sl.registerSingleton<ApiService>(apiService);

  // 2. Repositories
  final authRepo = AuthRepositoryImpl(apiClient: sl<IApiClient>());
  final siteRepo = SiteRepositoryImpl(apiClient: sl<IApiClient>());
  final alertRepo = AlertRepositoryImpl(apiClient: sl<IApiClient>(), wsClient: sl<IWsClient>());
  final cameraRepo = CameraRepositoryImpl(apiClient: sl<IApiClient>());
  final employeeRepo = EmployeeRepositoryImpl(apiClient: sl<IApiClient>());

  sl.registerSingleton<IAuthRepository>(authRepo);
  sl.registerSingleton<ISiteRepository>(siteRepo);
  sl.registerSingleton<IAlertRepository>(alertRepo);
  sl.registerSingleton<ICameraRepository>(cameraRepo);
  sl.registerSingleton<IEmployeeRepository>(employeeRepo);

  // Legacy unified repository
  final unifiedRepo = HttpSurveillanceRepository(apiService: sl<ApiService>());
  sl.registerSingleton<SurveillanceRepository>(unifiedRepo);

  // 3. Cubits / State Management
  sl.registerFactory<AuthCubit>(() => AuthCubit(repository: sl<IAuthRepository>()));
  sl.registerFactory<SiteCubit>(() => SiteCubit(repository: sl<ISiteRepository>()));
  sl.registerFactory<AlertInboxCubit>(() => AlertInboxCubit(repository: sl<IAlertRepository>()));
  sl.registerFactory<CameraStreamCubit>(() => CameraStreamCubit(repository: sl<ICameraRepository>()));
  sl.registerFactory<CameraManagementCubit>(() => CameraManagementCubit(repository: sl<ICameraRepository>()));
  sl.registerFactory<EmployeeCubit>(() => EmployeeCubit(repository: sl<IEmployeeRepository>()));
  sl.registerFactory<ConnectivityCubit>(() => ConnectivityCubit());
}
