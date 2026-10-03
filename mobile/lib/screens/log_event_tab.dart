import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/log_event_service.dart';
import '../services/app_shell_navigation.dart';
import '../services/ppe_service.dart';

class LogEventTab extends StatefulWidget {
  const LogEventTab({super.key});

  @override
  State<LogEventTab> createState() => _LogEventTabState();
}

class _LogEventTabState extends State<LogEventTab> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _eventService = EventService();
  final _logEventService = LogEventService();
  final _ppeService = PPEService();

  DateTime? _selectedDate;
  bool? _samePPE;
  bool _isLoading = false;

  static const _successMsg = 'Event data stored successfully';
  static const _failMsg = 'Event data transfer failed. Try again later';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showPpeFollowUpDialog(String eventId) async {
    final want = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update PPE information?'),
          content: const Text(
            'Would you like to update PPE information for this event as well?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (want == true) {
      await _ppeService.setIsPpeUpdatedPending(true);
      await _ppeService.setPendingPpeEventId(eventId);

      if (!mounted) return;

      AppShellNavigation.goToPpeTab();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_samePPE == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select whether you used the same PPE'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final eventId = await _logEventService.submitLogEvent(
        eventDate: _selectedDate!,
        eventAddress: _addressController.text.trim(),
        isSamePpe: _samePPE!,
      );

      final ok = eventId != null && eventId.trim().isNotEmpty;

      if (!mounted) return;

      if (ok) {
        final event = Event(
          date: _selectedDate!,
          address: _addressController.text.trim(),
          samePPE: _samePPE!,
        );

        await _eventService.saveEvent(event);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_successMsg),
            backgroundColor: Colors.green,
          ),
        );

        if (_samePPE == true) {
          await Future<void>.delayed(const Duration(seconds: 1));

          if (!mounted) return;

          await _showPpeFollowUpDialog(eventId);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_failMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _selectedDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Did you use DIFFERENT PPE in this event?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<bool>(
                title: const Text('YES'),
                value: true,
                groupValue: _samePPE,
                onChanged: (value) {
                  setState(() {
                    _samePPE = value;
                  });
                },
              ),
              RadioListTile<bool>(
                title: const Text('NO'),
                value: false,
                groupValue: _samePPE,
                onChanged: (value) {
                  setState(() {
                    _samePPE = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}