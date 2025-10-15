#!/bin/bash

# Untuk direktori template dari produk, disesuaikan.
PPE_TEMPLATE_DIR="./ppe-templates" # Misal untuk direktorinya seluruh di dalam ppe-templates

# Check for nix-eval
if ! command -v nix &> /dev/null; then
    echo "Error: 'nix' command not found. Please install Nix to use this script. Haha ..."
    exit 1
fi

# Function to prompt for input
prompt_input() {
  local prompt_message="$1"
  local default_value="$2"
  read -rp "$prompt_message [$default_value]: " input
  echo "${input:-$default_value}"
}

# Untuk array, gunakan koma sebagai separasi.
prompt_array_input() {
  local prompt_message="$1"
  local default_value="$2"
  read -rp "$prompt_message (comma-separated) [$default_value]: " input
  local cleaned_input=""
  # If input is empty, use default value
  if [ -z "$input" ]; then
      cleaned_input=$(echo "$default_value" | sed 's/, */ /g')
  else
      cleaned_input=$(echo "$input" | sed 's/, */ /g')
  fi

  local array_elements=""
  for item in $cleaned_input; do
    # Ensure items that contain spaces are properly quoted if they weren't already
    if [[ "$item" == *" "* && "$item" != \"*\"* ]]; then
        array_elements+="\"$item\" "
    else
        array_elements+="\"$item\" " # Always quote for consistency in Nix lists
    fi
  done
  echo "${array_elements}"
}


echo "--- Generating New PPE Nix File ---"

# --- prompt untuk bagian INFORMASI ---
echo -e "\n--- Informasi Alat ---"
nomor_seri=$(prompt_input "Nomor Seri" "N/A")
nama_alat=$(prompt_input "Nama Alat (e.g., Carabiner OSLG PETZL GRAY <3 angka akhir>)" "N/A")
produsen=$(prompt_input "Produsen" "Petzl")
reference=$(prompt_input "Reference" "N/A")
nomor_batch=$(prompt_input "Nomor Batch" "N/A")
model=$(prompt_input "Model (nama produk dari PETZL)" "N/A")
tanggal_pembuatan=$(prompt_input "Tanggal Pembuatan (YYYY-MM-DD)" "$(date +%Y-%m-%d)")

# --- prompt untuk bagian MASA PAKAI ---
echo -e "\n--- Masa Pakai ---"
tanggal_pembelian=$(prompt_input "Tanggal Pembelian (YYYY-MM-DD)" "$(date +%Y-%m-%d)")
masa_berlaku_petzl=$(prompt_input "Masa Berlaku Petzl" "tak hingga")
tanggal_kadaluarsa_rekomendasi=$(prompt_input "Tanggal Kadaluarsa Rekomendasi (YYYY-MM-DD)" "2034-05-15")
status_inspeksi=$(prompt_input "Status Inspeksi" "Lolos")
tanggal_inspeksi_terakhir=$(prompt_input "Tanggal Inspeksi Terakhir (YYYY-MM-DD)" "N/A")
tanggal_inspeksi_berikutnya=$(prompt_input "Tanggal Inspeksi Berikutnya (YYYY-MM-DD)" "N/A")

# --- PROMPT FOR RIWAYAT ---
echo -e "\n--- Riwayat Penggunaan ---"
kondisi_alat=$(prompt_input "Kondisi Alat" "Baik (Sedikit goresan pada frame)")
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

sering_digunakan_untuk=$(prompt_array_input "Sering Digunakan Untuk (comma-separated, e.g., Anchor,Ascent)" "")


# --- prompt untuk spesifikasi teknis (menggunakan templates) ---
echo -e "\n--- Spesifikasi Teknis ---"

# Check if the template directory exists
if [ ! -d "$PPE_TEMPLATE_DIR" ]; then
  echo "Error: PPE template directory '$PPE_TEMPLATE_DIR' not found."
  echo "Please create it and add your .nix specification files there."
  exit 1
fi

# List available templates
echo "Available templates in '$PPE_TEMPLATE_DIR':"
select_options=()
while IFS= read -r -d $'\0' file; do
    select_options+=("$(basename "$file")")
done < <(find "$PPE_TEMPLATE_DIR" -maxdepth 1 -name "*.nix" -print0)

# Initialize specification variables with empty strings
declare -A spec_values
spec_attrs=(
  "kategori_peralatan" "deskripsi" "web" "warna" "berat" "max_lifespan_f_dom"
  "tipe_gate" "gate_actions" "material" "mbs_major_axis" "mbs_minor_axis"
  "mbs_gate_open" "gate_opening" "guarantee" "jenis_kunci" "major_axis_length"
  "standar_sertifikasi"
)

# Initialize all spec_values to empty
for attr in "${spec_attrs[@]}"; do
    spec_values["$attr"]=""
done

selected_template_file=""
if [ ${#select_options[@]} -eq 0 ]; then
  echo "No .nix templates found in '$PPE_TEMPLATE_DIR'."
  echo "Proceeding with manual specification input."
else
  PS3="Select a template (or type 'manual' for no template): "
  select selected_template_name in "${select_options[@]}" "manual"; do
    if [ "$selected_template_name" == "manual" ]; then
      echo "Proceeding with manual specification input."
      break
    elif [ -n "$selected_template_name" ]; then
      selected_template_file="$PPE_TEMPLATE_DIR/$selected_template_name"
      echo "Using template: $selected_template_name"

      # Load values from template using nix eval
      echo "Loading defaults from template '$selected_template_name' using nix eval..."
      for attr in "${spec_attrs[@]}"; do
          # Special handling for array attributes - we want a comma-separated string for prompt_array_input
          if [ "$attr" == "standar_sertifikasi" ]; then
              # Evaluate array to a space-separated list of raw strings
              # Then convert to comma-separated for prompt_array_input's default handling
              ARRAY_RAW=$(nix eval --raw --file "$selected_template_file" "$attr" 2>/dev/null | tr ' ' ',' | sed 's/,\"//g' | sed 's/\,\"//g' | sed 's/,$//')
              spec_values["$attr"]=$(echo "$ARRAY_RAW" | sed 's/"//g') # Remove quotes for display
          else
              spec_values["$attr"]=$(nix eval --raw --file "$selected_template_file" "$attr" 2>/dev/null)
          fi
          # Handle potential 'null' or empty strings if attribute is not found
          if [ "${spec_values[$attr]}" == "null" ]; then
              spec_values["$attr"]=""
          fi
      done
      break # Exit select loop after template is chosen and loaded
    else
      echo "Invalid selection. Please try again."
    fi
  done
fi

# Bagian ini, menentukan apakah untuk menggunakan template utuh atau menggantinya.
if [ -n "$selected_template_file" ]; then
  read -rp "Template '$selected_template_name' loaded. Do you want to override any technical specifications? (y/n) [n]: " override_choice
  if [[ "$override_choice" =~ ^[Yy]$ ]]; then
    echo "Prompting to override values from template:"
    for attr in "${spec_attrs[@]}"; do
        current_default="${spec_values[$attr]}"
        if [ "$attr" == "gate_actions" ]; then # Integers
            spec_values["$attr"]=$(prompt_input "${attr//_// } (integer)" "$current_default")
        elif [ "$attr" == "standar_sertifikasi" ]; then # Arrays
            spec_values["$attr"]=$(prompt_array_input "${attr//_// } (comma-separated)" "$current_default")
        else # Regular strings
            spec_values["$attr"]=$(prompt_input "${attr//_// }" "$current_default")
        fi
    done
  else
    echo "Using technical specifications from template without changes."
  fi
else # No template was selected, so proceed with full manual input
  echo "Proceeding with manual entry for all technical specifications."
  for attr in "${spec_attrs[@]}"; do
      current_default="${spec_values[$attr]}" # This will be empty
      if [ "$attr" == "gate_actions" ]; then # Integers
          spec_values["$attr"]=$(prompt_input "${attr//_// } (integer)" "$current_default")
      elif [ "$attr" == "standar_sertifikasi" ]; then # Arrays
          spec_values["$attr"]=$(prompt_array_input "${attr//_// } (comma-separated)" "$current_default")
      else # Regular strings
          spec_values["$attr"]=$(prompt_input "${attr//_// }" "$current_default")
      fi
  done
fi


# --- Membuat nama file---
echo -e "\n--- File Output ---"
default_filename=$(echo "$nama_alat" | tr '[:upper:] ' '[:lower:]-' | sed 's/[^a-z0-9-]//g' | cut -c 1-20)-$(echo "$nomor_seri" | tail -c 4).nix
read -rp "Enter desired filename (e.g., carabiner-oslg-petzl-gray-<3angka>.nix) [$default_filename]: " filename
filename="${filename:-$default_filename}"

# --- Ini membuat (write) pada filename yang telah dibuat ---
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
    kategori_peralatan = "${spec_values["kategori_peralatan"]}";
    deskripsi = "${spec_values["deskripsi"]}";
    web = "${spec_values["web"]}";
    warna = "${spec_values["warna"]}";
    berat = "${spec_values["berat"]}";
    max_lifespan_f_dom = "${spec_values["max_lifespan_f_dom"]}";
    tipe_gate = "${spec_values["tipe_gate"]}";
    gate_actions = ${spec_values["gate_actions"]};
    material = "${spec_values["material"]}"; # Bagian ini terletak pada reference dari produk PETZL.
    mbs_major_axis = "${spec_values["mbs_major_axis"]}";
    mbs_minor_axis = "${spec_values["mbs_minor_axis"]}";
    mbs_gate_open = "${spec_values["mbs_gate_open"]}";
    gate_opening = "${spec_values["gate_opening"]}";
    guarantee = "${spec_values["guarantee"]}";
    jenis_kunci = "${spec_values["jenis_kunci"]}";
    major_axis_length = "${spec_values["major_axis_length"]}";
    # List (Array) String standar sertifikasi mengacu pada EU declaration of conformity.
    standar_sertifikasi = [ ${spec_values["standar_sertifikasi"]} ];
  };
}
EOF

echo -e "\nSuccessfully created '$filename'!"
echo "You can now add it to your Git repository: git add $filename && git commit -m \"Add new PPE: $nama_alat\""
