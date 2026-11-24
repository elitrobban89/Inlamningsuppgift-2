package org.example.vetclinic;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Hittar husdjur
 */
public class FindPetsJdbc {
    static void main() throws SQLException {
        System.out.println("Söker efter Rex:");
        findPetsByName("Rex");

        System.out.println("Försök till SQL-injektion:");
        findPetsByName("' OR '1'='1"); //Injection försök att den ska tolka sökning som sql
    }

    public static void findPetsByName(String name) throws SQLException {
        // Strängkonkatenering är farligt (SQL-injektion). Därför används ? och setString,
        // så att namnet alltid behandlas som data och aldrig tolkas som ett SQL-kommando.
        String sql = "SELECT pet_id, owner_id, name, species FROM pet WHERE name = ?";
        try (Connection c = Database.getConnection();
             PreparedStatement stmt = c.prepareStatement(sql)) {
            stmt.setString(1, name);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int petId = rs.getInt("pet_id");
                    int ownerId = rs.getInt("owner_id");
                    String petName = rs.getString("name");
                    String species = rs.getString("species");
                    System.out.println("Pet ID: " + petId + ", Owner ID: " + ownerId + ", Name: " + petName + ", Species: " + species);
                }
            }
        }
    }
}
