import '../entities/shared_ride_detail.dart';

abstract class SharedRideRepository {
  Future<SharedRideDetail> getSharedRideDetail({required String detailApi});
}
