import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../storage.dart';

class CustomPlatePage extends StatefulWidget {
  const CustomPlatePage({super.key});

  @override
  State<CustomPlatePage> createState() => _CustomPlatePageState();
}

class _CustomPlatePageState extends State<CustomPlatePage> {
  final TextEditingController _controller = TextEditingController();
  Color _bgColor = Colors.black;
  Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedText = await loadCustomText();
    final colors = await loadPlateColors();

    setState(() {
      _controller.text = savedText ?? '';
      _bgColor = colors['bg']!;
      _textColor = colors['text']!;
    });
  }

  Future<void> _save() async {
    await saveCustomText(_controller.text);
    await savePlateColors(_bgColor, _textColor);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Plaque sauvegardée ✅')));
    }
  }

  Future<void> _pickColor(bool isBg) async {
    Color selectedColor = isBg ? _bgColor : _textColor;
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir une couleur'),
          content: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (c) => selectedColor = c,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, selectedColor),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBg) {
          _bgColor = picked;
        } else {
          _textColor = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaque personnalisée')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Texte de la plaque',
              ),
              onChanged: (_) => setState(() {}), // mise à jour aperçu en live
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _pickColor(true),
                  child: const Text('Couleur de fond'),
                ),
                Container(width: 30, height: 30, color: _bgColor),
                ElevatedButton(
                  onPressed: () => _pickColor(false),
                  child: const Text('Couleur du texte'),
                ),
                Container(width: 30, height: 30, color: _textColor),
              ],
            ),
            const SizedBox(height: 30),
            // Aperçu de la plaque
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _controller.text.isEmpty ? 'Aperçu' : _controller.text,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
