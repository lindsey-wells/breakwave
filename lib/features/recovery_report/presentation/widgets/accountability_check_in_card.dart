// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: accountability_check_in_card.dart
// Purpose: Editable local-only accountability check-in composer.
// Notes: BW-89A12D copies only user-reviewed text and never sends automatically.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/accountability_check_in_template.dart';

class AccountabilityCheckInCard extends StatefulWidget {
  const AccountabilityCheckInCard({super.key});

  @override
  State<AccountabilityCheckInCard> createState() =>
      _AccountabilityCheckInCardState();
}

class _AccountabilityCheckInCardState
    extends State<AccountabilityCheckInCard> {
  AccountabilityCheckInTemplate _selected =
      AccountabilityCheckInTemplate.weeklyCheckIn;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _selected.starterText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTemplate(
    AccountabilityCheckInTemplate template,
  ) {
    setState(() {
      _selected = template;
      _controller.text = template.starterText;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _resetTemplate() {
    setState(() {
      _controller.text = _selected.starterText;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  Future<void> _copyMessage() async {
    final String text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add a message before copying it.',
          ),
        ),
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: text),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Copied check-in message. You choose where to paste or send it.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Accountability check-in',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a starting message, edit every word you want, then copy it when you are ready. BreakWave does not add recovery or report data to this message, and nothing is sent automatically.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AccountabilityCheckInTemplate.values
                .map(
                  (
                    AccountabilityCheckInTemplate template,
                  ) => ChoiceChip(
                    key: Key(
                      'accountability-template-${template.name}',
                    ),
                    label: Text(template.label),
                    selected: _selected == template,
                    onSelected: (_) =>
                        _selectTemplate(template),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key(
              'accountability-check-in-editor',
            ),
            controller: _controller,
            minLines: 5,
            maxLines: 9,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Message to copy',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key(
                    'accountability-reset-template',
                  ),
                  onPressed: _resetTemplate,
                  icon: const Icon(Icons.restart_alt),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text('Reset'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const Key(
                    'accountability-copy-message',
                  ),
                  onPressed: _copyMessage,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text('Copy message'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'This draft stays separate from the recovery-report TXT and JSON files. Copying is local; you decide what app or person receives it.',
          ),
        ],
      ),
    );
  }
}
