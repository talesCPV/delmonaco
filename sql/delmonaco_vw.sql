/* ORÇAMENTO */

	DROP VIEW IF EXISTS vw_orcamento;
 	CREATE VIEW vw_orcamento AS
	SELECT ORC.id, ORC.id_cli,ORC.id_owner,ORC.capa,ORC.data,CLI.fantasia AS cliente, USR.nome AS owner,
    (SELECT SUM(valor) FROM tb_orc_prod WHERE id_orc=ORC.id) AS valor
	FROM tb_orcamento AS ORC
	INNER JOIN tb_cliente AS CLI
    INNER JOIN tb_usuario AS USR
	ON ORC.id_cli = CLI.id
    AND ORC.id_owner = USR.id;
    
SELECT * FROM vw_orcamento;

DROP VIEW IF EXISTS vw_orc_item;
 CREATE VIEW vw_orc_item AS
	SELECT ORC.id AS id_orc, PROD.id AS id_prod, PROD.nome, ITEM.valor, PROD.sobre
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

SELECT (IFNULL(SUM(ITEM.valor),0) + IFNULL(SUM(TXT.valor),0)) AS valor 
FROM vw_orc_item AS ITEM 
LEFT JOIN vw_orc_texto AS TXT
ON ITEM.id_orc = TXT.id_orc;

SELECT IFNULL(SUM(valor),0) AS valor FROM vw_orc_texto WHERE id_orc=1;