import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';

abstract class AnnouncementsState extends Equatable {
  const AnnouncementsState();
  @override
  List<Object> get props => [];
}

class AnnouncementsInitial extends AnnouncementsState {}

class AnnouncementsLoading extends AnnouncementsState {}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<AnnouncementModel> announcements;

  const AnnouncementsLoaded({required this.announcements});

  @override
  List<Object> get props => [announcements];
}

class AnnouncementsError extends AnnouncementsState {
  final String message;
  const AnnouncementsError({required this.message});
  @override
  List<Object> get props => [message];
}
