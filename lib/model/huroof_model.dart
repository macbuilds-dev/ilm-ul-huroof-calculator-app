// models/huroof_model.dart

class HuroofLetter {
  final String letter;
  final int baseValue;
  final List<String> groupedWith; // Letters with same base value

  HuroofLetter({
    required this.letter,
    required this.baseValue,
    this.groupedWith = const [],
  });
}

class HuroofData {
  // P0 - Base Abjad values according to traditional Ilm-ul-Huroof
  static final Map<String, int> baseValues = {
    'ا': 1,
    'ب': 2,
    'پ': 2,
    'ج': 3,
    'چ': 3,
    'د': 4,
    'ڈ': 4,
    'ہ': 5,
    'ھ': 5,
    'و': 6,
    'ز': 7,
    'ژ': 7,
    'ح': 8,
    'ط': 9,
    'ی': 10,
    'ک': 20,
    'گ': 20,
    'ل': 30,
    'م': 40,
    'ن': 50,
    'س': 60,
    'ع': 70,
    'ف': 80,
    'ص': 90,
    'ق': 100,
    'ر': 200,
    'ڑ': 200,
    'ش': 300,
    'ت': 400,
    'ٹ': 400,
    'ث': 500,
    'خ': 600,
    'ذ': 700,
    'ض': 800,
    'ظ': 900,
    'غ': 1000,
  };

  // Letter spellings (how each letter is spelled/named)
  static final Map<String, List<String>> letterSpellings = {
    'ا': ['ا', 'ل', 'ف'],
    'ب': ['ب', 'ا'],
    'پ': ['پ', 'ا'], // Same as ب
    'ت': ['ت', 'ا'],
    'ٹ': ['ٹ', 'ا'], // Same as ت
    'ث': ['ث', 'ا'],
    'ج': ['ج', 'ی', 'م'],
    'چ': ['چ', 'ی', 'م'], // Same as ج
    'ح': ['ح', 'ا'],
    'خ': ['خ', 'ا'],
    'د': ['د', 'ا', 'ل'],
    'ڈ': ['ڈ', 'ا', 'ل'], // Same as د
    'ذ': ['ذ', 'ا', 'ل'],
    'ر': ['ر', 'ا'],
    'ڑ': ['ڑ', 'ا'], // Same as ر
    'ز': ['ز', 'ا'],
    'ژ': ['ژ', 'ا'], // Same as ز
    'س': ['س', 'ی', 'ن'],
    'ش': ['ش', 'ی', 'ن'],
    'ص': ['ص', 'ا', 'د'],
    'ض': ['ض', 'ا', 'د'],
    'ط': ['ط', 'ا'],
    'ظ': ['ظ', 'ا'],
    'ع': ['ع', 'ی', 'ن'],
    'غ': ['غ', 'ی', 'ن'],
    'ف': ['ف', 'ا'],
    'ق': ['ق', 'ا', 'ف'],
    'ک': ['ک', 'ا', 'ف'],
    'گ': ['گ', 'ا', 'ف'], // Same as ک
    'ل': ['ل', 'ا', 'م'],
    'م': ['م', 'ی', 'م'],
    'ن': ['ن', 'و', 'ن'],
    'و': ['و', 'ا', 'و'],
    'ہ': ['ہ', 'ا'],
    'ھ': ['ھ', 'ا'], // Same as ہ
    'ی': ['ی', 'ا'],
  };

  // Get all letters sorted by base value
  static List<HuroofLetter> getAllLetters() {
    Map<int, List<String>> grouped = {};

    baseValues.forEach((letter, value) {
      if (!grouped.containsKey(value)) {
        grouped[value] = [];
      }
      grouped[value]!.add(letter);
    });

    List<HuroofLetter> letters = [];
    baseValues.forEach((letter, value) {
      letters.add(HuroofLetter(
        letter: letter,
        baseValue: value,
        groupedWith: grouped[value] ?? [],
      ));
    });

    // Sort by base value
    letters.sort((a, b) => a.baseValue.compareTo(b.baseValue));
    return letters;
  }

  static int getBaseValue(String letter) {
    return baseValues[letter] ?? 0;
  }

