import 'package:flutter/material.dart';
import 'package:kiemphieu/page/QuayThuongBatchPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phat_page.dart';
import 'thu_batch_page.dart'; // 🔥 MÀN CHỌN ĐỢT THU
import 'qr_scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentBatch = 0;

  @override
  void initState() {
    super.initState();
    loadBatch();
  }

  Future<void> loadBatch() async {
    final prefs = await SharedPreferences.getInstance();
    currentBatch = prefs.getInt("current_batch") ?? 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ====================================
            // 🔥 PHÁT PHIẾU
            // ====================================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhatPage()),
                ).then((_) => loadBatch()); // <🔥 reload batch after return>
              },
              child: const Text("PHÁT PHIẾU"),
            ),

            const SizedBox(height: 20),

            // ====================================
            // 🔥 THU PHIẾU (chọn đợt)
            // ====================================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThuBatchPage()),
                );
              },
              child: const Text("THU PHIẾU"),
            ),

            const SizedBox(height: 40),

            // ====================================
            // 🔥 QUAY THƯỞNG
            // ====================================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuayThuongBatchPage(),
                  ),
                );
              },
              child: const Text("Quay thưởng"),
            ),
          ],
        ),
      ),
    );
  }
}
