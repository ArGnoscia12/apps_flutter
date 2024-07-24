<!-- <?php
        function dbconnection()
        {
            $con = mysqli_connect("localhost", "root", "", "tugas_akhir");
            return $con;
        }
        ?> -->


<!-- <?php
        $servername = "localhost";
        $username = "root";
        $password = "";
        $dbname = "tugas_akhir";

        // Create connection
        try {
            $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            echo "Connection failed: " . $e->getMessage();
        }
        ?> -->

<?php
$con = mysqli_connect('localhost', 'root', '', 'tugas_akhir') or die('tidak terkoneksi');
?>