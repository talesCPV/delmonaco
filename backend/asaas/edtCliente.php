<?php
    require_once('vendor/autoload.php');
    require_once('../../access.php');

    if(isset($_POST['cust']) && isset($_POST['body'])){    
        $client = new \GuzzleHttp\Client();
        $endpoint = asaas_api.'/customers//'.$_POST['cust'];

        $response = $client->request('PUT', $endpoint, [
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