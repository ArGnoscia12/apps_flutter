<?php
// Koneksi ke database MySQL
$conn = mysqli_connect("localhost", "root", "", "tugas_akhir");

// Periksa koneksi
if (!$conn) {
    die("Koneksi ke database gagal: " . mysqli_connect_error());
}

// Kueri untuk mengambil data tanaman
$sql = "SELECT id_plant, title, desk, kategori, img, date FROM tb_plant";

// Jalankan kueri SQL
$result = mysqli_query($conn, $sql);

// Inisialisasi array untuk menyimpan data tanaman
$plants = array();

// Base URL untuk gambar (sesuaikan dengan alamat server Anda)
$base_url = 'http://' . $_SERVER['SERVER_ADDR'] . '/Upload/uploads/';

// Periksa apakah kueri berhasil dijalankan
if (mysqli_num_rows($result) > 0) {
    // Ambil setiap baris data tanaman dan tambahkan ke array
    while ($row = mysqli_fetch_assoc($result)) {
        // Tambahkan URL penuh untuk gambar
        $row['img'] = $base_url . $row['img'];
        $plants[] = $row;
    }
}

// Konversi array ke format JSON
$json_response = json_encode($plants);

// Set header untuk respon JSON
header('Content-Type: application/json');

// Tampilkan respon JSON
echo $json_response;

// Tutup koneksi database
mysqli_close($conn);
