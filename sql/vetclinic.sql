-- Uppgift 2: skapa databasen vetclinic (ta bort den först om den finns)
DROP DATABASE IF EXISTS vetclinic;
CREATE DATABASE vetclinic;
USE vetclinic;

-- Ägarna: unika ägare

CREATE TABLE owner(
    owner_id INT AUTO_INCREMENT PRIMARY_KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE pet(
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(30) NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
);

--Besöken
CREATE TABLE visit(
    owner_id INT AUTO_INCREMENT PRIMARY_KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE
);
