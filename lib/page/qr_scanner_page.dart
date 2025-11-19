import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerPage extends StatefulWidget {
  final String mode;
  const QRScannerPage({super.key, required this.mode});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _canDetect = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// LƯU LOCAL (có thêm docId)
  Future<void> saveHistoryLocal(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList("qr_history") ?? [];

    saved.add(jsonEncode(data)); // data có thêm docId từ Firebase
    await prefs.setStringList("qr_history", saved);
  }

  /// LƯU FIREBASE (và trả về docId)
  Future<void> saveHistoryFirebase(Map<String, dynamic> data) async {
    final doc = await FirebaseFirestore.instance.collection("qr_scans").add({
      "type": data["type"],
      "id": data["id"],
      "mode": widget.mode,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Gán docId vào data để lưu local
    data["docId"] = doc.id;

    print("🔥 Lưu lên Firebase thành công! docId = ${doc.id}");
  }

  Map<String, dynamic>? parseJsonSafe(String raw) {
    try {
      final fixed = raw
          .replaceAll("'", "\"")
          .replaceAll("“", "\"")
          .replaceAll("”", "\"")
          .trim();

      return jsonDecode(fixed);
    } catch (e) {
      print("JSON ERROR: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quét mã QR"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (!_canDetect) return;
              _canDetect = false;

              final raw = capture.barcodes.first.rawValue;
              if (raw == null) {
                Navigator.pop(context, {"error": true});
                return;
              }

              final parsed = parseJsonSafe(raw);
              if (parsed == null) {
                Navigator.pop(context, {"error": true});
                return;
              }

              // LƯU FIREBASE TRƯỚC để lấy docId
              try {
                await saveHistoryFirebase(parsed);
              } catch (e) {
                print("Firebase ERROR: $e");
              }

              // Sau đó lưu local (đã có docId)
              await saveHistoryLocal(parsed);

              if (!mounted) return;
              Navigator.pop(context, parsed);
            },
          ),

          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: "flash",
                  backgroundColor: Colors.black54,
                  child: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () => _controller.toggleTorch(),
                ),

                FloatingActionButton(
                  heroTag: "switch",
                  backgroundColor: Colors.black54,
                  child: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: () => _controller.switchCamera(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
