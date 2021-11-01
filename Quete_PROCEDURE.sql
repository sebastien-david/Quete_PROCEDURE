DROP DATABASE IF EXISTS SectTracking
GO
CREATE DATABASE SectTracking
GO

USE SectTracking

CREATE TABLE Address(address_id INT PRIMARY KEY IDENTITY(1,1),
                     street_number INT,
                     street_name VARCHAR(120) NOT NULL)
CREATE TABLE Sect(sect_id INT PRIMARY KEY IDENTITY(1,1),
                  name VARCHAR(60) NOT NULL)
CREATE TABLE Adherent(adherent_id INT PRIMARY KEY IDENTITY(1,1),
                      name VARCHAR(60))
CREATE TABLE SectAdherent(sect_adherent_id INT PRIMARY KEY IDENTITY(1,1),
                          FK_adherent_id INT NOT NULL,
                          FOREIGN KEY (FK_adherent_id) REFERENCES Adherent(adherent_id),
                          FK_sect_id INT NOT NULL,
                          FOREIGN KEY (FK_sect_id) REFERENCES Sect(sect_id))
GO

INSERT INTO Sect(name) VALUES ('Le Concombre Sacré'), ('Tomatologie'), ('Les abricots volant')
GO

DECLARE Sect_Cursor CURSOR SCROLL FOR
   SELECT sect_id FROM Sect
DECLARE @LastAdherentId INT
DECLARE @SectId INT
WHILE (SELECT COUNT(*) FROM SectAdherent) < 30
   BEGIN
      OPEN Sect_Cursor
      FETCH FIRST FROM Sect_Cursor INTO @SectId
      WHILE @@FETCH_STATUS = 0
         BEGIN
            INSERT INTO Adherent(name) VALUES(NULL)
            SET @LastAdherentId = (SELECT TOP(1) adherent_id FROM Adherent ORDER BY adherent_id DESC)
            INSERT INTO SectAdherent(FK_adherent_id, FK_sect_id) VALUES (@LastAdherentId, @SectId)
            FETCH NEXT FROM Sect_Cursor INTO @SectId
         END
      CLOSE Sect_Cursor
   END
DEALLOCATE Sect_Cursor
GO

CREATE OR ALTER PROCEDURE sp_NombreAdherentsParSecte
	AS
		BEGIN
			SELECT Sect.name AS "Nom de la secte", COUNT(SectAdherent.sect_adherent_id) AS "Nombre d'adhérents"
			FROM SectAdherent
			INNER JOIN Sect
			ON FK_sect_id = sect_id
			GROUP BY Sect.name
		END
GO

EXECUTE sp_NombreAdherentsParSecte
GO

CREATE OR ALTER PROCEDURE sp_AssociationAdherentSecte
	AS
		BEGIN
			SELECT Sect.name AS "Nom de la secte", SectAdherent.FK_adherent_id AS "Adhérent id"
						FROM SectAdherent
						INNER JOIN Sect
						ON FK_sect_id = sect_id
		END
GO

EXECUTE sp_AssociationAdherentSecte
GO

CREATE OR ALTER PROCEDURE sp_NombreSectes
@NombreSectes INT OUTPUT
	AS
		SELECT @NombreSectes = COUNT(Sect.sect_id)
		FROM Sect
GO

DECLARE @Sectes INT
EXECUTE sp_NombreSectes
	@NombreSectes = @Sectes OUTPUT
PRINT @Sectes
GO