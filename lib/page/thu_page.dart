import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_scanner_page.dart';

class ThuPage extends StatefulWidget {
  const ThuPage({super.key});

  @override
  State<ThuPage> createState() => _ThuPageState();
}

class _ThuPageState extends State<ThuPage> {
  int phat1 = 0, phat2 = 0, phat3 = 0, phat4 = 0;
  int thu1 = 0, thu2 = 0, thu3 = 0, thu4 = 0;

  Future<void> loadData() async {
    final data = await FirebaseFirestore.instance.collection("qr_scans").get();

    phat1 = phat2 = phat3 = phat4 = 0;
    thu1 = thu2 = thu3 = thu4 = 0;

    for (var d in data.docs) {
      if (d["mode"] == "phat") {
        switch (d["type"]) {
          case 1:
            phat1++;
            break;
          case 2:
            phat2++;
            break;
          case 3:
            phat3++;
            break;
          case 4:
            phat4++;
            break;
        }
      }

      if (d["mode"] == "thu") {
        switch (d["type"]) {
          case 1:
            thu1++;
            break;
          case 2:
            thu2++;
            break;
          case 3:
            thu3++;
            break;
          case 4:
            thu4++;
            break;
        }
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
    return Scaffold(
      appBar: AppBar(title: const Text("Thu phiếu")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _box("Số phiếu đã thu:",
                "1 - $thu1\n2 - $thu2\n3 - $thu3\n4 - $thu4"),

            _box("Số cần thu:",
                "1 - ${phat1 - thu1}\n2 - ${phat2 - thu2}\n3 - ${phat3 - thu3}\n4 - ${phat4 - thu4}"),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QRScannerPage(mode: "thu")),
                );
                loadData();
              },
              child: const Text("Quét mã QR"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _box(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
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
