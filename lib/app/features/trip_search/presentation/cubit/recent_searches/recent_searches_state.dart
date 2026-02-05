import 'package:equatable/equatable.dart';
import 'package:plumo/app/core/database/app_database.dart';

abstract class RecentSearchesState extends Equatable {
  const RecentSearchesState();

  @override
  List<Object> get props => [];
}

class RecentSearchesInitial extends RecentSearchesState {}

class RecentSearchesLoading extends RecentSearchesState {}

class RecentSearchesLoaded extends RecentSearchesState {
  final List<RecentSearch> searches;

  const RecentSearchesLoaded(this.searches);

  @override
  List<Object> get props => [searches];
}
