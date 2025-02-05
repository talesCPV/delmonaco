<?php

    if(isset($_GET['asaas_id'])){
        include_once "connect.php";

        $query = 'CALL sp_confirma_email("'.$_GET['asaas_id'].'");';

        $result = mysqli_query($conexao, $query);
        $conexao->close();

        header("Location: https://planet3.com.br//backhand/");

    }

?>