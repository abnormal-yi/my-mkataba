import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  const DataTableWidget({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
        columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)))).toList(),
        rows: rows.map((r) => DataRow(cells: r.map<DataCell>((c) => DataCell(c is Widget ? c : Text('$c', style: const TextStyle(fontSize: 13)))).toList())).toList(),
      ),
    );
  }
}
