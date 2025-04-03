<?php
    require_once('vendor/autoload.php');

    if(isset($_POST['cust'])){ 
        $client = new \GuzzleHttp\Client();
        $response = $client->request('DELETE', asaas_api.'/customers/'.$_POST['cust'], [
            'headers' => [
            'accept' => 'application/json',
            'access_token' => access_token,
        ],
        ]);

        echo $response->getBody();
    }
?>