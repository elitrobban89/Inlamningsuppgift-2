package org.example.vetclinic;

import jakarta.persistence.*;

/**
 * Klassen är ett djur i tabellen pet
 */
@Entity
@Table(name = "pet")
public class Pet {


    @Id //Primary key i create
    @GeneratedValue(strategy = GenerationType.IDENTITY) //Auto increment i CREATE
    @Column(name = "pet_id")
    private Integer id;

    @Column(name = "owner_id")
    private Integer ownerId;

    @Column(name = "name")
    private String name;

    @Column(name = "species")
    private String species;

    protected Pet () { // Konstruktor - Hibernate behöver denna

    }

    public Integer getId() {
        return id;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public String getName() {
        return name;
    }

    public String getSpecies() {
        return species;
    }

    @Override
    public String toString() {
        return "Pet{" +
                "id=" + id +
                ", ownerId=" + ownerId +
                ", name='" + name + '\'' +
                ", species='" + species + '\'' +
                '}';
    }
}




