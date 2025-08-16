#!/bin/bash
echo "==== نصب پنل BotMirza ===="
read -p "نام دیتابیس: " DB_NAME
read -p "نام کاربری دیتابیس: " DB_USER
read -sp "رمز عبور دیتابیس: " DB_PASS
echo
read -p "آدرس دامنه یا IP: " SITE_URL

echo "🔹 نصب پیش‌نیازها..."
apt update -y
apt install -y apache2 php php-mysql mysql-server unzip curl

echo "🔹 دانلود سورس..."
cd /var/www/html
rm -rf botmirzapanel
curl -L -o botmirzapanel.zip https://github.com/Toxicnonoal/botmirzapanel/archive/refs/heads/main.zip
unzip botmirzapanel.zip
mv botmirzapanel-main botmirzapanel
rm botmirzapanel.zip

echo "🔹 تنظیم دیتابیس..."
mysql -u root -p${DB_PASS} -e "CREATE DATABASE ${DB_NAME}; GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'; FLUSH PRIVILEGES;"

echo "🔹 تغییر کانفیگ..."
CONFIG_FILE="/var/www/html/botmirzapanel/config.php"
sed -i "s/DB_NAME_HERE/${DB_NAME}/g" $CONFIG_FILE
sed -i "s/DB_USER_HERE/${DB_USER}/g" $CONFIG_FILE
sed -i "s/DB_PASS_HERE/${DB_PASS}/g" $CONFIG_FILE
sed -i "s/SITE_URL_HERE/${SITE_URL}/g" $CONFIG_FILE

echo "🔹 راه‌اندازی سرویس‌ها..."
systemctl restart apache2
systemctl enable apache2

echo "✅ نصب کامل شد!"
echo "آدرس پنل: http://${SITE_URL}/botmirzapanel"
