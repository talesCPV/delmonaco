<?php
    require_once('vendor/autoload.php');

    $client = new \GuzzleHttp\Client();
    $response = $client->request('GET', asaas_api.'/financialTransactions', [
    'headers' => [
        'accept' => 'application/json',
        'access_token' => access_token
    ],
    ]);

    echo $response->getBody();
?>