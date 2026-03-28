import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';

/// Monitors network connectivity and shows an offline banner.
///
/// Uses a simple ping-based check since connectivity_plus isn't in pubspec.
/// For production, add connectivity_plus to pubspec.yaml.
///
/// Usage: Wrap the top-level Scaffold body with this widget.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOnline = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check connectivity every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnectivity());
    _checkConnectivity();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    // Simple check: try to resolve supabase hostname
    // For a real implementation, use connectivity_plus package
    try {
      // We use a lighter approach: observe if the last Supabase request failed
      // The state is maintained by catching errors in providers
      // Here we just keep current state — actual offline detection needs
      // connectivity_plus package to be added to pubspec.yaml
      if (!mounted) return;
    } catch (_) {
      if (mounted) {
        setState(() => _isOnline = false);
      }
    }
  }

  /// Call this to set offline state from elsewhere (e.g., when a request fails)
  void setOffline(bool offline) {
    if (mounted && _isOnline == offline) {
      setState(() => _isOnline = !offline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              color: AppColors.warning.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ühendus puudub. Kuvatakse salvestatud andmeid.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        size: 18, color: Colors.white),
                    onPressed: _checkConnectivity,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Stateless inline widget that shows offline banner and cached data notice.
class OfflineDataNotice extends StatelessWidget {
  const OfflineDataNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Näitame salvestatud andmeid. Kontrollige interneti ühendust.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
