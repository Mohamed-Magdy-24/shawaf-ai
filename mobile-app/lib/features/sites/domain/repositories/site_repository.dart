import '../../../../models/models.dart';

abstract class ISiteRepository {
  Future<List<Site>> getSites();
}
