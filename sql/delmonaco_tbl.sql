 DROP TABLE IF EXISTS tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) NOT NULL,
    hash varchar(64) NOT NULL,
    nome varchar(30) NOT NULL DEFAULT "",
    token varchar(64) DEFAULT NULL,
    access int(11) DEFAULT -1,
    cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	UNIQUE KEY (hash),
	UNIQUE KEY (email),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- ALTER TABLE tb_usuario ADD expira TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
	INSERT INTO tb_usuario (email,hash,access,nome)VALUES("tales@planet3.com.br","b494f6a8b457c58f8feaac439d771a15045337826d72be5b14bb2f224dc7eb39",0,"Developer");
-- UPDATE tb_usuario SET nome="Tales C. Dantas" WHERE id=1;

 DROP TABLE IF EXISTS tb_usr_perm_perfil;
CREATE TABLE tb_usr_perm_perfil (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    perm varchar(50) NOT NULL DEFAULT "0",
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_mail;
CREATE TABLE tb_mail (
	data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    id_from int(11) NOT NULL,
    id_to int(11) NOT NULL,
    message varchar(1000),
    looked boolean DEFAULT 0,
    FOREIGN KEY (id_from) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (id_to) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (data,id_from)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_calendario;
CREATE TABLE tb_calendario (
    id_user int(11) NOT NULL,
    data_agd date NOT NULL,
    obs varchar(255),
    PRIMARY KEY (id_user,data_agd)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* FIM PADRÂO */

DROP TABLE IF EXISTS tb_cliente;
CREATE TABLE tb_cliente(
    id int(11) NOT NULL AUTO_INCREMENT,
    razao_social varchar(80) NOT NULL,
    fantasia varchar(40) DEFAULT null,
    cnpj varchar(14) DEFAULT NULL,
    ie varchar(14) DEFAULT NULL,
    im varchar(14) DEFAULT NULL,
    end varchar(60) DEFAULT NULL,
	num varchar(6) DEFAULT NULL,
    comp varchar(50) DEFAULT NULL,
    bairro varchar(60) DEFAULT NULL,
    cidade varchar(30) DEFAULT NULL,
    uf varchar(2) DEFAULT NULL,
    cep varchar(10) DEFAULT NULL,
    ramo varchar(80) DEFAULT NULL,
    tel varchar(15) DEFAULT NULL,
    email varchar(80) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_user_cli;
CREATE TABLE tb_user_cli(
    id_user int(11) NOT NULL,
    id_cliente int(11) NOT NULL,
    access int DEFAULT 1,
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    PRIMARY KEY (id_user,id_cliente)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/*
 DROP TABLE tb_colaborador;
CREATE TABLE tb_colaborador (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL DEFAULT "",
    nasc date DEFAULT NULL,
    rg varchar(15) DEFAULT NULL,
    cpf varchar(15) DEFAULT NULL,
    pis varchar(15) DEFAULT NULL,
    end varchar(60) DEFAULT NULL,
    num varchar(6) DEFAULT NULL,
    cidade varchar(30) DEFAULT NULL,
    bairro varchar(40) DEFAULT NULL,
    uf varchar(2) DEFAULT NULL,
    cep varchar(10) DEFAULT NULL,    
    data_adm date DEFAULT NULL,
	data_dem date DEFAULT NULL,
    id_cargo int(11) DEFAULT 0,
	id_setor int(11) DEFAULT 0,
    tel varchar(15) DEFAULT NULL,
    cel varchar(15) DEFAULT NULL,
    ativo boolean DEFAULT 1,
	obs varchar(200) DEFAULT NULL,
    reg VARCHAR(5) DEFAULT "0",
    nick VARCHAR(20) DEFAULT "",
    PRIMARY KEY (id),
    FOREIGN KEY (id_setor) REFERENCES tb_setores(id),
    FOREIGN KEY (id_cargo) REFERENCES tb_cargos(id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8; 
*/

/* PRODUTO */

DROP TABLE IF EXISTS tb_produto;
CREATE TABLE tb_produto(
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    valor double NOT NULL DEFAULT 0,
    sobre varchar(1024) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_escopo;
CREATE TABLE tb_escopo(
    id int(11) NOT NULL AUTO_INCREMENT,
    id_prod int(11) NOT NULL,
    nome varchar(30) NOT NULL,
    texto varchar(2048) NOT NULL DEFAULT "",
	FOREIGN KEY (id_prod) REFERENCES tb_produto(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* ORÇAMENTOS */

DROP TABLE IF EXISTS tb_orcamento;
CREATE TABLE tb_orcamento(
    id int(11) NOT NULL AUTO_INCREMENT,
    id_cli int(11) NOT NULL,
    id_owner int(11) NOT NULL,
    capa boolean DEFAULT 0,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor double NOT NULL DEFAULT 0,
	FOREIGN KEY (id_cli) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    FOREIGN KEY (id_owner) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_texto;
CREATE TABLE tb_texto(
    id int(11) NOT NULL AUTO_INCREMENT,
    titulo varchar(90) NOT NULL,
    texto varchar(4096) NOT NULL DEFAULT "",
    valor double NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_orc_prod;
CREATE TABLE tb_orc_prod(
    id_orc int(11) NOT NULL,
    id_prod int(11) NOT NULL,
    valor double NOT NULL DEFAULT 0,
    FOREIGN KEY (id_orc) REFERENCES tb_orcamento(id) ON DELETE CASCADE,
    FOREIGN KEY (id_prod) REFERENCES tb_produto(id) ON DELETE CASCADE,
    PRIMARY KEY (id_orc,id_prod)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_orc_texto;
CREATE TABLE tb_orc_texto(
    id_orc int(11) NOT NULL,
    id_texto int(11) NOT NULL,
    valor double NOT NULL DEFAULT 0,
    FOREIGN KEY (id_orc) REFERENCES tb_orcamento(id) ON DELETE CASCADE,
    FOREIGN KEY (id_texto) REFERENCES tb_texto(id) ON DELETE CASCADE,
    PRIMARY KEY (id_orc,id_texto)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* NORMAS */

DROP TABLE IF EXISTS tb_normas;
CREATE TABLE tb_normas(
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(120) NOT NULL,
    sobre varchar(2048) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 ALTER TABLE tb_normas DROP COLUMN resumo;
-- ALTER TABLE tb_normas ADD COLUMN link varchar(500) DEFAULT NULL;

DROP TABLE IF EXISTS tb_leis;
CREATE TABLE tb_leis(
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(240) NOT NULL,
	esfera varchar(9) NOT NULL DEFAULT "FEDERAL",
    assunto varchar(120) DEFAULT NULL,
	resumo varchar(10240) DEFAULT NULL,
    aplicabilidade varchar(13) DEFAULT "NÃO APLICÁVEL",
	link varchar(500) DEFAULT NULL,
    revogada bool DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_tarefas;
CREATE TABLE tb_tarefas(
    id int(11) NOT NULL AUTO_INCREMENT,
    id_lei int(11) NOT NULL,
    pergunta varchar(1024) NOT NULL,
    conhecimento bool DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_norma_cli;
CREATE TABLE tb_norma_cli(
    id_norma int(11) NOT NULL,
    id_cliente int(11) NOT NULL,
    expira TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_norma) REFERENCES tb_normas(id) ON DELETE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    PRIMARY KEY (id_norma,id_cliente)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- ALTER TABLE tb_norma_cli ADD COLUMN expira TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

DROP TABLE IF EXISTS tb_norma_lei;
CREATE TABLE tb_norma_lei(
    id_norma int(11) NOT NULL,
    id_lei int(11) NOT NULL,
	FOREIGN KEY (id_norma) REFERENCES tb_normas(id) ON DELETE CASCADE,
    FOREIGN KEY (id_lei) REFERENCES tb_leis(id) ON DELETE CASCADE,
    PRIMARY KEY (id_norma,id_lei)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_check;
CREATE TABLE tb_check(
    id_cliente int(11) NOT NULL,
    id_tarefa int(11) NOT NULL,
    id_resp int(11) NOT NULL,
    ok bool DEFAULT 0,
    nao_aplica BOOL DEFAULT 0,
    obs VARCHAR(512) DEFAULT NULL,
    validade TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tarefa) REFERENCES tb_tarefas(id) ON DELETE CASCADE,
    FOREIGN KEY (id_resp) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (id_cliente,id_tarefa)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

INSERT INTO tb_check (id_cliente,id_tarefa,id_resp,ok) VALUES (2,3,1,1);

-- ALTER TABLE tb_check DROP COLUMN aplicavel;
-- ALTER TABLE tb_check ADD COLUMN nao_aplica BOOL DEFAULT 0;
--  ALTER TABLE tb_check CHANGE COLUMN validade_timestamp BIGINT NOT NULL DEFAULT CURRENT_TIMESTAMP;

DROP TABLE IF EXISTS tb_pgto;
CREATE TABLE tb_pgto(
	id int(11) NOT NULL AUTO_INCREMENT,
    id_norma int(11) NOT NULL,
    id_cliente int(11) NOT NULL,
    valor double NOT NULL,
    mes int DEFAULT 0,
    expira datetime DEFAULT NULL,
    efetuado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    FOREIGN KEY (id_norma) REFERENCES tb_normas(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_pgto_plano;
CREATE TABLE tb_pgto_plano(
	id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(50) NOT NULL,
    cred_mes int NOT NULL,
    valor double NOT NULL DEFAULT 0,
    texto varchar(512) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- Gestão de Processos

-- Tarefas

DROP TABLE IF EXISTS tb_tarefas;
CREATE TABLE tb_tarefas(
	id int(11) NOT NULL AUTO_INCREMENT,
    id_produto int(11) NOT NULL,
    nome varchar(50) NOT NULL,
    descricao varchar(255) DEFAULT NULL,
	FOREIGN KEY (id_produto) REFERENCES tb_produto(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_perguntas;
CREATE TABLE tb_perguntas(
	id int(11) NOT NULL AUTO_INCREMENT,
    id_tarefa int(11) NOT NULL,
    titulo varchar(150) DEFAULT NULL,
    pergunta varchar(1500) NOT NULL,
    relatorio boolean DEFAULT 1,
	FOREIGN KEY (id_tarefa) REFERENCES tb_tarefas(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_task_cli;
CREATE TABLE tb_task_cli(
	id int(11) NOT NULL AUTO_INCREMENT,
    id_tarefa int(11) NOT NULL,
    id_cliente int(11) NOT NULL,
    titulo varchar(30) NOT NULL,
    cod varchar(10) DEFAULT NULL,
    ok boolean DEFAULT 0,
	FOREIGN KEY (id_tarefa) REFERENCES tb_tarefas(id) ON DELETE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_respostas;
CREATE TABLE tb_respostas(
    id_pergunta int(11) NOT NULL,
    id_task_cli int(11) NOT NULL,
    id_usuario int(11) NOT NULL,
    resposta varchar(512) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_pergunta) REFERENCES tb_perguntas(id) ON DELETE CASCADE,
	FOREIGN KEY (id_task_cli) REFERENCES tb_task_cli(id) ON DELETE CASCADE,
	FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (id_pergunta,id_task_cli,id_usuario,data_hora)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_like;
CREATE TABLE tb_like(
    id_pergunta int(11) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_user_like int(11) NOT NULL,
	FOREIGN KEY (id_pergunta) REFERENCES tb_perguntas(id) ON DELETE CASCADE,
	FOREIGN KEY (id_user_like) REFERENCES tb_usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (id_pergunta,id_user_like,data_hora)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_prod_cli;
CREATE TABLE tb_prod_cli(
    id_prod int(11) NOT NULL,
    id_cliente int(11) NOT NULL,
    expira TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_prod) REFERENCES tb_produto(id) ON DELETE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id) ON DELETE CASCADE,
    PRIMARY KEY (id_prod,id_cliente)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_task_rev;
CREATE TABLE tb_task_rev(
    id_task_cli int(11) NOT NULL,
    id_usuario int(11) NOT NULL,
    revisao int NOT NULL DEFAULT 0,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    historico varchar(50) NOT NULL,
    elab varchar(30) DEFAULT NULL,
    aprov varchar(30) DEFAULT NULL,
	FOREIGN KEY (id_task_cli) REFERENCES tb_task_cli(id) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id),
    PRIMARY KEY (id_task_cli,revisao)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_task_setor;
CREATE TABLE tb_task_setor(
    id_task_cli int(11) NOT NULL,
    setor varchar(20) NOT NULL,
	FOREIGN KEY (id_task_cli) REFERENCES tb_task_cli(id) ON DELETE CASCADE,
    PRIMARY KEY (id_task_cli,setor)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;