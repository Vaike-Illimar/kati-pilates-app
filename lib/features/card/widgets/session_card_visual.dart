import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/session_card.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';

/// A reusable gradient card widget showing session card details.
class SessionCardVisual extends StatelessWidget {
  final SessionCard card;

  const SessionCardVisual({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative circle in upper-right area
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Decorative circle in lower-left area
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card type label
                Text(
                  _cardTypeName(card),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                // Large remaining sessions number
                Text(
                  '${card.remainingSessions}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 56,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 4),
                // "X-st tunnist" subtitle
                Text(
                  '${card.totalSessions}-st tunnist',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 8),
                // Valid until date
                Text(
                  'Kehtib kuni ${DateFormatter.formatDate(card.validUntil)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cardTypeName(SessionCard card) {
    return '${card.totalSessions}-tunnine kaart';
  }
}
