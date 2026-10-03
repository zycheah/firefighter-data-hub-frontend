import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';

class _SamplerRow {
  _SamplerRow()
      : chemicalController = TextEditingController(),
        percentageController = TextEditingController();

  final TextEditingController chemicalController;
  final TextEditingController percentageController;

  void clear() {
    chemicalController.clear();
    percentageController.clear();
  }

  void dispose() {
    chemicalController.dispose();
    percentageController.dispose();
  }
}

class SmokeSamplerPage extends StatefulWidget {
  const SmokeSamplerPage({super.key});

  @override
  State<SmokeSamplerPage> createState() => _SmokeSamplerPageState();
}

class _SmokeSamplerPageState extends State<SmokeSamplerPage> {
  static const int _maxRows = 50;
  static const Duration _httpTimeout = Duration(seconds: 30);

  final _formKey = GlobalKey<FormState>();
  final List<_SamplerRow> _rows = [_SamplerRow()];

  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  String _chemicalLabel(int index) {
    if (index == 0) return 'Chemical name';
    return 'Chemical name #${index + 1}';
  }

  String _percentageLabel(int index) {
    if (index == 0) return 'Percentage Proportion';
    return 'Percentage Proportion #${index + 1}';
  }

  void _addRow() {
    if (_rows.length >= _maxRows) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max limit reached')),
      );
      return;
    }

    setState(() {
      _rows.add(_SamplerRow());
    });
  }

  void _removeLastRow() {
    if (_rows.length <= 1) return;

    setState(() {
      final removed = _rows.removeLast();
      removed.dispose();
    });
  }

  void _resetFormFields() {
    final rowsToDispose = <_SamplerRow>[];

    if (_rows.isEmpty) {
      _rows.add(_SamplerRow());
    }

    // Keep the first row alive because Flutter may still reference its
    // controllers during the current rebuild.
    _rows.first.clear();

    // Remove extra rows from the visible list first.
    if (_rows.length > 1) {
      rowsToDispose.addAll(_rows.skip(1));
      _rows.removeRange(1, _rows.length);
    }

    _formKey.currentState?.reset();

    // Dispose removed rows after the current frame. This avoids:
    // "TextEditingController was used after being disposed."
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final row in rowsToDispose) {
        row.dispose();
      }
    });
  }

  String? _validateChemical(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    if (value.trim().length > 255) {
      return 'Chemical name is too long';
    }

    return null;
  }

  String? _validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    final cleanedValue = value.trim().replaceAll('%', '');

    final parsed = double.tryParse(cleanedValue);

    if (parsed == null) {
      return 'Enter a valid number';
    }

    if (parsed < 0 || parsed > 100.0) {
      return 'Must be between 0 and 100';
    }

    return null;
  }

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String) {
          return detail;
        }

        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;

          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }

          return detail.toString();
        }

        if (decoded['message'] is String) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {}

    return 'Failed to send smoke sampler data. Status code: $statusCode';
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final samples = <Map<String, dynamic>>[];

    try {
      for (final row in _rows) {
        final cleanedPercentage =
            row.percentageController.text.trim().replaceAll('%', '');

        samples.add({
          'chemical_name': row.chemicalController.text.trim(),
          'percentage_proportion': double.parse(cleanedPercentage),
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid percentage values.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final body = jsonEncode({'samples': samples});

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse(AppConfig.smokeSamplerUrl);

      final response = await AuthService()
          .authorizedPost(uri, body: body)
          .timeout(_httpTimeout);

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        int sampleCount = samples.length;

        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> &&
              decoded['sample_count'] != null) {
            sampleCount = decoded['sample_count'] as int;
          }
        } catch (_) {}

        setState(() {
          _resetFormFields();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully sent $sampleCount smoke sample${sampleCount == 1 ? '' : 's'}.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage = _extractErrorMessage(
          response.body,
          response.statusCode,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Smoke sampler request timed out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send smoke sampler data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smoke Sampler'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...List.generate(_rows.length, (index) {
                final row = _rows[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: row.chemicalController,
                        decoration: InputDecoration(
                          labelText: _chemicalLabel(index),
                          border: const OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: _validateChemical,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: row.percentageController,
                        decoration: InputDecoration(
                          labelText: _percentageLabel(index),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePercentage,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _isSubmitting || _rows.length <= 1
                        ? null
                        : _removeLastRow,
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove last row',
                  ),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    onPressed: _isSubmitting ? null : _addRow,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add row',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}