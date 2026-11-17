import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../repositories/surveillance_repository.dart';

abstract class SiteState extends Equatable {
  const SiteState();
  @override
  List<Object?> get props => [];
}

class SiteInitial extends SiteState {}

class SiteLoading extends SiteState {}

class SiteLoaded extends SiteState {
  final List<Site> sites;
  final Site selectedSite;

  const SiteLoaded({
    required this.sites,
    required this.selectedSite,
  });

  @override
  List<Object?> get props => [sites, selectedSite];
}

class SiteError extends SiteState {
  final String message;
  const SiteError(this.message);

  @override
  List<Object?> get props => [message];
}

class SiteCubit extends Cubit<SiteState> {
  final SurveillanceRepository _repository;

  SiteCubit({required SurveillanceRepository repository})
      : _repository = repository,
        super(SiteInitial());

  Future<void> loadSites({String? preferredSiteCode}) async {
    emit(SiteLoading());
    try {
      final sites = await _repository.getSites();
      if (sites.isEmpty) {
        emit(const SiteError('No industrial sites configured.'));
        return;
      }

      Site selected = sites.first;
      if (preferredSiteCode != null) {
        final match = sites.firstWhere(
          (s) => s.code.toUpperCase() == preferredSiteCode.toUpperCase(),
          orElse: () => sites.first,
        );
        selected = match;
      }

      emit(SiteLoaded(sites: sites, selectedSite: selected));
    } catch (e) {
      emit(SiteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void selectSite(Site site) {
    if (state is SiteLoaded) {
      final current = state as SiteLoaded;
      emit(SiteLoaded(sites: current.sites, selectedSite: site));
    }
  }

  void switchSiteByCode(String code) {
    if (state is SiteLoaded) {
      final current = state as SiteLoaded;
      final match = current.sites.firstWhere(
        (s) => s.code.toUpperCase() == code.toUpperCase(),
        orElse: () => current.selectedSite,
      );
      emit(SiteLoaded(sites: current.sites, selectedSite: match));
    }
  }
}
