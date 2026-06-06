import 'package:equatable/equatable.dart';

import '../entities/bus_booking.dart';
import '../repositories/bus_booking_repository.dart';

class CreateOfferBookingParams extends Equatable {
  const CreateOfferBookingParams({
    required this.offerId,
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.price,
  });

  final String offerId;
  final String pickupLocationId;
  final String dropoffLocationId;
  final double price;

  @override
  List<Object?> get props => [
    offerId,
    pickupLocationId,
    dropoffLocationId,
    price,
  ];
}

class CreateOfferBookingUseCase {
  CreateOfferBookingUseCase(this._repository);

  final BusBookingRepository _repository;

  Future<BusBooking> call(CreateOfferBookingParams params) {
    return _repository.createOfferBooking(
      offerId: params.offerId,
      pickupLocationId: params.pickupLocationId,
      dropoffLocationId: params.dropoffLocationId,
      price: params.price,
    );
  }
}
