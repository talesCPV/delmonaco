/* ORÇAMENTO */

	DROP VIEW IF EXISTS vw_orcamento;
 	CREATE VIEW vw_orcamento AS
		SELECT ORC.id, ORC.id_cli,ORC.id_owner,ORC.capa,ORC.data,
		CLI.fantasia AS cliente, USR.nome AS owner,CLI.razao_social,CLI.cnpj,
		IFNULL(TOT.valor,0) AS valor
		FROM tb_orcamento AS ORC
		INNER JOIN tb_cliente AS CLI
		INNER JOIN tb_usuario AS USR
		INNER JOIN vw_tot_orc AS TOT
		ON ORC.id_cli = CLI.id
		AND ORC.id_owner = USR.id
		AND ORC.id = TOT.id_orc;
    
SELECT * FROM vw_orcamento;

DROP VIEW IF EXISTS vw_orc_item;
 CREATE VIEW vw_orc_item AS
	SELECT ORC.id AS id_orc, PROD.id AS id_prod, PROD.nome, ITEM.valor, PROD.sobre,
    (SELECT GROUP_CONCAT(DISTINCT CONCAT(id,"|",nome,"|",texto) SEPARATOR "||") FROM tb_escopo WHERE id_prod=PROD.id) AS escopo
	FROM tb_produto AS PROD
	INNER JOIN tb_orcamento AS ORC
	INNER JOIN tb_orc_prod AS ITEM
	ON ORC.id = ITEM.id_orc
	AND PROD.id = ITEM.id_prod;
    
SELECT * FROM vw_orc_item;

DROP VIEW IF EXISTS vw_orc_texto;
 CREATE VIEW vw_orc_texto AS
	SELECT ORC.id AS id_orc, TXT.id AS id_texto, TXT.titulo, ITEM.valor, TXT.texto
	FROM tb_texto AS TXT
	INNER JOIN tb_orcamento AS ORC
	INNER JOIN tb_orc_texto AS ITEM
	ON ORC.id = ITEM.id_orc
	AND TXT.id = ITEM.id_texto;
    
SELECT * FROM vw_orc_texto;

DROP VIEW IF EXISTS vw_tot_orc_prod;
 CREATE VIEW vw_tot_orc_prod AS
	SELECT ORC.id, IFNULL(SUM(ITEM.valor),0) AS valor
	FROM tb_orcamento AS ORC
	LEFT JOIN tb_orc_prod AS ITEM
	ON ORC.id = ITEM.id_orc
	GROUP BY ORC.id;

SELECT * FROM vw_tot_orc_prod;

DROP VIEW IF EXISTS vw_tot_orc_text;
 CREATE VIEW vw_tot_orc_text AS
	SELECT ORC.id, IFNULL(SUM(TXT.valor),0) AS valor 
	FROM tb_orcamento AS ORC
	LEFT JOIN tb_orc_texto AS TXT
	ON ORC.id = TXT.id_orc
    GROUP BY ORC.id;

SELECT * FROM vw_tot_orc_text;

DROP VIEW IF EXISTS vw_tot_orc;
 CREATE VIEW vw_tot_orc AS
	SELECT PROD.id AS id_orc, (PROD.valor + TXT.valor) AS valor
	FROM vw_tot_orc_prod AS PROD
	INNER JOIN vw_tot_orc_text AS TXT
	ON PROD.id=TXT.id;

SELECT * FROM vw_tot_orc;

DROP VIEW IF EXISTS vw_usr_cli;
 CREATE VIEW vw_usr_cli AS
	SELECT UCL.*,CLI.fantasia AS cliente,USR.nome, CLI.cnpj
	FROM tb_user_cli AS UCL
	INNER JOIN tb_usuario AS USR
	INNER JOIN tb_cliente AS CLI
	ON UCL.id_user=USR.id
	AND UCL.id_cliente = CLI.id;

SELECT * FROM vw_usr_cli;

DROP VIEW IF EXISTS vw_norma_cli;
 CREATE VIEW vw_norma_cli AS
	SELECT NCL.*,CLI.fantasia AS cliente,NOR.nome, NOR.sobre
	FROM tb_norma_cli AS NCL
	INNER JOIN tb_normas AS NOR
	INNER JOIN tb_cliente AS CLI
	ON NCL.id_norma=NOR.id
	AND NCL.id_cliente = CLI.id;

SELECT * FROM vw_norma_cli;

DROP VIEW IF EXISTS vw_legis_lei;
  CREATE VIEW vw_legis_lei AS
	SELECT NLEI.*, NOR.nome AS norma, LEI.nome AS lei, LEI.esfera, LEI.assunto, LEI.resumo, LEI.aplicabilidade, LEI.link
	FROM tb_norma_lei AS NLEI
    INNER JOIN tb_normas AS NOR
	INNER JOIN tb_leis AS LEI
	ON NLEI.id_lei = LEI.id
    AND NLEI.id_norma = NOR.id;
    
SELECT * FROM vw_legis_lei;

