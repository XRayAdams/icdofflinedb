import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/result_provider.dart';

class ViewResult extends StatefulWidget {
  const ViewResult({super.key});

  @override
  State<ViewResult> createState() => _ViewResultState();
}

class _ViewResultState extends State<ViewResult> {
  @override
  Widget build(BuildContext context) {
    ResultProvider model = Provider.of<ResultProvider>(context);

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      title: const Text('Details'),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                children: _buildTextSpans(model),
              ),
              textAlign: TextAlign.start,
            ),
            if (model.conversion != null) ...[
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: () {
                  final String textToCopy = TextSpan(children: _buildTextSpans(model)).toPlainText();
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy to clipboard'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  List<TextSpan> _buildTextSpans(ResultProvider model) {
    final List<TextSpan> spans = [];

    if (model.result == null) {
      return spans;
    }

    // Source Details
    spans.add(
      const TextSpan(
        text: 'Source\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    spans.add(const TextSpan(text: 'Code : '));
    spans.add(
      TextSpan(
        text: '${model.result!.code}\n',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    spans.add(const TextSpan(text: 'Type : '));
    spans.add(
      TextSpan(
        text: '${model.result!.rType}\n\n',
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );

    // Source Description
    spans.add(const TextSpan(text: 'Description\n'));
    spans.add(TextSpan(text: '${model.result!.description}\n\n'));

    // Conversion Title
    final conversionTitle =
        'Conversion to ${model.isICD9 == null
            ? ""
            : model.isICD9!
            ? "ICD10"
            : "ICD9"}\n';
    spans.add(
      TextSpan(
        text: conversionTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    // Conversion Body
    if (!model.isLoaded) {
      spans.add(const TextSpan(text: 'Loading...'));
    } else if (model.conversion == null) {
      spans.add(const TextSpan(text: 'Unable to find corresponding data'));
    } else {
      // Conversion Details
      spans.add(const TextSpan(text: 'Code : '));
      spans.add(
        TextSpan(
          text: '${model.conversion!.code}\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      spans.add(const TextSpan(text: 'Type : '));
      spans.add(
        TextSpan(
          text: '${model.conversion!.rType}\n\n',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      // Conversion Description
      spans.add(const TextSpan(text: 'Description\n'));
      spans.add(TextSpan(text: model.conversion!.description));
    }

    return spans;
  }
}
