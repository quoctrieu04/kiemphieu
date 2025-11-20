import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_scanner_page.dart';
import 'group_list_page.dart';
import 'batch_page.dart';

class PhatPage extends StatefulWidget {
  final int? selectedBatch;

  const PhatPage({super.key, this.selectedBatch});

  @override
  State<PhatPage> createState() => _PhatPageState();
}

class _PhatPageState extends State<PhatPage> {
  int t1 = 0, t2 = 0, t3 = 0, t4 = 0;
  int currentBatch = 0;

  List<Map<String, dynamic>> type1 = [];
  List<Map<String, dynamic>> type2 = [];
  List<Map<String, dynamic>> type3 = [];
  List<Map<String, dynamic>> type4 = [];

  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    loadBatch();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (_mounted && mounted) setState(fn);
  }

  Future<void> loadBatch() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.selectedBatch != null) {
      currentBatch = widget.selectedBatch!;
    } else {
      currentBatch = prefs.getInt("current_batch") ?? 0;
    }

    await loadData();
  }

  Future<void> newBatch() async {
    final prefs = await SharedPreferences.getInstance();

    currentBatch++;
    await prefs.setInt("current_batch", currentBatch);

    t1 = t2 = t3 = t4 = 0;
    type1.clear();
    type2.clear();
    type3.clear();
    type4.clear();

    safeSetState(() {});
  }

  Future<void> loadData() async {
    final snaps = await FirebaseFirestore.instance
        .collection("qr_scans")
        .where("mode", isEqualTo: "phat")
        .where("batch", isEqualTo: currentBatch)
        .get();

    t1 = t2 = t3 = t4 = 0;
    type1.clear();
    type2.clear();
    type3.clear();
    type4.clear();

    for (var doc in snaps.docs) {
      Map<String, dynamic> it = {"id": doc["id"]};

      switch (doc["type"]) {
        case 1:
          type1.add(it);
          t1++;
          break;
        case 2:
          type2.add(it);
          t2++;
          break;
        case 3:
          type3.add(it);
          t3++;
          break;
        case 4:
          type4.add(it);
          t4++;
          break;
      }
    }

    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {

    // ====== TÍNH SỐ NHÓM ĐỦ ======
    int validGroups = [t1, t2, t3, t4].reduce((a, b) => a < b ? a : b);
    int total = t1 + t2 + t3 + t4;

    // ====== TÍNH PHIẾU CẦN THÊM ĐỂ CÓ NHÓM TIẾP THEO ======
    int nextGroup = validGroups + 1;

    int need1 = nextGroup - t1;
    int need2 = nextGroup - t2;
    int need3 = nextGroup - t3;
    int need4 = nextGroup - t4;

    need1 = need1 < 0 ? 0 : need1;
    need2 = need2 < 0 ? 0 : need2;
    need3 = need3 < 0 ? 0 : need3;
    need4 = need4 < 0 ? 0 : need4;

    List<String> suggestions = [];
    if (need1 > 0) suggestions.add("• Thiếu $need1 phiếu loại 1");
    if (need2 > 0) suggestions.add("• Thiếu $need2 phiếu loại 2");
    if (need3 > 0) suggestions.add("• Thiếu $need3 phiếu loại 3");
    if (need4 > 0) suggestions.add("• Thiếu $need4 phiếu loại 4");

    String suggestionText =
        suggestions.isEmpty ? "✔ Đã đủ để lập nhóm tiếp theo!" : suggestions.join("\n");

    // ===========================================================
    return Scaffold(
      appBar: AppBar(
        title: Text("Phát phiếu (Đợt $currentBatch)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BatchPage()),
              ).then((_) => loadBatch());
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _box("Đợt phát hiện tại:", "$currentBatch"),
            const SizedBox(height: 15),

            _box("Số phiếu loại:", "1 - $t1\n2 - $t2\n3 - $t3\n4 - $t4"),
            _box("Tổng phiếu:", "$total"),
            _box("Số nhóm đủ (4 loại):", "$validGroups"),

            // ====== BOX MỚI: SỐ PHIẾU CẦN THÊM ======
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cần thêm để đủ nhóm ${validGroups + 1}:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Type 1: $need1\n"
                    "Type 2: $need2\n"
                    "Type 3: $need3\n"
                    "Type 4: $need4",
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    suggestionText,
                    style: TextStyle(
                      color: suggestions.isEmpty ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupListPage(
                      numGroups: validGroups,
                      type1: type1,
                      type2: type2,
                      type3: type3,
                      type4: type4,
                    ),
                  ),
                );
              },
              child: const Text(
                "Xem danh sách nhóm",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QRScannerPage(mode: "phat", batch: currentBatch),
                  ),
                );
                loadData();
              },
              child: const Text("Quét mã QR"),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _box(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
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
