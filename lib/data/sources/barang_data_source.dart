import 'package:flutter/material.dart';
import '../models/barang.dart';

class BarangDataSource extends DataTableSource {
  final List<Barang> data;
  final void Function(Barang) onEdit;
  final void Function(Barang) onDelete;

  BarangDataSource({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final item = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.namaBarang)),
        DataCell(Text(item.totalStok.toString())),
        DataCell(Text(item.satuan)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => onEdit(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => onDelete(item),
            ),
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}