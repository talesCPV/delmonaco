<?php


//    $post = '{"id": "evt_05b708f961d739ea7eba7e4db318f621&780387603","event": "PAYMENT_CREATED","dateCreated": "2024-11-28 15:43:38","payment": {"object": "payment","id": "pay_fdilqhpy0yjb1wsd","dateCreated": "2024-11-28","customer": "cus_000103120055","paymentLink": null,"value": 100,"netValue": 97.52,"originalValue": null,"interestValue": null,"description": null,"billingType": "UNDEFINED","pixTransaction": null,"status": "PENDING","dueDate": "2024-11-30","originalDueDate": "2024-11-30","paymentDate": null,"clientPaymentDate": null,"installmentNumber": null,"invoiceUrl": "https://www.asaas.com/i/fdilqhpy0yjb1wsd","invoiceNumber": "480513077","externalReference": "BACKHAND","deleted": false,"anticipated": false,"anticipable": false,"creditDate": null,"estimatedCreditDate": null,"transactionReceiptUrl": null,"nossoNumero": "267817456","bankSlipUrl": "https://www.asaas.com/b/pdf/fdilqhpy0yjb1wsd","lastInvoiceViewedDate": null,"lastBankSlipViewedDate": null,"discount": {"value": 0,"limitDate": null,"dueDateLimitDays": 0,"type": "FIXED"},"fine": {"value": 0,"type": "FIXED"},"interest": {"value": 0,"type": "PERCENTAGE"},"postalService": false,"custody": null,"refunds": null}}';
//    $post = '{"id":"evt_d26e303b238e509335ac9ba210e51b0f&773381934","event":"PAYMENT_RECEIVED","dateCreated":"2024-11-19 16:41:18","payment":{"object":"payment","id":"pay_w4tu4ttrw7dbclmo","dateCreated":"2024-11-19","customer":"cus_000102323317","paymentLink":null,"value":100,"netValue":99.01,"originalValue":null,"interestValue":null,"description":null,"billingType":"PIX","confirmedDate":"2024-11-19","pixTransaction":"95c11b82-4014-4ad1-a704-7a5cf45a28f4","pixQrCodeId":"TALESCEMBRANELIDANTAS00011456307ASA","status":"RECEIVED","dueDate":"2024-11-21","originalDueDate":"2024-11-21","paymentDate":"2024-11-19","clientPaymentDate":"2024-11-19","installmentNumber":null,"invoiceUrl":"https://www.asaas.com/i/w4tu4ttrw7dbclmo","invoiceNumber":"476382822","externalReference":"BACKHAND","deleted":false,"anticipated":false,"anticipable":false,"creditDate":"2024-11-19","estimatedCreditDate":"2024-11-19","transactionReceiptUrl":"https://www.asaas.com/comprovantes/h/UEFZTUVOVF9SRUNFSVZFRDpwYXlfdzR0dTR0dHJ3N2RiY2xtbw%3D%3D","nossoNumero":"265201769","bankSlipUrl":null,"lastInvoiceViewedDate":null,"lastBankSlipViewedDate":null,"discount":{"value":0.00,"limitDate":null,"dueDateLimitDays":0,"type":"FIXED"},"fine":{"value":0.00,"type":"FIXED"},"interest":{"value":0.00,"type":"PERCENTAGE"},"postalService":false,"custody":null,"refunds":null}}';
    $post = file_get_contents('php://input');

    saveFile($post);

    $json = json_decode($post);

    if($json->payment->externalReference == 'BACKHAND'){
        saveFile($post);        
        switch ($json->event) {
            case 'PAYMENT_CREATED':
                createPayment($json);
                break;
            case 'PAYMENT_RECEIVED':
                receivePayment($json);
                break;
            case 'PAYMENT_CHECKOUT_VIEWED':
                checkoutPayment($json);
                break;
            case 'PAYMENT_OVERDUE':
                overduePayment($json);
                break;
            case 'PAYMENT_BANK_SLIP_VIEWED':
                bankCkeckoutPayment($json);
                break;
        }
    }

    function createPayment($payment) {
        saveFile("Pagamento Criado: ID ".$payment->id."\r\nCLIENTE ID:".$payment->payment->customer."\r\nVALOR R$".$payment->payment->value."\r\n");
    }

    function receivePayment($payment) {
        $asaas_id = $payment->payment->customer;
        $valor = $payment->payment->value;
        $month = getMonth($valor);
        $pay_id = $payment->payment->id;

        try{
            require_once('../connect.php');
            $query = 'CALL sp_add_credit("'.$asaas_id.'","'.$month.'","'.$valor.'");';            
            $result = mysqli_query($conexao, $query);
            if(is_object($result)){
                saveFile('Credito adicionado!');
            }
            $conexao->close();    
            saveFile("Pagamento Efetuado: ID ".$pay_id."\r\nCLIENTE ID:".$asaas_id."\r\nVALOR R$".$valor."\r\n");
        }catch (Exception $e){
            saveFile('Pagamento '.$pay_id.' de R$'.$valor.',00 para '.$month.' meses de créditos foi efetuado mas não adicionado ao cliente '.$asaas_id).'\r\n';
            saveFile('Cód do Erro: '.$e);
        }
    }

    function checkoutPayment($payment) {
        saveFile("Pagamento Visualizado: ID ".$payment->id."\r\nCLIENTE ID:".$payment->payment->customer."\r\nVALOR R$".$payment->payment->value."\r\n");
    }

    function bankCkeckoutPayment($payment) {
        saveFile("Boleto Visualizado: ID ".$payment->id."\r\nCLIENTE ID:".$payment->payment->customer."\r\nVALOR R$".$payment->payment->value."\r\n");
    }

    function overduePayment($payment) {
        saveFile("Pagamento Vencido: ID ".$payment->id."\r\nCLIENTE ID:".$payment->payment->customer."\r\nVALOR R$".$payment->payment->value."\r\n");
    }

    function saveFile($txt){        
        $path = getcwd().'/webhook.txt';
        $fp = fopen($path, "a");
        fwrite($fp,$txt."\r\n");
        fclose($fp);
    }

    function getMonth($valor){
        $out = 0;
        switch($valor){
            case 840:
                $out = 12;
                break;
            case 480:
                $out = 6;
                break;
            case 270:
                $out = 3;
                break;                
            case 100:
                $out = 1;
                break;
        }
        return $out;
    }

     http_response_code(200);
?>