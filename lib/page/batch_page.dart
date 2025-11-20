import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phat_page.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({super.key});

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  List<int> batchList = [];
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    loadBatches();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (_mounted && mounted) setState(fn);
  }

  Future<void> loadBatches() async {
    final snaps = await FirebaseFirestore.instance.collection("qr_scans").get();

    final set = <int>{};

    for (var d in snaps.docs) {
      if (d.data().containsKey("batch")) {
        set.add(d["batch"]);
      }
    }

    batchList = set.toList()..sort();
    safeSetState(() {});
  }

  Future<void> deleteBatch(int batch) async {
    final yes = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xoá đợt này?"),
        content: Text("Bạn có chắc muốn xoá Đợt $batch không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xoá"),
          ),
        ],
      ),
    );

    if (yes != true) return;

    // 🔥 XÓA FIRESTORE
    final snaps = await FirebaseFirestore.instance
        .collection("qr_scans")
        .where("batch", isEqualTo: batch)
        .get();

    for (var d in snaps.docs) {
      await d.reference.delete();
    }

    // 🔥 XÓA TRONG DANH SÁCH BATCH
    batchList.remove(batch);
    safeSetState(() {});

    // ------------------------------------------
    // 🔥 XÓA LỊCH SỬ LOCAL CHO ĐỢT NÀY (QUAN TRỌNG)
    // ------------------------------------------
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("qr_history") ?? [];

    List<String> newList = [];

    for (String item in list) {
      final data = jsonDecode(item);

      // Giữ lại mục KHÔNG thuộc batch này
      if (data["batch"] != batch) {
        newList.add(item);
      }
    }

    await prefs.setStringList("qr_history", newList);

    // 🔥 XỬ LÝ current_batch
    int? current = prefs.getInt("current_batch");

    if (current == batch) {
      if (batchList.isNotEmpty) {
        await prefs.setInt("current_batch", batchList.last);
      } else {
        await prefs.remove("current_batch");
      }
    }
  }

  Future<void> createNewBatch() async {
    final prefs = await SharedPreferences.getInstance();
    final newBatch = (batchList.isEmpty ? 1 : batchList.last + 1);

    await prefs.setInt("current_batch", newBatch);

    await FirebaseFirestore.instance.collection("qr_scans").add({
      "batch": newBatch,
      "created_at": DateTime.now(),
    });

    batchList.add(newBatch);
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn đợt phát"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: createNewBatch),
        ],
      ),

      body: batchList.isEmpty
          ? const Center(
              child: Text(
                "Chưa có đợt phát nào.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: batchList.length,
              itemBuilder: (_, i) {
                final batch = batchList[i];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PhatPage(selectedBatch: batch),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                "Đợt $batch",
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteBatch(batch),
                        ),

                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhatPage(selectedBatch: batch),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
