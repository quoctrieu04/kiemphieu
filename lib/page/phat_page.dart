import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_scanner_page.dart';
import 'group_list_page.dart';

class PhatPage extends StatefulWidget {
  const PhatPage({super.key});

  @override
  State<PhatPage> createState() => _PhatPageState();
}

class _PhatPageState extends State<PhatPage> {
  int t1 = 0, t2 = 0, t3 = 0, t4 = 0;

  final TextEditingController groupController =
      TextEditingController(text: "10");

  // NHẬP SỐ LƯỢNG MỖI TYPE TRONG 1 NHÓM
  final TextEditingController t1Slot = TextEditingController(text: "1");
  final TextEditingController t2Slot = TextEditingController(text: "1");
  final TextEditingController t3Slot = TextEditingController(text: "1");
  final TextEditingController t4Slot = TextEditingController(text: "1");

  int goalGroups = 10;

  Future<void> loadData() async {
    final data = await FirebaseFirestore.instance
        .collection("qr_scans")
        .where("mode", isEqualTo: "phat")
        .get();

    t1 = t2 = t3 = t4 = 0;

    for (var doc in data.docs) {
      switch (doc["type"]) {
        case 1:
          t1++;
          break;
        case 2:
          t2++;
          break;
        case 3:
          t3++;
          break;
        case 4:
          t4++;
          break;
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    goalGroups = int.tryParse(groupController.text) ?? 0;

    // SLOT MỖI TYPE TRONG NHÓM
    int s1 = int.tryParse(t1Slot.text) ?? 0;
    int s2 = int.tryParse(t2Slot.text) ?? 0;
    int s3 = int.tryParse(t3Slot.text) ?? 0;
    int s4 = int.tryParse(t4Slot.text) ?? 0;

    // TỔNG NGƯỜI TRONG 1 NHÓM
    int peoplePerGroup = s1 + s2 + s3 + s4;

    // TỔNG PHIẾU ĐÃ QUÉT
    int total = t1 + t2 + t3 + t4;

    // ================================
    //  🔥 TÍNH SỐ NHÓM ĐỦ THEO DỮ LIỆU
    // ================================

    int currentGroups = 999;

    List<List<int>> pairs = [
      [t1, s1],
      [t2, s2],
      [t3, s3],
      [t4, s4],
    ];

    for (var p in pairs) {
      int have = p[0];
      int need = p[1];

      if (need == 0) continue; // type này không yêu cầu

      int canMake = have ~/ need; // SỐ NHÓM TỐI ĐA CHO TYPE NÀY

      if (canMake < currentGroups) {
        currentGroups = canMake;
      }
    }

    if (currentGroups == 999) currentGroups = 0;

    // ================================
    // 🔥 TÍNH PHIẾU CẦN & PHIẾU THIẾU
    // ================================

    int need1 = goalGroups * s1;
    int need2 = goalGroups * s2;
    int need3 = goalGroups * s3;
    int need4 = goalGroups * s4;

    int missing1 = (need1 - t1).clamp(0, 999);
    int missing2 = (need2 - t2).clamp(0, 999);
    int missing3 = (need3 - t3).clamp(0, 999);
    int missing4 = (need4 - t4).clamp(0, 999);

    return Scaffold(
      appBar: AppBar(title: const Text("Phát phiếu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // NHẬP SỐ NHÓM
            TextField(
              controller: groupController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số nhóm muốn chia",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // CẤU TRÚC 1 NHÓM
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Số lượng từng type trong 1 nhóm",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: t1Slot,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Type 1"),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: t2Slot,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Type 2"),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: t3Slot,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Type 3"),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: t4Slot,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Type 4"),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _box("Số loại phiếu đã phát:", "1 - $t1\n2 - $t2\n3 - $t3\n4 - $t4"),

            _box("Tổng người / nhóm:", "$peoplePerGroup"),

            _box("Số nhóm đủ theo dữ liệu:", "$currentGroups"),

            _box(
              "Thiếu phiếu:",
              "Type 1: $missing1 / $need1\n"
              "Type 2: $missing2 / $need2\n"
              "Type 3: $missing3 / $need3\n"
              "Type 4: $missing4 / $need4",
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QRScannerPage(mode: "phat")),
                );
                loadData();
              },
              child: const Text("Quét mã QR"),
            ),

            const SizedBox(height: 12),

            // Xem danh sách nhóm
            ElevatedButton(
              onPressed: () async {
                final numGroups = int.tryParse(groupController.text) ?? 0;

                final data = await FirebaseFirestore.instance
                    .collection("qr_scans")
                    .where("mode", isEqualTo: "phat")
                    .get();

                List<Map<String, dynamic>> type1 = [];
                List<Map<String, dynamic>> type2 = [];
                List<Map<String, dynamic>> type3 = [];
                List<Map<String, dynamic>> type4 = [];

                for (var d in data.docs) {
                  switch (d["type"]) {
                    case 1:
                      type1.add({"id": d["id"]});
                      break;
                    case 2:
                      type2.add({"id": d["id"]});
                      break;
                    case 3:
                      type3.add({"id": d["id"]});
                      break;
                    case 4:
                      type4.add({"id": d["id"]});
                      break;
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupListPage(
                      numGroups: numGroups,
                      type1: type1,
                      type2: type2,
                      type3: type3,
                      type4: type4,
                      slot1: s1,
                      slot2: s2,
                      slot3: s3,
                      slot4: s4,
                    ),
                  ),
                );
              },
              child: const Text("Xem danh sách nhóm"),
            ),
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
