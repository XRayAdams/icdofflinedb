import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            style: Theme.of(context).textTheme.titleLarge,
            children: const [
              TextSpan(text: 'An error occurred while loading the database.\n\nPlease check that required library libsqlite3-0 is installed.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
