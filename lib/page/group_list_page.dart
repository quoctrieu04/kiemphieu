import 'package:flutter/material.dart';

class GroupListPage extends StatelessWidget {
  final int numGroups;

  final List<Map<String, dynamic>> type1;
  final List<Map<String, dynamic>> type2;
  final List<Map<String, dynamic>> type3;
  final List<Map<String, dynamic>> type4;

  const GroupListPage({
    super.key,
    required this.numGroups,
    required this.type1,
    required this.type2,
    required this.type3,
    required this.type4,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách nhóm ($numGroups nhóm)"),
      ),
      body: ListView.builder(
        itemCount: numGroups,
        itemBuilder: (_, i) {
          String id1 = i < type1.length ? type1[i]["id"] : "❌ thiếu type 1";
          String id2 = i < type2.length ? type2[i]["id"] : "❌ thiếu type 2";
          String id3 = i < type3.length ? type3[i]["id"] : "❌ thiếu type 3";
          String id4 = i < type4.length ? type4[i]["id"] : "❌ thiếu type 4";

          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nhóm ${i + 1}",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Type 1: $id1"),
                  Text("Type 2: $id2"),
                  Text("Type 3: $id3"),
                  Text("Type 4: $id4"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
