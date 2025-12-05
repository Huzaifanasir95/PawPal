import 'package:injectable/injectable.dart';
import '../services/api_client.dart';

@module
abstract class ApiClientModule {
  @lazySingleton
  ApiClient get apiClient => ApiClient.instance;
}
