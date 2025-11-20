import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class QuayThuongPage extends StatefulWidget {
  final int batch;

  const QuayThuongPage({super.key, required this.batch});

  @override
  State<QuayThuongPage> createState() => _QuayThuongPageState();
}

class _QuayThuongPageState extends State<QuayThuongPage> {
  List<String> allIDs = [];
  List<String> winners = [];

  final TextEditingController countController =
      TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    loadIDs();
  }

  /// 🔥 Tải tất cả ID đã phát của đợt
  Future<void> loadIDs() async {
    final snaps = await FirebaseFirestore.instance
        .collection("qr_scans")
        .where("batch", isEqualTo: widget.batch)
        .where("mode", isEqualTo: "phat")
        .get();

    allIDs = snaps.docs.map((e) => e["id"].toString()).toList();

    setState(() {});
  }

  /// 🎉 Random ID trúng thưởng
  void randomWinners() {
    int count = int.tryParse(countController.text) ?? 0;

    if (count <= 0) {
      showMsg("Số lượng phải lớn hơn 0!");
      return;
    }
    if (count > allIDs.length) {
      showMsg("Không đủ phiếu để quay!");
      return;
    }

    final rng = Random();
    final pool = [...allIDs];

    winners.clear();

    for (int i = 0; i < count; i++) {
      final index = rng.nextInt(pool.length);
      winners.add(pool[index]);
      pool.removeAt(index);
    }

    setState(() {});
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quay thưởng (Đợt ${widget.batch})"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Số phiếu đã phát: ${allIDs.length}",
                style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            TextField(
              controller: countController,
              decoration: const InputDecoration(
                labelText: "Số phiếu muốn quay",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: randomWinners,
              child: const Text("🎉 QUAY NGAY"),
            ),

            const SizedBox(height: 20),

            if (winners.isNotEmpty)
              const Text(
                "🎉 KẾT QUẢ TRÚNG THƯỞNG:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 10),

            // ⭐⭐ LISTVIEW CUỘN – KHÔNG BAO GIỜ TRÀN ⭐⭐
            Expanded(
              child: ListView.builder(
                itemCount: winners.length,
                itemBuilder: (_, i) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading:
                          const Icon(Icons.star, color: Colors.orange, size: 28),
                      title: Text(
                        "ID: ${winners[i]}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
