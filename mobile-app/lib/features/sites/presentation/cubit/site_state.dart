import 'package:equatable/equatable.dart';
import '../../../../models/models.dart';

abstract class SiteState extends Equatable {
  const SiteState();

  @override
  List<Object?> get props => [];
}

class SiteInitial extends SiteState {
  const SiteInitial();
}

class SiteLoading extends SiteState {
  const SiteLoading();
}

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
