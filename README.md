# Inlämningsuppgift 2 – Databaser

Java-applikation för en veterinärklinik (`vetclinic`) som använder **JPA/Hibernate** mot en
**MySQL-databas som körs i Docker**.

## Teknik

| Del         | Version              |
|-------------|----------------------|
| Java        | 27                   |
| Maven       | 3.9                  |
| Hibernate   | 7.4 (Jakarta Persistence 3.2) |
| MySQL       | 26.10 (Docker-image `mysql`) |
| JDBC-driver | mysql-connector-j 26.10 |

## Projektstruktur

```
src/main/java/org/example/vetclinic/
├── Database.java      # Skapar EntityManagerFactory, läser inloggning från .env
└── Main.java          # Startpunkt – testar anslutningen mot databasen
src/main/resources/META-INF/
└── persistence.xml    # JPA-konfiguration (persistence unit "vetclinic")
.env.example           # Mall för anslutningsuppgifter
```

## Kom igång

### 1. Starta MySQL i Docker

Om containern inte redan finns:

```bash
docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=<root-lösenord> mysql:latest
```

Om den finns men är stoppad:

```bash
docker start mysql
```

### 2. Skapa databas och användare

```bash
docker exec -it mysql mysql -uroot -p
```

```sql
CREATE DATABASE IF NOT EXISTS vetclinic CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS 'vetclinic'@'%' IDENTIFIED BY '<lösenord>';
GRANT ALL PRIVILEGES ON vetclinic.* TO 'vetclinic'@'%';
FLUSH PRIVILEGES;
```

### 3. Lägg in anslutningsuppgifter

Kopiera `.env.example` till `.env` i projektroten och fyll i lösenordet:

```
DB_URL=jdbc:mysql://localhost:3306/vetclinic
DB_USER=vetclinic
DB_PASSWORD=<lösenord>
```

`.env` är gitignorerad – lösenord checkas aldrig in. Värdena kan också sättas som
miljövariabler, som då går före `.env`.

### 4. Kör programmet

Kör `Main` i IntelliJ, eller från terminalen:

```bash
mvn compile
mvn dependency:build-classpath -Dmdep.outputFile=target/cp.txt
java -cp "target/classes;$(cat target/cp.txt)" org.example.vetclinic.Main
```

(På macOS/Linux används `:` i stället för `;` i classpath.)

Vid lyckad anslutning skrivs t.ex. ut:

```
Ansluten till MySQL 26.10.0, databas: vetclinic
```

Programmet måste köras från projektroten så att `.env` hittas.

## Tabeller

Hibernate skapar och uppdaterar tabellerna automatiskt utifrån entitetsklasserna
(`hibernate.hbm2ddl.auto=update`). En ny entitet läggs till så här:

1. Skapa en klass med `@Entity`.
2. Registrera den i `persistence.xml`:
   ```xml
   <class>org.example.vetclinic.entity.Animal</class>
   ```
3. Kör programmet – tabellen skapas i databasen.

## Visa databasen i IntelliJ

1. Öppna **Database**-panelen → **+** → **Data Source** → **MySQL**.
2. Host `localhost`, port `3306`, användare `vetclinic`, lösenord från `.env`, databas `vetclinic`.
3. **Test Connection** → **OK**.
4. Under fliken **Schemas**, kryssa i `vetclinic` och tryck på refresh (🔄).
