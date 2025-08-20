#!/bin/bash

echo "🔹 نصب ربات میرزا پنل (نسخه پیشرفته) شروع شد..."

# پرسیدن اطلاعات موردنیاز
read -p "👉 توکن ربات تلگرام: " BOT_TOKEN
read -p "👉 آیدی عددی ادمین: " ADMIN_ID
read -p "👉 نام دیتابیس: " DB_NAME
read -p "👉 یوزر دیتابیس: " DB_USER
read -sp "👉 پسورد دیتابیس: " DB_PASS
echo
read -p "👉 دامنه (domain.com): " DOMAIN
read -p "👉 ایمیل برای SSL: " EMAIL
read -p "👉 مرچنت آی‌دی زرین‌پال: " ZARINPAL_MERCHANT

# نصب پیش‌نیازها
apt update -y
apt install -y apache2 php php-mysql mariadb-server unzip curl certbot python3-certbot-apache

# ساخت دیتابیس
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -u root -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# ایمپورت جدول‌ها
mysql -u $DB_USER -p$DB_PASS $DB_NAME < sql/schema.sql

# کپی فایل‌ها
mkdir -p /var/www/html/botmirzapanel
cp -r * /var/www/html/botmirzapanel

# ساخت config.php
cat <<EOF > /var/www/html/botmirzapanel/config.php
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
EOF

# ست کردن SSL
certbot --apache -d $DOMAIN -m $EMAIL --agree-tos --non-interactive

# ریستارت سرویس‌ها
systemctl restart apache2
systemctl restart mysql

echo "✅ نصب با موفقیت انجام شد!"
echo "🌐 آدرس ربات: https://$DOMAIN/botmirzapanel/bot.php"
