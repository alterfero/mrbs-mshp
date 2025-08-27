#!/usr/bin/env bash
set -euo pipefail

# Required envs: MYSQLHOST, MYSQLPORT, MYSQL_DATABASE, MYSQLUSER, MYSQLPASSWORD
wait_for_mysql() {
  echo "Waiting for MySQL at $MYSQLHOST:$MYSQLPORT ..."
  for i in {1..60}; do
    if php -r 'exit(@mysqli_connect(getenv("MYSQLHOST"),getenv("MYSQLUSER"),getenv("MYSQLPASSWORD"),null,(int)getenv("MYSQLPORT"))?0:1);'; then
      echo "MySQL reachable."
      return 0
    fi
    sleep 1
  done
  echo "MySQL not reachable after timeout." >&2
  exit 1
}

need_bootstrap() {
  # Return 0 if tables missing
  php -r '
    $h=getenv("MYSQLHOST"); $u=getenv("MYSQLUSER"); $p=getenv("MYSQLPASSWORD");
    $d=getenv("MYSQL_DATABASE"); $po=(int)getenv("MYSQLPORT");
    $pref=getenv("DB_PREFIX") ?: "mrbs_";
    $link=@mysqli_connect($h,$u,$p,$d,$po);
    if(!$link){ fwrite(STDERR,"Connect fail\n"); exit(2); }
    $res=mysqli_query($link,"SHOW TABLES LIKE \"{$pref}area\"");  // pick one canonical table
    exit(mysqli_num_rows($res)>0?1:0);
  '
}

import_schema() {
  echo "Importing MRBS schema ..."
  mysql -h "$MYSQLHOST" -P "${MYSQLPORT:-3306}" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" "$MYSQL_DATABASE" < /var/www/mrbs/tables.my.sql
  echo "Schema imported."
}

# Ensure mysql client exists
if ! command -v mysql >/dev/null 2>&1; then
  apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*
fi

wait_for_mysql
if need_bootstrap; then
  import_schema
else
  echo "MRBS tables already present; skipping bootstrap."
fi

exec apache2-foreground
