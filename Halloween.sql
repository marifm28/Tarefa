create schema Halloween;

use Halloween;

CREATE TABLE Usuario (
nome VARCHAR(200),
email VARCHAR(200),
idade INT
);

DELIMITER $$

CREATE PROCEDURE InsereUsuariosAleatorios()
BEGIN
	DECLARE i INT DEFAULT 0;
    
    WHILE i < 1000000 DO
		SET @nome := CONCAT('usuario',i);
		SET @email := CONCAT('usuario',i,'@exemplo.com');
		SET @idade := FLOOR(RAND()*80) + 18;
    
		INSERT INTO Usuario (nome, email, idade) VALUES (@nome, @email, @idade);
        SET i = i +1;
	END WHILE;
END$$

DELIMITER ;

call halloween.InsereUsuariosAleatorios();

select count(*) from usuario;