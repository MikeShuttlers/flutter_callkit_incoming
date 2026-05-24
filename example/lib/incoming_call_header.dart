import 'dart:convert';

import 'package:flutter/material.dart';

class IncomingCallHeader extends StatelessWidget {
  const IncomingCallHeader({required this.uri, super.key});

  final Uri uri;

  Map<String, dynamic> _payload() {
    final rawPayload = uri.queryParameters['callkitData'];
    if (rawPayload == null || rawPayload.isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Keep fallback rendering when payload is missing or malformed.
    }
    return const <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload();
    final custom = (payload['custom'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final title = (custom['title'] as String?) ??
        (payload['nameCaller'] as String?) ??
        'Incoming call';
    final subtitle =
        (custom['subtitle'] as String?) ?? (payload['handle'] as String?) ?? '';

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Incoming Priority Call',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.isEmpty ? 'Available now' : subtitle,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.8)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Call Notes',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- Sprint planning follow-up',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '- Discuss release timeline',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '- Confirm QA handoff details',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
