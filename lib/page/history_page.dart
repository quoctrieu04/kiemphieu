import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final qrStream = FirebaseFirestore.instance
        .collection("qr_scans")
        .orderBy("timestamp", descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử quét theo đợt"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final approve = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Xoá toàn bộ?"),
                  content: const Text("Bạn có chắc xoá tất cả dữ liệu?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Hủy")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Xóa")),
                  ],
                ),
              );

              if (approve == true) {
                final docs = await FirebaseFirestore.instance
                    .collection("qr_scans")
                    .get();
                for (var d in docs.docs) {
                  d.reference.delete();
                }
              }
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: qrStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text("Lỗi Firestore: ${snap.error}"),
            );
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.docs;

          if (data.isEmpty) {
            return const Center(
              child: Text("Chưa có dữ liệu!", style: TextStyle(fontSize: 20)),
            );
          }

          /// 🔥 GOM NHÓM THEO BATCH
          final Map<int, List<QueryDocumentSnapshot>> batchMap = {};

          for (var doc in data) {
            final map = doc.data() as Map<String, dynamic>;

            int batch = map["batch"] ?? 0;  // 🔥 FIX: nếu không có batch thì gán 0

            batchMap[batch] = batchMap[batch] ?? [];
            batchMap[batch]!.add(doc);
          }

          final batches = batchMap.keys.toList()..sort();

          return ListView.builder(
            itemCount: batches.length,
            itemBuilder: (_, i) {
              final batch = batches[i];
              final list = batchMap[batch]!;

              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔥 TIÊU ĐỀ ĐỢT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          batch == 0 ? "Đợt (Cũ - không batch)" : "Đợt $batch",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            for (var doc in list) {
                              doc.reference.delete();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// 🔥 DS PHIẾU TRONG ĐỢT
                    ...list.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.qr_code),
                          title: Text("Type: ${d["type"]}"),
                          subtitle: Text("ID: ${d["id"]}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => doc.reference.delete(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
