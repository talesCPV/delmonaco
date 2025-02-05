<?php
    require_once('vendor/autoload.php');
    require_once('../../access.php');

    if(isset($_POST['cust'])){ 
        $client = new \GuzzleHttp\Client();
        $endpoint = asaas_api.'/customers//'.$_POST['cust'];

        $response = $client->request('DELETE', $endpoint, [
            'headers' => [
            'accept' => 'application/json',
            'access_token' => access_token,
        ],
        ]);

        echo $response->getBody();
    }
?>