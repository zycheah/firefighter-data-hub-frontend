import 'package:flutter/material.dart';

import '../doc/location_consent.dart';
import '../services/consent_preferences_service.dart';

/// Returns true only when the user accepted the location consent.
///
/// This does not request OS permissions; it only records the user's consent.
Future<bool> showLocationConsentIfNeeded(
  BuildContext context, {
  required Future<bool> Function() hasOsLocationPermission,
}) async {
  if (await hasOsLocationPermission()) return true;
  if (!context.mounted) return false;

  final accepted = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => const LocationConsentPage(),
    ),
  );

  return accepted == true;
}

class LocationConsentPage extends StatefulWidget {
  const LocationConsentPage({super.key});

  @override
  State<LocationConsentPage> createState() => _LocationConsentPageState();
}

class _LocationConsentPageState extends State<LocationConsentPage> {
  bool _busy = false;
  int _refuseCount = 0;

  Future<void> _onAccept() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ConsentPreferencesService().setLocationConsentAccepted(true);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onRefuse() {
    if (_busy) return;
    if (_refuseCount == 0) {
      setState(() => _refuseCount = 1);
      return;
    }
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final title = (locationAccessContent['screen_title'] as String?) ??
        'Location Access';
    final description = (locationAccessContent['description'] as String?) ?? '';

    final usage =
        locationAccessContent['usage_section'] as Map<String, dynamic>?;
    final usageTitle = (usage?['title'] as String?) ?? '';
    final usageDetails = (usage?['details'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];

    final footer = (locationAccessContent['footer_consent_text'] as String?) ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.location_on,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Requirement: all consent text must fit on one page without scrolling.
                      // We scale down if needed to fit smaller screens.
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: _ConsentBody(
                            description: description,
                            usageTitle: usageTitle,
                            usageDetails: usageDetails,
                            footer: footer,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_refuseCount > 0) ...[
                  Text(
                    'App the require GPS access to function.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _busy ? null : _onAccept,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('I Accept'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _busy ? null : _onRefuse,
                  child: const Text('I Refuse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentBody extends StatelessWidget {
  const _ConsentBody({
    required this.description,
    required this.usageTitle,
    required this.usageDetails,
    required this.footer,
  });

  final String description;
  final String usageTitle;
  final List<Map<String, dynamic>> usageDetails;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (description.isNotEmpty)
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        const SizedBox(height: 12),
        if (usageTitle.isNotEmpty) ...[
          _SectionTitle(text: usageTitle),
          const SizedBox(height: 10),
        ],
        ...usageDetails.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _LabeledBullet(
              label: (item['label'] as String?) ?? '',
              content: (item['content'] as String?) ?? '',
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (footer.isNotEmpty)
          Text(
            footer,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _LabeledBullet extends StatelessWidget {
  const _LabeledBullet({required this.label, required this.content});

  final String label;
  final String content;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label.trim();
    final effectiveContent = content.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Text('• '),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                if (effectiveLabel.isNotEmpty)
                  TextSpan(
                    text: effectiveLabel.endsWith(' ')
                        ? effectiveLabel
                        : '$effectiveLabel ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                TextSpan(text: effectiveContent),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

