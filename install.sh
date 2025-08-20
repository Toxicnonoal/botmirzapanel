#!/bin/bash

echo "🚀 شروع نصب پایگاه‌داده برای پروژه ..."

# گرفتن اطلاعات از کاربر
read -p "👉 نام پایگاه‌داده رو وارد کن: " DB_NAME
read -p "👉 یوزر پایگاه‌داده رو وارد کن: " DB_USER
read -s -p "👉 پسورد پایگاه‌داده رو وارد کن: " DB_PASS
echo
read -p "👉 مسیر فایل SQL رو وارد کن (مثلا sql/schema.sql): " SQL_FILE

# بررسی وجود فایل SQL
if [ ! -f "$SQL_FILE" ]; then
  echo "❌ فایل SQL پیدا نشد: $SQL_FILE"
  exit 1
fi

# اجرای دستورات MySQL
mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \$DB_NAME\ CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \$DB_NAME\.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
USE \$DB_NAME\;
SOURCE $SQL_FILE;
MYSQL_SCRIPT

# بررسی موفقیت عملیات
if [ $? -eq 0 ]; then
  echo "✅ نصب با موفقیت انجام شد!"
  echo "📂 دیتابیس: $DB_NAME"
  echo "👤 یوزر: $DB_USER"
else
  echo "❌ خطا در نصب. لطفا لاگ‌ها رو بررسی کن."
  exit 1
fi
