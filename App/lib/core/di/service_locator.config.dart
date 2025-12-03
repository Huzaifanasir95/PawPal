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
import 'package:pawpawl/core/utils/image_service.dart' as _i480;
import 'package:pawpawl/features/community/data/repositories/community_repository.dart'
    as _i37;
import 'package:pawpawl/features/community/presentation/bloc/community_bloc.dart'
    as _i404;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i480.ImageService>(() => _i480.ImageService());
    gh.factory<_i37.CommunityRepository>(() => _i37.CommunityRepository());
    gh.factory<_i404.CommunityBloc>(
      () => _i404.CommunityBloc(gh<_i37.CommunityRepository>()),
    );
    return this;
  }
}
