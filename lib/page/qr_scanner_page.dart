import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerPage extends StatefulWidget {
  final String mode; // phat | thu
  final int batch;

  const QRScannerPage({
    super.key,
    required this.mode,
    required this.batch,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _canScan = true;

  List<String> scannedIDs = [];

  @override
  void initState() {
    super.initState();
    loadLocalHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Load lịch sử local chỉ theo batch + mode hiện tại
  Future<void> loadLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("qr_history") ?? [];

    scannedIDs = list
        .map((e) {
          final obj = jsonDecode(e);
          if (obj["batch"] == widget.batch && obj["mode"] == widget.mode) {
            return obj["id"].toString();
          }
          return null;
        })
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  }

  Future<void> saveHistoryLocal(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("qr_history") ?? [];

    list.add(jsonEncode(data));
    await prefs.setStringList("qr_history", list);
  }

  Future<String?> saveHistoryFirebase(Map<String, dynamic> data) async {
    try {
      final doc = await FirebaseFirestore.instance.collection("qr_scans").add({
        "type": data["type"],
        "id": data["id"],
        "mode": widget.mode,
        "batch": widget.batch,
        "timestamp": FieldValue.serverTimestamp(),
      });

      return doc.id;
    } catch (e) {
      print("🔥 FIREBASE ERROR: $e");
      return null;
    }
  }

  Map<String, dynamic>? parseJson(String raw) {
    try {
      return jsonDecode(
        raw
            .replaceAll("'", "\"")
            .replaceAll("“", "\"")
            .replaceAll("”", "\"")
            .trim(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 🔥 Kiểm tra trong batch này ID đã phát chưa? đã thu chưa?
  Future<Map<String, bool>> checkStatus(String id) async {
    final snaps = await FirebaseFirestore.instance
        .collection("qr_scans")
        .where("batch", isEqualTo: widget.batch)
        .where("id", isEqualTo: id)
        .get();

    bool daPhat = false;
    bool daThu = false;

    for (var d in snaps.docs) {
      if (d["mode"] == "phat") daPhat = true;
      if (d["mode"] == "thu") daThu = true;
    }

    return {"phat": daPhat, "thu": daThu};
  }

  /// 🔥 Xử lý khi quét QR
  Future<void> handleScan(String raw) async {
    if (!_canScan) return;

    _canScan = false;
    await Future.delayed(const Duration(milliseconds: 700));
    _canScan = true;

    final parsed = parseJson(raw);
    if (parsed == null) {
      showMsg("❌ QR không hợp lệ!");
      return;
    }

    final id = parsed["id"].toString();

    // 🔥 Chống trùng local
    if (scannedIDs.contains(id)) {
      showMsg("⚠ Mã $id đã quét rồi trong thiết bị!");
      return;
    }

    // 🔥 Kiểm tra trạng thái trong batch (đã phát / đã thu)
    final status = await checkStatus(id);
    final daPhat = status["phat"]!;
    final daThu = status["thu"]!;

    // ==========================
    // 🔥 MODE PHÁT
    // ==========================
    if (widget.mode == "phat") {
      if (daPhat) {
        showMsg("⚠ Mã $id đã tồn tại trong ĐỢT ${widget.batch}!");
        return;
      }
    }

    // ==========================
    // 🔥 MODE THU
    // ==========================
    if (widget.mode == "thu") {
      if (!daPhat) {
        showMsg("❌ Mã $id chưa được PHÁT — không thể THU!");
        return;
      }
      if (daThu) {
        showMsg("⚠ Mã $id đã THU rồi!");
        return;
      }
    }

    // Lưu vào Firebase
    final docId = await saveHistoryFirebase(parsed);
    if (docId != null) parsed["docId"] = docId;

    // Lưu local
    parsed["batch"] = widget.batch;
    parsed["mode"] = widget.mode;

    await saveHistoryLocal(parsed);
    scannedIDs.add(id);

    showMsg(
      "✔ ${widget.mode == "phat" ? "Đã PHÁT" : "Đã THU"} | ID: $id | Type: ${parsed["type"]} | Đợt: ${widget.batch}",
    );
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quét mã QR (${widget.mode.toUpperCase()})")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final raw = capture.barcodes.first.rawValue;
              if (raw != null) handleScan(raw);
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
