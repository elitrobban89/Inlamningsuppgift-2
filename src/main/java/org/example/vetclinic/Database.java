package org.example.vetclinic;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

/**
 * Håller en EntityManagerFactory mot MySQL-databasen i Docker.
 * Anslutningsuppgifter läses från miljövariabler eller filen .env i projektroten
 * (DB_URL, DB_USER, DB_PASSWORD), så att lösenord aldrig hamnar i git.
 */
public final class Database {

    private static final EntityManagerFactory EMF = createFactory();

    private Database() {
    }

    public static EntityManager createEntityManager() {
        return EMF.createEntityManager();
    }

    public static void close() {
        if (EMF.isOpen()) {
            EMF.close();
        }
    }

    private static EntityManagerFactory createFactory() {
        Map<String, String> env = loadDotEnv();
        Map<String, Object> props = new HashMap<>();
        props.put("jakarta.persistence.jdbc.url",
                setting(env, "DB_URL", "jdbc:mysql://localhost:3306/vetclinic"));
        props.put("jakarta.persistence.jdbc.user", setting(env, "DB_USER", null));
        props.put("jakarta.persistence.jdbc.password", setting(env, "DB_PASSWORD", null));
        return Persistence.createEntityManagerFactory("vetclinic", props);
    }

    /** Miljövariabel går före .env; saknas båda används standardvärdet. */
    private static String setting(Map<String, String> dotEnv, String key, String defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) {
            value = dotEnv.get(key);
        }
        if (value == null || value.isBlank()) {
            if (defaultValue == null) {
                throw new IllegalStateException(key + " saknas – lägg till den i .env eller som miljövariabel");
            }
            return defaultValue;
        }
        return value;
    }

    private static Map<String, String> loadDotEnv() {
        Map<String, String> values = new HashMap<>();
        Path file = Path.of(".env");
        if (!Files.exists(file)) {
            return values;
        }
        try {
            for (String line : Files.readAllLines(file)) {
                line = line.strip();
                if (line.isEmpty() || line.startsWith("#") || !line.contains("=")) {
                    continue;
                }
                int i = line.indexOf('=');
                values.put(line.substring(0, i).strip(), line.substring(i + 1).strip());
            }
        } catch (IOException e) {
            throw new IllegalStateException("Kunde inte läsa .env", e);
        }
        return values;
    }
}
