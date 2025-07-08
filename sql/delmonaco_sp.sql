/* FUNCTIONS */

 DROP PROCEDURE IF EXISTS sp_getHash;
DELIMITER $$
	CREATE PROCEDURE sp_getHash(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SELECT SHA2(CONCAT(Iemail, Isenha), 256) AS HASH;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_allow;
DELIMITER $$
	CREATE PROCEDURE sp_allow(
		IN Iallow varchar(80),
		IN Ihash varchar(64)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @quer =CONCAT('SET @allow = (SELECT ',@access,' IN ',Iallow,');');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
	END $$
DELIMITER ;

/* LOGIN */

 DROP PROCEDURE IF EXISTS sp_login;
DELIMITER $$
	CREATE PROCEDURE sp_login(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @hash = (SELECT SHA2(CONCAT(Iemail, Isenha), 256));
		SELECT *, IF(nome="",SUBSTRING_INDEX(email,"@",1),nome) AS nome FROM tb_usuario WHERE hash=@hash;
	END $$
DELIMITER ;

/* USER */

 DROP PROCEDURE IF EXISTS sp_setUser;
DELIMITER $$
	CREATE PROCEDURE sp_setUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Inome varchar(30),
		IN Iemail varchar(80),
		IN Isenha varchar(30),
        IN Iaccess int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iemail="")THEN
				DELETE FROM tb_mail WHERE id_from=Iid OR id_to=Iid;
				DELETE FROM tb_usuario WHERE id=Iid;
                DELETE FROM tb_user_cli WHERE id_user=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_usuario (email,hash,access,nome)VALUES(Iemail,SHA2(CONCAT(Iemail, Isenha), 256),Iaccess,Inome);
                ELSE
					IF(Isenha="")THEN
						UPDATE tb_usuario SET nome=Inome, email=Iemail, access=Iaccess WHERE id=Iid;
                    ELSE
						UPDATE tb_usuario SET nome=Inome, email=Iemail, hash=SHA2(CONCAT(Iemail, Isenha), 256), access=Iaccess WHERE id=Iid;
                    END IF;
                END IF;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_viewUser;
DELIMITER $$
	CREATE PROCEDURE sp_viewUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT id,nome,email,access, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil FROM tb_usuario AS USR WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_updatePass;
DELIMITER $$
	CREATE PROCEDURE sp_updatePass(	
		IN Ihash varchar(64),
        IN Inome varchar(30),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @call_id = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@call_id > 0)THEN
			IF(Isenha="")THEN
				UPDATE tb_usuario SET nome=Inome WHERE id=@call_id;
            ELSE
				UPDATE tb_usuario SET hash = SHA2(CONCAT(email, Isenha), 256), nome=Inome WHERE id=@call_id;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

/* PERMISSÂO */

 DROP PROCEDURE IF EXISTS sp_set_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_set_usr_perm_perf(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid int(11),
		IN Inome varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			IF(Iid = 0 AND Inome != "")THEN
				INSERT INTO tb_usr_perm_perfil (nome) VALUES (Inome);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_usr_perm_perfil WHERE id=Iid;
				ELSE
					UPDATE tb_usr_perm_perfil SET nome = Inome WHERE id=Iid;
                END IF;
            END IF;			
			SELECT * FROM tb_usr_perm_perfil;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_view_usr_perm_perf(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SET @quer = CONCAT('SELECT * FROM tb_usr_perm_perfil WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

/* CALENDAR */

 DROP PROCEDURE IF EXISTS sp_view_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_view_calendar(	
		IN Ihash varchar(64),
		IN IdataIni date,
		IN IdataFin date
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM tb_calendario WHERE id_user=@id_call AND data_agd>=IdataIni AND data_agd<=IdataFin;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_set_calendar(	
		IN Ihash varchar(64),
		IN Idata date,
		IN Iobs varchar(255)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			SET @exist = (SELECT COUNT(*) FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata);
			IF(@exist AND Iobs = "")THEN
				DELETE FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata; 
			ELSE
				INSERT INTO tb_calendario (id_user, data_agd, obs) VALUES(@id_call, Idata, Iobs)
                ON DUPLICATE KEY UPDATE obs=Iobs;
			END IF;
        END IF;
	END $$
DELIMITER ;

/* MAIL */

 DROP PROCEDURE IF EXISTS sp_check_usr_mail;
DELIMITER $$
	CREATE PROCEDURE sp_check_usr_mail(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call>0)THEN        
			SELECT COUNT(*) AS new_mail FROM tb_mail WHERE id_to = @id_call AND looked=0;
		ELSE
			SELECT 0 AS new_mail ;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_mail;
DELIMITER $$
	CREATE PROCEDURE sp_set_mail(	
		IN Ihash varchar(64),
        IN Iid_to int(11),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			INSERT INTO tb_mail (id_from,id_to,message) VALUES (@id_call,Iid_to,Imessage);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_mail;
DELIMITER $$
	CREATE PROCEDURE sp_view_mail(	
		IN Ihash varchar(64),
        IN Isend boolean
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Isend)THEN
				SELECT MAIL.*, USR.email AS mail_from
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_from = USR.id AND MAIL.id_to = @id_call;            
            ELSE
				SELECT MAIL.*, USR.email AS mail_to
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_to = USR.id AND MAIL.id_from = @id_call;            
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_del_mail;
DELIMITER $$
	CREATE PROCEDURE sp_del_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			DELETE FROM tb_mail WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_mark_mail;
DELIMITER $$
	CREATE PROCEDURE sp_mark_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			UPDATE tb_mail SET looked=1 WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_all_mail_adress;
DELIMITER $$
	CREATE PROCEDURE sp_all_mail_adress(	
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT id,email FROM tb_usuario WHERE id != @id_call ORDER BY email ASC;
	END $$
DELIMITER ;

/* FIM PADRÂO */

/* CLIENTES */

 DROP PROCEDURE IF EXISTS sp_view_cli;
DELIMITER $$
	CREATE PROCEDURE sp_view_cli(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SET @quer = CONCAT('SELECT * FROM tb_cliente WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_cli;
DELIMITER $$
	CREATE PROCEDURE sp_set_cli(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Irazao_social varchar(80),    
		IN Ifant varchar(40),
		IN Icnpj varchar(14),
		IN Iie varchar(14),
		IN Iim varchar(14),
		IN Iend varchar(60),
		IN Inum varchar(6),
		IN Icomp varchar(50),
		IN Ibairro varchar(60),
		IN Icidade varchar(30),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Iramo varchar(80),
		IN Itel varchar(15),
		IN Iemail varchar(80)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Irazao_social = "")THEN
				DELETE FROM tb_cliente WHERE id = Iid;
                DELETE FROM tb_user_cli WHERE id_cliente=Iid;
                DELETE FROM tb_norma_cli WHERE id_cliente=Iid;
                DELETE FROM tb_check WHERE id_cliente=Iid;
                DELETE FROM tb_orcamento WHERE id_cli=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_cliente (id,razao_social,fantasia,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,ramo,tel,email) 
					VALUES (Iid,Irazao_social,Ifant,Icnpj,Iie,Iim,Iend,Inum,Icomp,Ibairro,Icidade,Iuf,Icep,Iramo,Itel,Iemail);
				ELSE 
					UPDATE tb_cliente SET razao_social=Irazao_social, fantasia=Ifant,cnpj=Icnpj, ie=Iie, im=Iim, end=Iend, num=Inum,
                    comp=Icomp, bairro=Ibairro, cidade=Icidade, uf=Iuf, cep=Icep, ramo=Iramo, tel=Itel, email=Iemail ;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_user_cli;
DELIMITER $$
	CREATE PROCEDURE sp_set_user_cli(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_user int(11),
		IN Iid_cliente int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_user_cli WHERE id_user=Iid_user AND id_cliente=Iid_cliente);
			IF(@has)THEN
				DELETE FROM tb_user_cli WHERE id_user=Iid_user AND id_cliente=Iid_cliente;
                SELECT 0 AS acesso;
            ELSE
				INSERT INTO tb_user_cli (id_user,id_cliente)
				VALUES (Iid_user,Iid_cliente);
                SELECT 1 AS acesso;                
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_cli_user;
DELIMITER $$
	CREATE PROCEDURE sp_view_cli_user(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid > 0)THEN
				SELECT * FROM vw_usr_cli WHERE id_user=Iid;
            ELSE
				SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
				SELECT * FROM vw_usr_cli WHERE id_user=@id_call;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* PRODUTOS */

 DROP PROCEDURE IF EXISTS sp_view_prod;
DELIMITER $$
	CREATE PROCEDURE sp_view_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Inome varchar(30)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_produto WHERE nome COLLATE utf8_general_ci LIKE CONCAT('%',Inome,'%') COLLATE utf8_general_ci ORDER BY nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_prod;
DELIMITER $$
	CREATE PROCEDURE sp_set_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(30),
		IN Ivalor double,
		IN Isobre varchar(1024)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome = "")THEN
				DELETE FROM tb_produto WHERE id = Iid;
                DELETE FROM tb_escopo WHERE id_prod = Iid;
                DELETE FROM tb_orc_prod WHERE id_prod = Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_produto (nome,valor,sobre) 
					VALUES (Inome, Ivalor, Isobre);
				ELSE 
					UPDATE tb_produto SET nome=Inome, valor=Ivalor, sobre=Isobre WHERE id=Iid ;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_escopo;
DELIMITER $$
	CREATE PROCEDURE sp_view_escopo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_prod int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SELECT * FROM tb_escopo WHERE id_prod = Iid_prod ORDER BY id;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_escopo;
DELIMITER $$
	CREATE PROCEDURE sp_set_escopo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_prod int(11),
		IN Inome varchar(30),
		IN Itexto varchar(256)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome = "")THEN
				DELETE FROM tb_escopo WHERE id = Iid;
                SELECT "DELETADO" AS RESP;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_escopo (id_prod,nome,texto) 
					VALUES (Iid_prod,Inome, Itexto);
					SELECT "ADICIONADO" AS RESP;
				ELSE 
					UPDATE tb_escopo SET nome=Inome, texto=Itexto WHERE id=Iid;
					SELECT "EDITADO" AS RESP;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_up_escopo;
DELIMITER $$
	CREATE PROCEDURE sp_up_escopo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_prod int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid>0)THEN
				UPDATE tb_escopo SET id=0 WHERE id=Iid AND id_prod=Iid_prod;
                UPDATE tb_escopo SET id=Iid WHERE id=(Iid-1) AND id_prod=Iid_prod;
                UPDATE tb_escopo SET id=(Iid-1) WHERE id=0 AND id_prod=Iid_prod;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* ORÇAMENTO */

 DROP PROCEDURE IF EXISTS sp_view_orc;
DELIMITER $$
	CREATE PROCEDURE sp_view_orc(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN IdtIni date,
        IN IdtFin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SELECT * FROM vw_orcamento WHERE data>= CONCAT(IdtIni," 00:00:00") AND data<= CONCAT(IdtFin," 23:59:59") ORDER BY data DESC;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_orc;
DELIMITER $$
	CREATE PROCEDURE sp_set_orc(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_cli int(11),
		IN Icapa boolean,
		IN Idata datetime,
		IN Ivalor double
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_cli = 0)THEN
				DELETE FROM tb_orcamento WHERE id=Iid;
                DELETE FROM tb_orc_prod WHERE id_orc=Iid;
                DELETE FROM tb_orc_texto WHERE id_orc=Iid;
            ELSE
				IF(Iid=0)THEN
					SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
					INSERT INTO tb_orcamento (id_cli,id_owner,capa,data,valor) 
					VALUES (Iid_cli,@id_call,Icapa,Idata,Ivalor);
                    SET @id_orc = (SELECT MAX(id) FROM tb_orcamento);
                    INSERT INTO tb_orc_texto (id_orc,id_texto,valor) SELECT @id_orc , id, valor FROM tb_texto;
				ELSE
					UPDATE tb_orcamento SET id_cli=Iid_cli, capa=Icapa, data=Idata, valor=Ivalor WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_orc_view_item;
DELIMITER $$
	CREATE PROCEDURE sp_orc_view_item(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_orc int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SET SESSION group_concat_max_len = 999999;
			SELECT * FROM vw_orc_item WHERE id_orc = Iid_orc;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_orc_set_item;
DELIMITER $$
	CREATE PROCEDURE sp_orc_set_item(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_orc int(11),
		IN Iid_prod int(11),
        IN Ivalor double
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_orc_prod WHERE id_orc=Iid_orc AND id_prod=Iid_prod);
			IF(@has AND Ivalor=0)THEN
				DELETE FROM tb_orc_prod WHERE id_orc=Iid_orc AND id_prod=Iid_prod;
            ELSE
				SET @valor = (SELECT valor FROM tb_produto WHERE id=Iid_prod);
				IF(Ivalor=0)THEN
					INSERT INTO tb_orc_prod (id_orc,id_prod,valor) 
					VALUES (Iid_orc,Iid_prod,@valor);
				ELSE
					UPDATE tb_orc_prod SET valor = Ivalor WHERE id_orc=Iid_orc AND id_prod=Iid_prod;
				END IF;
            END IF;
            SELECT * FROM vw_tot_orc WHERE id_orc=Iid_orc;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_texto;
DELIMITER $$
	CREATE PROCEDURE sp_view_texto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ititulo varchar(30)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_texto WHERE titulo COLLATE utf8_general_ci LIKE CONCAT('%',Ititulo,'%') COLLATE utf8_general_ci ORDER BY id;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_texto;
DELIMITER $$
	CREATE PROCEDURE sp_set_texto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Ititulo varchar(90),
		IN Itexto varchar(4096),
		IN Ivalor double
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Ititulo = "")THEN
				DELETE FROM tb_texto WHERE id = Iid;
                DELETE FROM tb_orc_texto WHERE id_texto = Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_texto (titulo,texto,valor) 
					VALUES (Ititulo,Itexto,Ivalor);
				ELSE 
					UPDATE tb_texto SET titulo=Ititulo, valor=Ivalor, texto=Itexto WHERE id=Iid ;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_up_texto;
DELIMITER $$
	CREATE PROCEDURE sp_up_texto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid>0)THEN
				UPDATE tb_texto SET id=0 WHERE id=Iid;
                UPDATE tb_texto SET id=Iid WHERE id=(Iid-1);
                UPDATE tb_texto SET id=(Iid-1) WHERE id=0;
            END IF;
        END IF;
        SELECT * FROM tb_texto ORDER BY id;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_orc_view_texto;
DELIMITER $$
	CREATE PROCEDURE sp_orc_view_texto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_orc int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SELECT * FROM vw_orc_texto WHERE id_orc = Iid_orc;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_orc_set_texto;
DELIMITER $$
	CREATE PROCEDURE sp_orc_set_texto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_orc int(11),
		IN Iid_texto int(11),
        IN Ivalor double
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_orc_texto WHERE id_orc=Iid_orc AND id_texto=Iid_texto);
			IF(@has AND Ivalor=0)THEN
				DELETE FROM tb_orc_texto WHERE id_orc=Iid_orc AND id_texto=Iid_texto;
            ELSE
				SET @valor = (SELECT valor FROM tb_texto WHERE id=Iid_texto);
				IF(Ivalor=0)THEN
					INSERT INTO tb_orc_texto (id_orc,id_texto,valor) 
					VALUES (Iid_orc,Iid_texto,@valor);
				ELSE
					UPDATE tb_orc_texto SET valor = Ivalor WHERE id_orc=Iid_orc AND id_texto=Iid_texto;
				END IF;
            END IF;
			SELECT * FROM vw_tot_orc WHERE id_orc=Iid_orc;
        END IF;
	END $$
DELIMITER ;

/* NORMAS */

 DROP PROCEDURE IF EXISTS sp_view_normas;
DELIMITER $$
	CREATE PROCEDURE sp_view_normas(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Inome varchar(120)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SELECT * FROM tb_normas WHERE nome COLLATE utf8_general_ci LIKE CONCAT("%",Inome,"%") COLLATE utf8_general_ci;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_norma;
DELIMITER $$
	CREATE PROCEDURE sp_set_norma(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(120),
        IN Isobre varchar(2048)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome = '')THEN
				DELETE FROM tb_normas WHERE id=Iid;
                DELETE FROM tb_norma_cli WHERE id_norma=Iid;
                DELETE FROM tb_norma_lei WHERE id_norma=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_normas (nome,sobre) 
					VALUES (Inome,Isobre);
				ELSE
					UPDATE tb_normas SET nome=Inome, sobre=Isobre WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_norma_cli;
DELIMITER $$
	CREATE PROCEDURE sp_set_norma_cli(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_norma int(11),
		IN Iid_cliente int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_norma_cli WHERE id_norma=Iid_norma AND id_cliente=Iid_cliente);
			IF(@has)THEN
				DELETE FROM tb_norma_cli WHERE id_norma=Iid_norma AND id_cliente=Iid_cliente;
            ELSE
				INSERT INTO tb_norma_cli (id_norma,id_cliente,expira)
				VALUES (Iid_norma,Iid_cliente,DATE_ADD(CURRENT_TIMESTAMP,INTERVAL 1 MONTH));
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_valida_norma_cli;
DELIMITER $$
	CREATE PROCEDURE sp_valida_norma_cli(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_norma int(11),
		IN Iid_cliente int(11),
        IN Iexpira datetime
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_norma_cli WHERE id_norma=Iid_norma AND id_cliente=Iid_cliente);
			IF(@has)THEN
				UPDATE tb_norma_cli 
                SET expira=Iexpira 
                WHERE id_norma=Iid_norma 
                AND id_cliente=Iid_cliente;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_cli_norma;
DELIMITER $$
	CREATE PROCEDURE sp_view_cli_norma(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_cli int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_cli)THEN
				SELECT * FROM vw_norma_cli WHERE id_cliente=Iid;
            ELSE
				SELECT * FROM vw_norma_cli WHERE id_norma=Iid;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* LEIS */

 DROP PROCEDURE IF EXISTS sp_view_leis;
DELIMITER $$
	CREATE PROCEDURE sp_view_leis(	
		IN Iallow varchar(80),
        IN Ihash varchar(64),
		IN Ifield varchar(30),
		IN Isignal varchar(30),
        IN Ivalue varchar(60)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer = CONCAT('SELECT * FROM tb_leis WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');            
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_lei;
DELIMITER $$
	CREATE PROCEDURE sp_set_lei(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(240),
        IN Iesfera varchar(9),
		IN Iassunto varchar(120),
        IN Iresumo varchar(10240),
		IN Iaplicabilidade varchar(13),
        IN Ilink varchar(500)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome = '')THEN
				DELETE FROM tb_leis WHERE id=Iid;
                DELETE FROM tb_norma_lei WHERE id_lei=Iid;
                DELETE CHK
					FROM tb_check AS CHK
					JOIN tb_tarefas AS TASK 
                    ON CHK.id_tarefa = TASK.id
					WHERE TASK.id_lei = Iid;
                DELETE FROM tb_tarefas WHERE id_lei=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_leis (nome,esfera,assunto,resumo,aplicabilidade,link) 
					VALUES (Inome,Iesfera,Iassunto,Iresumo,Iaplicabilidade,Ilink);
				ELSE
					UPDATE tb_leis 
                    SET nome=Inome,esfera=Iesfera,assunto=Iassunto,resumo=Iresumo,aplicabilidade=Iaplicabilidade,link=Ilink
                    WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_tarefas;
DELIMITER $$
	CREATE PROCEDURE sp_view_tarefas(	
		IN Iallow varchar(80),
        IN Ihash varchar(64),
		IN Iid_lei int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_tarefas WHERE id_lei=Iid_lei;
		END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_tarefa;
DELIMITER $$
	CREATE PROCEDURE sp_set_tarefa(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_lei int(11),
		IN Ipergunta varchar(1024),
        IN Iconhecimento bool
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Ipergunta = '')THEN
				DELETE FROM tb_tarefas WHERE id=Iid;
                DELETE FROM tb_check WHERE id_tarefa=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_tarefas (id_lei,pergunta,conhecimento) 
					VALUES (Iid_lei,Ipergunta,Iconhecimento);
				ELSE
					UPDATE tb_tarefas 
                    SET pergunta=Ipergunta,conhecimento=Iconhecimento
                    WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_norma_lei;
DELIMITER $$
	CREATE PROCEDURE sp_view_norma_lei(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_lei int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_lei)THEN
				SELECT * FROM vw_legis_lei WHERE id_lei=Iid;
            ELSE
				SELECT * FROM vw_legis_lei WHERE id_norma=Iid;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_norma_lei;
DELIMITER $$
	CREATE PROCEDURE sp_set_norma_lei(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_norma int(11),
		IN Iid_lei int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_norma_lei WHERE id_norma=Iid_norma AND id_lei=Iid_lei);
			IF(@has)THEN
				DELETE FROM tb_norma_lei WHERE id_norma=Iid_norma AND id_lei=Iid_lei;
            ELSE
				INSERT INTO tb_norma_lei (id_norma,id_lei)
				VALUES (Iid_norma,Iid_lei);
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_cli_leis;
DELIMITER $$
	CREATE PROCEDURE sp_view_cli_leis(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_cli int(11),
        IN Iid_norma int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			SET @user_allow = (SELECT COUNT(*) FROM tb_user_cli WHERE id_user=@id_call AND id_cliente=Iid_cli);
			IF(@user_allow)THEN
            
 				SELECT id_cliente,id_norma,id_lei,lei,esfera,assunto,resumo,aplicabilidade,link, COUNT(*) AS TOT, SUM(ok) AS ok, ROUND(SUM(ok)/COUNT(*) * 100,2) AS perc
				FROM vw_check_tarefa
                WHERE id_cliente=Iid_cli AND id_norma=Iid_norma
				GROUP BY id_cliente,id_norma, id_lei;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_check_tarefa;
DELIMITER $$
	CREATE PROCEDURE sp_view_check_tarefa(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_cli int(11),
        IN Iid_lei int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			SET @user_allow = (SELECT COUNT(*) FROM tb_user_cli WHERE id_user=@id_call AND id_cliente=Iid_cli);
			IF(@user_allow)THEN
				SELECT * FROM vw_check_tarefa WHERE id_cliente=Iid_cli AND id_lei=Iid_lei
                GROUP BY id_tarefa;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_check_task;
DELIMITER $$
	CREATE PROCEDURE sp_set_check_task(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_cliente int(11),
        IN Iid_tarefa int(11),
		IN Iok bool,
        IN Inao_aplica bool,
        IN Iobs varchar(512),
		IN Ivalidade datetime
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iobs="DELETAR")THEN
				DELETE FROM tb_check WHERE id_cliente=Iid_cliente AND id_tarefa=Iid_tarefa;
            ELSE
                SET @has = (SELECT COUNT(*) FROM tb_check WHERE id_cliente=Iid_cliente AND id_tarefa=Iid_tarefa);
				IF(@has)THEN
					UPDATE tb_check 
                    SET ok=Iok, obs=Iobs, validade=Ivalidade, nao_aplica=Inao_aplica
                    WHERE id_cliente=Iid_cliente AND id_tarefa=Iid_tarefa;
				ELSE
					SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
					INSERT INTO tb_check (id_cliente,id_tarefa,id_resp,ok,nao_aplica,obs,validade) 
					VALUES (Iid_cliente,Iid_tarefa,@id_call,Iok,Inao_aplica,Iobs,Ivalidade);
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;
/*  PAGAMENTOS  */

 DROP PROCEDURE IF EXISTS sp_view_pgto;
DELIMITER $$
	CREATE PROCEDURE sp_view_pgto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_norma int(11),
		IN Iid_cliente int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN            
			SELECT * FROM tb_pgto WHERE id_norma=Iid_norma AND id_cliente=Iid_cliente;
        END IF;
	END $$
DELIMITER ;


 DROP PROCEDURE IF EXISTS sp_set_pgto;
DELIMITER $$
	CREATE PROCEDURE sp_set_pgto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_norma int(11),
		IN Iid_cliente int(11),
		IN Ivalor double,
		IN Imes int
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN

			SET @has = (SELECT COUNT(*) FROM tb_norma_cli WHERE id_cliente=Iid_cliente AND id_norma=Iid_norma);
			IF(@has)THEN
				SET @expira = (SELECT IF(expira < CURRENT_TIMESTAMP,DATE_ADD(CURRENT_TIMESTAMP,INTERVAL Imes MONTH),DATE_ADD(expira,INTERVAL Imes MONTH)) 
								FROM tb_norma_cli 
								WHERE id_cliente=Iid_cliente AND id_norma=Iid_norma);
				
				UPDATE tb_norma_cli 
				SET expira=@expira
				WHERE id_cliente=Iid_cliente AND id_norma=Iid_norma;

				INSERT INTO tb_pgto (id_norma,id_cliente,valor,mes,expira) 
				VALUES (Iid_norma,Iid_cliente,Ivalor,Imes,@expira);
			END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_pgto_plano;
DELIMITER $$
	CREATE PROCEDURE sp_set_pgto_plano(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(50),
		IN Icred_mes int,
		IN Ivalor double,
		IN Itexto varchar(512)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome="")THEN
				DELETE FROM tb_pgto_plano WHERE id=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_pgto_plano (id,nome,cred_mes,valor,texto) 
					VALUES (Iid,Inome,Icred_mes,Ivalor,Itexto);
				ELSE
					UPDATE tb_pgto_plano 
                    SET nome=Inome, cred_mes=Icred_mes, valor=Ivalor, texto=Itexto
                    WHERE id=Iid;                
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_pgto_plano;
DELIMITER $$
	CREATE PROCEDURE sp_view_pgto_plano(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Inome varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN            
			SELECT * FROM tb_pgto_plano WHERE nome COLLATE utf8_general_ci LIKE CONCAT("%",Inome,"%");
        END IF;
	END $$
DELIMITER ;

 /* */
 
  DROP PROCEDURE IF EXISTS sp_view_cli_prod;
DELIMITER $$
	CREATE PROCEDURE sp_view_cli_prod(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_cli int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_cli)THEN
				SELECT * FROM vw_prod_cli WHERE id_cliente=Iid;
            ELSE
				SELECT * FROM vw_prod_cli WHERE id_prod=Iid;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_prod_cli;
DELIMITER $$
	CREATE PROCEDURE sp_set_prod_cli(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_prod int(11),
		IN Iid_cliente int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_prod_cli WHERE id_prod=Iid_prod AND id_cliente=Iid_cliente);
			IF(@has)THEN
				DELETE FROM tb_prod_cli WHERE id_prod=Iid_prod AND id_cliente=Iid_cliente;
            ELSE
				INSERT INTO tb_prod_cli (id_prod,id_cliente,expira)
				VALUES (Iid_prod,Iid_cliente,DATE_ADD(CURRENT_TIMESTAMP,INTERVAL 1 MONTH));
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_task;
DELIMITER $$
	CREATE PROCEDURE sp_view_task(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SET @quer = CONCAT('SELECT * FROM vw_tasks WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
            PREPARE stmt1 FROM @quer;
 			EXECUTE stmt1;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_task;
DELIMITER $$
	CREATE PROCEDURE sp_set_task(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_prod int(11),
		IN Inome varchar(50),
		IN Idesc varchar(255)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome = "")THEN
				DELETE FROM tb_tarefas WHERE id = Iid;
                DELETE FROM tb_perguntas WHERE id_tarefa = Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_tarefas (id_produto,nome,descricao) 
					VALUES (Iid_prod,Inome, Idesc);
				ELSE 
					UPDATE tb_tarefas SET nome=Inome, descricao=Idesc WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_quest;
DELIMITER $$
	CREATE PROCEDURE sp_view_quest(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN   
			SET @quer = CONCAT('SELECT * FROM tb_perguntas WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
            PREPARE stmt1 FROM @quer;
 			EXECUTE stmt1;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_quest;
DELIMITER $$
	CREATE PROCEDURE sp_set_quest(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_tarefa int(11),
        IN Ititulo varchar(150),
		IN Ipergunta varchar(1500),
		IN Irelat boolean
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Ipergunta = "")THEN
                DELETE FROM tb_perguntas WHERE id = Iid;
                DELETE FROM tb_respostas WHERE id_pergunta = Iid;
                DELETE FROM tb_like WHERE id_pergunta = Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_perguntas (id_tarefa,titulo,pergunta,relatorio) 
					VALUES (Iid_tarefa,Ititulo,Ipergunta, Irelat);
				ELSE 
					UPDATE tb_perguntas SET titulo=Ititulo, pergunta=Ipergunta, relatorio=Irelat WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_answer;
DELIMITER $$
	CREATE PROCEDURE sp_view_answer(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_pergunta int(11),
        IN Iid_task_cli int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_answers 
            WHERE id_pergunta=Iid_pergunta 
            AND id_task_cli=Iid_task_cli
            ORDER BY data_hora;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_answer;
DELIMITER $$
	CREATE PROCEDURE sp_set_answer(
		IN Iallow varchar(80),
        IN Ihash varchar(64),
		IN Iid_pergunta int(11),
		IN Iid_task_cli int(11),
		IN Iresposta varchar(512),
		IN Idata_hora datetime
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_usuario = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(Iresposta = "")THEN
                DELETE FROM tb_respostas WHERE id_usuario = @id_usuario AND data_hora=Idata_hora;
                DELETE FROM tb_like WHERE id_pergunta=Iid_pergunta AND data_hora=Idata_hora;
            ELSE
				SET @has = (SELECT COUNT(*) FROM tb_respostas WHERE id_pergunta=Iid_pergunta AND id_task_cli=Iid_task_cli AND data_hora=Idata_hora);
				IF(@has)THEN
					UPDATE tb_respostas SET resposta=Iresposta WHERE id_pergunta=Iid_pergunta AND id_task_cli=Iid_task_cli AND data_hora=Idata_hora;
				ELSE 
					INSERT INTO tb_respostas (id_pergunta,id_task_cli,id_usuario,resposta) 
					VALUES (Iid_pergunta,Iid_task_cli,@id_usuario,Iresposta);
                END IF;
            END IF;
            SELECT * FROM vw_answers 
            WHERE id_pergunta=Iid_pergunta 
            AND id_task_cli=Iid_task_cli
            ORDER BY data_hora;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_like;
DELIMITER $$
	CREATE PROCEDURE sp_set_like(
		IN Iallow varchar(80),
        IN Ihash varchar(64),
		IN Iid_pergunta int(11),
		IN Idata_hora datetime
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_usuario = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
            SET @has = (SELECT COUNT(*) FROM tb_like WHERE id_pergunta=Iid_pergunta AND data_hora=Idata_hora AND id_user_like=@id_usuario);
			IF(@has)THEN
                DELETE FROM tb_like WHERE id_pergunta=Iid_pergunta AND data_hora=Idata_hora AND id_user_like=@id_usuario;
            ELSE
				INSERT INTO tb_like (id_pergunta,data_hora,id_user_like) 
				VALUES (Iid_pergunta,Idata_hora,@id_usuario);
            END IF;
			SELECT GROUP_CONCAT(DISTINCT CONCAT(LK.id_user_like,",",USR.nome)   SEPARATOR "|") AS LIKES
				FROM tb_like AS LK 
                INNER JOIN tb_usuario AS USR 
                ON LK.id_user_like=USR.id 
                WHERE id_pergunta=Iid_pergunta 
                AND data_hora=Idata_hora;
        END IF;
	END $$
DELIMITER ;

  DROP PROCEDURE IF EXISTS sp_view_task_cli;
DELIMITER $$
	CREATE PROCEDURE sp_view_task_cli(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_cli int(11),
        IN Iid_prod int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_cli_task WHERE id_cliente=Iid_cli AND id_produto=Iid_prod;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_task_cli;
DELIMITER $$
	CREATE PROCEDURE sp_set_task_cli(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_task int(11),
		IN Iid_cli int(11),
        IN Ititulo varchar(30),
		IN Icod varchar(10)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid=0) THEN
				INSERT INTO tb_task_cli (id_tarefa,id_cliente,titulo,cod) 
				VALUES (Iid_task,Iid_cli,Ititulo,Icod);
			ELSE
				IF(Ititulo = "") THEN
					DELETE FROM tb_task_cli WHERE id=Iid;
				ELSE
					UPDATE tb_task_cli SET titulo=Ititulo, cod=Icod WHERE id=Iid;
				END IF;
            END IF;
            SELECT * FROM vw_cli_task WHERE id_cliente=Iid_cli AND id_produto=(SELECT id_produto FROM tb_tarefas WHERE id=Iid_task);
        END IF;
	END $$
DELIMITER ;

  DROP PROCEDURE IF EXISTS sp_view_main_answer;
DELIMITER $$
	CREATE PROCEDURE sp_view_main_answer(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_tarefa int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_main_answer WHERE id_tarefa=Iid_tarefa ORDER BY id_pergunta;
        END IF;
	END $$
DELIMITER ;

  DROP PROCEDURE IF EXISTS sp_view_task_rev;
DELIMITER $$
	CREATE PROCEDURE sp_view_task_rev(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_task_cli int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_task_rev WHERE id_task_cli=Iid_task_cli;
        END IF;
	END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_set_task_rev;
DELIMITER $$
	CREATE PROCEDURE sp_set_task_rev(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_task_cli int(11),
		IN Irevisao int,
		IN Ihistorico varchar(50),
        IN Ielab varchar(30),
        IN Iaprov varchar(30)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
        SET @has = (SELECT COUNT(*) FROM tb_task_rev WHERE id_task_cli=Iid_task_cli AND revisao=Irevisao);
			IF(@has) THEN
				IF(Ihistorico = "") THEN
					DELETE FROM tb_task_rev WHERE id_task_cli=Iid_task_cli AND revisao=Irevisao;
				ELSE
					UPDATE tb_task_rev 
                    SET revisao=Irevisao, historico=Ihistorico, elab=Ielab, aprov=Iaprov
                    WHERE id_task_cli=Iid_task_cli AND revisao=Irevisao;
				END IF;  
			ELSE
				SET @id_usuario = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
				INSERT INTO tb_task_rev (id_task_cli,id_usuario,revisao,historico,elab,aprov) 
				VALUES (Iid_task_cli,@id_usuario,Irevisao,Ihistorico,Ielab,Iaprov);
            END IF;
            SELECT * FROM tb_task_rev WHERE id_task_cli=Iid_task_cli;
        END IF;
	END $$
DELIMITER ;

  DROP PROCEDURE IF EXISTS sp_view_task_setor;
DELIMITER $$
	CREATE PROCEDURE sp_view_task_setor(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_task_cli int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_task_setor WHERE id_task_cli=Iid_task_cli;
        END IF;
	END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_set_task_setor;
DELIMITER $$
	CREATE PROCEDURE sp_set_task_setor(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_task_cli int(11),
        IN Isetor varchar(30),
        IN del boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(del) THEN
				DELETE FROM tb_task_setor WHERE id_task_cli = Iid_task_cli AND setor COLLATE utf8_general_ci = Isetor COLLATE utf8_general_ci;
			ELSE
				INSERT INTO tb_task_setor (id_task_cli,setor) 
				VALUES (Iid_task_cli,Isetor)
				ON DUPLICATE KEY UPDATE setor=Isetor;
			END IF;  
            SELECT * FROM tb_task_setor WHERE id_task_cli=Iid_task_cli;
        END IF;
	END $$
DELIMITER ;
