/* ORÇAMENTO */

	DROP VIEW IF EXISTS vw_orcamento;
	CREATE VIEW vw_orcamento AS
	SELECT ORC.*, CLI.fantasia AS cliente
	FROM tb_orcamento AS ORC
	INNER JOIN tb_cliente AS CLI
	ON ORC.id_cli = CLI.id;
    
SELECT * FROM vw_orcamento;    