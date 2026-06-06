import 'package:equatable/equatable.dart';
import '../../domain/entities/shared_ride_offer.dart';
import '../../domain/entities/shipment_offer.dart';

enum OffersStatus { initial, loading, success, failure, empty }

class OffersState extends Equatable {
  const OffersState({
    this.status = OffersStatus.initial,
    this.sharedRides = const [],
    this.shipments = const [],
    this.errorMessage,
  });

  final OffersStatus status;
  final List<SharedRideOffer> sharedRides;
  final List<ShipmentOffer> shipments;
  final String? errorMessage;

  OffersState copyWith({
    OffersStatus? status,
    List<SharedRideOffer>? sharedRides,
    List<ShipmentOffer>? shipments,
    String? errorMessage,
  }) {
    return OffersState(
      status: status ?? this.status,
      sharedRides: sharedRides ?? this.sharedRides,
      shipments: shipments ?? this.shipments,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sharedRides, shipments, errorMessage];
}
