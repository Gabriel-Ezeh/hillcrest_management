// Helper for showing a modal bottom sheet with a searchable list of banks
import 'package:flutter/material.dart';
import 'package:hillcrest_finance/features/kyc/data/models/bank.dart';

Future<Bank?> showBankSelectionModal({
  required BuildContext context,
  required List<Bank> banks,
}) async {
  return showModalBottomSheet<Bank>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return _BankSelectionSheet(banks: banks);
    },
  );
}

class _BankSelectionSheet extends StatefulWidget {
  final List<Bank> banks;
  const _BankSelectionSheet({required this.banks});

  @override
  State<_BankSelectionSheet> createState() => _BankSelectionSheetState();
}

class _BankSelectionSheetState extends State<_BankSelectionSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.banks
        .where((b) => b.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search bank',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No banks found'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final bank = filtered[i];
                        return ListTile(
                          title: Text(bank.name),
                          onTap: () => Navigator.pop(context, bank),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
