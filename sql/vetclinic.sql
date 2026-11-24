-- Uppgift 2: skapa databasen vetclinic (ta bort den först om den finns)
DROP DATABASE IF EXISTS vetclinic;
CREATE DATABASE vetclinic;
USE vetclinic;

-- Ägare: varje ägare lagras en gång, telefonnumret är unikt
CREATE TABLE owner(
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE
);

-- Djur: varje djur tillhör en ägare, species lagras som text
CREATE TABLE pet(
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(30) NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
);

-- Besök: varje besök gäller ett djur
CREATE TABLE visit(
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    visit_date DATE NOT NULL,
    diagnosis VARCHAR(100) NOT NULL,
    fee DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (pet_id) REFERENCES pet(pet_id)
);

-- Uppgift 3: lägg in datan, varje ägare/djur/besök bara en gång
-- owner_id: 1 = Anna, 2 = Erik, 3 = Sara, 4 = jag själv
-- Då vi har Auto Increment så sköts owner_id automatiskt i create table ovanför
INSERT INTO owner (name, phone) VALUES
    ('Anna Berg', '070-111 11 11'),
    ('Erik Holm', '070-222 22 22'),
    ('Sara Lind', '070-333 33 33'),
    ('Robert Andersson', '0739 99 99 99');

-- pet_id: 1 = Rex, 2 = Misse, 3 = Bella, 4 = Pelle, 5 = mitt djur
-- Då vi har Auto Increment så sköts pet_id automatiskt i create table ovanför
INSERT INTO pet (owner_id, name, species) VALUES
    (1, 'Rex',   'Hund'),
    (1, 'Misse', 'Katt'),
    (2, 'Bella', 'Hund'),
    (3, 'Pelle', 'Kanin'),
    (4, 'Gekko', 'Kronbärande gecko');

INSERT INTO visit (pet_id, visit_date, diagnosis, fee) VALUES
    (1, '2026-01-10', 'Vaccination',      450),
    (1, '2026-03-02', 'Klokklippning',    150),
    (2, '2026-02-14', 'Öroninflammation', 600),
    (3, '2026-01-20', 'Hälta',            800),
    (3, '2026-04-05', 'Kontroll',         300),
    (4, '2026-02-28', 'Tandkontroll',     350);

-- Kontroll: förväntat owner = 4, pet = 5, visit = 6
SELECT COUNT(*) AS antal_owner FROM owner;
SELECT COUNT(*) AS antal_pet   FROM pet;
SELECT COUNT(*) AS antal_visit FROM visit;

-- Uppgift 4: constraints
-- pet.name NOT NULL och owner.phone UNIQUE finns redan i CREATE TABLE ovan.
-- Det som saknas är att avgiften inte får vara negativ:
ALTER TABLE visit
    ADD CONSTRAINT chk_visit_fee CHECK (fee >= 0);

-- Kontroll: visa hur tabellerna ser ut nu
SHOW CREATE TABLE owner;
SHOW CREATE TABLE pet;
SHOW CREATE TABLE visit;
