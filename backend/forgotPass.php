<?php

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

    require_once 'data.php';
    include_once "connect.php";
    include_once "mail_pnt3.php";

    if(isset($_GET['email']) && !isset($_GET['hash'])){

        $rows = array();
        $query = 'SELECT hash FROM tb_usuario WHERE email = "'.$_GET['email'].'";';

        $result = mysqli_query($conexao, $query);
        if(is_object($result)){
            if($result->num_rows > 0){			
                while($r = mysqli_fetch_assoc($result)) {
                    $rows[] = $r;
                }
            }        
        }
        $conexao->close();

        $hash = $rows[0]['hash'];

        $texto = '
             <style>
                body{
                    display: flex;
                    flex-direction: column;
                }

                fieldset{
                    display: flex;
                    flex-direction: column;
                    gap: 10px;
                    border-radius: 5px;
                }

                input{
                    padding: 5px;
                }

                .button{
                    padding: 5px;
                    background-color: #84ecb2;
                    border: solid 1px;
                    border-radius: 3px;
                    text-decoration: none;
                    cursor: pointer;
                }

                .button:hover{
                    background-color: #519972;
                    color: aliceblue;
                }

                .head, .middle{
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                }

            </style>

            <div class="head">
                <h2>BACKHAND</h2>
                <h4>o maior portal gerenciador de aulas de tênis do Brasil</h4>    
            </div>

            <form class="middle" target="_blank" action="'.SERVER_URL.'/backhand/backend/forgotPass.php" method="POST">
                <p>Você acionou o sistema de recuperação de senha pelo nosso portal, clique no botão abaixo para escolher uma nova senha</p>

                <a class="button" href="'.SERVER_URL.'/backhand/backend/forgotPass.php?email='.$_GET['email'].'&hash='.$hash.'">ALTERAR SENHA</a>

                <p>Caso não tenha sido você, ignore este email</p>
            </form>
        ';

        $send_it = $hash=='' ? 0 : sendMail($_GET['email'],'BACKHAND - Recuperação de Senha',$texto);
        if($send_it){
            header("Location:".SERVER_URL."/backhand/");
        }else{
            print('Ocorreu algum erro no reenvio do email, tente novamente mais tarde.');
        }

    }else if(isset($_GET['email']) && isset($_GET['hash'])){
        $conexao->close();
        $texto = '
             <style>
                body{
                    display: flex;
                    flex-direction: column;
                }

                fieldset{
                    display: flex;
                    flex-direction: column;
                    gap: 10px;
                    border-radius: 5px;
                }

                input{
                    padding: 5px;
                }

                button{
                    padding: 5px;
                    background-color: #84ecb2;
                    border: solid 1px;
                    border-radius: 3px;
                    text-decoration: none;
                    cursor: pointer;
                }

                button:hover{
                    background-color: #519972;
                    color: aliceblue;
                }

                .head, .middle{
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                }

            </style>

            <div class="head">
                <h2>BACKHAND</h2>
                <h4>o maior portal gerenciador de aulas de tênis do Brasil</h4>    
            </div>

            <form class="middle" action="'.SERVER_URL.'/backhand/backend/forgotPass.php" method="POST">
                <p>Você acionou o sistema de recuperação de senha pelo nosso portal, clique no botão abaixo para escolher uma nova senha</p>

                <fieldset>
                    <legend id="lgd">Resetar a Senha de Acesso</legend>
                    <input type="text" value="'.$_GET['email'].'" disabled>
                    <input type="password" name="pass" id="edtPass" placeholder="Digite a nova senha">
                    <input type="password" name="repass" id="edtRePass" placeholder="Repita a senha">
                    <input type="hidden" name="hash" id="asaas_id" value="'.$_GET['hash'].'">
                    <input type="hidden" name="email" id="asaas_id" value="'.$_GET['email'].'">
                    <button type="submit" class="button">Salvar</button>

                </fieldset>

                <p>Caso não tenha sido você, ignore este email</p>
            </form>
        ';
        print($texto);

    }else if(isset($_POST['hash']) && isset($_POST['pass']) && isset($_POST['email'])){
        include_once "connect.php";
        $query = 'CALL sp_updatePass("'.$_POST['hash'].'","'.$_POST['email'].'","'.$_POST['pass'].'");';
        $result = mysqli_query($conexao, $query);
        $conexao->close();
        header("Location:".SERVER_URL."/backhand/?email=".$_POST['email']);
    }

?>