import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("qr_history");

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
          ? const Center(
              child: Text(
                "Chưa có dữ liệu!",
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final item = history[i];
                return ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text("Type: ${item['type']}"),
                  subtitle: Text("ID: ${item['id']}"),
                );
              },
            ),
    );
  }
}
