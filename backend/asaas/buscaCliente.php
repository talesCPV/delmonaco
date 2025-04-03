<?php

    if (IsSet($_POST["cnpj"])){

        require_once('vendor/autoload.php');

        $cnpj = $_POST["cnpj"];
        $client = new \GuzzleHttp\Client();
    
        $response = $client->request('GET', asaas_api.'/customers?cpfCnpj='.$cnpj, [
            'headers' => [
                'accept' => 'application/json',
                'access_token' => access_token,
            ],
        ]);
    
        print $response->getBody();

    }



?>