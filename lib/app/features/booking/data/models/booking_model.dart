import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';

// O Modelo de Dados que sabe ler/escrever no Supabase
class BookingModel extends BookingEntity {
  const BookingModel({
    super.id,
    required super.tripId,
    required super.passengerId,
    required super.driverId,
    super.status,
    required super.totalPrice,
    required super.originWaypointId,
    required super.destinationWaypointId,
    super.paymentId,
    super.createdAt,
    super.trip,
  });

  /// Construtor de fábrica: 'fromMap' (Lê do Supabase)
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      passengerId: map['passenger_id'] as String,
      driverId: map['driver_id'] as String,
      status: map['status'] as String,
      totalPrice: double.parse(map['total_price'].toString()),
      originWaypointId: map['origin_waypoint_id'] as String,
      destinationWaypointId: map['destination_waypoint_id'] as String,
      paymentId: map['payment_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      trip: map['trips'] == null
          ? null
          : TripModel.fromMap(map['trips'] as Map<String, dynamic>),
    );
  }

  /// Método 'toMap': (Escreve no Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'status': status,
      'total_price': totalPrice,
      'origin_waypoint_id': originWaypointId,
      'destination_waypoint_id': destinationWaypointId,
      'payment_id': paymentId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
