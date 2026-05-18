import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    required this.entityType,
    this.size = 58,
  });

  final String? category;
  final String entityType;
  final double size;

  // =====================================================
  // ICON
  // =====================================================

  IconData _icon() {
    if (entityType == 'trip') {
      return Icons.groups_rounded;
    }

    if (entityType == 'payment') {
      return Icons.payments_rounded;
    }

    switch (category) {
      // ENTERTAINMENT
      case 'games':
        return Icons.sports_esports_rounded;

      case 'movies':
        return Icons.movie_creation_outlined;

      case 'music':
        return Icons.music_note_rounded;

      // FOOD
      case 'groceries':
        return Icons.shopping_cart_rounded;

      case 'dining':
        return Icons.restaurant_rounded;

      case 'liquor':
        return Icons.local_bar_rounded;

      // HOME
      case 'mortgage':
        return Icons.home_rounded;

      case 'household-supplies':
        return Icons.inventory_2_rounded;

      case 'furniture':
        return Icons.chair_rounded;

      case 'cleaning':
        return Icons.cleaning_services_rounded;

      case 'maintenance':
        return Icons.build_rounded;

      // UTILITIES
      case 'electricity':
        return Icons.bolt_rounded;

      case 'gas':
        return Icons.local_fire_department_rounded;

      case 'internet':
        return Icons.wifi_rounded;

      case 'water':
        return Icons.water_drop_rounded;

      case 'trash':
        return Icons.delete_outline_rounded;

      // TRANSPORT
      case 'car':
        return Icons.directions_car_rounded;

      case 'bus-train':
        return Icons.train_rounded;

      case 'fuel':
        return Icons.local_gas_station_rounded;

      case 'plane':
        return Icons.flight_rounded;

      case 'taxi':
        return Icons.local_taxi_rounded;

      case 'bicycle':
        return Icons.pedal_bike_rounded;

      case 'parking':
        return Icons.local_parking_rounded;

      // PERSONAL
      case 'medical':
        return Icons.medical_services_outlined;

      case 'education':
        return Icons.school_rounded;

      case 'clothing':
        return Icons.checkroom_rounded;

      case 'pets':
        return Icons.pets_rounded;

      case 'gifts':
        return Icons.card_giftcard_rounded;

      // TRAVEL / HOTEL
      case 'hotel':
        return Icons.hotel_rounded;

      // SPORTS
      case 'sports':
        return Icons.sports_cricket_outlined;

      // SERVICES
      case 'services':
        return Icons.miscellaneous_services_rounded;

      // TECH
      case 'electronics':
        return Icons.devices_rounded;

      default:
        return Icons.receipt_long_rounded;
    }
  }

  // =====================================================
  // GROUP COLOR
  // =====================================================

  ({Color bg, Color fg}) _colors(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    // PAYMENT
    if (entityType == 'payment') {
      return (
        bg: const Color(0xFFDCFCE7),
        fg: const Color(0xFF16A34A),
      );
    }

    // TRIP
    if (entityType == 'trip') {
      return (
        bg: primary.withOpacity(0.14),
        fg: primary,
      );
    }

    switch (category) {
      // =====================================================
      // ENTERTAINMENT -> PURPLE
      // =====================================================

      case 'games':
      case 'movies':
      case 'music':
        return (
          bg: const Color(0xFFF3E8FF),
          fg: const Color(0xFF9333EA),
        );

      // =====================================================
      // FOOD -> ORANGE
      // =====================================================

      case 'groceries':
      case 'dining':
      case 'liquor':
        return (
          bg: const Color(0xFFFFEDD5),
          fg: const Color(0xFFEA580C),
        );

      // =====================================================
      // HOME -> BROWN
      // =====================================================

      case 'mortgage':
      case 'household-supplies':
      case 'furniture':
      case 'maintenance':
      case 'cleaning':
        return (
          bg: const Color(0xFFEFEBE9),
          fg: const Color(0xFF6D4C41),
        );

      // =====================================================
      // UTILITIES -> BLUE
      // =====================================================

      case 'electricity':
      case 'gas':
      case 'internet':
      case 'water':
      case 'trash':
        return (
          bg: const Color(0xFFE0F2FE),
          fg: const Color(0xFF0284C7),
        );

      // =====================================================
      // TRANSPORT -> CYAN
      // =====================================================

      case 'car':
      case 'bus-train':
      case 'fuel':
      case 'plane':
      case 'taxi':
      case 'bicycle':
      case 'parking':
        return (
          bg: const Color(0xFFCCFBF1),
          fg: const Color(0xFF0F766E),
        );

      // =====================================================
      // PERSONAL -> PINK
      // =====================================================

      case 'medical':
      case 'education':
      case 'clothing':
      case 'pets':
      case 'gifts':
        return (
          bg: const Color(0xFFFCE7F3),
          fg: const Color(0xFFDB2777),
        );

      // =====================================================
      // SPORTS -> GREEN
      // =====================================================

      case 'sports':
        return (
          bg: const Color(0xFFDCFCE7),
          fg: const Color(0xFF16A34A),
        );

      // =====================================================
      // HOTEL / SERVICES / TECH
      // =====================================================

      case 'hotel':
      case 'services':
      case 'electronics':
        return (
          bg: const Color(0xFFE2E8F0),
          fg: const Color(0xFF475569),
        );

      // =====================================================
      // DEFAULT
      // =====================================================

      default:
        return (
          bg: primary.withOpacity(0.14),
          fg: primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.bg,
      ),
      child: Icon(
        _icon(),
        size: size * 0.48,
        color: colors.fg,
      ),
    );
  }
}
