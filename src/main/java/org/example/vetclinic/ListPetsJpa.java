package org.example.vetclinic;

import jakarta.persistence.EntityManager;

import java.util.List;

/**
 * Listar alla djur i databasen med JPA/Hibernate
 */
public class ListPetsJpa {
    static void main() {
        try (EntityManager em = Database.createEntityManager()) {
            List<Pet> pets = em.createQuery("SELECT p FROM Pet p", Pet.class).getResultList();
            for (Pet pet : pets) {
                System.out.println(pet.getId() + " | " +
                        pet.getOwnerId() + " | " + pet.getName() + " | " + pet.getSpecies());
            }
        } finally {
            Database.close();
        }
    }
}
