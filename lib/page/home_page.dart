import 'package:flutter/material.dart';
import 'qr_scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? type;
  String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Icon(Icons.qr_code_scanner, size: 120, color: Colors.deepPurple),

            const SizedBox(height: 30),

            Text(
              "Kết quả quét gần nhất:",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 10),

            Text(
              "Type: ${type ?? "--"}   |   ID: ${id ?? "--"}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                "Quét QR",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerPage()),
                );

                if (!mounted || result == null || result["error"] == true) return;

                setState(() {
                  type = result["type"];
                  id = result["id"];
                });
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
