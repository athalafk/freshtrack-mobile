class Barang {
  final int id;
  final String namaBarang;
  final String satuan;
  final int totalStok;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.satuan,
    required this.totalStok,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: int.tryParse(json['id'].toString()) ?? 0,
      namaBarang: json['nama_barang'].toString(),
      satuan: json['satuan'].toString(),
      totalStok: int.tryParse(json['total_stok'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'satuan': satuan,
    };
  }

  Barang copyWith({
    String? namaBarang,
    String? satuan,
  }) {
    return Barang(
      id: id,
      namaBarang: namaBarang ?? this.namaBarang,
      satuan: satuan ?? this.satuan,
      totalStok: totalStok,
    );
  }
}