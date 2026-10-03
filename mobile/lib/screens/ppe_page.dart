import 'package:flutter/material.dart';
import '../models/ppe_model.dart';
import '../services/ppe_service.dart';

class PPEPage extends StatefulWidget {
  const PPEPage({
    super.key,
    this.prefillExisting = false,
  });

  /// If true, existing locally saved PPE values are loaded into the form.
  /// For normal "Update PPE Equipment" flow, keep this false so the page opens fresh.
  final bool prefillExisting;

  @override
  PPEPageState createState() => PPEPageState();
}

class PPEPageState extends State<PPEPage> {
  final _formKey = GlobalKey<FormState>();
  final _helmetController = TextEditingController();
  final _hoodController = TextEditingController();
  final _faceMaskController = TextEditingController();
  final _scbaController = TextEditingController();
  final _gloveController = TextEditingController();
  final _bootController = TextEditingController();
  final _turnoutCoatController = TextEditingController();
  final _turnoutPantsController = TextEditingController();

  final _ppeService = PPEService();

  bool _isLoading = false;

  /// Mirrors pending log-event → PPE flow.
  bool _isPpeUpdated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ppeService.loadPersistedPPE();

      final pending = await _ppeService.getIsPpeUpdatedPending();

      if (!mounted) return;

      setState(() {
        _isPpeUpdated = pending;
      });

      if (widget.prefillExisting) {
        final existing = _ppeService.getCurrentPPE();
        if (existing != null && mounted) {
          setState(() {
            _applyPpeToControllers(existing);
          });
        }
      } else {
        _clearControllers();
      }
    });
  }

  /// Called by MainNavigation when this page becomes visible again.
  Future<void> syncPendingBannerFromStorage() async {
    final pending = await _ppeService.getIsPpeUpdatedPending();

    if (!mounted) return;

    setState(() {
      _isPpeUpdated = pending;
    });
  }

  /// Opens the PPE form as a clean new-entry form.
  void startFreshEntry() {
    _clearControllers();
    _formKey.currentState?.reset();

    if (mounted) {
      setState(() {});
    }
  }

  void _applyPpeToControllers(PPE existingPPE) {
    _helmetController.text = existingPPE.helmetId ?? '';
    _hoodController.text = existingPPE.hoodId ?? '';
    _faceMaskController.text = existingPPE.faceMaskId ?? '';
    _scbaController.text = existingPPE.scbaId ?? '';
    _gloveController.text = existingPPE.gloveId ?? '';
    _bootController.text = existingPPE.bootId ?? '';
    _turnoutCoatController.text = existingPPE.turnoutCoat ?? '';
    _turnoutPantsController.text = existingPPE.turnoutPants ?? '';
  }

  void _clearControllers() {
    _helmetController.clear();
    _hoodController.clear();
    _faceMaskController.clear();
    _scbaController.clear();
    _gloveController.clear();
    _bootController.clear();
    _turnoutCoatController.clear();
    _turnoutPantsController.clear();
  }

  @override
  void dispose() {
    _helmetController.dispose();
    _hoodController.dispose();
    _faceMaskController.dispose();
    _scbaController.dispose();
    _gloveController.dispose();
    _bootController.dispose();
    _turnoutCoatController.dispose();
    _turnoutPantsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final ppe = PPE(
      helmetId: _helmetController.text.trim().isEmpty
          ? null
          : _helmetController.text.trim(),
      hoodId:
          _hoodController.text.trim().isEmpty ? null : _hoodController.text.trim(),
      faceMaskId: _faceMaskController.text.trim().isEmpty
          ? null
          : _faceMaskController.text.trim(),
      scbaId:
          _scbaController.text.trim().isEmpty ? null : _scbaController.text.trim(),
      gloveId: _gloveController.text.trim().isEmpty
          ? null
          : _gloveController.text.trim(),
      bootId:
          _bootController.text.trim().isEmpty ? null : _bootController.text.trim(),
      turnoutCoat: _turnoutCoatController.text.trim().isEmpty
          ? null
          : _turnoutCoatController.text.trim(),
      turnoutPants: _turnoutPantsController.text.trim().isEmpty
          ? null
          : _turnoutPantsController.text.trim(),
      lastUpdated: DateTime.now(),
    );

    try {
      final ok = await _ppeService.submitPPEToBackend(ppe);

      if (!mounted) return;

      if (ok) {
        setState(() {
          _isPpeUpdated = false;
        });

        _clearControllers();
        _formKey.currentState?.reset();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'PPE data stored successfully.'
                : 'PPE data transfer failed. Please try again later.',
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
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
        title: const Text('PPE Equipment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              if (_isPpeUpdated)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Submit to complete PPE update from log event.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

              TextFormField(
                controller: _helmetController,
                decoration: const InputDecoration(
                  labelText: 'Helmet ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _hoodController,
                decoration: const InputDecoration(
                  labelText: 'Hood ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _faceMaskController,
                decoration: const InputDecoration(
                  labelText: 'Face Mask ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _scbaController,
                decoration: const InputDecoration(
                  labelText: 'SCBA ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _gloveController,
                decoration: const InputDecoration(
                  labelText: 'Glove ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _bootController,
                decoration: const InputDecoration(
                  labelText: 'Boot ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _turnoutCoatController,
                decoration: const InputDecoration(
                  labelText: 'Turnout/Bunker Coat',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _turnoutPantsController,
                decoration: const InputDecoration(
                  labelText: 'Turnout/Bunker Pants',
                  border: OutlineInputBorder(),
                ),
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