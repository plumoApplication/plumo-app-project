import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';

abstract class AnnouncementsRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements(String role);
}
