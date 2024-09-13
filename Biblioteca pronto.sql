create schema biblioteca;
 
use biblioteca;
 
create table autor (
id integer primary key,
nome varchar(50),
sobrenome varchar(50));
 
create table livro (
id integer primary key,
titulo varchar (100),
autor varchar (255),
ano_publicacao integer,
constraint id_autor foreign key (id) references autor(id)
);

create table usuario (
id integer primary key,
nome varchar (100),
situacao boolean ,
dt_cod date
);
 
create table reserva (
id integer primary key,
constraint id_livro foreign key (id) references livro(id),
constraint id_usuario foreign key (id) references usuario(id),
dt_reserva date,
dt_devolucao date,
situacao varchar (50)
);
 
create table devolucoes (
id int auto_increment primary key,
id_livro int,
id_usuario int,
data_devolucao date,
data_devolucao_esperada date,
foreign key (id_livro) references livro(id),
foreign key (id_usuario) references usuario(id)
);
 
create table multas (
id int auto_increment primary key,
id_usuario int,
valor_multa decimal (10, 2),
data_multa date,
foreign key (id_usuario) references usuario(id)
);
 
delimiter $$
 
create trigger trigger_VerificarAtrasos
before insert on devolucoes
for each row 
begin
	declare atraso int;
    set atraso = datediff(new.data_devolucao_esperada,
    new.data_devolucao);
    if atraso > 0 then
    insert into mensagens (destinatario, assunto, corpo)
    values ('Bibliotecário', 'Alerta de Atraso', concat('O Livro com ID',
    new.id_livro,'não foi devolvido na data de devolução esperada.'));
    end if;
    end;$$ 
    delimiter //
 
create table mensagens ( 
id int auto_increment primary key,
destinatario varchar(225) not null,
assunto varchar(225) not null, 
corpo text, 
data_envio datetime default 
current_timestamp);

delimiter $$
create trigger trigger_gerar_multa2 after insert on devolucoes for each row
begin
	declare atraso int;
    declare valor_multa decimal (10, 2);
    set atraso = datediff(new.data_devolucao_esperada, new.data_devolucao);
	if atraso > 0 then 
		set valor_multa = atraso * 2.00;
		insert into multas (id_usuario, valor_multa, data_multa)
		values (new.id_usuario, valor_multa, now());
	end if;
end;$$
delimiter //

create table emprestimo (
id int auto_increment primary key,
status_livro varchar (20),
id_livro int,
id_usuario int,
foreign key (id_livro) references livro(id),
foreign key (id_usuario) references usuario(id)
);

delimiter $$
create trigger trigger_atualizar_status_emprestado after insert on emprestimo for each row 
begin
	update livro 
    set status_livro = "Emprestado"
    where id = new.id_livro;
end;$$
delimiter //

delimiter $$
create trigger trigger_atualizar_total_exemplares after insert on livro for each row
begin
	update livro 
    set total_exemplares = total_exemplares + 1
    where id = new.id;
    end;$$
delimiter // 

create table livros_atualizados(
id int auto_increment primary key,
id_livro int not null,
titulo varchar (100) not null,
autor varchar (100) not null,
data_atualizacao datetime default current_timestamp,
foreign key (id_livro) references livro(id)
);

create table autor_livro(
id_livro int,
id_autor int,
foreign key (id_livro) references livro(id),
foreign key (id_autor) references autor(id)
);

delimiter $$
create trigger trigger_registrar_atualizacao_livro after update on livro for each row
begin
	insert into livros_atualizados (id_livro, titulo, autor, data_atualizacao) 
    values (old.id, old.titulo, old.autor, now());
end;$$
delimiter // 

delimiter $$
create trigger trigger_registrar_exclusao_livro after delete on livro for each row
begin
 
insert into livros_excluidos (id_livro, titulo, autor, data_exclusao)

values( old.id, old.titulo,now());

end;$$
delimiter //

DELIMITER $$

CREATE FUNCTION contar_livros_reservados (data_inicio DATE, data_fim DATE) RETURNS INT BEGIN DECLARE total INT;

SELECT
  COUNT(*) INTO total
FROM
  reserva
WHERE
  dt_reserva BETWEEN data_inicio AND data_fim;

RETURN total;

END;$$

DELIMITER //

DELIMITER $$
CREATE FUNCTION contar_livros_devolvidos (data_inicio DATE, data_fim DATE) RETURNS INT BEGIN DECLARE total INT;

SELECT
  COUNT(*) INTO total
FROM
  devolucoes
WHERE
  data_devolucao BETWEEN data_inicio AND data_fim;

RETURN total;

END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION media_multas (data_inicio DATE, data_fim DATE) RETURNS DECIMAL(10, 2) BEGIN DECLARE media DECIMAL(10, 2);

SELECT
  AVG(valor_multa) INTO media
FROM
  multas
WHERE
  data_multa BETWEEN data_inicio AND data_fim;

RETURN media;

END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION contar_livros_emprestados (id_usuario INT) RETURNS INT BEGIN DECLARE total INT;

SELECT
  COUNT(*) INTO total
FROM
  emprestimo
WHERE
  id_usuario = id_usuario;

RETURN total;

END;$$

DELIMITER //

DELIMITER $$
CREATE FUNCTION verificar_disponibilidade_livro (id_livro INT) RETURNS BOOLEAN BEGIN DECLARE disponivel BOOLEAN;

SELECT
  CASE
    WHEN status_livro = 'Disponível' THEN TRUE
    ELSE FALSE
  END INTO disponivel
FROM
  livro
WHERE
  id = id_livro;

RETURN disponivel;

END;$$

DELIMITER //

DELIMITER $$
CREATE FUNCTION total_multas_usuario (id_usuario INT) RETURNS DECIMAL(10, 2) BEGIN DECLARE total DECIMAL(10, 2);

SELECT
  SUM(valor_multa) INTO total
FROM
  multas
WHERE
  id_usuario = id_usuario;

RETURN total;

END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION contar_livros_autor (id_autor INT) RETURNS INT BEGIN DECLARE total INT;

SELECT
  COUNT(*) INTO total
FROM
  livro l
  JOIN autor_livro al ON l.id = al.id_livro
WHERE
  al.id_autor = id_autor;

RETURN total;

END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION contar_reservas_ativas_usuario (id_usuario INT) RETURNS INT BEGIN DECLARE total INT;

SELECT
  COUNT(*) INTO total
FROM
  reserva
WHERE
  id_usuario = id_usuario
  AND situacao = 'Ativa';

RETURN total;

END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION total_exemplares_livro (id_livro INT) RETURNS INT BEGIN DECLARE total INT;

SELECT
  total_exemplares INTO total
FROM
  livro
WHERE
  id = id_livro;

RETURN total;

END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION contar_livros_emprestados_periodo (data_inicio DATE, data_fim DATE) RETURNS INT BEGIN DECLARE total INT;

SELECT
  COUNT(*) INTO total
FROM
  emprestimo
WHERE
  dt_emprestimo BETWEEN data_inicio AND data_fim;

RETURN total;

END;$$

DELIMITER //