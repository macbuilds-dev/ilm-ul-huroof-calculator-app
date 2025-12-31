
import '../model/huroof_model.dart';

class HuroofController {
  // Calculate P-levels using optimized frequency-based method
  // This avoids memory overflow by tracking letter counts instead of full expansion
  static CalculationResult calculatePLevels({
    required String letter,
    required int maxLevel,
    bool isZakat = false,
  }) {
    int baseValue = HuroofData.getBaseValue(letter);
    Map<int, BigInt> pLevels = {};

    if (isZakat) {
      // For Zakat, calculate from P-9 onwards
      Map<int, BigInt> normalLevels = _calculateOptimizedLevels(letter, 8);

      // Calculate Zakat levels starting from P-9
      for (int i = 1; i <= maxLevel; i++) {
        int actualLevel = i + 8;
        pLevels[actualLevel] = _calculateZakatLevel(letter, actualLevel, normalLevels);
      }
    } else {
      // Normal P-level calculations (P-1 to P-n)
      pLevels = _calculateOptimizedLevels(letter, maxLevel);
    }

    return CalculationResult(
      letter: letter,
      baseValue: baseValue,
      pLevels: pLevels,
      isZakat: isZakat,
    );
  }

  // Optimized calculation using frequency map instead of full expansion
  // This prevents memory overflow for large P-levels
  static Map<int, BigInt> _calculateOptimizedLevels(String letter, int maxLevel) {
    Map<int, BigInt> levels = {};

    // Start with frequency map: {letter: count}
    Map<String, BigInt> currentFrequency = {};

    // Initialize with the letter's spelling
    List<String> spelling = HuroofData.getSpelling(letter);
    for (String l in spelling) {
      currentFrequency[l] = (currentFrequency[l] ?? BigInt.zero) + BigInt.one;
    }

    // P1: Sum of P0 values (base * frequency)
    BigInt p1 = _sumFrequencyValues(currentFrequency);
    levels[1] = p1;

    // Calculate P2, P3, P4, ... using frequency expansion
    for (int level = 2; level <= maxLevel; level++) {
      Map<String, BigInt> nextFrequency = {};

      // Expand each letter based on its frequency
      currentFrequency.forEach((currentLetter, frequency) {
        List<String> expansion = HuroofData.getSpelling(currentLetter);

        // Add expanded letters with multiplied frequency
        for (String expandedLetter in expansion) {
          nextFrequency[expandedLetter] =
              (nextFrequency[expandedLetter] ?? BigInt.zero) + frequency;
        }
      });

      // Calculate P-level value from frequency map
      BigInt pValue = _sumFrequencyValues(nextFrequency);
      levels[level] = pValue;

      // Update for next iteration
      currentFrequency = nextFrequency;
    }

    return levels;
  }

  // Sum P0 values multiplied by their frequencies
  static BigInt _sumFrequencyValues(Map<String, BigInt> frequency) {
    BigInt sum = BigInt.zero;

    frequency.forEach((letter, count) {
      int baseValue = HuroofData.getBaseValue(letter);
      sum += BigInt.from(baseValue) * count;
    });

    return sum;
  }

  // Calculate Zakat level (P-9 onwards with exponential growth)
  static BigInt _calculateZakatLevel(
      String letter,
      int level,
      Map<int, BigInt> normalLevels,
      ) {
    // Zakat calculations are based on the P-8 value with exponential multiplier
    BigInt baseP8 = normalLevels[8] ?? BigInt.zero;

    // Exponential growth factor for Zakat levels
    int zakatLevel = level - 8; // 1 for P-9, 2 for P-10, etc.

    // Use proper exponential growth
    BigInt multiplier = BigInt.from(1000);
    for (int i = 1; i < zakatLevel; i++) {
      multiplier = multiplier * BigInt.from(10); // Exponential: 1000, 10000, 100000...
    }

    BigInt zakatValue = baseP8 * multiplier;

    return zakatValue;
  }

  // Calculate for entire word/name
  static Map<String, CalculationResult> calculateForWord({
    required String word,
    required int maxLevel,
    bool isZakat = false,
  }) {
    Map<String, CalculationResult> results = {};

    for (int i = 0; i < word.length; i++) {
      String letter = word[i];
      if (HuroofData.baseValues.containsKey(letter)) {
        // Check if we already calculated this letter
        if (!results.containsKey(letter)) {
          results[letter] = calculatePLevels(
            letter: letter,
            maxLevel: maxLevel,
            isZakat: isZakat,
          );
        }
      }
    }

    return results;
  }

  // Get total sum for a specific P-level across all letters in word
  static BigInt getTotalForLevel(
      Map<String, CalculationResult> results,
      int level,
      ) {
    BigInt total = BigInt.zero;

    results.forEach((letter, result) {
      if (result.pLevels.containsKey(level)) {
        total += result.pLevels[level]!;
      }
    });

    return total;
  }

  // Get word total by counting letter occurrences
  static BigInt getWordTotalForLevel(
      String word,
      Map<String, CalculationResult> results,
      int level,
      ) {
    BigInt total = BigInt.zero;

    for (int i = 0; i < word.length; i++) {
      String letter = word[i];
      if (results.containsKey(letter)) {
        CalculationResult result = results[letter]!;
        if (result.pLevels.containsKey(level)) {
          total += result.pLevels[level]!;
        }
      }
    }

    return total;
  }

  // Debug function to see letter frequency at each level
  static Map<String, BigInt> getFrequencyAtLevel(String letter, int level) {
    Map<String, BigInt> frequency = {};

    // Start with the letter's spelling
    List<String> spelling = HuroofData.getSpelling(letter);
    for (String l in spelling) {
      frequency[l] = (frequency[l] ?? BigInt.zero) + BigInt.one;
    }

    // Expand level-1 times
    for (int i = 1; i < level; i++) {
      Map<String, BigInt> nextFrequency = {};

      frequency.forEach((currentLetter, count) {
        List<String> expansion = HuroofData.getSpelling(currentLetter);
        for (String expandedLetter in expansion) {
          nextFrequency[expandedLetter] =
              (nextFrequency[expandedLetter] ?? BigInt.zero) + count;
        }
      });

      frequency = nextFrequency;
    }

    return frequency;
  }

  // Get statistics about expansion growth
  static Map<String, dynamic> getExpansionStats(String letter, int level) {
    Map<String, BigInt> frequency = getFrequencyAtLevel(letter, level);

    BigInt totalLetters = BigInt.zero;
    frequency.forEach((l, count) {
      totalLetters += count;
    });

    return {
      'uniqueLetters': frequency.length,
      'totalLetters': totalLetters.toString(),
      'frequencies': frequency,
    };
  }
}