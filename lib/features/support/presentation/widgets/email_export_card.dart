// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_export_card.dart
// Purpose: BW-43 manual email export card.
// Notes: Exports saved email-consent data as CSV/JSON and shares manually.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/email_capture/email_capture_settings.dart';
import '../../../../core/email_capture/email_capture_store.dart';
import '../../../../core/email_capture/email_export_service.dart';

class EmailExportCard extends StatefulWidget {
  const EmailExportCard({super.key});

  @override
  State<EmailExportCard> createState() => _EmailExportCardState();
}

class _EmailExportCardState extends State<EmailExportCard> {
  bool _loading = true;
  bool _working = false;
  EmailCaptureSettings _settings = EmailCaptureSettings.defaults;

  @override
  void initState() {
    super.initState();
    EmailCaptureStore.changes.addListener(_handleStoreChange);
    _load();
  }

  @override
  void dispose() {
    EmailCaptureStore.changes.removeListener(_handleStoreChange);
    super.dispose();
  }

  void _handleStoreChange() {
    _load();
  }

  Future<void> _load() async {
    final EmailCaptureSettings settings = await EmailCaptureStore.load();
    if (!mounted) return;

    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _exportCsv() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      await EmailExportService.exportCsvFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV export created in app temp storage. Use Share export bundle to send it out.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create CSV export right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _exportJson() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      await EmailExportService.exportJsonFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON export created in app temp storage. Use Share export bundle to send it out.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create JSON export right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _shareBundle() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      await EmailExportService.shareExportBundle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opened share sheet for email export.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the share sheet right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool hasData = EmailExportService.hasExportableData(_settings);

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
                  'Email export',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasData
                      ? 'Manual export only. Create a CSV or JSON file from the saved email-consent data and share it yourself.'
                      : 'No saved email-consent data yet. Save optional email preferences above first.',
                  style: theme.textTheme.bodyMedium,
                ),
                if (hasData) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'Saved email: ${_settings.emailAddress.trim().isEmpty ? 'None' : _settings.emailAddress}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Marketing opt-in: ${_settings.marketingOptIn ? 'Yes' : 'No'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Research opt-in: ${_settings.researchOptIn ? 'Yes' : 'No'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: (!_working && hasData) ? _exportCsv : null,
                      child: const Text('Export CSV'),
                    ),
                    FilledButton.tonal(
                      onPressed: (!_working && hasData) ? _exportJson : null,
                      child: const Text('Export JSON'),
                    ),
                    FilledButton(
                      onPressed: (!_working && hasData) ? _shareBundle : null,
                      child: Text(_working ? 'Working...' : 'Share export bundle'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
