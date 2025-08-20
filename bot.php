<?php
require_once "config.php";
require_once "admin.php";
require_once "payment.php";

// تابع ارسال پیام
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

// گرفتن آپدیت
$update = json_decode(file_get_contents("php://input"), true);

if(!$update) exit;

$chat_id = $update["message"]["chat"]["id"];
$text    = $update["message"]["text"] ?? "";

// بررسی ادمین
if ($chat_id == $ADMIN_ID) {
    handle_admin($chat_id, $text);
}

// دستورات عمومی
if ($text == "/start") {
    $keyboard = [
        "keyboard" => [
            [["text" => "🎁 خرید اشتراک"]],
            [["text" => "ℹ️ درباره ما"]]
        ],
        "resize_keyboard" => true
    ];
    sendMessage($chat_id, "سلام 👋\nبه ربات خوش اومدی!", $keyboard);
}
elseif ($text == "ℹ️ درباره ما") {
    sendMessage($chat_id, "این یک ربات تستی با پرداخت زرین‌پال است ✅");
}
elseif ($text == "🎁 خرید اشتراک") {
    $amount = 20000; // مبلغ به تومان
    $callback = "https://$DOMAIN/botmirzapanel/bot.php?payment=verify&chat_id=$chat_id&amount=$amount";
    $url = request_payment($amount, $callback, "خرید اشتراک پریمیوم");
    if ($url) {
        sendMessage($chat_id, "برای پرداخت روی لینک زیر کلیک کن:\n$url");
    } else {
        sendMessage($chat_id, "❌ خطا در ایجاد تراکنش");
    }
}

// بررسی پرداخت
if (isset($_GET["payment"]) && $_GET["payment"] == "verify") {
    $chat_id = $_GET["chat_id"];
    $amount  = $_GET["amount"];
    $authority = $_GET["Authority"] ?? null;

    if ($authority && verify_payment($authority, $amount)) {
        sendMessage($chat_id, "✅ پرداخت موفق! اشتراک فعال شد.");
        // اینجا می‌تونی کاربر رو تو DB پریمیوم کنی
    } else {
        sendMessage($chat_id, "❌ پرداخت ناموفق بود.");
    }
}
?>
