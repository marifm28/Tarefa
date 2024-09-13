CREATE SCHEMA Teatro;

USE Teatro;

CREATE TABLE pecas_teatro (
id_peca INT PRIMARY KEY AUTO_INCREMENT,
nome_peca VARCHAR(100) NOT NULL,
descricao TEXT,
duracao INT NOT NULL,
data_estreia DATE,
diretor VARCHAR(100),
elenco TEXT
);

INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
VALUES
  (
    'Romeu e Julieta',
    'Uma tragédia escrita por William Shakespeare.',
    120,
    '2023-11-01',
    'João Silva',
    'Ana Clara, Pedro Paulo, Maria Fernanda'
  ),
  (
    'Hamlet',
    'Uma das mais conhecidas peças de William Shakespeare.',
    150,
    '2023-12-05',
    'Carlos Souza',
    'Ricardo Pereira, Juliana Alves, Marcos Vinicius'
  ),
  (
    'O Rei Leão',
    'Uma adaptação musical do filme da Disney.',
    90,
    '2024-01-10',
    'Fernanda Lima',
    'Lucas Santos, Beatriz Costa, Thiago Oliveira'
  ),
  (
    'A Megera Domada',
    'Uma comédia de William Shakespeare.',
    110,
    '2024-02-15',
    'Mariana Duarte',
    'Paulo Henrique, Camila Mendes, Renata Souza'
  ),
  (
    'Macbeth',
    'Uma tragédia de William Shakespeare sobre ambição e poder.',
    130,
    '2024-03-20',
    'Roberto Lima',
    'Gustavo Silva, Daniela Castro, Felipe Martins'
  );

DELIMITER $$

CREATE FUNCTION calcular_media_duracao (id_peca INT) RETURNS FLOAT BEGIN DECLARE media_duracao FLOAT;
SELECT
  AVG(duracao) INTO media_duracao
FROM
  teatro
WHERE
  id_peca = id_peca;
RETURN media_duracao;
END;$$

DELIMITER //

DELIMITER $$

CREATE FUNCTION verificar_disponibilidade (data_hora DATETIME) RETURNS BOOLEAN BEGIN DECLARE disponibilidade BOOLEAN;

IF EXISTS (
  SELECT
    1
  FROM
    pecas_teatro
  WHERE
    data_estreia = DATE(data_hora)
) THEN
SET
  disponibilidade = FALSE;

ELSE
SET
  disponibilidade = TRUE;

END IF;

RETURN disponibilidade;

END;$$

DELIMITER //

DELIMITER $$

CREATE PROCEDURE agendar_peca(
  IN nome_peca VARCHAR(100),
  IN descricao TEXT,
  IN duracao INT,
  IN data_estreia DATE,
  IN diretor VARCHAR(100),
  IN elenco TEXT
)
BEGIN
  DECLARE disponibilidade BOOLEAN;
  DECLARE media_duracao FLOAT;

  SET disponibilidade = verificar_disponibilidade(data_estreia);

  IF disponibilidade THEN

    INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
    VALUES (nome_peca, descricao, duracao, data_estreia, diretor, elenco);

    SET media_duracao = (SELECT AVG(duracao) FROM pecas_teatro);
    
    SELECT
      nome_peca AS Nome,
      descricao AS Descricao,
      duracao AS Duracao,
      data_estreia AS Data_Estreia,
      diretor AS Diretor,
      elenco AS Elenco,
      media_duracao AS Media_Duracao
    FROM
      pecas_teatro
    WHERE
      id_peca = LAST_INSERT_ID();
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data não disponível para agendamento.';
  END IF;
END;$$

DELIMITER //

CALL agendar_peca (
	'A Megera Domada',
    'Uma comédia de William Shakespeare.',
    110,
    '2024-10-15',
    'Mariana Duarte',
    'Paulo Henrique, Camila Mendes, Renata Souza'
);

CALL agendar_peca (
  'Hamlet',
    'Uma das mais conhecidas peças de William Shakespeare.',
    150,
    '2023-10-24',
    'Carlos Souza',
    'Ricardo Pereira, Juliana Alves, Marcos Vinicius'
);