  static List<String> getSpelling(String letter) {
    return letterSpellings[letter] ?? [letter];
  }
}

class CalculationResult {
  final String letter;
  final int baseValue;
  final Map<int, BigInt> pLevels; // P-1, P-2, P-3, etc.
  final bool isZakat; // Whether this is Zakat calculation

  CalculationResult({
    required this.letter,
    required this.baseValue,
    required this.pLevels,
    this.isZakat = false,
  });
}




// class HuroofLetter {
//   final String letter;
//   final int baseValue;
//   final List<String> groupedWith; // Letters with same base value
//
//   HuroofLetter({
//     required this.letter,
//     required this.baseValue,
//     this.groupedWith = const [],
//   });
// }
//
// class HuroofData {
//   // Base Abjad values according to traditional Ilm-ul-Huroof
//   static final Map<String, int> baseValues = {
//     'ا': 1,
//     'ب': 2,
//     'پ': 2,
//     'ج': 3,
//     'چ': 3,
//     'د': 4,
//     'ڈ': 4,
//     'ہ': 5,
//     'ھ': 5,
//     'و': 6,
//     'ز': 7,
//     'ژ': 7,
//     'ح': 8,
//     'ط': 9,
//     'ی': 10,
//     'ک': 20,
//     'گ': 20,
//     'ل': 30,
//     'م': 40,
//     'ن': 50,
//     'س': 60,
//     'ع': 70,
//     'ف': 80,
//     'ص': 90,
//     'ق': 100,
//     'ر': 200,
//     'ڑ': 200,
//     'ش': 300,
//     'ت': 400,
//     'ٹ': 400,
//     'ث': 500,
//     'خ': 600,
//     'ذ': 700,
//     'ض': 800,
//     'ظ': 900,
//     'غ': 1000,
//   };
//
//   // Get all letters sorted by base value
//   static List<HuroofLetter> getAllLetters() {
//     Map<int, List<String>> grouped = {};
//
//     baseValues.forEach((letter, value) {
//       if (!grouped.containsKey(value)) {
//         grouped[value] = [];
//       }
//       grouped[value]!.add(letter);
//     });
//
//     List<HuroofLetter> letters = [];
//     baseValues.forEach((letter, value) {
//       letters.add(HuroofLetter(
//         letter: letter,
//         baseValue: value,
//         groupedWith: grouped[value] ?? [],
//       ));
//     });
//
//     // Sort by base value
//     letters.sort((a, b) => a.baseValue.compareTo(b.baseValue));
//     return letters;
//   }
//
//   static int getBaseValue(String letter) {
//     return baseValues[letter] ?? 0;
//   }
// }
//
// class CalculationResult {
//   final String letter;
//   final int baseValue;
//   final Map<int, BigInt> pLevels; // P-1, P-2, P-3, etc.
//   final bool isZakat; // Whether this is Zakat calculation
//
//   CalculationResult({
//     required this.letter,
//     required this.baseValue,
//     required this.pLevels,
//     this.isZakat = false,
//   });
// }

// ا => ا+ل+ف => (ا+ل+ف) + (ل+ا+م) + (ف+ا) => {(ا+ل+ف) + (ل+ا+م) + (ف+ا)} + {(ل+ا+م) + (ا+ل+ف) + (م+ي+م)} + {(ف+ا) + (ا+ل+ف)} =>.......
// ب => ب+ا
// ت => ت+ا
// ث => ث+ا
// ج => ج+ي+م
// ح => ح+ا
// خ => خ+ا
// د => د+ا+ل
// ذ => ذ+ا+ل
// ر => ر+ا
// ز => ز+ا
// س => س+ي+ن
// ش => ش+ي+ن
// ص => ص+ا+د
// ض => ض+ا+د
// ط => ط+ا
// ظ => ظ+ا
// ع => ع+ي+ن
// غ => غ+ي+ن
// ف => ف+ا
// ق => ق+ا+ف
// ك => ك+ا+ف
// ل => ل+ا+م
// م => م+ي+م
// ن => ن+و+ن
// و => و+ا+و
// ه => ه+ا
// ي => ي+ا