import 'package:flutter/material.dart';

import '../doc/user_consent.dart';
import '../services/consent_preferences_service.dart';

class UserConsentPage extends StatefulWidget {
  const UserConsentPage({super.key, required this.onAccepted});

  final VoidCallback onAccepted;

  @override
  State<UserConsentPage> createState() => _UserConsentPageState();
}

class _UserConsentPageState extends State<UserConsentPage> {
  bool _busy = false;
  int _refuseCount = 0;

  Future<void> _onAccept() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ConsentPreferencesService().setUserConsentAccepted(true);
      if (!mounted) return;
      widget.onAccepted();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onRefuse() {
    if (_busy) return;
    if (_refuseCount == 0) {
      setState(() => _refuseCount = 1);
    } else {
      setState(() => _refuseCount = _refuseCount + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (researchConsentContent['screen_title'] as String?) ??
        'User Consent';
    final dataCollection =
        researchConsentContent['data_collection_section'] as Map<String, dynamic>?;
    final purpose =
        researchConsentContent['purpose_section'] as Map<String, dynamic>?;
    final sharing =
        researchConsentContent['sharing_section'] as Map<String, dynamic>?;

    final dataTitle = (dataCollection?['title'] as String?) ?? '';
    final dataDetails =
        (dataCollection?['details'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            const <Map<String, dynamic>>[];

    final purposeTitle = (purpose?['title'] as String?) ?? '';
    final purposeContent = (purpose?['content'] as String?) ?? '';

    final sharingTitle = (sharing?['title'] as String?) ?? '';
    final sharingContent = (sharing?['content'] as String?) ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: _ConsentBody(
                      dataTitle: dataTitle,
                      dataDetails: dataDetails,
                      purposeTitle: purposeTitle,
                      purposeContent: purposeContent,
                      sharingTitle: sharingTitle,
                      sharingContent: sharingContent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_refuseCount > 0) ...[
                  Text(
                    'User must provide the consent inorder to user app',
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
    required this.dataTitle,
    required this.dataDetails,
    required this.purposeTitle,
    required this.purposeContent,
    required this.sharingTitle,
    required this.sharingContent,
  });

  final String dataTitle;
  final List<Map<String, dynamic>> dataDetails;
  final String purposeTitle;
  final String purposeContent;
  final String sharingTitle;
  final String sharingContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dataTitle.isNotEmpty) ...[
          _SectionTitle(text: dataTitle),
          const SizedBox(height: 8),
        ],
        ...dataDetails.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: _LabeledBullet(
              label: (item['label'] as String?) ?? '',
              content: (item['content'] as String?) ?? '',
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (purposeTitle.isNotEmpty) ...[
          _SectionTitle(text: purposeTitle),
          const SizedBox(height: 6),
        ],
        if (purposeContent.isNotEmpty)
          Text(
            purposeContent,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 10),
        if (sharingTitle.isNotEmpty) ...[
          _SectionTitle(text: sharingTitle),
          const SizedBox(height: 6),
        ],
        if (sharingContent.isNotEmpty)
          Text(
            sharingContent,
            style: Theme.of(context).textTheme.bodyMedium,
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
        Text('•  ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
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

