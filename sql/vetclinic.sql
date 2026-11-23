-- Uppgift 2: skapa databasen vetclinic (ta bort den först om den finns)
DROP DATABASE IF EXISTS vetclinic;
CREATE DATABASE vetclinic;
USE vetclinic;

-- Ägarna: unika ägare

CREATE TABLE owner(
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
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

-- Besöken
CREATE TABLE visit(
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    visit_date DATE NOT NULL,
    diagnosis VARCHAR(100) NOT NULL,
    fee DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (pet_id) REFERENCES pet(pet_id)
);
