import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/bank_account_model.dart';

class BankAccountDialog extends StatefulWidget {
  final BankAccountModel? initialAccount;

  const BankAccountDialog({super.key, this.initialAccount});

  @override
  State<BankAccountDialog> createState() => _BankAccountDialogState();
}

class _BankAccountDialogState extends State<BankAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _accountHolderController;

  static const List<String> popularBanks = [
    'BCA',
    'Mandiri',
    'BNI',
    'BRI',
    'BSI',
    'CIMB Niaga',
    'Permata',
    'Seabank',
  ];

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(text: widget.initialAccount?.bankName ?? '');
    _accountNumberController = TextEditingController(text: widget.initialAccount?.accountNumber ?? '');
    _accountHolderController = TextEditingController(text: widget.initialAccount?.accountHolder ?? '');
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.initialAccount != null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.initialAccount?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final account = BankAccountModel(
      id: id,
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountHolder: _accountHolderController.text.trim(),
    );

    Navigator.of(context).pop(account);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? LucideIcons.edit3 : LucideIcons.building,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Rekening Bank' : 'Tambah Rekening Bank',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing
                              ? 'Perbarui rincian akun bank pembayaran pre-order'
                              : 'Tambahkan akun bank baru untuk menerima pembayaran pre-order',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // 1. Bank Name Field
              const Text(
                'Nama Bank',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: BCA / Bank Central Asia',
                  prefixIcon: const Icon(LucideIcons.landmark, size: 18, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama bank tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Quick Selector Chips for popular banks
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: popularBanks.map((bName) {
                  final isSelected = _bankNameController.text.trim().toUpperCase() == bName.toUpperCase();
                  return ChoiceChip(
                    label: Text(bName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _bankNameController.text = bName;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFF475569),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // 2. Account Number Field
              const Text(
                'Nomor Rekening',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 1234567890',
                  prefixIcon: const Icon(LucideIcons.creditCard, size: 18, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor rekening tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 3. Account Holder Field
              const Text(
                'Nama Pemilik / Atas Nama (a.n.)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountHolderController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Contoh: PT Pustaka Ilman Utama',
                  prefixIcon: const Icon(LucideIcons.userCheck, size: 18, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama pemilik rekening tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Actions Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(isEditing ? LucideIcons.check : LucideIcons.plus, size: 16),
                    label: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Rekening'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
