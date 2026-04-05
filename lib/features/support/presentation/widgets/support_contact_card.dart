// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact_card.dart
// Purpose: BW-21 support contact card.
// Notes: Saves one trusted contact for quick support actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_store.dart';

class SupportContactCard extends StatefulWidget {
  const SupportContactCard({super.key});

  @override
  State<SupportContactCard> createState() => _SupportContactCardState();
}

class _SupportContactCardState extends State<SupportContactCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _contactLineController;

  bool _loading = true;
  bool _saving = false;
  bool _hasSavedContact = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _contactLineController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactLineController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final SupportContact? contact = await SupportContactStore.loadContact();
    if (!mounted) return;

    _nameController.text = contact?.name ?? '';
    _contactLineController.text = contact?.contactLine ?? '';

    setState(() {
      _hasSavedContact = contact != null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final String contactLine = _contactLineController.text.trim();

    if (name.isEmpty || contactLine.isEmpty || _saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await SupportContactStore.saveContact(
        SupportContact(
          name: name,
          contactLine: contactLine,
        ),
      );

      if (!mounted) return;

      setState(() {
        _hasSavedContact = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trusted contact saved.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save that trusted contact right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _clear() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await SupportContactStore.clearContact();

      if (!mounted) return;

      _nameController.clear();
      _contactLineController.clear();

      setState(() {
        _hasSavedContact = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trusted contact cleared.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear that trusted contact right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Trusted contact',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Save one person you can reach when the wave starts getting louder.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact name',
                    hintText: 'Example: Leah',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactLineController,
                  decoration: const InputDecoration(
                    labelText: 'Reach line',
                    hintText: 'Example: text first • 555-0101',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_saving ? 'Saving...' : 'Save trusted contact'),
                  ),
                ),
                if (_hasSavedContact) ...<Widget>[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _saving ? null : _clear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Clear trusted contact'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
