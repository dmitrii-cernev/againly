import 'package:flutter/material.dart';
import '../models/recurrence_config.dart';

class RecurrencePicker extends StatefulWidget {
  final RecurrenceConfig initialConfig;
  final ValueChanged<RecurrenceConfig> onChanged;

  const RecurrencePicker({
    super.key,
    required this.initialConfig,
    required this.onChanged,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late RecurrenceUnit _selectedUnit;
  late int _interval;
  late TimeOfDay? _resetTime;
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialConfig.unit;
    _interval = widget.initialConfig.interval;
    _resetTime = widget.initialConfig.resetTime;
    _intervalController = TextEditingController(text: _interval.toString());
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  void _updateConfig() {
    final config = RecurrenceConfig(
      unit: _selectedUnit,
      interval: _interval,
      resetTimeHour: _resetTime?.hour,
      resetTimeMinute: _resetTime?.minute,
    );
    widget.onChanged(config);
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _resetTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _resetTime = time;
      });
      _updateConfig();
    }
  }

  Widget _buildUnitSelector() {
    return DropdownButton<RecurrenceUnit>(
      value: _selectedUnit,
      onChanged: (RecurrenceUnit? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedUnit = newValue;
            if (newValue == RecurrenceUnit.none) {
              _interval = 1;
              _resetTime = null;
              _intervalController.text = '1';
            } else if (!newValue.allowsFixedTime && _resetTime != null) {
              _resetTime = null;
            }
          });
          _updateConfig();
        }
      },
      items: RecurrenceUnit.values.map((RecurrenceUnit unit) {
        return DropdownMenuItem<RecurrenceUnit>(
          value: unit,
          child: Text(unit.displayName),
        );
      }).toList(),
    );
  }

  Widget _buildIntervalInput() {
    if (_selectedUnit == RecurrenceUnit.none) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Text('Every '),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: (value) {
              final newInterval = int.tryParse(value) ?? 1;
              if (newInterval > 0 && newInterval <= 999) {
                setState(() {
                  _interval = newInterval;
                });
                _updateConfig();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(_selectedUnit.displayName.toLowerCase()),
      ],
    );
  }

  Widget _buildTimeSelector() {
    if (_selectedUnit == RecurrenceUnit.none) {
      return const SizedBox.shrink();
    }

    final isTimeSelectionEnabled = _selectedUnit.allowsFixedTime;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Schedule',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: isTimeSelectionEnabled ? () {
                setState(() {
                  _resetTime = null;
                });
                _updateConfig();
              } : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _resetTime != null,
                      onChanged: isTimeSelectionEnabled ? (bool? value) {
                        if (value == false) {
                          setState(() {
                            _resetTime = null;
                          });
                          _updateConfig();
                        }
                      } : null,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('After inactivity'),
                          Text(
                            'Timer resets when you interact with items',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: isTimeSelectionEnabled ? () {
                if (_resetTime == null) {
                  _showTimePicker();
                }
              } : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _resetTime != null,
                      onChanged: isTimeSelectionEnabled ? (bool? value) {
                        if (value == true) {
                          _showTimePicker();
                        }
                      } : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'At specific time',
                            style: TextStyle(
                              color: isTimeSelectionEnabled ? null : Colors.grey,
                            ),
                          ),
                          Text(
                            isTimeSelectionEnabled
                                ? (_resetTime != null 
                                    ? 'Resets daily at ${_resetTime!.format(context)}'
                                    : 'Choose a time for automatic reset')
                                : 'Only available for daily, weekly, or monthly recurrence',
                            style: TextStyle(
                              fontSize: 12, 
                              color: isTimeSelectionEnabled ? Colors.grey : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_resetTime != null && isTimeSelectionEnabled) ...[
              const SizedBox(height: 8),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _showTimePicker,
                  icon: const Icon(Icons.access_time),
                  label: Text('Change time: ${_resetTime!.format(context)}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedUnit == RecurrenceUnit.none) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'No automatic reset',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final config = RecurrenceConfig(
      unit: _selectedUnit,
      interval: _interval,
      resetTimeHour: _resetTime?.hour,
      resetTimeMinute: _resetTime?.minute,
    );

    String modeDescription;
    if (config.isFixedMode) {
      modeDescription = 'Fixed schedule: Resets at the same time regardless of your activity';
    } else {
      modeDescription = 'Relative mode: Countdown resets each time you check/uncheck items';
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  config.isFixedMode ? Icons.schedule : Icons.timer,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.displayText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              modeDescription,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.refresh, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Recurrence:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildUnitSelector()),
          ],
        ),
        
        if (_selectedUnit != RecurrenceUnit.none) ...[
          const SizedBox(height: 16),
          _buildIntervalInput(),
          const SizedBox(height: 16),
          _buildTimeSelector(),
        ],
        
        const SizedBox(height: 16),
        _buildPreview(),
      ],
    );
  }
}