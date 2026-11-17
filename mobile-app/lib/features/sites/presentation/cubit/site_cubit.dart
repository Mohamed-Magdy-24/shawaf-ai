import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/site_repository.dart';
import 'site_state.dart';

export 'site_state.dart';

class SiteCubit extends Cubit<SiteState> {
  final ISiteRepository _repository;

  SiteCubit({required ISiteRepository repository})
      : _repository = repository,
        super(const SiteInitial());

  Future<void> loadSites({String? preferredSiteCode}) async {
    emit(const SiteLoading());
    try {
      final sites = await _repository.getSites();
      if (sites.isEmpty) {
        emit(const SiteError('No industrial sites configured.'));
        return;
      }

      var selected = sites.first;
      if (preferredSiteCode != null) {
        selected = sites.firstWhere(
          (s) => s.code.toUpperCase() == preferredSiteCode.toUpperCase(),
          orElse: () => sites.first,
        );
      }

      emit(SiteLoaded(sites: sites, selectedSite: selected));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(SiteError(msg));
    }
  }

  void selectSite(String siteId) {
    if (state is SiteLoaded) {
      final current = state as SiteLoaded;
      final target = current.sites.firstWhere(
        (s) => s.id == siteId || s.code.toUpperCase() == siteId.toUpperCase(),
        orElse: () => current.selectedSite,
      );
      if (target != current.selectedSite) {
        emit(SiteLoaded(sites: current.sites, selectedSite: target));
      }
    }
  }

  void switchSiteByCode(String code) {
    selectSite(code);
  }
}
