#!/bin/bash

# Function to prompt for input
prompt_input() {
  local prompt_message="$1"
  local default_value="$2"
  read -rp "$prompt_message [$default_value]: " input
  echo "${input:-$default_value}"
}

# Function to prompt for array input (comma-separated)
prompt_array_input() {
  local prompt_message="$1"
  local default_value="$2"
  read -rp "$prompt_message (comma-separated) [$default_value]: " input
  local cleaned_input=$(echo "$input" | sed 's/, */ /g') # Replace commas with spaces
  local array_elements=""
  for item in $cleaned_input; do
    array_elements+="\"$item\" "
  done
  echo "${array_elements:-$(echo "$default_value" | sed 's/, */ /g' | sed 's/\(.*\)/"\1"/')}"
}

echo "--- Generating New PPE Nix File ---"

# --- PROMPT FOR INFORMASI ---
echo -e "\n--- Informasi Alat ---"
nomor_seri=$(prompt_input "Nomor Seri" "N/A")
nama_alat=$(prompt_input "Nama Alat (e.g., Carabiner OSLG PETZL SILVER 863)" "N/A")
produsen=$(prompt_input "Produsen" "Petzl")
reference=$(prompt_input "Reference" "N/A")
nomor_batch=$(prompt_input "Nomor Batch" "N/A")
model=$(prompt_input "Model (nama produk dari PETZL)" "N/A")
tanggal_pembuatan=$(prompt_input "Tanggal Pembuatan (YYYY-MM-DD)" "$(date +%Y-%m-%d)")

# --- PROMPT FOR MASA PAKAI ---
echo -e "\n--- Masa Pakai ---"
tanggal_pembelian=$(prompt_input "Tanggal Pembelian (YYYY-MM-DD)" "$(date +%Y-%m-%d)")
masa_berlaku_petzl=$(prompt_input "Masa Berlaku Petzl" "tak hingga")
tanggal_kadaluarsa_rekomendasi=$(prompt_input "Tanggal Kadaluarsa Rekomendasi (YYYY-MM-DD)" "2034-05-15")
status_inspeksi=$(prompt_input "Status Inspeksi" "Lolos")
tanggal_inspeksi_terakhir=$(prompt_input "Tanggal Inspeksi Terakhir (YYYY-MM-DD)" "N/A")
tanggal_inspeksi_berikutnya=$(prompt_input "Tanggal Inspeksi Berikutnya (YYYY-MM-DD)" "N/A")

# --- PROMPT FOR RIWAYAT ---
echo -e "\n--- Riwayat Penggunaan ---"
kondisi_alat=$(prompt_input "Kondisi Alat" "Baik (Minor Scratches)")
total_penggunaan_tercatat=$(prompt_input "Total Penggunaan Tercatat (integer)" "0")

read -rp "Do you want to add usage history? (y/n) [n]: " add_history_choice
terakhir_digunakan_entries=""
if [[ "$add_history_choice" =~ ^[Yy]$ ]]; then
  history_count=1
  while true; do
    echo -e "\n  -- Riwayat Penggunaan $history_count --"
    read -rp "  Tanggal (YYYY-MM-DD) [skip to finish]: " h_date
    if [ -z "$h_date" ]; then
      break
    fi
    h_aktivitas=$(prompt_input "  Aktivitas" "N/A")
    h_lokasi=$(prompt_input "  Lokasi" "N/A")

    terakhir_digunakan_entries+="
      {
        tanggal = \"$h_date\";
        aktivitas = \"$h_aktivitas\";
        lokasi = \"$h_lokasi\";
      }"
    history_count=$((history_count + 1))
  done
fi

sering_digunakan_untuk=$(prompt_array_input "Sering Digunakan Untuk (comma-separated, e.g., Anchor,Ascent)" "N/A")


