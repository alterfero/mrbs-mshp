<?php // -*-mode: PHP; coding:utf-8;-*-
namespace MRBS;

$timezone = $_ENV['MRBS_TIMEZONE'] ?? 'Europe/London';
$dbsys = $_ENV['MRBS_DB_SYSTEM'] ?? 'mysql';
$db_host = $_ENV['MRBS_DB_HOST'] ?? 'db';
$db_database = $_ENV['MRBS_DB_DATABASE'] ?? 'mrbs';
$db_login = $_ENV['MRBS_DB_USER'] ?? 'mrbs';
$db_password = $_ENV['MRBS_DB_PASSWORD'] ?? 'mrbs';
$db_tbl_prefix = $_ENV['MRBS_DB_TBL_PREFIX'] ?? 'mrbs_';
$db_persist = FALSE;

// Allow configuration via common Railway environment variables
$db_host = $_ENV['MYSQLHOST'] ?? $_ENV['MYSQL_HOST'] ?? $db_host;
if (!empty($_ENV['MYSQLPORT'])) {
  $db_port = $_ENV['MYSQLPORT'];
}
$db_database = $_ENV['MYSQLDATABASE'] ?? $_ENV['MYSQL_DATABASE'] ?? $db_database;
$db_login = $_ENV['MYSQLUSER'] ?? $db_login;
$db_password = $_ENV['MYSQLPASSWORD'] ?? $_ENV['MYSQL_ROOT_PASSWORD'] ?? $db_password;

if ($url = $_ENV['MYSQL_URL'] ?? $_ENV['MYSQL_PUBLIC_URL'] ?? null) {
  $url_parts = parse_url($url);
  if (!empty($url_parts['host'])) {
    $db_host = $url_parts['host'];
  }
  if (!empty($url_parts['port'])) {
    $db_port = $url_parts['port'];
  }
  if (!empty($url_parts['user'])) {
    $db_login = $url_parts['user'];
  }
  if (!empty($url_parts['pass'])) {
    $db_password = $url_parts['pass'];
  }
  if (!empty($url_parts['path'])) {
    $db_database = ltrim($url_parts['path'], '/');
  }
}
