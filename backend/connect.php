<?php
    
    require_once('../access.php');

    $conexao = new mysqli(db_ip, db_user, db_pass, db_name);
    if (!$conexao){
        die ("Erro de conexão com localhost, o seguinte erro ocorreu -> ".mysql_error());
    }    
?>