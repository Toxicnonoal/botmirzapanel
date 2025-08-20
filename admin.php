<?php
require_once "config.php";

// تابع ارسال پیام به تلگرام
function sendMessage($chat_id, $text, $reply_markup = null) {
    global $BOT_TOKEN;
    $url = "https://api.telegram.org/bot$BOT_TOKEN/sendMessage";
    $post = [
        "chat_id" => $chat_id,
        "text" => $text,
        "parse_mode" => "HTML"
    ];
    if ($reply_markup) {
        $post["reply_markup"] = json_encode($reply_markup);
    }
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_exec($ch);
    curl_close($ch);
}

// هندل دستورات ادمین
function handle_admin($chat_id, $text) {
    global $ADMIN_ID;

    if ($chat_id != $ADMIN_ID) {
        return; // فقط ادمین دسترسی داره
    }

    if ($text == "/admin") {
        $keyboard = [
            "keyboard" => [
                [["text" => "➕ افزودن دکمه"], ["text" => "📝 ویرایش متن"]],
                [["text" => "📊 آمار کاربران"]]
            ],
            "resize_keyboard" => true
        ];
        sendMessage($chat_id, "🔹 منوی مدیریت:", $keyboard);
    } elseif ($text == "📊 آمار کاربران") {
        // اینجا باید کوئری دیتابیس اضافه بشه
        sendMessage($chat_id, "👥 تعداد کاربران: [درحال توسعه]");
    } elseif ($text == "➕ افزودن دکمه") {
        sendMessage($chat_id, "نام دکمه‌ای که می‌خوای اضافه کنی رو بفرست:");
        // اینجا باید لاجیک ذخیره دکمه در DB نوشته بشه
    } elseif ($text == "📝 ویرایش متن") {
        sendMessage($chat_id, "متنی که می‌خوای ویرایش کنی رو بفرست:");
        // اینجا هم می‌تونیم DB رو آپدیت کنیم
    }
}
?>
