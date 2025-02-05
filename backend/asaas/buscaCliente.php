<?php
    require_once('vendor/autoload.php');
    require_once('../../access.php');

    $client = new \GuzzleHttp\Client();
    $endpoint = asaas_api.'/customers';

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

        for ($i=0; $i<count($data); $i++) {
            if($data[$i]->id == $_POST['asaas_id']){
                $out = $data[$i];
            }
        }
    }

    print json_encode($out);

?>