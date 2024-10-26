<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "babysitting_app";

// 创建数据库连接
$conn = new mysqli($servername, $username, $password, $dbname);

// 检查连接
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// 获取POST请求中的字段
$name = $_POST['name'];
$phone = $_POST['phone'];
$gender = $_POST['gender'];
$email = $_POST['email'];
$address = $_POST['address'];
$password = $_POST['password'];
$nanniesCertificate = $_POST['nannies_certificate'];

// 检查是否上传了证书图片
$certificate_image_url = '';
if (isset($_FILES['certificate_image_url'])) {
    $file_tmp = $_FILES['certificate_image_url']['tmp_name'];
    $file_name = basename($_FILES['certificate_image_url']['name']);
    $upload_dir = 'uploads/';
    $file_path = $upload_dir . $file_name;

    if (move_uploaded_file($file_tmp, $file_path)) {
        $certificate_image_url = $file_path;
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload certificate']);
        exit();
    }
}

// 插入数据到数据库
$sql = "INSERT INTO nannies (name, phone, gender, email, address, password, nannies_certificate, certificate_image_url) 
        VALUES ('$name', '$phone', '$gender', '$email', '$address', '$password', '$nanniesCertificate', '$certificate_image_url')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

// 关闭连接
$conn->close();
?>
