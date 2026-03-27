import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';

// ---------------------------------------------------------------------------
// Recipient selection result
// ---------------------------------------------------------------------------

class RecipientSelection {
  final bool allClients;
  final List<String> selectedIds;
  final String label;

  const RecipientSelection({
    required this.allClients,
    required this.selectedIds,
    required this.label,
  });
}

// ---------------------------------------------------------------------------
// Mock data for groups and clients
// ---------------------------------------------------------------------------

class _GroupOption {
  final String id;
  final String name;
  final int memberCount;

  const _GroupOption({
    required this.id,
    required this.name,
    required this.memberCount,
  });
}

class _ClientOption {
  final String id;
  final String name;

  const _ClientOption({required this.id, required this.name});
}

const _mockGroups = [
  _GroupOption(id: 'g1', name: 'Esmaspäev 18:00', memberCount: 8),
  _GroupOption(id: 'g2', name: 'Teisipäev 10:00', memberCount: 6),
  _GroupOption(id: 'g3', name: 'Kolmapäev 19:00', memberCount: 8),
  _GroupOption(id: 'g4', name: 'Neljapäev 10:00', memberCount: 6),
];

const _mockClients = [
  _ClientOption(id: 'u1', name: 'Mari Tamm'),
  _ClientOption(id: 'u2', name: 'Kati Kask'),
  _ClientOption(id: 'u3', name: 'Liisa Mets'),
  _ClientOption(id: 'u4', name: 'Anna Põld'),
  _ClientOption(id: 'u5', name: 'Piret Saar'),
  _ClientOption(id: 'u6', name: 'Kersti Vaher'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SelectRecipientsScreen extends StatefulWidget {
  final bool allClientsSelected;
  final List<String> selectedIds;

  const SelectRecipientsScreen({
    super.key,
    this.allClientsSelected = true,
    this.selectedIds = const [],
  });

  @override
  State<SelectRecipientsScreen> createState() =>
      _SelectRecipientsScreenState();
}

class _SelectRecipientsScreenState extends State<SelectRecipientsScreen> {
  late bool _allClients;
  final Set<String> _selectedGroupIds = {};
  final Set<String> _selectedClientIds = {};

  @override
  void initState() {
    super.initState();
    _allClients = widget.allClientsSelected;
    _selectedClientIds.addAll(widget.selectedIds);
  }

  int get _totalCount {
    if (_allClients) return 24; // mock total
    int count = 0;
    for (final g in _mockGroups) {
      if (_selectedGroupIds.contains(g.id)) {
        count += g.memberCount;
      }
    }
    count += _selectedClientIds.length;
    return count;
  }

  String get _label {
    if (_allClients) return 'Kõik kliendid (24)';
    final parts = <String>[];
    if (_selectedGroupIds.isNotEmpty) {
      parts.add('${_selectedGroupIds.length} gruppi');
    }
    if (_selectedClientIds.isNotEmpty) {
      parts.add('${_selectedClientIds.length} klienti');
    }
    if (parts.isEmpty) return 'Vali saajad';
    return '${parts.join(', ')} ($_totalCount)';
  }

  List<String> get _allSelectedIds {
    if (_allClients) {
      return _mockClients.map((c) => c.id).toList();
    }
    final ids = <String>{};
    ids.addAll(_selectedClientIds);
    // In a real app, group member IDs would be resolved here
    return ids.toList();
  }

  void _confirm() {
    Navigator.of(context).pop(
      RecipientSelection(
        allClients: _allClients,
        selectedIds: _allSelectedIds,
        label: _label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vali saajad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // All clients toggle
                _CheckboxTile(
                  label: 'Kõik kliendid',
                  subtitle: '24 klienti',
                  isChecked: _allClients,
                  onChanged: (val) {
                    setState(() {
                      _allClients = val ?? false;
                      if (_allClients) {
                        _selectedGroupIds.clear();
                        _selectedClientIds.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Groups
                const Text(
                  'Grupid',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ..._mockGroups.map((group) {
                  return _CheckboxTile(
                    label: group.name,
                    subtitle: '${group.memberCount} liiget',
                    isChecked:
                        _allClients || _selectedGroupIds.contains(group.id),
                    enabled: !_allClients,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedGroupIds.add(group.id);
                        } else {
                          _selectedGroupIds.remove(group.id);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Individual clients
                const Text(
                  'Kliendid',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ..._mockClients.map((client) {
                  return _CheckboxTile(
                    label: client.name,
                    isChecked:
                        _allClients || _selectedClientIds.contains(client.id),
                    enabled: !_allClients,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedClientIds.add(client.id);
                        } else {
                          _selectedClientIds.remove(client.id);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _confirm,
                child: Text('Kinnita ($_totalCount)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Checkbox tile
// ---------------------------------------------------------------------------

class _CheckboxTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isChecked;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile({
    required this.label,
    this.subtitle,
    required this.isChecked,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: enabled ? () => onChanged(!isChecked) : null,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: enabled ? onChanged : null,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return null;
                }),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
