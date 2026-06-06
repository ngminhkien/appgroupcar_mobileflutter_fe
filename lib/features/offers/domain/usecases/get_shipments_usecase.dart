import '../entities/shipment_offer.dart';
import '../repositories/offers_repository.dart';

class GetShipmentsUseCase {
  GetShipmentsUseCase(this._repository);

  final OffersRepository _repository;

  Future<List<ShipmentOffer>> call({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _repository.getShipments(
      pickupLocationId: pickupLocationId,
      dropoffLocationId: dropoffLocationId,
      startTime: startTime,
      endTime: endTime,
      startPrice: startPrice,
      endPrice: endPrice,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
