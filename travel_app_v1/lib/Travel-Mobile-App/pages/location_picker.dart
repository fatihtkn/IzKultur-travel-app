import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final LatLng initialPosition;
  final bool isDetailCard;

  const LocationPicker({
    super.key,
    required this.initialPosition,
    this.isDetailCard = false,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng selectedPosition;
  late CameraPosition _lastCameraPosition;
  late double _lastZoom;
  bool _isZooming = false;
  static const double _initialZoom = 13;

  @override
  void initState() {
    super.initState();
    selectedPosition = widget.initialPosition;
    _lastCameraPosition = CameraPosition(
      target: widget.initialPosition,
      zoom: _initialZoom,
    );
    _lastZoom = _initialZoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isDetailCard
          ? AppBar()
          : AppBar(title: const Text("Konum Seç")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _lastCameraPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            scrollGesturesEnabled: true, // Her iki modda da hareket edebilir
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            // Marker sadece isDetailCard true iken sabit gösterilecek
            markers: widget.isDetailCard
                ? {
                    Marker(
                      markerId: const MarkerId('static_marker'),
                      position: widget.initialPosition,
                    ),
                  }
                : {},
            onCameraMove: (CameraPosition pos) {
              if (widget.isDetailCard) return;

              // Zoom hareketini ayır
              if ((pos.zoom - _lastZoom).abs() > 1e-6) {
                _isZooming = true;
                _lastZoom = pos.zoom;
              } else {
                _isZooming = false;
              }

              _lastCameraPosition = pos;
            },
            onCameraIdle: () {
              if (widget.isDetailCard) return;

              if (!_isZooming) {
                setState(() {
                  selectedPosition = _lastCameraPosition.target;
                });
              }
            },
          ),

          // Ekran ortasındaki kırmızı icon sadece seçim modunda görünür
          if (!widget.isDetailCard)
            const Center(
              child: Icon(Icons.location_on, size: 40, color: Colors.red),
            ),

          // Buton sadece seçim modunda görünür
          if (!widget.isDetailCard)
            Positioned(
              bottom: 20,
              left: 70,
              right: 70,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedPosition),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Bu Konumu Seç",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
