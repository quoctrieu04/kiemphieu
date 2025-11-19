import 'package:flutter/material.dart';
import 'phat_page.dart';
import 'thu_page.dart';
import 'qr_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 2 nút lớn: PHÁT & THU
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhatPage()),
                );
              },
              child: const Text("PHÁT PHIẾU"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThuPage()),
                );
              },
              child: const Text("THU PHIẾU"),
            ),

            const SizedBox(height: 40),

            // Nút quét nhanh như hiện tại
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: 
                      (_) => const QRScannerPage(mode: "phat")), // mặc định chế độ phát
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
