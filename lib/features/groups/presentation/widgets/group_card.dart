import 'package:flutter/material.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/models/trip_net_summary.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.trip,
    required this.summary,
    required this.onTap,
  });

  final ShortTripModel trip;
  final TripNetSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[800],
          ),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/trip.png'),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Opacity(
                    opacity: summary.settled ? 0.5 : 0.9,
                    child: Text(
                      summary.message,
                      style: TextStyle(
                        color: summary.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
