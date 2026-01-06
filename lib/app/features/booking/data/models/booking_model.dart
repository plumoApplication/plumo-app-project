import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/profile/data/models/profile_model.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    super.id,
    required super.tripId,
    required super.passengerId,
    required super.driverId,
    super.status,
    super.paymentStatus,
    required super.totalPrice,
    required super.originName,
    required super.destinationName,
    required super.seats,
    super.paymentId,
    super.createdAt,
    super.pickupLat,
    super.pickupLng,
    super.pickupAddress,
    super.trip,
    super.passengerProfile,
    super.driverProfile,
    super.message,
    super.paymentMethod,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String?,
      tripId: map['trip_id'] as String,
      passengerId: map['passenger_id'] as String,
      driverId: map['driver_id'] as String,
      status: map['status'] as String?,
      paymentStatus: map['payment_status'] as String?,
      totalPrice: double.tryParse(map['total_price'].toString()) ?? 0.0,

      // Mapeamento correto com o banco
      originName: map['origin_name'] as String,
      destinationName: map['destination_name'] as String,
      seats: map['seats'] as int? ?? 1,

      paymentId: map['payment_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,

      pickupLat: map['pickup_lat'] != null
          ? (map['pickup_lat'] as num).toDouble()
          : null,
      pickupLng: map['pickup_lng'] != null
          ? (map['pickup_lng'] as num).toDouble()
          : null,
      pickupAddress: map['pickup_address'] as String?,

      trip: map['trips'] != null
          ? TripModel.fromMap(map['trips'] as Map<String, dynamic>)
          : null,

      passengerProfile: map['passenger'] != null
          ? ProfileModel.fromMap(map['passenger'] as Map<String, dynamic>)
          : null,

      driverProfile: map['driver'] != null
          ? ProfileModel.fromMap(map['driver'] as Map<String, dynamic>)
          : null,

      message: map['message'] as String?,
      paymentMethod: map['payment_method'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trip_id': tripId,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'status': status,
      'payment_status': paymentStatus,
      'total_price': totalPrice,
      'origin_name': originName,
      'destination_name': destinationName,
      'seats': seats,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'message': message,
      'payment_method': paymentMethod,
    };
  }
}
