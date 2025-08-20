#!/bin/bash

echo "🚀 شروع نصب پنل بات ..."

# گرفتن اطلاعات از کاربر
read -p "👉 نام پایگاه‌داده رو وارد کن: " DB_NAME
read -p "👉 یوزر پایگاه‌داده رو وارد کن: " DB_USER
read -s -p "👉 پسورد پایگاه‌داده رو وارد کن: " DB_PASS
echo
read -p "👉 مسیر فایل SQL رو وارد کن (مثلا sql/schema.sql): " SQL_FILE
read -p "👉 توکن ربات تلگرام رو وارد کن: " BOT_TOKEN
read -p "👉 آیدی عددی ادمین رو وارد کن: " ADMIN_ID
read -p "👉 دامنه (Domain) رو وارد کن (مثلا example.com): " DOMAIN
read -p "👉 کد مرچنت زرین‌پال رو وارد کن: " ZARINPAL_MERCHANT

# بررسی وجود فایل SQL
if [ ! -f "$SQL_FILE" ]; then
  echo "❌ فایل SQL پیدا نشد: $SQL_FILE"
  exit 1
fi

# ساخت دیتابیس و یوزر
mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \$DB_NAME\ CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \$DB_NAME\.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
USE \$DB_NAME\;
SOURCE $SQL_FILE;
MYSQL_SCRIPT

if [ $? -ne 0 ]; then
  echo "❌ خطا در نصب دیتابیس. لطفا بررسی کن."
  exit 1
fi

# به‌روزرسانی فایل config.php
CONFIG_FILE="config.php"
if [ -f "$CONFIG_FILE" ]; then
cat > $CONFIG_FILE <<EOL
<?php
\$BOT_TOKEN = "$BOT_TOKEN";
\$ADMIN_ID = $ADMIN_ID;

\$DB_NAME = "$DB_NAME";
\$DB_USER = "$DB_USER";
\$DB_PASS = "$DB_PASS";
\$DB_HOST = "localhost";

\$DOMAIN = "$DOMAIN";
\$ZARINPAL_MERCHANT = "$ZARINPAL_MERCHANT";
?>
EOL

  echo "✅ فایل config.php ساخته و تنظیم شد."
else
  echo "⚠️ فایل config.php پیدا نشد، پس خودم یکی ساختم."
  cat > config.php <<EOL
<?php
\$BOT_TOKEN = "$BOT_TOKEN";
\$ADMIN_ID = $ADMIN_ID;

\$DB_NAME = "$DB_NAME";
\$DB_USER = "$DB_USER";
\$DB_PASS = "$DB_PASS";
\$DB_HOST = "localhost";

\$DOMAIN = "$DOMAIN";
\$ZARINPAL_MERCHANT = "$ZARINPAL_MERCHANT";
?>
EOL
fi

echo "✅ نصب کامل شد!"
echo "📂 دیتابیس: $DB_NAME"
echo "👤 یوزر: $DB_USER"
echo "🤖 توکن: $BOT_TOKEN"
echo "👑 ادمین: $ADMIN_ID"
echo "🌐 دامنه: $DOMAIN"
echo "💳 زرین‌پال: $ZARINPAL_MERCHANT"
