import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/session_card.dart';
import 'package:kati_pilates/providers/card_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin screen to create a new session card for a client.
class CreateCardScreen extends ConsumerStatefulWidget {
  final String userId;

  const CreateCardScreen({super.key, required this.userId});

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();

  CardType _cardType = CardType.tenSessions;
  final _priceController = TextEditingController();
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 90));
  bool _isSaving = false;

  static const _cardTypeLabels = {
    CardType.fourSessions: '4 sessiooni',
    CardType.fiveSessions: '5 sessiooni',
    CardType.tenSessions: '10 sessiooni',
  };

  static const _cardTypeSessions = {
    CardType.fourSessions: 4,
    CardType.fiveSessions: 5,
    CardType.tenSessions: 10,
  };

  // Default prices in cents (can be overridden)
  static const _defaultPrices = {
    CardType.fourSessions: 6000, // 60 EUR
    CardType.fiveSessions: 7500, // 75 EUR
    CardType.tenSessions: 14000, // 140 EUR
  };

  @override
  void initState() {
    super.initState();
    _priceController.text =
        (_defaultPrices[_cardType]! / 100).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Loo uus kaart'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card type selection
              _SectionLabel(label: 'Kaardi tüüp'),
              const SizedBox(height: 8),
              ...CardType.values.map((type) => RadioListTile<CardType>(
                    value: type,
                    groupValue: _cardType,
                    title: Text(_cardTypeLabels[type]!),
                    subtitle: Text(
                        '${_cardTypeSessions[type]} sessiooni'),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _cardType = v;
                          _priceController.text =
                              (_defaultPrices[v]! / 100)
                                  .toStringAsFixed(2);
                        });
                      }
                    },
                  )),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Hind (EUR) *',
                  prefixText: '€ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (n == null || n < 0) return 'Sisesta kehtiv hind';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Valid from
              _SectionLabel(label: 'Kehtib alates'),
              const SizedBox(height: 8),
              _DatePickerField(
                date: _validFrom,
                onDateSelected: (d) => setState(() {
                  _validFrom = d;
                  if (_validUntil.isBefore(d)) {
                    _validUntil = d.add(const Duration(days: 90));
                  }
                }),
              ),
              const SizedBox(height: 16),

              // Valid until
              _SectionLabel(label: 'Kehtib kuni'),
              const SizedBox(height: 8),
              _DatePickerField(
                date: _validUntil,
                firstDate: _validFrom,
                onDateSelected: (d) => setState(() => _validUntil = d),
              ),
              const SizedBox(height: 8),

              // Duration info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.primaryDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Kaardi kehtivus: ${_validUntil.difference(_validFrom).inDays} päeva',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryDark,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _createCard,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Loo kaart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final sessions = _cardTypeSessions[_cardType]!;
      final priceText = _priceController.text.replaceAll(',', '.');
      final priceCents = (double.parse(priceText) * 100).round();

      await Supabase.instance.client.from('session_cards').insert({
        'user_id': widget.userId,
        'card_type': _cardTypeJsonValue(_cardType),
        'total_sessions': sessions,
        'remaining_sessions': sessions,
        'price_cents': priceCents,
        'valid_from': _validFrom.toIso8601String().split('T')[0],
        'valid_until': _validUntil.toIso8601String().split('T')[0],
        'original_valid_until': _validUntil.toIso8601String().split('T')[0],
        'status': 'active',
        'purchased_at': DateTime.now().toIso8601String(),
      });

      // Invalidate card providers
      ref.invalidate(cardRepositoryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaart loodud edukalt!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaardi loomine ebaõnnestus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _cardTypeJsonValue(CardType type) {
    switch (type) {
      case CardType.fourSessions:
        return '4_sessions';
      case CardType.fiveSessions:
        return '5_sessions';
      case CardType.tenSessions:
        return '10_sessions';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final DateTime? firstDate;
  final void Function(DateTime) onDateSelected;

  const _DatePickerField({
    required this.date,
    this.firstDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('et'),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          border: Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
