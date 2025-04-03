<?php
    require_once('vendor/autoload.php');

    if(isset($_POST['body'])){
//echo $_POST['body'];
      $client = new \GuzzleHttp\Client();
      $response = $client->request('POST', asaas_api.'/payments', [
        'body' => $_POST['body'],
        'headers' => [
          'accept' => 'application/json',
          'access_token' => access_token,
          'content-type' => 'application/json',
        ],
      ]);

      echo $response->getBody();
    }
// {"customer":"cus_000006613338","value":"2400","dueDate":"2025-04-18","description":"Add Credito Semestral","daysAfterDueDateToRegistrationCancellation":15,"externalReference":"GDM-ELEVATE"}
?>  