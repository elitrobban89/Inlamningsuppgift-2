-- Del D: Fördjupning (VG)
-- Körs EFTER vetclinic.sql. Ändrar schemat för pet, så Java-klasserna
-- i uppgift 7–8 (som läser pet.species) hör till schemat före Del D.
USE vetclinic;

-- Uppgift 9:
-- Skapa en tabell species och ersätt textkolumnen i pet med en främmande nyckel.

CREATE TABLE species(
                      species_id INT AUTO_INCREMENT PRIMARY KEY,
                      name VARCHAR(30) NOT NULL UNIQUE);

-- Lägg in från pet unika arter
INSERT INTO species (name)
    SELECT DISTINCT species FROM pet;

-- kontroll
SELECT * FROM species;

ALTER TABLE pet
    ADD COLUMN species_id INT;

-- Koppla djur till rätt art genom att matcha texten

UPDATE pet
    JOIN species ON pet.species = species.name
SET pet.species_id =  species.species_id;

-- Kontroll
SELECT * FROM pet;

-- Främmande nyckel och ta bort textkolumnen

ALTER TABLE pet
MODIFY species_id INT NOT NULL,
    ADD FOREIGN KEY(species_id) REFERENCES species(species_id),
 DROP COLUMN species;

-- Kontroll: species-kolumnen är borta och FOREIGN KEY till species finns
SHOW CREATE TABLE pet;
SELECT * FROM pet;
