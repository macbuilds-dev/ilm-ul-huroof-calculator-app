import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/huroof_controller.dart';
import '../model/huroof_model.dart';
import 'results_view.dart';

class CalculatorView extends StatefulWidget {
  final bool isZakat;

  const CalculatorView({
    Key? key,
    required this.isZakat,
  }) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();

  String _selectedMode = 'single'; // 'single' or 'word'
  String? _selectedLetter;
  int _maxLevel = 4;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _maxLevel = widget.isZakat ? 4 : 8; // Zakat: P-9 to P-12, Normal: P-1 to P-8
    _levelController.text = _maxLevel.toString();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_selectedMode == 'single' && _selectedLetter == null) {
      _showError('Please select a letter');
      return;
    }

    if (_selectedMode == 'word' && _inputController.text.trim().isEmpty) {
      _showError('Please enter a word or name');
      return;
    }

    setState(() => _isCalculating = true);

    // Show loading dialog for large calculations
    if (_maxLevel > 10) {
      _showLoadingDialog();
    }

    // Use Future to prevent UI blocking
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        if (_selectedMode == 'single') {
          CalculationResult result = HuroofController.calculatePLevels(
            letter: _selectedLetter!,
            maxLevel: _maxLevel,
            isZakat: widget.isZakat,
          );

          setState(() => _isCalculating = false);
          if (_maxLevel > 10) Navigator.pop(context); // Close loading dialog

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsView(
                results: {_selectedLetter!: result},
                isZakat: widget.isZakat,
                inputText: _selectedLetter!,
              ),
            ),
          );
        } else {
          Map<String, CalculationResult> results = HuroofController.calculateForWord(
            word: _inputController.text.trim(),
            maxLevel: _maxLevel,
            isZakat: widget.isZakat,
          );

          setState(() => _isCalculating = false);
          if (_maxLevel > 10) Navigator.pop(context); // Close loading dialog

          if (results.isEmpty) {
            _showError('No valid letters found in input');
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsView(
                  results: results,
                  isZakat: widget.isZakat,
                  inputText: _inputController.text.trim(),
                ),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isCalculating = false);
        if (_maxLevel > 10) Navigator.pop(context); // Close loading dialog
        _showError('Calculation error: ${e.toString()}');
      }
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF00695C),
              ),
              const SizedBox(height: 20),
              const Text(
                'Calculating...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Processing P-level $_maxLevel',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This may take a moment for large calculations',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isZakat ? 'حروف کی زکوٰۃ' : 'حروف کے اعداد',
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Selection
            _buildModeSelector(),

            const SizedBox(height: 25),

            // Input Section
            if (_selectedMode == 'single')
              _buildLetterSelector()
            else
              _buildWordInput(),

            const SizedBox(height: 25),

            // Level Input
            _buildLevelInput(),

            const SizedBox(height: 30),

            // Calculate Button
            _buildCalculateButton(),

            const SizedBox(height: 20),

            // Info Card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton('single', 'Single Letter', Icons.text_fields),
          ),
          Expanded(
            child: _buildModeButton('word', 'Word/Name', Icons.article),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, String label, IconData icon) {
    bool isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() {
        _selectedMode = mode;
        _selectedLetter = null;
        _inputController.clear();
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00695C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterSelector() {
    List<HuroofLetter> letters = HuroofData.getAllLetters();

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Letter (حرف منتخب کریں)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: letters.map((letter) {
              bool isSelected = _selectedLetter == letter.letter;
              return InkWell(
                onTap: () => setState(() => _selectedLetter = letter.letter),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00695C)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00695C)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter.letter,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedLetter != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00695C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Base Value (اصل عدد): ${HuroofData.getBaseValue(_selectedLetter!)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordInput() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Word or Name (لفظ یا نام لکھیں)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _inputController,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'مثال: محمد',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 20,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00695C),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInput() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isZakat
                ? 'Number of Zakat Levels (P-9 to P-${8 + _maxLevel})'
                : 'Number of P-Levels (P-1 to P-$_maxLevel)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_maxLevel > 1) {
                    setState(() {
                      _maxLevel--;
                      _levelController.text = _maxLevel.toString();
                    });
                  }
                },
                icon: const Icon(Icons.remove_circle),
                color: const Color(0xFF00695C),
                iconSize: 36,
              ),
              Expanded(
                child: TextField(
                  controller: _levelController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D40),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00695C),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    int? newLevel = int.tryParse(value);
                    if (newLevel != null && newLevel > 0 && newLevel <= 1000) {
                      setState(() => _maxLevel = newLevel);
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_maxLevel < 1000) {
                    setState(() {
                      _maxLevel++;
                      _levelController.text = _maxLevel.toString();
                    });
                  }
                },
                icon: const Icon(Icons.add_circle),
                color: const Color(0xFF00695C),
                iconSize: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _isCalculating ? null : _calculate,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00695C),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: _isCalculating
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Calculate (حساب کریں)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.isZakat
                      ? 'Zakat Levels Information'
                      : 'P-Levels Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.isZakat
                ? 'Zakat calculations use exponential growth from P-8. Higher levels grow very large.'
                : 'P-levels use recursive expansion. You can calculate up to P-1000.\n\n'
                '• P-1 to P-20: Very fast (< 1 second)\n'
                '• P-21 to P-50: Fast (1-5 seconds)\n'
                '• P-51 to P-100: Moderate (5-15 seconds)\n'
                '• P-100+: Slower (15-60 seconds)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[900],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}