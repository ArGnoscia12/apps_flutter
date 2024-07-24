<?php
header('Content-Type: application/json');

// Database connection
$host = 'localhost';
$db = 'tugas_akhir';
$user = 'root';
$pass = '';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get JSON input
$input = file_get_contents('php://input');
$data = json_decode($input, true);

$topic = $data['topic'];
$value = $data['value'];
$speed = isset($data['speed']) ? $data['speed'] : null;

if ($topic == 'sensor/waterflow1') {
    $stmt = $conn->prepare("INSERT INTO tb_waterflow1 (timestamp, waterflow1_value, waterflow1_speed) VALUES (NOW(), ?, ?)");
    $stmt->bind_param("dd", $value, $speed);
} else if ($topic == 'sensor/waterflow2') {
    $stmt = $conn->prepare("INSERT INTO tb_waterflow2 (timestamp, waterflow2_value, waterflow2_speed) VALUES (NOW(), ?, ?)");
    $stmt->bind_param("dd", $value, $speed);
} else if ($topic == 'sensor/tds') {
    $stmt = $conn->prepare("INSERT INTO tb_ppm (timestamp, ppm_value) VALUES (NOW(), ?)");
    $stmt->bind_param("d", $value);
} else if ($topic == 'sensor/ultrasonic') {
    $stmt = $conn->prepare("INSERT INTO tb_waterlevel (timestamp, ultrasonic_value) VALUES (NOW(), ?)");
    $stmt->bind_param("d", $value);
} else {
    echo json_encode(["status" => "error", "message" => "Unknown topic"]);
    exit;
}

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}

$stmt->close();
$conn->close();
