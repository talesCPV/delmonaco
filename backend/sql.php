<?php

    $query_db = array(
        /* LOGIN */
        "LOG-0"  => 'CALL sp_login("x00", "x01");', // USER, PASS

        /* USERS */
        "USR-0"  => 'CALL sp_viewUser(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "USR-1"  => 'CALL sp_setUser(@access,@hash,x00,"x01","x02","x03",x04);', // ID, NOME, EMAIL, PASS, ACCESS
        "USR-2"  => 'CALL sp_updatePass(@hash,"x00","x01");', // NOME, PASS
        "USR-3"  => 'CALL sp_check_usr_mail(@hash);',

        /* CALENDAR */
        "CAL-0"  => 'CALL sp_view_calendar(@hash,"x00","x01");', // DT_INI, DT_FIN
        "CAL-1"  => 'CALL sp_set_calendar(@hash,"x00","x01");', // DT_AGD, OBS

        /* MAIL */
        "MAIL-0"  => 'CALL sp_set_mail(@hash,"x00","x01");', // ID_TO, MESSAGE
        "MAIL-1"  => 'CALL sp_view_mail(@hash,x00);', // I_SEND
        "MAIL-2"  => 'CALL sp_all_mail_adress(@hash);', //      
        "MAIL-3"  => 'CALL sp_del_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO
        "MAIL-4"  => 'CALL sp_mark_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO

        /* SYSTEMA */
        "SYS-0"  => 'CALL sp_set_usr_perm_perf(@access,@hash,x00,"x01");', // ID, NOME
        "SYS-1"  => 'CALL sp_view_usr_perm_perf(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE

        /* CLIENTES */
        "CLI-0"  => 'CALL sp_view_cli(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "CLI-1"  => 'CALL sp_set_cli(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09","x10","x11","x12","x13","x14","x15");', // id,razao_social,fantasia,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,ramo,tel,email

        /* PRODUTOS */
        "PROD-0"  => 'CALL sp_view_prod(@access,@hash,"x00");', // Nome
        "PROD-1"  => 'CALL sp_set_prod(@access,@hash,x00,"x01","x02","x03");', // id,nome,valor,sobre
        "PROD-2"  => 'CALL sp_view_escopo(@access,@hash,x00);', // ID_PROD
        "PROD-3"  => 'CALL sp_set_escopo(@access,@hash,x00,x01,"x02","x03");', // id,id_prod,nome,texto
        "PROD-4"  => 'CALL sp_up_escopo(@access,@hash,x00,x01);', // id, id_prod

        /* ORÇAMENTOS */
        "ORC-0"  => 'CALL sp_view_orc(@access,@hash,"x00","x01");', // DT_INI, DT_FIN
        "ORC-1"  => 'CALL sp_set_orc(@access,@hash,x00,x01,"x02","x03","x04");', // id,id_cli,capa,data,valor
        "ORC-2"  => 'CALL sp_orc_set_item(@access,@hash,x00,x01,"x02");', // id_orc,id_prod,valor
        "ORC-3"  => 'CALL sp_orc_view_item(@access,@hash,x00);', // id_orc
        "ORC-4"  => 'CALL sp_view_texto(@access,@hash,"x00");', // titulo
        "ORC-5"  => 'CALL sp_set_texto(@access,@hash,x00,"x01","x02","x03");', // id,titulo,texto,valor
        "ORC-6"  => 'CALL sp_orc_set_texto(@access,@hash,x00,x01,"x02");', // id_orc,id_texto,valor
        "ORC-7"  => 'CALL sp_orc_view_texto(@access,@hash,x00);', // id_orc


        
    );

?>