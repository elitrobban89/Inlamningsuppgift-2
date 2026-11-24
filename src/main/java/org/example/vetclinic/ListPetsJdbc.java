package org.example.vetclinic;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Javaklassen som ska lista alla djur i databasen med ren JDBC
 */
public class ListPetsJdbc {

    public static void main(String[] args) throws SQLException {
        String sql = "SELECT pet_id, owner_id, name, species FROM pet";
        try (Connection c = Database.getConnection();
             PreparedStatement stmt = c.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                System.out.println(rs.getInt("pet_id") + " | " +
                        rs.getInt("owner_id") + " | " + rs.getString("name") + " | " + rs.getString("species"));
            }
        }
    }
}
