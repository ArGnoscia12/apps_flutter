<?php
// Koneksi ke database
$conn = mysqli_connect("localhost", "root", "", "tugas_akhir");

// Periksa koneksi
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Mendapatkan tanggal mulai dan akhir dari permintaan
$startDate = isset($_GET['start_date']) ? $_GET['start_date'] : null;
$endDate = isset($_GET['end_date']) ? $_GET['end_date'] : null;

// Menyiapkan klausa WHERE untuk filter tanggal
$whereClause = "";
if ($startDate && $endDate) {
    $whereClause = " WHERE timestamp BETWEEN '$startDate' AND '$endDate'";
}

$data = array();
$data1 = array();
$data2 = array();
$data3 = array();

// Mengambil data dari tabel tb_waterflow1 termasuk kolom timestamp dan id
$sql = "SELECT id_wf1 as x, timestamp, waterflow1_value as y1 FROM tb_waterflow1 $whereClause";
$result = $conn->query($sql);

if ($result) {
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }
} else {
    echo "Error: " . $conn->error;
}

// Mengambil data dari tabel tb_waterflow2 termasuk kolom timestamp dan id
$sql1 = "SELECT id_wf2 as x, timestamp, waterflow2_value as y2 FROM tb_waterflow2 $whereClause";
$result1 = $conn->query($sql1);

if ($result1) {
    if ($result1->num_rows > 0) {
        while ($row = $result1->fetch_assoc()) {
            $data1[] = $row;
        }
    }
} else {
    echo "Error: " . $conn->error;
}

// Mengambil data dari tabel tb_ppm termasuk kolom timestamp dan id
$sql2 = "SELECT id_ppm as x, timestamp, ppm_value as y3 FROM tb_ppm $whereClause";
$result2 = $conn->query($sql2);

if ($result2) {
    if ($result2->num_rows > 0) {
        while ($row = $result2->fetch_assoc()) {
            $data2[] = $row;
        }
    }
} else {
    echo "Error: " . $conn->error;
}

// Mengambil data dari tabel tb_waterlevel termasuk kolom timestamp dan id
$sql3 = "SELECT id_wl as x, timestamp, ultrasonic_value as y FROM tb_waterlevel $whereClause";
$result3 = $conn->query($sql3);

if ($result3) {
    if ($result3->num_rows > 0) {
        while ($row = $result3->fetch_assoc()) {
            $data3[] = $row;
        }
    }
} else {
    echo "Error: " . $conn->error;
}

// Tutup koneksi
$conn->close();

// Mengatur header untuk respon JSON
header('Content-Type: application/json');

// Mengirimkan data sebagai JSON
echo json_encode(array(
    'tb_waterflow1' => $data,
    'tb_waterflow2' => $data1,
    'tb_ppm' => $data2,
    'tb_waterlevel' => $data3
));
