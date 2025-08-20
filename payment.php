<?php
require_once "config.php";

function request_payment($amount, $callback_url, $description = "پرداخت در ربات") {
    global $ZARINPAL_MERCHANT;

    $data = array(
        "merchant_id" => $ZARINPAL_MERCHANT,
        "amount" => $amount,
        "callback_url" => $callback_url,
        "description" => $description,
    );

    $jsonData = json_encode($data);
    $ch = curl_init('https://api.zarinpal.com/pg/v4/payment/request.json');
    curl_setopt($ch, CURLOPT_USERAGENT, 'ZarinPal Rest Api v4');
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
    curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
    $result = curl_exec($ch);
    $err = curl_error($ch);
    curl_close($ch);

    $result = json_decode($result, true);

    if (isset($result["data"]) && isset($result["data"]["authority"])) {
        return "https://www.zarinpal.com/pg/StartPay/" . $result["data"]["authority"];
    } else {
        return false;
    }
}

function verify_payment($authority, $amount) {
    global $ZARINPAL_MERCHANT;

    $data = array(
        "merchant_id" => $ZARINPAL_MERCHANT,
        "amount" => $amount,
        "authority" => $authority
    );

    $jsonData = json_encode($data);
    $ch = curl_init('https://api.zarinpal.com/pg/v4/payment/verify.json');
    curl_setopt($ch, CURLOPT_USERAGENT, 'ZarinPal Rest Api v4');
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
    curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
    $result = curl_exec($ch);
    $err = curl_error($ch);
    curl_close($ch);

    $result = json_decode($result, true);

    if (isset($result["data"]) && $result["data"]["code"] == 100) {
        return true;
    } else {
        return false;
    }
}
?>
