import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/models/class_instance.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _instanceDetailProvider =
    FutureProvider.autoDispose.family<ClassInstanceWithDetails, String>(
  (ref, id) async {
    final repo = ref.watch(classRepositoryProvider);
    return repo.getClassInstance(id);
  },
);

final _instanceBookingsProvider =
    FutureProvider.autoDispose.family<List<BookingDetailed>, String>(
  (ref, instanceId) async {
    final data = await Supabase.instance.client
        .from('bookings_detailed')
        .select()
        .eq('class_instance_id', instanceId)
        .inFilter('status', ['confirmed', 'waitlisted', 'attended', 'no_show'])
        .order('status')
        .order('booked_at');
    return data.map((json) => BookingDetailed.fromJson(json)).toList();
  },
);

class AdminInstanceScreen extends ConsumerStatefulWidget {
  final String instanceId;

  const AdminInstanceScreen({super.key, required this.instanceId});

  @override
  ConsumerState<AdminInstanceScreen> createState() =>
      _AdminInstanceScreenState();
}

class _AdminInstanceScreenState extends ConsumerState<AdminInstanceScreen> {
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instanceAsync =
        ref.watch(_instanceDetailProvider(widget.instanceId));
    final bookingsAsync =
        ref.watch(_instanceBookingsProvider(widget.instanceId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: instanceAsync.whenOrNull(
          data: (ci) => Text(ci.className ?? 'Tunni haldus'),
        ),
        actions: [
          instanceAsync.whenOrNull(
            data: (ci) => IconButton(
              icon: Icon(
                ci.isCancelled
                    ? Icons.restore_rounded
                    : Icons.cancel_outlined,
                color:
                    ci.isCancelled ? AppColors.success : AppColors.error,
              ),
              tooltip: ci.isCancelled ? 'Taasta tund' : 'Tühista tund',
              onPressed: () => _toggleCancel(ci),
            ),
          ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: instanceAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Laadimine ebaõnnestus',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.invalidate(_instanceDetailProvider(widget.instanceId)),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
        data: (ci) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(_instanceDetailProvider(widget.instanceId));
            ref.invalidate(_instanceBookingsProvider(widget.instanceId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero info card
                _buildHeroCard(context, ci),
                const SizedBox(height: 16),

                // Notes section
                _buildNotesSection(context, ci),
                const SizedBox(height: 16),

                // Bookings section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Broneerijad',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                bookingsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Broneerijate laadimine ebaõnnestus: $e'),
                  ),
                  data: (bookings) {
                    if (bookings.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Broneerijaid pole',
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: bookings
                          .map((b) => _BookingRow(
                                booking: b,
                                onStatusChange: (newStatus) =>
                                    _updateBookingStatus(b.id, newStatus),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, ClassInstanceWithDetails ci) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormatter.formatTime(ci.startTime)} – ${DateFormatter.formatTime(ci.endTime)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.formatDate(ci.date),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          if (ci.instructorName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  ci.instructorName!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${ci.confirmedCount}/${ci.maxParticipants} kohal',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
              if (ci.waitlistCount > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '(+${ci.waitlistCount} ootel)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ],
          ),
          if (ci.isCancelled) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TÜHISTATUD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(
      BuildContext context, ClassInstanceWithDetails ci) {
    if (_notesController.text.isEmpty && ci.notes != null) {
      _notesController.text = ci.notes ?? '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Märkused',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Lisa märkused selle tunni kohta...',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _isSaving ? null : () => _saveNotes(ci),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Salvesta märkused'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCancel(ClassInstanceWithDetails ci) async {
    final isCancelling = !ci.isCancelled;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius)),
        title: Text(isCancelling ? 'Tühista tund' : 'Taasta tund'),
        content: Text(
          isCancelling
              ? 'Kas soovite selle tunni tühistada?'
              : 'Kas soovite selle tunni taastada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ei'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isCancelling
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(isCancelling ? 'Tühista' : 'Taasta'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await Supabase.instance.client
          .from('class_instances')
          .update({'is_cancelled': isCancelling})
          .eq('id', widget.instanceId);

      ref.invalidate(_instanceDetailProvider(widget.instanceId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isCancelling ? 'Tund tühistatud' : 'Tund taastatud')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tegevus ebaõnnestus: $e')),
        );
      }
    }
  }

  Future<void> _saveNotes(ClassInstanceWithDetails ci) async {
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client
          .from('class_instances')
          .update({'notes': _notesController.text.trim()})
          .eq('id', widget.instanceId);

      ref.invalidate(_instanceDetailProvider(widget.instanceId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Märkused salvestatud')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Salvestamine ebaõnnestus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);

      ref.invalidate(_instanceBookingsProvider(widget.instanceId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staatus uuendatud')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uuendamine ebaõnnestus: $e')),
        );
      }
    }
  }
}

class _BookingRow extends StatelessWidget {
  final BookingDetailed booking;
  final void Function(String status) onStatusChange;

  const _BookingRow({required this.booking, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final statusColor = _statusColor(b.status);
    final statusLabel = _statusLabel(b.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Status indicator dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.instructorName ?? 'Kasutaja',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  statusLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
          // Quick status actions for confirmed bookings
          if (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.attended ||
              b.status == BookingStatus.noShow)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  size: 18, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppShape.cardRadius)),
              onSelected: onStatusChange,
              itemBuilder: (_) => [
                if (b.status != BookingStatus.attended)
                  const PopupMenuItem(
                    value: 'attended',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 18, color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Kohal'),
                      ],
                    ),
                  ),
                if (b.status != BookingStatus.noShow)
                  const PopupMenuItem(
                    value: 'no_show',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Ei ilmunud'),
                      ],
                    ),
                  ),
                if (b.status == BookingStatus.attended ||
                    b.status == BookingStatus.noShow)
                  const PopupMenuItem(
                    value: 'confirmed',
                    child: Row(
                      children: [
                        Icon(Icons.restore_rounded,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Kinnita'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.waitlisted:
        return AppColors.warning;
      case BookingStatus.attended:
        return AppColors.primary;
      case BookingStatus.noShow:
        return AppColors.error;
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Kinnitatud';
      case BookingStatus.waitlisted:
        return 'Ootenimekiri';
      case BookingStatus.attended:
        return 'Kohal';
      case BookingStatus.noShow:
        return 'Ei ilmunud';
      case BookingStatus.cancelled:
        return 'Tühistatud';
    }
  }
}
