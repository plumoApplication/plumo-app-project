import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_cubit.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_state.dart';

class DriverTripDetailPage extends StatelessWidget {
  final TripEntity trip;

  const DriverTripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DriverTripDetailsCubit>()..fetchPassengers(trip.id!),
      child: _DriverTripDetailView(trip: trip),
    );
  }
}

class _DriverTripDetailView extends StatefulWidget {
  final TripEntity trip;
  const _DriverTripDetailView({required this.trip});

  @override
  State<_DriverTripDetailView> createState() => _DriverTripDetailViewState();
}

class _DriverTripDetailViewState extends State<_DriverTripDetailView> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  /// Configura os Marcadores e a Linha da rota
  void _setupMapElements() {
    final waypoints = widget.trip.waypoints;
    if (waypoints.isEmpty) return;

    // 1. Cria os Marcadores (Pins)
    for (var i = 0; i < waypoints.length; i++) {
      final wp = waypoints[i];
      final isOrigin = i == 0;
      final isDest = i == waypoints.length - 1;

      // Define a cor do marcador (Verde=Inicio, Vermelho=Fim, Azul=Meio)
      double hue = BitmapDescriptor.hueAzure;
      if (isOrigin) hue = BitmapDescriptor.hueGreen;
      if (isDest) hue = BitmapDescriptor.hueRed;

      _markers.add(
        Marker(
          markerId: MarkerId(wp.id ?? 'wp_$i'),
          position: LatLng(wp.latitude, wp.longitude),
          infoWindow: InfoWindow(
            title: wp.placeName,
            snippet: isOrigin ? 'Origem' : (isDest ? 'Destino' : 'Parada $i'),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        ),
      );
    }

    // 2. Cria uma linha simples conectando os pontos (Polyline)
    final List<LatLng> polylineCoordinates = waypoints
        .map((wp) => LatLng(wp.latitude, wp.longitude))
        .toList();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('trip_route'),
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      ),
    );
  }

  /// Ajusta o zoom do mapa para caber todos os pontos
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_markers.isEmpty) return;

    // Pequeno delay para o mapa carregar antes de mover a câmera
    Future.delayed(const Duration(milliseconds: 500), () {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_calculateBounds(_markers), 50),
      );
    });
  }

  /// Helper para calcular os limites (bounds) dos marcadores
  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = 90.0;
    double minLng = 180.0;
    double maxLat = -90.0;
    double maxLng = -180.0;

    for (final marker in markers) {
      final pos = marker.position;
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes da Viagem")),
      body: Column(
        children: [
          // --- O MAPA (Topo) ---
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.trip.originLat ?? -14.2350,
                  widget.trip.originLng ?? -51.9253,
                ),
                zoom: 10,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: false, // Simplificado para MVP
            ),
          ),

          // --- TÍTULO DA LISTA ---
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade100,
            child: const Text(
              "Passageiros Confirmados",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // --- LISTA DE PASSAGEIROS (Manifesto) ---
          Expanded(
            child: BlocBuilder<DriverTripDetailsCubit, DriverTripDetailsState>(
              builder: (context, state) {
                if (state is DriverTripDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DriverTripDetailsError) {
                  return Center(child: Text('Erro: ${state.message}'));
                }
                if (state is DriverTripDetailsLoaded) {
                  if (state.passengers.isEmpty) {
                    return const Center(
                      child: Text('Nenhum passageiro confirmado ainda.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: state.passengers.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final booking = state.passengers[index];
                      return _buildPassengerTile(booking);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // --- BOTÃO DE AÇÃO (Futuro) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  //Iniciar Viagem / Waze
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Iniciar viagem: Em breve!")),
                  );
                },
                icon: const Icon(Icons.navigation),
                label: const Text("Iniciar Viagem"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerTile(BookingEntity booking) {
    final name = booking.passengerProfile?.fullName ?? 'Passageiro';
    final status = booking.status ?? 'unknown';

    // Define ícone baseado no status
    IconData icon = Icons.help_outline;
    Color color = Colors.grey;

    if (status == 'paid') {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (status == 'approved') {
      icon = Icons.access_time; // Aguardando pgto
      color = Colors.orange;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Text(name[0].toUpperCase()),
      ),
      title: Text(name),
      subtitle: Text('Status: ${status.toUpperCase()}'),
      trailing: Icon(icon, color: color),
      onTap: () {
        // Futuro: Ver detalhes do passageiro
      },
    );
  }
}
