import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/common.dart';
import 'processing.dart';

/// Camera-style screen. The shutter opens the device camera (native camera on
/// iPhone Safari); the gallery button picks an existing photo. Supports several
/// pages: each photo is added, then "Analyze" sends them all together.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const _maxPages = 5;
  final _picker = ImagePicker();
  final List<Uint8List> _pages = [];
  bool _busy = false;

  Future<void> _addPage(ImageSource source) async {
    if (_busy) return;
    if (_pages.length >= _maxPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 5 pages.', style: TextStyle(fontSize: 17))),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600, // shrink before upload: faster + under size limit
        maxHeight: 2200,
        imageQuality: 80,
      );
      if (file == null || !mounted) return; // cancelled
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _pages.add(bytes));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open the camera. Please allow camera access and try again.',
            style: TextStyle(fontSize: 17)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _analyze(List<Uint8List> pages) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProcessingScreen(pages: pages)),
      );

  @override
  Widget build(BuildContext context) {
    final hasPages = _pages.isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFF15171C),
      body: SafeArea(
        child: PhoneWidth(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      iconSize: 30,
                      color: Colors.white,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (hasPages)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text('${_pages.length} / $_maxPages pages',
                            style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      ),
                  ],
                ),
              ),
              const Text('Take a Photo',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Add each page of your document, then Analyze',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),

              // Frame guide / page thumbnails
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: hasPages ? _thumbnails() : _emptyFrame(),
                ),
              ),

              // Analyze button appears once there is at least one page
              if (hasPages)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 26),
                      label: Text('Analyze ${_pages.length} '
                          '${_pages.length == 1 ? 'page' : 'pages'}'),
                      onPressed: () => _analyze(List.of(_pages)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Bottom controls
              Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Choose a photo',
                      iconSize: 34,
                      color: Colors.white,
                      icon: const Icon(Icons.photo_library_outlined),
                      onPressed: () => _addPage(ImageSource.gallery),
                    ),
                    Semantics(
                      button: true,
                      label: hasPages ? 'Add another page' : 'Take photo',
                      child: GestureDetector(
                        onTap: () => _addPage(ImageSource.camera),
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 5),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: _busy
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: CircularProgressIndicator(strokeWidth: 3),
                                  )
                                : (hasPages
                                    ? const Icon(Icons.add, size: 34, color: Colors.black)
                                    : null),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tip: use good light',
                      iconSize: 34,
                      color: Colors.white,
                      icon: const Icon(Icons.flash_on_rounded),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Tip: turn on a light or use your camera\'s flash.',
                            style: TextStyle(fontSize: 17)),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyFrame() => GestureDetector(
        onTap: () => _addPage(ImageSource.camera),
        child: CustomPaint(
          painter: _FrameCornersPainter(),
          child: Container(
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: _busy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, size: 72, color: Colors.white38),
                        SizedBox(height: 14),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Tap the white button to open your camera.\n'
                            'Use good light and fit the whole page.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.4),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );

  Widget _thumbnails() => GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _pages.length,
        itemBuilder: (context, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_pages[i],
                  fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: GestureDetector(
                onTap: () => setState(() => _pages.removeAt(i)),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
}

/// White corner brackets around the document frame.
class _FrameCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 34.0;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, len)..lineTo(0, 0)..lineTo(len, 0)
      ..moveTo(w - len, 0)..lineTo(w, 0)..lineTo(w, len)
      ..moveTo(w, h - len)..lineTo(w, h)..lineTo(w - len, h)
      ..moveTo(len, h)..lineTo(0, h)..lineTo(0, h - len);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