# --- PROMPT FOR SPESIFIKASI TEKNIS ---
echo -e "\n--- Spesifikasi Teknis ---"
kategori_peralatan=$(prompt_input "Kategori Peralatan" "PPE - Carabiners / Connectors")
deskripsi=$(prompt_input "Deskripsi" "Lightweight oval carabiner")
web=$(prompt_input "URL Produk" "https://www.petzl.com")
warna=$(prompt_input "Warna" "Gray")
berat=$(prompt_input "Berat" "70 gram")
max_lifespan_f_dom=$(prompt_input "Max Lifespan From DOM" "Unlimited years")
tipe_gate=$(prompt_input "Tipe Gate" "SCREW-LOCK")
gate_actions=$(prompt_input "Gate Actions (integer)" "1")
material=$(prompt_input "Material" "Aluminium")
mbs_major_axis=$(prompt_input "MBS Major Axis" "25 kN")
mbs_minor_axis=$(prompt_input "MBS Minor Axis" "8 kN")
mbs_gate_open=$(prompt_input "MBS Gate Open" "7 kN")
gate_opening=$(prompt_input "Gate Opening" "22 mm")
guarantee=$(prompt_input "Guarantee" "3 years")
jenis_kunci=$(prompt_input "Jenis Kunci" "Screw-Lock")
major_axis_length=$(prompt_input "Major Axis Length" "88 mm")
standar_sertifikasi=$(prompt_array_input "Standar Sertifikasi (comma-separated, e.g., CE EN 362:2004,UIAA 121:2018)" "CE EN 362 : 2004,CE EN 12275 : 2013,UIAA  121 : 2018")

# --- GENERATE FILE NAME ---
echo -e "\n--- File Output ---"
default_filename=$(echo "$nama_alat" | tr '[:upper:] ' '[:lower:]-' | sed 's/-//g' | cut -c 1-20)-$(echo "$nomor_seri" | tail -c 4).nix
read -rp "Enter desired filename (e.g., Carabiner-OSLG-PETZL-GRAY-863.nix) [$default_filename]: " filename
filename="${filename:-$default_filename}"

# --- WRITE TO FILE ---
cat << EOF > "$filename"
{
  # Set Atribut: Identifikasi bagian Serial number, Part number, Batch number, Date of Manufacture (DOM), Owned by.
  informasi = {
    nomor_seri = "$nomor_seri";
    nama_alat = "$nama_alat";
    produsen = "$produsen"; # Manufacturer
    reference = "$reference"; # Reference
    nomor_batch = "$nomor_batch";
    model = "$model"; # nama produk dari PETZL
    tanggal_pembuatan = "$tanggal_pembuatan";
  };

  # Set Atribut: Masa Pakai
  masa_pakai = {
    tanggal_pembelian = "$tanggal_pembelian";
    masa_berlaku_petzl = "$masa_berlaku_petzl";
    tanggal_kadaluarsa_rekomendasi = "$tanggal_kadaluarsa_rekomendasi";
    status_inspeksi = "$status_inspeksi";
    tanggal_inspeksi_terakhir = "$tanggal_inspeksi_terakhir";
    tanggal_inspeksi_berikutnya = "$tanggal_inspeksi_berikutnya";
  };

  # Set Atribut: Riwayat Penggunaan
  riwayat = {
    kondisi_alat = "$kondisi_alat";
    total_penggunaan_tercatat = $total_penggunaan_tercatat; # Nilai integer
    terakhir_digunakan = [$terakhir_digunakan_entries
    ];

    # List (Array) String
    sering_digunakan_untuk = [ ${sering_digunakan_untuk} ];
  };

  # Set Atribut: Spesifikasi Teknis
  spesifikasi_teknis = {
    kategori_peralatan = "$kategori_peralatan";
    deskripsi = "$deskripsi";
    web = "$web";
    warna = "$warna";
    berat = "$berat";
    max_lifespan_f_dom = "$max_lifespan_f_dom";
    tipe_gate = "$tipe_gate";
    gate_actions = $gate_actions;
    material = "$material"; # Bagian ini terletak pada reference dari produk PETZL.
    mbs_major_axis = "$mbs_major_axis";
    mbs_minor_axis = "$mbs_minor_axis";
    mbs_gate_open = "$mbs_gate_open";
    gate_opening = "$gate_opening";
    guarantee = "$guarantee";
    jenis_kunci = "$jenis_kunci";
    major_axis_length = "$major_axis_length";
    # List (Array) String standar sertifikasi mengacu pada EU declaration of conformity.
    standar_sertifikasi = [ ${standar_sertifikasi} ];
  };
}
EOF

echo -e "\nSuccessfully created '$filename'!"
echo "You can now add it to your Git repository: git add $filename && git commit -m \"Add new PPE: $nama_alat\""
