class BatchBarang {
  final int id;
  final int barangId;
  final String namaBarang;
  final int stok;
  final String satuan;
  final String tanggalKadaluarsa;
  final int hariMenujuKadaluarsa;

  BatchBarang({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.stok,
    required this.satuan,
    required this.tanggalKadaluarsa,
    required this.hariMenujuKadaluarsa,
  });

  factory BatchBarang.fromJson(Map<String, dynamic> json) {
    return BatchBarang(
      id: int.tryParse(json['id'].toString()) ?? 0,
      barangId: int.tryParse(json['barang_id'].toString()) ?? 0,
      namaBarang: json['nama_barang'].toString(),
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      satuan: json['satuan'].toString(),
      tanggalKadaluarsa: json['tanggal_kadaluarsa'].toString(),
      hariMenujuKadaluarsa: int.tryParse(json['hari_menuju_kadaluarsa'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barang_id': barangId,
      'stok': stok,
      'tanggal_kadaluarsa': tanggalKadaluarsa,
    };
  }

  BatchBarang copyWith({
    int? stok,
    String? tanggalKadaluarsa,
  }) {
    return BatchBarang(
      id: id,
      barangId: barangId,
      namaBarang: namaBarang,
      stok: stok ?? this.stok,
      satuan: satuan,
      tanggalKadaluarsa: tanggalKadaluarsa ?? this.tanggalKadaluarsa,
      hariMenujuKadaluarsa: hariMenujuKadaluarsa,
    );
  }
}