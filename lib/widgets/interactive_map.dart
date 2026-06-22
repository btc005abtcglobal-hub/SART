import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class InteractiveMapWidget extends StatefulWidget {
  final String mode; // e.g. 'Rides', 'Parking', 'SOS', 'Mechanic', 'General'
  final Function(double lat, double lng, String address)? onLocationSelected;
  final bool showRoute;
  final String? customDestination;

  const InteractiveMapWidget({
    super.key,
    required this.mode,
    this.onLocationSelected,
    this.showRoute = false,
    this.customDestination,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> with SingleTickerProviderStateMixin {
  Offset? _userPin;
  late AnimationController _animationController;
  final List<Map<String, dynamic>> _nearbyPins = [];
  String _pinnedAddress = "Tap map to set location";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _generateNearbyPins();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateNearbyPins() {
    final Random random = Random();
    final String iconType = widget.mode == 'Parking'
        ? 'local_parking'
        : widget.mode == 'SOS'
            ? 'local_hospital'
            : widget.mode == 'Mechanic'
                ? 'build'
                : 'directions_car';

    // Generate some random positions around the center
    for (int i = 0; i < 5; i++) {
      _nearbyPins.add({
        'x': 100.0 + random.nextDouble() * 200.0,
        'y': 80.0 + random.nextDouble() * 160.0,
        'type': iconType,
        'label': '${widget.mode} Unit #${100 + i}',
        'status': random.nextBool() ? 'Available' : 'Busy',
      });
    }
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints) {
    setState(() {
      _userPin = details.localPosition;
      final lat = 12.9716 + (0.5 - _userPin!.dy / constraints.maxHeight) * 0.05;
      final lng = 77.5946 + (_userPin!.dx / constraints.maxWidth - 0.5) * 0.05;
      _pinnedAddress = "${(100 + _userPin!.dx / 2).toInt()} Metro Layout, Indiranagar, Bangalore";
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(lat, lng, _pinnedAddress);
      }
    });
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'local_parking':
        return Icons.local_parking;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'build':
        return Icons.build;
      default:
        return Icons.electric_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        
        // If showRoute is enabled but user hasn't pinned anything, place a mock pin
        if (widget.showRoute && _userPin == null) {
          _userPin = Offset(constraints.maxWidth * 0.75, constraints.maxHeight * 0.3);
          _pinnedAddress = widget.customDestination ?? "Manipal Hospital Hub, Bangalore";
        }

        return GestureDetector(
          onTapUp: (details) => _handleTap(details, constraints),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // 1. Vector Map Grid Paint
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _MapGridPainter(
                    isDark: isDark,
                    userPin: _userPin,
                    center: center,
                    showRoute: widget.showRoute,
                    pulseValue: _animationController,
                  ),
                ),

                // 2. Center User Marker (My Location)
                Positioned(
                  left: center.dx - 18,
                  top: center.dy - 18,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Nearby Mock Nodes Markers
                ..._nearbyPins.map((pin) {
                  return Positioned(
                    left: pin['x'] - 14,
                    top: pin['y'] - 14,
                    child: Tooltip(
                      message: '${pin['label']} • ${pin['status']}',
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _userPin = Offset(pin['x'], pin['y']);
                            _pinnedAddress = pin['label'];
                            if (widget.onLocationSelected != null) {
                              widget.onLocationSelected!(12.9716, 77.5946, pin['label']);
                            }
                          });
                        },
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: pin['status'] == 'Available' 
                                    ? Colors.green.withValues(alpha: 0.2) 
                                    : AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: pin['status'] == 'Available' ? Colors.green : AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _getIconData(pin['type']),
                                size: 14,
                                color: pin['status'] == 'Available' ? Colors.green : AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),

                // 4. Pin Placed by User
                if (_userPin != null) ...[
                  Positioned(
                    left: _userPin!.dx - 15,
                    top: _userPin!.dy - 34,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 32,
                      ),
                    ),
                  ),
                ],

                // 5. HUD Telemetry overlay info panel
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.mode == 'SOS'
                                ? Icons.emergency
                                : widget.mode == 'Parking'
                                    ? Icons.local_parking
                                    : Icons.navigation_outlined,
                            color: widget.mode == 'SOS' ? AppColors.error : AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.mode == 'SOS' ? 'SOS Active Coordinates' : 'Selected Destination',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _pinnedAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (_userPin != null) ...[
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('ETA', style: TextStyle(fontSize: 9, color: AppColors.darkTextSecondary)),
                              Text('6 Mins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.green)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final bool isDark;
  final Offset? userPin;
  final Offset center;
  final bool showRoute;
  final Animation<double> pulseValue;

  _MapGridPainter({
    required this.isDark,
    this.userPin,
    required this.center,
    required this.showRoute,
    required this.pulseValue,
  }) : super(repaint: pulseValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final Paint roadPaint = Paint()
      ..color = isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFF94A3B8).withValues(alpha: 0.2)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 1. Draw grid backdrop lines
    const double step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 2. Draw mock highway roads
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.6), roadPaint);

    // 3. Draw animated route line
    if (showRoute && userPin != null) {
      final Paint routeBgPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.2)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final Paint routeLinePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final Path routePath = Path();
      routePath.moveTo(center.dx, center.dy);
      
      // Draw grid-aligned path (simulating city navigation)
      final midPointX = center.dx + (userPin!.dx - center.dx) * 0.4;
      routePath.lineTo(midPointX, center.dy);
      routePath.lineTo(midPointX, userPin!.dy);
      routePath.lineTo(userPin!.dx, userPin!.dy);

      canvas.drawPath(routePath, routeBgPaint);

      // Dash pattern mapping using animation pulse
      final double dashOffset = pulseValue.value * 50.0;
      final Path dashPath = _buildDashPath(routePath, 10.0, 8.0, dashOffset);
      canvas.drawPath(dashPath, routeLinePaint);
    }
  }

  Path _buildDashPath(Path source, double dashLength, double gapLength, double offset) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = offset % (dashLength + gapLength);
      if (distance > dashLength) {
        distance = distance - dashLength;
      } else {
        distance = 0.0;
      }
      
      while (distance < metric.length) {
        final double len = min(dashLength, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += len + gapLength;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.userPin != userPin ||
        oldDelegate.showRoute != showRoute ||
        oldDelegate.isDark != isDark;
  }
}
