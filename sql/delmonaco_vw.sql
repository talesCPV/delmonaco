/* ORÇAMENTO */

	DROP VIEW IF EXISTS vw_orcamento;
 	CREATE VIEW vw_orcamento AS
	SELECT ORC.*, CLI.fantasia AS cliente, USR.nome AS owner
	FROM tb_orcamento AS ORC
	INNER JOIN tb_cliente AS CLI
    INNER JOIN tb_usuario AS USR
	ON ORC.id_cli = CLI.id
    AND ORC.id_owner = USR.id;
    
SELECT * FROM vw_orcamento;

DROP VIEW IF EXISTS vw_orc_item;
CREATE VIEW vw_orc_item AS
	SELECT ORC.id AS id_orc, PROD.id AS id_prod, PROD.nome, PROD.valor, PROD.sobre
	FROM tb_produto AS PROD
	INNER JOIN tb_orcamento AS ORC
	INNER JOIN tb_orc_prod AS ITEM
	ON ORC.id = ITEM.id_orc
	AND PROD.id = ITEM.id_prod;
    
SELECT * FROM vw_orc_item;