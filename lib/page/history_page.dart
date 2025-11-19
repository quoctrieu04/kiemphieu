import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList("qr_history");

    if (saved != null) {
      setState(() {
        history = saved
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  /// XÓA 1 ITEM (LOCAL + FIREBASE)
  Future<void> deleteSingleItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final item = history[index];

    // Xoá Firebase nếu có docId
    if (item["docId"] != null) {
      await FirebaseFirestore.instance
          .collection("qr_scans")
          .doc(item["docId"])
          .delete();
    }

    history.removeAt(index);

    // Ghi lại local
    final List<String> newList =
        history.map((e) => jsonEncode(e)).toList();

    await prefs.setStringList("qr_history", newList);

    setState(() {});
  }

  /// XOÁ TẤT CẢ FIREBASE
  Future<void> clearFirebase() async {
    final snapshots =
        await FirebaseFirestore.instance.collection("qr_scans").get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  /// XOÁ TẤT CẢ (LOCAL + FIREBASE)
  Future<void> clearHistory() async {
    bool yes = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa toàn bộ lịch sử?"),
        content: const Text("Bao gồm dữ liệu trên thiết bị và Firebase."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (yes != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("qr_history");

    await clearFirebase();

    setState(() => history.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử quét"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearHistory,
          )
        ],
      ),

      body: history.isEmpty
          ? const Center(child: Text("Chưa có dữ liệu!", style: TextStyle(fontSize: 20)))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final item = history[i];
                return ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text("Type: ${item['type']}"),
                  subtitle: Text("ID: ${item['id']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteSingleItem(i),
                  ),
                );
              },
            ),
    );
  }
}
