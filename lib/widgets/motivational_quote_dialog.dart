import 'package:flutter/material.dart';
import 'dart:math';

class MotivationalQuoteDialog extends StatelessWidget {
  final String appName;
  final VoidCallback onDismiss;

  const MotivationalQuoteDialog({
    super.key,
    required this.appName,
    required this.onDismiss,
  });

  static final List<String> _quotes = [
    "Every minute spent scrolling is a minute stolen from your dreams.",
    "Focus on what matters. Your future self will thank you.",
    "Distraction is the enemy of progress.",
    "Time is your most valuable asset. Invest it wisely.",
    "Success is built one focused moment at a time.",
    "Your goals are waiting for your attention.",
    "Break the scroll, build your soul.",
    "Productivity is never an accident. It's always the result of commitment.",
    "The best time to focus was yesterday. The second best time is now.",
    "Your phone can wait. Your dreams cannot.",
    "Small daily improvements lead to stunning results.",
    "Don't let your screen time steal your dream time.",
    "The secret of getting ahead is getting started.",
    "Focus is the gateway to thinking, feeling, learning, and remembering.",
    "You don't have to be great to start, but you have to start to be great.",
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[Random().nextInt(_quotes.length)];
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                size: 40,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$appName Blocked',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Text(
                '"$quote"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Stay Focused'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDismiss,
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

