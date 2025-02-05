<?php

    require_once('vendor/autoload.php');
    require_once('../../access.php');

    $client = new \GuzzleHttp\Client();
    $endpoint = asaas_api.'/payments';

    $response = $client->request('GET', $endpoint, [
        'headers' => [
            'accept' => 'application/json',
            'access_token' => access_token,
        ],
    ]);

    $out = '{"OK":0}';

    if($_POST['asaas_id']==''){
        $out = $response->getBody();
    }else{
        $data = json_decode($response->getBody())->data;

        $out = array();

        for ($i=0; $i<count($data); $i++) {
            if($data[$i]->customer == $_POST['asaas_id']){
                array_push($out,$data[$i]);
            }
        }
    }

    print json_encode($out);


//    echo $response->getBody();

?>