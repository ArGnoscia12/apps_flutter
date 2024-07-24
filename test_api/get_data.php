<?php
// Koneksi ke database MySQL
$conn = mysqli_connect("localhost", "root", "", "tugas_akhir");

// Periksa koneksi
if (!$conn) {
    die("Koneksi ke database gagal: " . mysqli_connect_error());
}

// Periksa apakah parameter username diberikan
if (isset($_GET['username'])) {
    $username = $_GET['username'];
    $sql = "SELECT username, fullname FROM tb_login WHERE username = '$username'";
} else {
    // Tidak ada username, kembalikan semua data pengguna
    $sql = "SELECT username, fullname FROM tb_login";
}

// Jalankan kueri SQL
$result = mysqli_query($conn, $sql);

// Inisialisasi array untuk menyimpan data pengguna
$users = array();

// Periksa apakah kueri berhasil dijalankan
if (mysqli_num_rows($result) > 0) {
    // Ambil setiap baris data pengguna dan tambahkan ke array
    while ($row = mysqli_fetch_assoc($result)) {
        $users[] = $row;
    }
}

// Konversi array ke format JSON
$json_response = json_encode($users);

// Set header untuk respon JSON
header('Content-Type: application/json');

// Tampilkan respon JSON
echo $json_response;

// Tutup koneksi database
mysqli_close($conn);
