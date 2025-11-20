import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'qr_scanner_page.dart';

class ThuPage extends StatefulWidget {
  final int selectedBatch;

  const ThuPage({super.key, required this.selectedBatch});

  @override
  State<ThuPage> createState() => _ThuPageState();
}

class _ThuPageState extends State<ThuPage> {
  int phat1 = 0, phat2 = 0, phat3 = 0, phat4 = 0;
  int thu1 = 0, thu2 = 0, thu3 = 0, thu4 = 0;

  List<String> listPhat = [];
  List<String> listThu = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// 🔥 Load dữ liệu phát & thu theo batch
  Future<void> loadData() async {
    final snaps = await FirebaseFirestore.instance
        .collection("qr_scans")
        .where("batch", isEqualTo: widget.selectedBatch)
        .get();

    // reset
    phat1 = phat2 = phat3 = phat4 = 0;
    thu1 = thu2 = thu3 = thu4 = 0;
    listPhat.clear();
    listThu.clear();

    for (var d in snaps.docs) {
      final data = d.data();

      if (!data.containsKey("mode") ||
          !data.containsKey("type") ||
          !data.containsKey("id")) continue;

      final mode = data["mode"];
      final type = data["type"];
      final id = data["id"].toString();

      if (mode == "phat") {
        listPhat.add(id);
        switch (type) {
          case 1: phat1++; break;
          case 2: phat2++; break;
          case 3: phat3++; break;
          case 4: phat4++; break;
        }
      }

      if (mode == "thu") {
        listThu.add(id);
        switch (type) {
          case 1: thu1++; break;
          case 2: thu2++; break;
          case 3: thu3++; break;
          case 4: thu4++; break;
        }
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<String> listMissing =
        listPhat.where((id) => !listThu.contains(id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Thu phiếu (Đợt ${widget.selectedBatch})"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _box("Đã phát:", "1 - $phat1\n2 - $phat2\n3 - $phat3\n4 - $phat4"),
          _box("Đã thu:", "1 - $thu1\n2 - $thu2\n3 - $thu3\n4 - $thu4"),

          _box("Còn thiếu (${listMissing.length}):",
              listMissing.isEmpty ? "Đã thu đủ!" : listMissing.join(", ")),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QRScannerPage(mode: "thu", batch: widget.selectedBatch),
                ),
              );
              loadData();
            },
            child: const Text("Quét mã QR"),
          ),
        ],
      ),
    );
  }

  Widget _box(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }
}