DROP VIEW IF EXISTS vw_legis_lei_tarefa;
  CREATE VIEW vw_legis_lei_tarefa AS
	SELECT LEI.id_norma, LEI.id_lei,TRF.id AS id_tarefa,LEI.norma,LEI.lei,LEI.esfera,LEI.assunto,LEI.resumo,LEI.aplicabilidade,LEI.link,TRF.pergunta AS tarefa,TRF.conhecimento
	FROM tb_tarefas AS TRF
	INNER JOIN vw_legis_lei AS LEI
	ON TRF.id_lei=LEI.id_lei
    ORDER BY id_norma, id_lei, id_tarefa;

SELECT * FROM vw_legis_lei_tarefa;

DROP VIEW IF EXISTS vw_tarefa_cliente;
 CREATE VIEW vw_tarefa_cliente AS
	SELECT NCL.id_cliente,LLT.*
	FROM vw_legis_lei_tarefa AS LLT
    INNER JOIN vw_norma_cli AS NCL
	ON LLT.id_norma = NCL.id_norma
    ORDER BY id_cliente, id_norma, id_lei,id_tarefa;

SELECT * FROM vw_tarefa_cliente WHERE id_cliente=2;

DROP VIEW IF EXISTS vw_check_tarefa;
-- CREATE VIEW vw_check_tarefa AS
	SELECT TCL.*,
		IFNULL(IF(CHK.nao_aplica OR (CHK.ok AND (CHK.validade >= CURDATE() OR CHK.validade = "0000-00-00 00:00:00")) AND 1,1,0),0) AS ok,IFNULL(CHK.nao_aplica,0) AS nao_aplica, IFNULL(CHK.obs,'') AS obs, CHK.validade AS expira
		FROM vw_tarefa_cliente AS TCL
		LEFT JOIN tb_check AS CHK
		ON TCL.id_tarefa = CHK.id_tarefa
		AND TCL.id_cliente = CHK.id_cliente
		ORDER BY id_cliente, id_norma, id_lei;

SELECT * FROM vw_check_tarefa;


 DROP VIEW IF EXISTS vw_prod_cli;
  CREATE VIEW vw_prod_cli AS
	SELECT PCL.*,CLI.fantasia AS cliente,PROD.nome, PROD.sobre
	FROM tb_prod_cli AS PCL
	INNER JOIN tb_produto AS PROD
	INNER JOIN tb_cliente AS CLI
	ON PCL.id_prod=PROD.id
	AND PCL.id_cliente = CLI.id;

SELECT * FROM vw_prod_cli;

/*
DROP VIEW IF EXISTS vw_user_legis;
 CREATE VIEW vw_user_legis AS
	SELECT UCL.id_user, NCL.id_norma
	FROM tb_user_cli AS UCL
	INNER JOIN tb_norma_cli AS NCL
	ON UCL.id_cliente = NCL.id_cliente;
    
SELECT * FROM vw_user_legis;
SELECT * FROM vw_legis_lei;
*/

 DROP VIEW IF EXISTS vw_tasks;
	CREATE VIEW vw_tasks AS
	SELECT TASK.*,(SELECT GROUP_CONCAT(DISTINCT CONCAT(id,"|",pergunta) SEPARATOR "||") FROM tb_perguntas WHERE id_tarefa=TASK.id) AS quest FROM tb_tarefas AS TASK;

SELECT * FROM vw_tasks;

SELECT RESP.* 
FROM tb_respostas AS RESP;

 DROP VIEW IF EXISTS vw_answers;
 	CREATE VIEW vw_answers AS
	SELECT RESP.*, USR.nome AS nome_usuario,
    (SELECT GROUP_CONCAT(DISTINCT CONCAT(LK.id_user_like,",",USR.nome)   SEPARATOR "|") FROM tb_like AS LK INNER JOIN tb_usuario AS USR ON LK.id_user_like=USR.id WHERE id_pergunta=RESP.id_pergunta AND data_hora=RESP.data_hora) AS LIKES
	FROM tb_respostas AS RESP
	INNER JOIN tb_usuario AS USR
	ON RESP.id_usuario = USR.id
    ORDER BY data_hora;

SELECT * FROM vw_answers;


 DROP VIEW IF EXISTS vw_cli_task;
 	CREATE VIEW vw_cli_task AS
	SELECT PROD.id AS id_produto,TC.*, CL.fantasia AS cliente, PROD.nome AS produto,TASK.nome AS tarefa, TASK.descricao,
    (SELECT GROUP_CONCAT(DISTINCT CONCAT(id,"|",pergunta) SEPARATOR "||") FROM tb_perguntas WHERE id_tarefa=TASK.id) AS quest
	FROM tb_task_cli AS TC
	INNER JOIN tb_cliente AS CL
	INNER JOIN tb_tarefas AS TASK
    INNER JOIN tb_produto AS PROD
	ON TC.id_cliente=CL.id
	AND TC.id_tarefa = TASK.id
    AND TASK.id_produto = PROD.id;
    
SELECT * FROM vw_cli_task;
SELECT TASK.*,(SELECT GROUP_CONCAT(DISTINCT CONCAT(id,"|",pergunta) SEPARATOR "||") FROM tb_perguntas WHERE id_tarefa=TASK.id) AS quest 
FROM tb_tarefas AS TASK;