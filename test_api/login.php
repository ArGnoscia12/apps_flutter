<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "tugas_akhir");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$username = $_POST['username'];
$password = $_POST['password'];

// Query untuk mengambil hash password berdasarkan username
$query = $conn->prepare("SELECT * FROM tb_login WHERE username=?");
$query->bind_param("s", $username);
$query->execute();
$result = $query->get_result();

if ($result->num_rows == 1) {
    $data = $result->fetch_assoc();
    $hashedPassword = $data['password'];

    // Verifikasi password
    if (password_verify($password, $hashedPassword)) {
        $token = bin2hex(random_bytes(10)); // Generate a random token with 10 bytes

        // Simpan token ke database
        $updateQuery = $conn->prepare("UPDATE tb_login SET token=? WHERE username=?");
        $updateQuery->bind_param("ss", $token, $username);
        if ($updateQuery->execute()) {
            $data['token'] = $token;
            echo json_encode(array("success" => true, "data" => $data));
        } else {
            echo json_encode(array("success" => false, "message" => "Failed to update token"));
        }
    } else {
        echo json_encode(array("success" => false, "message" => "Invalid username or password."));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Invalid username or password."));
}

$conn->close();
