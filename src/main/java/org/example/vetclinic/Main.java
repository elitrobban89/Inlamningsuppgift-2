package org.example.vetclinic;

import jakarta.persistence.EntityManager;

public class Main {
    public static void main(String[] args) {
        try (EntityManager em = Database.createEntityManager()) {
            Object version = em.createNativeQuery("SELECT VERSION()").getSingleResult();
            Object schema = em.createNativeQuery("SELECT DATABASE()").getSingleResult();
            System.out.println("Ansluten till MySQL " + version + ", databas: " + schema);
        } finally {
            Database.close();
        }
    }
}
