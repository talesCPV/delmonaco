<?php
    require_once('vendor/autoload.php');
    require_once('../../access.php');

    $client = new \GuzzleHttp\Client();
    $endpoint = asaas_api.'/financialTransactions';

    $response = $client->request('GET', $endpoint, [
    'headers' => [
        'accept' => 'application/json',
        'access_token' => access_token
    ],
    ]);

    echo $response->getBody();
?>