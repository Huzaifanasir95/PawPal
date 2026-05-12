// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pawpawl/core/di/api_client_module.dart' as _i509;
import 'package:pawpawl/core/services/api_client.dart' as _i428;
import 'package:pawpawl/core/utils/image_service.dart' as _i480;
import 'package:pawpawl/features/auth/data/repositories/auth_repository.dart'
    as _i681;
import 'package:pawpawl/features/caregiver/data/repositories/booking_repository.dart'
    as _i537;
import 'package:pawpawl/features/caregiver/data/repositories/caregiver_repository.dart'
    as _i238;
import 'package:pawpawl/features/chat/data/repositories/chat_repository.dart'
    as _i218;
import 'package:pawpawl/features/chat/presentation/bloc/chat_bloc.dart'
    as _i638;
import 'package:pawpawl/features/chatbot/data/repositories/chatbot_repository.dart'
    as _i922;
import 'package:pawpawl/features/community/data/repositories/community_repository.dart'
    as _i37;
import 'package:pawpawl/features/community/data/repositories/community_repository_api.dart'
    as _i7;
import 'package:pawpawl/features/community/presentation/bloc/community_bloc.dart'
    as _i404;
import 'package:pawpawl/features/pets/data/repositories/pet_repository_api.dart'
    as _i11;
import 'package:pawpawl/features/vet/data/repositories/vet_repository.dart'
    as _i217;
import 'package:pawpawl/features/vet/presentation/bloc/vet_bloc.dart' as _i490;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final apiClientModule = _$ApiClientModule();
    gh.factory<_i480.ImageService>(() => _i480.ImageService());
    gh.factory<_i37.CommunityRepository>(() => _i37.CommunityRepository());
    gh.factory<_i7.CommunityRepositoryApi>(() => _i7.CommunityRepositoryApi());
    gh.factory<_i11.PetRepositoryApi>(() => _i11.PetRepositoryApi());
    gh.lazySingleton<_i428.ApiClient>(() => apiClientModule.apiClient);
    gh.lazySingleton<_i681.AuthRepository>(() => _i681.AuthRepository());
    gh.lazySingleton<_i537.BookingRepository>(
      () => _i537.BookingRepository(gh<_i428.ApiClient>()),
    );
    gh.lazySingleton<_i238.CaregiverRepository>(
      () => _i238.CaregiverRepository(gh<_i428.ApiClient>()),
    );
    gh.lazySingleton<_i218.ChatRepository>(
      () => _i218.ChatRepository(gh<_i428.ApiClient>()),
    );
    gh.lazySingleton<_i922.ChatbotRepository>(
      () => _i922.ChatbotRepository(gh<_i428.ApiClient>()),
    );
    gh.lazySingleton<_i217.VetRepository>(
      () => _i217.VetRepository(gh<_i428.ApiClient>()),
    );
    gh.factory<_i638.ChatBloc>(
      () => _i638.ChatBloc(gh<_i218.ChatRepository>()),
    );
    gh.factory<_i404.CommunityBloc>(
      () => _i404.CommunityBloc(gh<_i7.CommunityRepositoryApi>()),
    );
    gh.factory<_i490.VetBloc>(() => _i490.VetBloc(gh<_i217.VetRepository>()));
    return this;
  }
}

class _$ApiClientModule extends _i509.ApiClientModule {}
