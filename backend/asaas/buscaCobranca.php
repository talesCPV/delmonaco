<?php
    require_once('vendor/autoload.php');

    $client = new \GuzzleHttp\Client();

    $url = IsSet($_POST["asaas_id"]) ? asaas_api.'/payments?customer='.$_POST["asaas_id"] : asaas_api.'/payments';

    $response = $client->request('GET', $url, [
        'headers' => [
            'accept' => 'application/json',
            'access_token' => access_token,
        ],
    ]);

    echo $response->getBody();

?>