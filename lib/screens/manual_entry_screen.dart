import 'package:flutter/material.dart';
import '../models/course_catalog.dart';
import '../models/hole_score.dart';
import 'review_verification_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  String _selectedPreset = '18 Holes (Resort + Classic)';

  final List<String> _presets = [
    '18 Holes (Resort + Classic)',
    'Resort (Holes 1–9)',
    'Classic (Holes 10–18)',
    '3 Holes (1–3)',
  ];

  List<HoleScore> _generateHoles(String preset) {
    List<int> holeNums;
    if (preset == 'Resort (Holes 1–9)') {
      holeNums = List.generate(9, (i) => i + 1);
    } else if (preset == 'Classic (Holes 10–18)') {
      holeNums = List.generate(9, (i) => i + 10);
    } else if (preset == '3 Holes (1–3)') {
      holeNums = [1, 2, 3];
    } else {
      holeNums = List.generate(18, (i) => i + 1);
    }

    return holeNums.map((h) {
      final par = CourseCatalog.getExpectedPar(h);
      return HoleScore(holeNumber: h, par: par, strokes: par);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Round (Manual)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Course Format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your Nintendo Switch Sports golf round format to pre-fill standard hole pars.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ..._presets.map((preset) {
              final isSelected = _selectedPreset == preset;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    preset,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  value: preset,
                  groupValue: _selectedPreset,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPreset = val;
                      });
                    }
                  },
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final holes = _generateHoles(_selectedPreset);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ReviewVerificationScreen(
                        initialHoles: holes,
                        initialCourseType: _selectedPreset,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Continue to Score Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
