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
	SELECT UCL.*,CLI.fantasia AS cliente,USR.nome 
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

DROP VIEW IF EXISTS vw_lei_norma_cli;
 CREATE VIEW vw_lei_norma_cli AS
	SELECT NCL.id_cliente,LEI.*
	FROM vw_norma_cli AS NCL
	INNER JOIN tb_leis AS LEI
	ON NCL.id_norma = LEI.id_norma;

SELECT * FROM vw_lei_norma_cli; -- WHERE id_cliente=6;

DROP VIEW IF EXISTS vw_check_lei;
 CREATE VIEW vw_check_lei AS
	SELECT NCL.id_cliente, NCL.id_norma, NCL.id AS id_lei, NCL.nome, NCL.ementa, NCL.aplicabilidade,
		IFNULL(CHK.ok,0) AS ok, IFNULL(CHK.obs,'') AS obs, CHK.validade AS expira
		FROM vw_lei_norma_cli AS NCL
		LEFT JOIN tb_check AS CHK
		ON NCL.id = CHK.id_lei
		AND NCL.id_cliente = CHK.id_cliente
		ORDER BY id_cliente, id_norma, id_lei;

SELECT * FROM vw_check_lei;-- WHERE id_cliente=6;