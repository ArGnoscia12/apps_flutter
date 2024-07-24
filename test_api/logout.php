<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "tugas_akhir");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$token = $_POST['token'];

$query = "UPDATE tb_login SET token='' WHERE token='$token'";

if (mysqli_query($conn, $query)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["error" => "Failed to update token."]);
}

$conn->close();
