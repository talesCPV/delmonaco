<?php 

    function sendMail($para,$assunto,$texto){

//echo $para.$assunto.$texto;

        require("mail/PHPMailer.php"); 
        require("mail/SMTP.php"); 
        $mail = new PHPMailer\PHPMailer\PHPMailer();
        $mail->CharSet = "UTF-8";
        $mail->Encoding = 'base64';
        $mail->IsSMTP(); // enable SMTP 
        $mail->SMTPDebug = 0; // debugging: 1 = errors and messages, 2 = messages only 
        $mail->SMTPAuth = true; // authentication enabled 
        $mail->SMTPSecure = 'ssl'; // secure transfer enabled REQUIRED for Gmail 
        $mail->Host = "smtp.titan.email "; 
        $mail->Port = 465; //465 or 587 
        $mail->IsHTML(true); 
        $mail->Username = "tales@planet3.com.br"; 
        $mail->Password = "@Xspider0"; 
        $mail->From = 'tales@planet3.com.br';

        $mail->Subject = $assunto; 
        $mail->Body = $texto; 
        $mail->AddAddress($para); 

        if($mail->Send()) { 
            return 1;            
        } else { 
            return 0;
        } 
    }

    if(isset($_POST['para']) &&isset($_POST['assunto']) && isset($_POST['mensagem'])){
        echo '{"send_mail" : '.sendMail($_POST['para'], $_POST['assunto'], $_POST['mensagem']).'}';
    } 

?>