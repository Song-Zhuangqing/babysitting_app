<?php
// config.php

// 定义服务器的IP地址
define("SERVER_IP", "192.168.104.49");

// 定义根 URL（通常是 IP 地址 + 项目路径）
define("BASE_URL", "http://" . SERVER_IP . "/babysitting_app/php");

// 可以在此处定义其他配置，例如数据库配置
define("DB_HOST", "localhost");
define("DB_NAME", "cbcp");
define("DB_USER", "root");
define("DB_PASS", "");

// 获取 API 基础路径
define("API_URL", BASE_URL . "/api");

// 使用时，例如在其他文件中使用 BASE_URL 或 API_URL
// echo "访问 API: " . API_URL;
?>
