import 'package:flutter/material.dart';
import '../models/recurrence_config.dart';
import 'recurrence_picker.dart';

class RecurrenceBottomSheet extends StatefulWidget {
  final RecurrenceConfig initialConfig;
  final ValueChanged<RecurrenceConfig> onChanged;

  const RecurrenceBottomSheet({
    super.key,
    required this.initialConfig,
    required this.onChanged,
  });

  static Future<RecurrenceConfig?> show({
    required BuildContext context,
    required RecurrenceConfig initialConfig,
  }) {
    return showModalBottomSheet<RecurrenceConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => RecurrenceBottomSheet(
        initialConfig: initialConfig,
        onChanged: (config) {
          Navigator.of(context).pop(config);
        },
      ),
    );
  }

  @override
  State<RecurrenceBottomSheet> createState() => _RecurrenceBottomSheetState();
}

class _RecurrenceBottomSheetState extends State<RecurrenceBottomSheet> {
  late RecurrenceConfig _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.75;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(top: mediaQuery.size.height * 0.1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Recurrence Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => widget.onChanged(_currentConfig),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight - 100),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: RecurrencePicker(
                  initialConfig: _currentConfig,
                  onChanged: (config) {
                    setState(() {
                      _currentConfig = config;
                    });
                  },
                ),
              ),
            ),
          ),
          
          // Safe area padding at bottom
          SizedBox(height: mediaQuery.padding.bottom),
        ],
      ),
    );
  }
}