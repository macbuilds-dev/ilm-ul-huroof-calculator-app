import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/huroof_model.dart';

class ResultsView extends StatelessWidget {
  final Map<String, CalculationResult> results;
  final bool isZakat;
  final String inputText;

  const ResultsView({
    Key? key,
    required this.results,
    required this.isZakat,
    required this.inputText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Results (نتائج)',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareResults(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Summary
            _buildInputSummary(),

            const SizedBox(height: 20),

            // Main Results Table
            _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSummary() {
    int totalBaseValue = 0;

    // Count each letter occurrence in the word
    for (int i = 0; i < inputText.length; i++) {
      String letter = inputText[i];
      if (results.containsKey(letter)) {
        totalBaseValue += results[letter]!.baseValue;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            inputText,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total P0 (Base Value): $totalBaseValue',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    // Get all P-levels from first result
    var firstResult = results.values.first;
    List<int> levels = firstResult.pLevels.keys.toList()..sort();

    // Get all letters from the input (preserving order and duplicates)
    List<String> inputLetters = [];
    for (int i = 0; i < inputText.length; i++) {
      String letter = inputText[i];
      if (results.containsKey(letter)) {
        inputLetters.add(letter);
      }
    }

    // Get unique letters for display
    List<String> uniqueLetters = results.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF00695C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  isZakat ? 'Zakat Levels Table' : 'P-Levels Table',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header Row
                  _buildTableHeaderRow(uniqueLetters, levels),

                  const Divider(height: 1, thickness: 2),

                  // P0 Row
                  _buildP0Row(inputLetters),

                  const Divider(height: 1),

                  // P-Level Rows
                  ...levels.map((level) => _buildPLevelRow(level, inputLetters)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderRow(List<String> uniqueLetters, List<int> levels) {
    return Row(
      children: [
        // Level column header
        Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          child: const Text(
            'Level',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Letter columns from input text (showing each occurrence)
        ...inputText.split('').where((l) => results.containsKey(l)).map((letter) {
          return Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withOpacity(0.1),
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'P0: ${results[letter]!.baseValue}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),

        // Total column header
        Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            border: Border(
              left: BorderSide(color: Colors.amber[300]!, width: 2),
            ),
          ),
          child: Text(
            'Total\n(مجموعی)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildP0Row(List<String> inputLetters) {
    BigInt total = BigInt.zero;
    for (String letter in inputLetters) {
      total += BigInt.from(results[letter]!.baseValue);
    }

    return Row(
      children: [
        // P0 Label
        Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: const Text(
            'P0',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // P0 values for each letter occurrence
        ...inputLetters.map((letter) {
          return Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Text(
              results[letter]!.baseValue.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),

        // P0 Total
        Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            border: Border(
              left: BorderSide(color: Colors.amber[300]!, width: 2),
            ),
          ),
          child: Text(
            _formatNumber(total),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPLevelRow(int level, List<String> inputLetters) {
    BigInt total = BigInt.zero;

    // Calculate total for this level
    for (String letter in inputLetters) {
      if (results[letter]!.pLevels.containsKey(level)) {
        total += results[letter]!.pLevels[level]!;
      }
    }

    return Row(
      children: [
        // Level Label
        Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00695C).withOpacity(0.1),
          ),
          child: Text(
            'P-$level',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // P-level values for each letter occurrence
        ...inputLetters.map((letter) {
          BigInt value = results[letter]!.pLevels[level] ?? BigInt.zero;
          return Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Text(
              _formatNumber(value),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),

        // Level Total
        Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            border: Border(
              left: BorderSide(color: Colors.amber[300]!, width: 2),
            ),
          ),
          child: Text(
            _formatNumber(total),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _formatNumber(BigInt number) {
    String numStr = number.toString();

    // Add commas for readability
    String formatted = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = numStr[i] + formatted;
      count++;
    }

    return formatted;
  }

  void _shareResults(BuildContext context) {
    String text = 'علمُ الحروف Calculation Results\n';
    text += '═══════════════════════════════\n';
    text += 'Input: $inputText\n';
    text += 'Type: ${isZakat ? "Zakat Levels" : "P-Levels"}\n\n';

    // Get all levels
    var firstResult = results.values.first;
    List<int> levels = firstResult.pLevels.keys.toList()..sort();

    // Get input letters
    List<String> inputLetters = [];
    for (int i = 0; i < inputText.length; i++) {
      String letter = inputText[i];
      if (results.containsKey(letter)) {
        inputLetters.add(letter);
      }
    }

    // Table header
    text += 'Level\t';
    for (String letter in inputLetters) {
      text += '$letter\t';
    }
    text += 'Total\n';
    text += '─────────────────────────────\n';

    // P0 row
    text += 'P0\t';
    BigInt p0Total = BigInt.zero;
    for (String letter in inputLetters) {
      int val = results[letter]!.baseValue;
      text += '$val\t';
      p0Total += BigInt.from(val);
    }
    text += '${_formatNumber(p0Total)}\n';

    // P-level rows
    for (int level in levels) {
      text += 'P-$level\t';
      BigInt total = BigInt.zero;
      for (String letter in inputLetters) {
        BigInt val = results[letter]!.pLevels[level] ?? BigInt.zero;
        text += '${_formatNumber(val)}\t';
        total += val;
      }
      text += '${_formatNumber(total)}\n';
    }

    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results copied to clipboard'),
        backgroundColor: Color(0xFF00695C),
      ),
    );
  }
}