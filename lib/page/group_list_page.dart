import 'package:flutter/material.dart';

class GroupListPage extends StatelessWidget {
  final int numGroups;

  final List<Map<String, dynamic>> type1;
  final List<Map<String, dynamic>> type2;
  final List<Map<String, dynamic>> type3;
  final List<Map<String, dynamic>> type4;

  final int slot1;
  final int slot2;
  final int slot3;
  final int slot4;

  const GroupListPage({
    super.key,
    required this.numGroups,
    required this.type1,
    required this.type2,
    required this.type3,
    required this.type4,
    required this.slot1,
    required this.slot2,
    required this.slot3,
    required this.slot4,
  });

  // Helper
  List<String> extractIDs(List<Map<String, dynamic>> list, int start, int count) {
    List<String> result = [];
    for (int i = start; i < start + count; i++) {
      if (i < list.length) {
        result.add(list[i]["id"].toString());
      } else {
        result.add("❌ thiếu");
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách nhóm ($numGroups nhóm)")),

      body: ListView.builder(
        itemCount: numGroups,
        itemBuilder: (_, i) {
          int base1 = i * slot1;
          int base2 = i * slot2;
          int base3 = i * slot3;
          int base4 = i * slot4;

          List<String> g1 = extractIDs(type1, base1, slot1);
          List<String> g2 = extractIDs(type2, base2, slot2);
          List<String> g3 = extractIDs(type3, base3, slot3);
          List<String> g4 = extractIDs(type4, base4, slot4);

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nhóm ${i + 1}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Text("Type 1 (${slot1} người): ${g1.join(", ")}"),
                  Text("Type 2 (${slot2} người): ${g2.join(", ")}"),
                  Text("Type 3 (${slot3} người): ${g3.join(", ")}"),
                  Text("Type 4 (${slot4} người): ${g4.join(", ")}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
