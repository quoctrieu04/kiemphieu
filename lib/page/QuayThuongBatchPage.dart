import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quay_thuong_page.dart';

class QuayThuongBatchPage extends StatefulWidget {
  const QuayThuongBatchPage({super.key});

  @override
  State<QuayThuongBatchPage> createState() => _QuayThuongBatchPageState();
}

class _QuayThuongBatchPageState extends State<QuayThuongBatchPage> {
  List<int> batchList = [];

  @override
  void initState() {
    super.initState();
    loadBatches();
  }

  Future<void> loadBatches() async {
    final snaps = await FirebaseFirestore.instance.collection("qr_scans").get();

    final set = <int>{};
    for (var d in snaps.docs) {
      if (d.data().containsKey("batch")) set.add(d["batch"]);
    }

    batchList = set.toList()..sort();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chọn đợt quay thưởng")),

      body: ListView.builder(
        itemCount: batchList.length,
        itemBuilder: (_, i) {
          final batch = batchList[i];

          return ListTile(
            title: Text("Đợt $batch"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuayThuongPage(batch: batch),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
