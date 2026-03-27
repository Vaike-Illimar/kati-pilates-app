import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/admin_notification.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/notification_provider.dart';
import 'package:kati_pilates/features/admin/notifications/screens/select_recipients_screen.dart';

class CreateNotificationScreen extends ConsumerStatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  ConsumerState<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState
    extends ConsumerState<CreateNotificationScreen> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  NotificationType _selectedType = NotificationType.uudine;
  bool _sendNow = true;
  DateTime? _scheduledAt;
  bool _isSending = false;

  // Recipients state
  bool _allClients = true;
  List<String> _selectedRecipientIds = [];
  String _recipientsLabel = 'Kõik kliendid (24)';

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String _typeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.uudine:
        return 'Uudine';
      case NotificationType.meeldetuletus:
        return 'Meeldetuletus';
      case NotificationType.oluline:
        return 'Oluline';
    }
  }

  Future<void> _selectRecipients() async {
    final result = await Navigator.of(context).push<RecipientSelection>(
      MaterialPageRoute(
        builder: (_) => SelectRecipientsScreen(
          allClientsSelected: _allClients,
          selectedIds: _selectedRecipientIds,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _allClients = result.allClients;
        _selectedRecipientIds = result.selectedIds;
        _recipientsLabel = result.label;
      });
    }
  }

  Future<void> _pickScheduleDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _sendNotification() async {
    if (_subjectController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palun täida kõik väljad')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final user = ref.read(currentUserProvider);
      final repo = ref.read(notificationRepositoryProvider);

      final notification = await repo.createNotification(
        senderId: user?.id ?? '',
        subject: _subjectController.text.trim(),
        body: _bodyController.text.trim(),
        notificationType: _selectedType.name,
        scheduledAt: _sendNow ? null : _scheduledAt,
      );

      // If sending now, trigger the send
      if (_sendNow) {
        final sent = await repo.sendNotification(
          notification.id,
          _selectedRecipientIds,
        );
        if (mounted) {
          context.pushReplacement(
            '/admin/notifications/sent',
            extra: sent,
          );
        }
      } else {
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viga: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _saveDraft() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lisa vähemalt teema')),
      );
      return;
    }

    try {
      final user = ref.read(currentUserProvider);
      final repo = ref.read(notificationRepositoryProvider);

      await repo.createNotification(
        senderId: user?.id ?? '',
        subject: _subjectController.text.trim(),
        body: _bodyController.text.trim(),
        notificationType: _selectedType.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mustand salvestatud')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viga: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Uus teavitus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipients
                  _SectionLabel(label: 'Saajad'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectRecipients,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius:
                            BorderRadius.circular(AppShape.cardRadius),
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _recipientsLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Subject
                  _SectionLabel(label: 'Teema'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      hintText: 'Teavituse teema',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // Message body
                  _SectionLabel(label: 'Sõnum'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      hintText: 'Kirjuta sõnum...',
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 5,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // Type chips
                  _SectionLabel(label: 'Tüüp'),
                  const SizedBox(height: 8),
                  Row(
                    children: NotificationType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_typeLabel(type)),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedType = type),
                          selectedColor: AppColors.primaryLight,
                          backgroundColor: AppColors.cardWhite,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            width: 1,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Schedule toggle
                  _SectionLabel(label: 'Ajastamine'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius:
                          BorderRadius.circular(AppShape.cardRadius),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _sendNow ? 'Saada kohe' : 'Ajastatud',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Switch(
                              value: !_sendNow,
                              onChanged: (val) {
                                setState(() {
                                  _sendNow = !val;
                                  if (!_sendNow) _scheduledAt = null;
                                });
                              },
                              activeTrackColor: AppColors.primaryLight,
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                        if (!_sendNow) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickScheduleDateTime,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                    AppShape.badgeRadius),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _scheduledAt != null
                                        ? '${_scheduledAt!.day}.${_scheduledAt!.month.toString().padLeft(2, '0')}.${_scheduledAt!.year} '
                                          '${_scheduledAt!.hour.toString().padLeft(2, '0')}:${_scheduledAt!.minute.toString().padLeft(2, '0')}'
                                        : 'Vali kuupäev ja kellaaeg',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _scheduledAt != null
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Preview
                  _SectionLabel(label: 'Eelvaade'),
                  const SizedBox(height: 8),
                  _NotificationPreview(
                    subject: _subjectController.text,
                    body: _bodyController.text,
                    type: _selectedType,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSending ? null : _sendNotification,
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Saada teavitus'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isSending ? null : _saveDraft,
                    child: const Text('Salvesta mustandina'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification preview card
// ---------------------------------------------------------------------------

class _NotificationPreview extends StatelessWidget {
  final String subject;
  final String body;
  final NotificationType type;

  const _NotificationPreview({
    required this.subject,
    required this.body,
    required this.type,
  });

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.uudine:
        return Icons.newspaper_rounded;
      case NotificationType.meeldetuletus:
        return Icons.alarm_rounded;
      case NotificationType.oluline:
        return Icons.priority_high_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = subject.isNotEmpty || body.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: hasContent
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(type),
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subject.isNotEmpty)
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Eelvaade ilmub siia',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
    );
  }
}
