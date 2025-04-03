<?php
    require_once('vendor/autoload.php');

    if(isset($_POST['body'])){
     
      $client = new \GuzzleHttp\Client();
      $response = $client->request('POST', asaas_api.'/customers', [
        'body' => $_POST['body'],
        'headers' => [
          'accept' => 'application/json',
          'access_token' => access_token,
          'content-type' => 'application/json',
        ],
      ]);

      echo $response->getBody();
    }

?>  