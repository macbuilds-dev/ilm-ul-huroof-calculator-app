import 'package:flutter/material.dart';

import '../model/huroof_model.dart';

class LettersTableView extends StatelessWidget {
  const LettersTableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<HuroofLetter> letters = HuroofData.getAllLetters();

    // Group letters by base value
    Map<int, List<String>> grouped = {};
    letters.forEach((letter) {
      if (!grouped.containsKey(letter.baseValue)) {
        grouped[letter.baseValue] = [];
      }
      grouped[letter.baseValue]!.add(letter.letter);
    });

    List<int> sortedValues = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حروف کی فہرست',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF004D40)],
              ),
            ),
            child: Column(
              children: const [
                Icon(Icons.list_alt, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  'All Letters & Base Values',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Traditional Abjad Numerology',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Letter', Icons.text_fields, Colors.blue[700]!),
                _buildLegendItem('Base Value', Icons.calculate, Colors.green[700]!),
                _buildLegendItem('Group', Icons.group, Colors.orange[700]!),
              ],
            ),
          ),

          // Table
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedValues.length,
              itemBuilder: (context, index) {
                int baseValue = sortedValues[index];
                List<String> lettersInGroup = grouped[baseValue]!;

                return _buildLetterCard(baseValue, lettersInGroup);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLetterCard(int baseValue, List<String> letters) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with base value
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForValue(baseValue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calculate,
                        color: _getColorForValue(baseValue),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Base Value',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          baseValue.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${letters.length} ${letters.length == 1 ? "Letter" : "Letters"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Letters display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: letters.map((letter) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getColorForValue(baseValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getColorForValue(baseValue).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getColorForValue(baseValue),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForValue(int value) {
    if (value <= 10) return const Color(0xFF1976D2); // Blue
    if (value <= 50) return const Color(0xFF388E3C); // Green
    if (value <= 100) return const Color(0xFFF57C00); // Orange
    if (value <= 500) return const Color(0xFF7B1FA2); // Purple
    return const Color(0xFFC62828); // Red
  }
}