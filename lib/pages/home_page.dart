import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // REQUIRED

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _processedBytes;
  final ImagePicker _picker = ImagePicker();
  Color _bgColor = Colors.black;
  Color _textColor = Colors.white;
  String _customText = "TEST";

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() => _processedBytes = bytes);
  }

  // FIX: Using c.toARGB32 to get the integer color value, as recommended
  // for the image package functions.
  int Function() _colorToInt(Color c) => c.toARGB32;

  Future<void> _processImage() async {
    if (_processedBytes == null) return;

    img.Image? original = img.decodeImage(_processedBytes!);
    if (original == null) return;

    // Définir la zone de plaque
    final bbox = Rect.fromLTWH(
      original.width * 0.3,
      original.height * 0.7,
      original.width * 0.4,
      original.height * 0.1,
    );

    // Charger la police Bitmap
    final fontData = await rootBundle.load('assets/fonts/arial.fnt');
    final fontImageData = await rootBundle.load('assets/fonts/arial.png');

    // FIX: Decode the PNG data (ByteData) into an img.Image object first.
    final img.Image? fontImage = img.decodeImage(
      fontImageData.buffer.asUint8List(),
    );
    if (fontImage == null) {
      // Handle font image loading error
      print("Erreur: Impossible de charger l'image de la police.");
      return;
    }

    // The img.BitmapFont.fromFnt signature for v4.x is (ByteData fnt, Image image)
    final font = img.BitmapFont.fromFnt(fontData as String, fontImage);

    // Using '!' is safe here because original was checked for null above.
    original = _applyCustomPlate(
      original,
      bbox,
      _customText,
      font,
      _bgColor,
      _textColor,
    );

    setState(
      () => _processedBytes = Uint8List.fromList(img.encodeJpg(original!)),
    );
  }

  img.Image _applyCustomPlate(
    img.Image image,
    Rect region,
    String text,
    img.BitmapFont font,
    Color bg,
    Color fg,
  ) {
    // Fond
    img.fillRect(
      image,
      x1: region.left.toInt(),
      y1: region.top.toInt(),
      x2: region.right.toInt(),
      y2: region.bottom.toInt(),
      color: _colorToInt(bg), // Uses integer color
    );

    // Calculer position centrée du texte
    // FIX: Use img.textWidth with the required named 'font' argument
    final textWidth = img.textWidth(text, font: font);
    final x = (region.left + region.width / 2 - textWidth / 2).toInt();
    final y = (region.top + region.height / 2 - font.lineHeight ~/ 2).toInt();

    // FIX: Correct arguments for img.drawString: (image, font, x, y, text, {color})
    img.drawString(
      image,
      font as String,
      x,
      y,
      text,
      color: _colorToInt(fg), // Uses the named 'color' argument with integer
    );

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaques personnalisées')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_processedBytes != null)
                Image.memory(_processedBytes!, height: 400, fit: BoxFit.contain)
              else
                const Text('Aucune image sélectionnée.'),
              const SizedBox(height: 20),
              // Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Texte plaque'),
                  onChanged: (v) => _customText = v,
                  controller: TextEditingController(text: _customText),
                ),
              ),
              const SizedBox(height: 20),
              // Buttons
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Prendre une photo'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.blur_on),
                    label: const Text('Appliquer plaque'),
                    onPressed: _processImage,
                  ),
                  _buildColorButton(
                    isTextColor: true,
                    icon: Icons.color_lens,
                    label: 'Couleur texte',
                  ),
                  _buildColorButton(
                    isTextColor: false,
                    icon: Icons.format_color_fill,
                    label: 'Couleur fond',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton({
    required bool isTextColor,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () => _showColorPicker(isTextColor),
    );
  }

  Future<void> _showColorPicker(bool isTextColor) async {
    Color selectedColor = isTextColor ? _textColor : _bgColor;
    Color tempColor = selectedColor;

    final Color? color = await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isTextColor ? 'Choisir couleur texte' : 'Choisir couleur fond',
        ),
        content: SingleChildScrollView(
          // ColorPicker requires flutter_colorpicker package
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, tempColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (color != null) {
      setState(() {
        if (isTextColor) {
          _textColor = color;
        } else {
          _bgColor = color;
        }
      });
    }
  }
}
