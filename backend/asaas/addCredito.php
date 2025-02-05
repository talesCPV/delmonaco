<?php
    require_once('vendor/autoload.php');
    require_once('../../access.php');

    if(isset($_POST['asaas_id']) && isset($_POST['value'])){

        $today = date("Y-m-d H:i:s");
        $client = new \GuzzleHttp\Client();
        $endpoint = asaas_api.'/payments';
        $body = '{"billingType":"UNDEFINED","customer":"'.$_POST['asaas_id'].'","value":'.$_POST['value'].',"dueDate":"'.date('Y-m-d', strtotime($today. ' + 2 days')).'","externalReference":"BACKHAND","postalService":false}';

        $response = $client->request('POST', $endpoint, [
            'body' => $body,
            'headers' => [
                'accept' => 'application/json',
                'access_token' => access_token,
                'content-type' => 'application/json',
            ],
      ]);

      echo $response->getBody();

    }

?>  