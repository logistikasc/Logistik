# File: carabiner-metadata.nix
# Berikut merupakan metadata alat dengan beberapa parameter yang mereferensi pada PETZL.
# Variabel di bawah berikut direferensikan secara berturut-turut.
{
  # Set Atribut: Identifikasi bagian Serial number, Part number, Batch number, Date of Manufacture (DOM), Owned by.
  informasi = {
    nomor_seri = "18D0133481863";
    nama_alat = "Carabiner OSLG PETZL GRAY 863";
    produsen = "Petzl"; # Manufacturer
    reference = "M33A SL"; # Reference
    nomor_batch = "0133481";
    model = "OK SCREW LOCK"; # nama produk dari PETZL
    tanggal_pembuatan = "2018-04-01";
  };
  
  # Set Atribut: Masa Pakai
  masa_pakai = {
    tanggal_pembelian = "2024-05-15";
    masa_berlaku_petzl = "tak hingga"; 
    tanggal_kadaluarsa_rekomendasi = "2034-05-15";
    status_inspeksi = "Lolos";
    tanggal_inspeksi_terakhir = "2025-10-13";
    tanggal_inspeksi_berikutnya = "2026-9-13";
  };
  
  # Set Atribut: Riwayat Penggunaan
  riwayat = {
    kondisi_alat = "Baik (Minor Scratches), goresan terletak bagian frame (major axis) dan di atas keylock terdapat tok asc"; 
    total_penggunaan_tercatat = 40; # Nilai integer
    terakhir_digunakan = [
      # Penggunaan 1: Paling Terbaru
      {
        tanggal = "2025-09-21";
        aktivitas = "Eksplorasi Gua Vertikal Sindon";
        lokasi = "Dekat Gua Bribin";
      }
      # Penggunaan 2
      # Penggunaan 3
      # ... dan seterusnya
    ];

    # List (Array) String
    sering_digunakan_untuk = [
      "Anchor (Penelusuran gua vertikal)"
    ];
  };
  
  # Set Atribut: Spesifikasi Teknis
  spesifikasi_teknis = {
    kategori_peralatan = "PPE - Carabiners / Connectors";
    deskripsi = "Lightweight oval carabiner";
    web = "https://www.petzl.com/INT/en/Sport/Carabiners-And-Quickdraws/OK";
    warna = "Gray";
    berat = "70 gram";
    max_lifespan_f_dom = "Unlimited years";
    tipe_gate = "SCREW-LOCK";
    gate_actions = 1;
    material = "Aluminium"; # Bagian ini terletak pada reference dari produk PETZL.
    mbs_major_axis = "25 kN";
    mbs_minor_axis = "8 kN";
    mbs_gate_open = "7 kN";
    gate_opening = "22 mm";
    guarantee = "3 years";
    jenis_kunci = "Screw-Lock";
    major_axis_length = "88 mm";
    # List (Array) String standar sertifikasi mengacu pada EU declaration of conformity.
    standar_sertifikasi = [ # Mengacu pada regulasi (EU) 2016/425 on personal protective equipment
      "CE EN 362 : 2004" 
      "CE EN 12275 : 2013"
      "UIAA  121 : 2018"
    ]; 
  };
}
