<?php
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tugas_akhir";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(array("status" => "error", "message" => "Connection failed: " . $conn->connect_error));
    exit();
}

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);
$username = $data['username'];
$password = $data['password'];
$fullname = $data['fullname'];

// Validate input data
if (empty($username) || empty($password) || empty($fullname)) {
    echo json_encode(array("status" => "error", "message" => "All fields are required."));
    exit();
}

// Check if username already exists
$sql = "SELECT * FROM tb_login WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();
if ($result->num_rows > 0) {
    echo json_encode(array("status" => "error", "message" => "Username already exists."));
    exit();
}

// Hash the password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$sql = "INSERT INTO tb_login (username, password, fullname) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $username, $hashed_password, $fullname);

if ($stmt->execute()) {
    echo json_encode(array("status" => "success", "message" => "Registration successful."));
} else {
    echo json_encode(array("status" => "error", "message" => "Registration failed."));
}

// Close connections
$stmt->close();
$conn->close();
