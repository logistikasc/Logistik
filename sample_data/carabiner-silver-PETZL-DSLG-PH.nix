# File: carabiner-metadata.nix

{
  # Atribut Dasar
  nama_alat = "Carabiner D-Shape Screw-Lock";
  tipe_peralatan = "PPE - Konektor";
  produsen = "Petzl";
  model = "OK Screw-Lock M33 SL";
  
  # Set Atribut: Identifikasi
  identifikasi = {
    kode_aset = "CRBN-PZ-0042A";
    nomor_seri = "18260AB0042";
    tahun_pembuatan = 2024;
  };
  
  # Set Atribut: Masa Pakai
  masa_pakai = {
    tanggal_pembelian = "2024-05-15";
    masa_berlaku_petzl = "10 Tahun"; 
    tanggal_kadaluarsa_rekomendasi = "2034-05-15";
    status_inspeksi = "Lolos";
    tanggal_inspeksi_terakhir = "2025-01-01";
    tanggal_inspeksi_berikutnya = "2025-07-01";
  };
  
  # Set Atribut: Riwayat Penggunaan
  riwayat_penggunaan = {
    kondisi_alat = "Baik (Minor Scratches)"; 
    total_penggunaan_tercatat = 45; # Nilai integer
    terakhir_digunakan = [
      # Penggunaan 1: Paling Terbaru
      {
        tanggal = "2025-03-25";
        aktivitas = "Climbing Lead (Racking on Harness)";
        lokasi = "Tebing Parang";
      }
      # Penggunaan 2
      {
        tanggal = "2025-03-22";
        aktivitas = "Rescue Training (Haul System)";
        lokasi = "Area Simulasi SAR";
      }
      # Penggunaan 3
      {
        tanggal = "2025-03-20";
        aktivitas = "Pemasangan Top-Rope Anchor";
        lokasi = "Tebing Batu Gajah";
      }
      # ... dan seterusnya
    ];

    # List (Array) String
    sering_digunakan_untuk = [
      "Climbing (Belay Station)"
      "Rope Access (Lanyard Attachment)"
      "Rescue (System Building)"
    ];
  };
  
  # Set Atribut: Spesifikasi Teknis
  spesifikasi_teknis = {
    bahan = "Aluminium";
    kekuatan_major_axis = "25 kN";
    kekuatan_minor_axis = "8 kN";
    jenis_kunci = "Screw-Lock";
    
    # List (Array) String
    standar_sertifikasi = [
      "CE EN 362" 
      "CE EN 12275"
    ]; 
  };
}
