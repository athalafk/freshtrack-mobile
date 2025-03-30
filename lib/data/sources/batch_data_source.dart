import 'package:flutter/material.dart';
import '../models/batch_barang.dart';
import 'package:intl/intl.dart';

class BatchBarangDataSource extends DataTableSource {
  final List<BatchBarang> data;

  BatchBarangDataSource({required this.data});

  @override
  DataRow getRow(int index) {
    final item = data[index];
    final days = item.hariMenujuKadaluarsa;
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.namaBarang)),
        DataCell(Text(item.stok.toString())),
        DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(item.tanggalKadaluarsa)))),
        DataCell(Text(days > 0 ? '$days hari' : 'Expired')),
        DataCell(
          days > 14
              ? const Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.warning, color: days > 0 ? Colors.orange : Colors.red),
        ),
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