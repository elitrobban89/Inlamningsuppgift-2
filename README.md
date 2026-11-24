# Inlämningsuppgift 2 – Databaser

Java-applikation för en veterinärklinik (`vetclinic`) som använder **JPA/Hibernate** mot en
**MySQL-databas som körs i Docker**.

## Utgångsdata

En veterinärklinik lagrar sina besök i ett kalkylblad:

| owner_name | owner_phone   | pet_name | species | visit_date | diagnosis        | fee |
|------------|---------------|----------|---------|------------|------------------|----:|
| Anna Berg  | 070-111 11 11 | Rex      | Hund    | 2026-01-10 | Vaccination      | 450 |
| Anna Berg  | 070-111 11 11 | Rex      | Hund    | 2026-03-02 | Klokklippning    | 150 |
| Anna Berg  | 070-111 11 11 | Misse    | Katt    | 2026-02-14 | Öroninflammation | 600 |
| Erik Holm  | 070-222 22 22 | Bella    | Hund    | 2026-01-20 | Hälta            | 800 |
| Erik Holm  | 070-222 22 22 | Bella    | Hund    | 2026-04-05 | Kontroll         | 300 |
| Sara Lind  | 070-333 33 33 | Pelle    | Kanin   | 2026-02-28 | Tandkontroll     | 350 |

## Del A: Normalisera (LR 2)

### 1. Upprepning av data

> Peka ut en upprepning av data i tabellen ovan och förklara vilket problem den ger vid uppdatering.

**Svar:**

Anna Berg och hennes telefonnummer 070-111 11 11 står på tre rader: två besök med Rex och ett med Misse.
Numret hör till Anna, inte till djuret eller besöket.

**Problemet vid uppdatering** är att om hon byter nummer måste alla tre raderna ändras.
Glömmer man en rad, till exempel Misses, har samma person två olika nummer, och man vet inte vilket som stämmer.
Det kallas en **uppdateringsanomali**.

Om Anna i stället lagras en gång i en egen tabell `owner`, och djuren pekar dit med `owner_id`,
ändras numret på ett enda ställe.

### 2. Skapa databasen

> Skapa databasen vetclinic (ta bort den först om den finns). Skapa tabellerna owner,
> pet och visit med primärnycklar (auto-increment) och främmande nycklar. species
> får vara text i pet. Redovisa sql queries som används.

**Svar:**

Ägaren lagras en gång i `owner`. Varje djur i `pet` pekar på sin ägare med `owner_id`,
och varje besök i `visit` pekar på ett djur med `pet_id`.
Samma SQL finns i [`sql/vetclinic.sql`](sql/vetclinic.sql).

```sql
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
```

### 3. Lägg in data

> Lägg in all data från tabellen med INSERT, så att varje ägare, djur och besök bara finns en
> gång. Visa SELECT COUNT(*) för varje tabell. Lägg även till dig själv och ett eget djur.

**Svar:**

Kalkylbladet har 6 rader, men bara 3 olika ägare och 4 olika djur.
Anna Berg står på tre rader men läggs in **en** gång i `owner`, och Rex står på två rader men läggs in
en gång i `pet`. Varje rad i kalkylbladet är ett eget besök, så alla 6 hamnar i `visit`.

Datan läggs in i ordningen `owner` → `pet` → `visit`, eftersom en främmande nyckel bara kan peka på en rad
som redan finns. Id:na sätts av `AUTO_INCREMENT` i den ordning raderna läggs in. Databasen skapas ny varje
gång skriptet körs, så id:na blir alltid desamma. Besöken pekar på djuret med `pet_id` i stället för att
upprepa ägarens namn och telefonnummer. Jag har lagt till mig själv som ägare 4 och min gecko som djur 5.

SQL:en ligger sist i [`sql/vetclinic.sql`](sql/vetclinic.sql):

```sql
-- owner_id: 1 = Anna, 2 = Erik, 3 = Sara, 4 = jag själv
INSERT INTO owner (name, phone) VALUES
    ('Anna Berg', '070-111 11 11'),
    ('Erik Holm', '070-222 22 22'),
    ('Sara Lind', '070-333 33 33'),
    ('Robert Andersson', '0739 99 99 99');

-- pet_id: 1 = Rex, 2 = Misse, 3 = Bella, 4 = Pelle, 5 = mitt djur
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

SELECT COUNT(*) AS antal_owner FROM owner;
SELECT COUNT(*) AS antal_pet   FROM pet;
SELECT COUNT(*) AS antal_visit FROM visit;
```

**Resultat:**

| Tabell  | `COUNT(*)` | Förklaring                          |
|---------|-----------:|-------------------------------------|
| `owner` | 4          | Anna, Erik, Sara + jag själv        |
| `pet`   | 5          | Rex, Misse, Bella, Pelle + min gecko |
| `visit` | 6          | ett per rad i kalkylbladet          |

## Del B: Constraints och transaktioner

### 4. Constraints

> Se till att pet.name är NOT NULL, owner.phone är UNIQUE och visit.fee har ett
> CHECK på att den är >= 0. Gör det i CREATE TABLE eller med ALTER TABLE.

**Svar:**

`pet.name NOT NULL` och `owner.phone UNIQUE` lade jag in direkt i CREATE TABLE i uppgift 2:

```sql
name VARCHAR(50) NOT NULL,          -- i pet
phone VARCHAR(20) NOT NULL UNIQUE   -- i owner
```

Det som saknades var att avgiften inte får vara negativ. Den lade jag till med ALTER TABLE.
Constrainten har ett eget namn, `chk_visit_fee`, så att det syns i felmeddelandet vilken regel som bröts.

```sql
ALTER TABLE visit
    ADD CONSTRAINT chk_visit_fee CHECK (fee >= 0);
```

**Resultat:**

`SHOW CREATE TABLE` visar att alla tre reglerna finns i databasen:

```text
owner:  `phone` varchar(20) NOT NULL,  UNIQUE KEY `phone` (`phone`)
pet:    `name` varchar(50) NOT NULL
visit:  CONSTRAINT `chk_visit_fee` CHECK ((`fee` >= 0))
```

### 5. Bryt mot reglerna

> Försök bryta mot två av reglerna (en FOREIGN KEY och en CHECK eller UNIQUE).
> Redovisa felmeddelanden.

**Svar:**

Jag bröt mot CHECK-regeln på `visit.fee` genom att lägga in ett besök med negativ avgift,
och mot främmande nyckeln `pet.owner_id` genom att lägga in ett djur som tillhör en ägare som inte finns
(ägarna har id 1–4). I båda satserna är allt annat korrekt, så att felet bara gäller den regel som testas.

Satserna ska misslyckas, och `mysql` stoppar normalt vid första felet. Därför körs skriptet med `--force`,
så att det fortsätter och visar båda felmeddelandena.

```sql
-- Bryter mot CHECK: avgiften får inte vara negativ
INSERT INTO visit (pet_id, visit_date, diagnosis, fee) VALUES
    (1, '2026-11-10', 'Vaccination', -200);

-- Bryter mot FOREIGN KEY: ägare med owner_id 5 finns inte
INSERT INTO pet (owner_id, name, species) VALUES
    (5, 'Hox', 'Bläckfisk');
```

**Resultat:**

```text
ERROR 3819 (HY000) at line 76: Check constraint 'chk_visit_fee' is violated.
```

Databasen stoppar besöket eftersom -200 bryter mot `chk_visit_fee` (`fee >= 0`) från uppgift 4.

```text
ERROR 1452 (23000) at line 80: Cannot add or update a child row: a foreign key constraint fails
(`vetclinic`.`pet`, CONSTRAINT `pet_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `owner` (`owner_id`))
```

Databasen stoppar djuret eftersom `owner_id` 5 inte finns i `owner`. "Child row" är raden i `pet`,
som måste peka på en befintlig rad i föräldertabellen `owner`. `pet_ibfk_1` är namnet som MySQL själv gav
främmande nyckeln.

Ingen av raderna kom in i databasen, så tabellerna har fortfarande 5 djur och 6 besök.

### 6. Transaktion

> Skriv en transaktion som lägger till en ny ägare och flyttar ett djur till den nya ägaren
> (INSERT och UPDATE). Avsluta med COMMIT.

**Svar:**

Den nya ägaren Gösta Bergling läggs in i `owner` och får `owner_id` 5 av `AUTO_INCREMENT`, eftersom ägarna
1–4 redan finns. Sedan flyttas Rex (`pet_id` 1) från Anna till Gösta genom att `owner_id` ändras till 5.

Båda satserna ligger mellan `START TRANSACTION` och `COMMIT` och räknas därför som en enhet: antingen sparas
både den nya ägaren och flytten, eller ingenting. Djuret väljs med primärnyckeln `pet_id` i stället för
namnet, eftersom namn inte är unika. En `SELECT` före och efter transaktionen visar ändringen.

```sql
SELECT * FROM pet;

START TRANSACTION;
INSERT INTO owner (name, phone) VALUES
    ('Gösta Bergling', '079-999 99 99');
UPDATE pet SET owner_id = 5 WHERE pet_id = 1; -- Flyttar Rex till Gösta Bergling
COMMIT;

SELECT * FROM pet;
```

**Resultat:**

Före transaktionen tillhör Rex Anna Berg (`owner_id` 1):

| pet_id | owner_id | name  | species           |
|-------:|---------:|-------|-------------------|
| 1      | **1**    | Rex   | Hund              |
| 2      | 1        | Misse | Katt              |
| 3      | 2        | Bella | Hund              |
| 4      | 3        | Pelle | Kanin             |
| 5      | 4        | Gekko | Kronbärande gecko |

Efter `COMMIT` tillhör Rex Gösta Bergling (`owner_id` 5). Övriga djur är oförändrade:

| pet_id | owner_id | name  | species           |
|-------:|---------:|-------|-------------------|
| 1      | **5**    | Rex   | Hund              |
| 2      | 1        | Misse | Katt              |
| 3      | 2        | Bella | Hund              |
| 4      | 3        | Pelle | Kanin             |
| 5      | 4        | Gekko | Kronbärande gecko |

## Del C: Java mot databasen (LR 5)

### 7. JDBC och JPA

> Skriv en liten Java-klass som listar alla djur med JDBC och en som gör det med
> JPA/Hibernate (entitet Pet). Slå på SQL-loggning i JPA. Klistra in SQL:en från respektive
> klass och beskriv eventuella skillnader.

**Svar:**

**Förberedelse i `persistence.xml`:**

SQL-loggningen slås på med två inställningar. `show_sql` gör att Hibernate skriver ut varje SQL-sats
som skickas till databasen, och `format_sql` delar upp satsen på flera rader så att den blir lättläst:

```xml
<property name="hibernate.show_sql" value="true"/>
<property name="hibernate.format_sql" value="true"/>
```

Jag har också ändrat `hibernate.hbm2ddl.auto` från `update` till `validate`:

```xml
<property name="hibernate.hbm2ddl.auto" value="validate"/>
```

Tabellerna skapas av SQL-skriptet i Del A och B, med NOT NULL, UNIQUE, CHECK och främmande nycklar.
Med `update` får Hibernate ändra tabellerna så att de passar entiteterna. Om ett fält i `Pet` hade fel namn
skulle Hibernate i tysthet lägga till en ny kolumn i `pet`. Med `validate` kontrollerar Hibernate bara att
entiteten stämmer med tabellen och stoppar programmet med ett tydligt fel om den inte gör det.
Databasen ändras aldrig.

**JDBC-anslutning i `Database.java`:**

För att Java ska kunna prata med databasen behövs en anslutning. Med JPA sköter Hibernate den själv via
`EntityManagerFactory`, och anslutningen är gömd inne i Hibernate. Med ren JDBC måste programmet själv öppna
en `java.sql.Connection`.

Därför har jag lagt till metoden `Database.getConnection()`. Den läser URL, användare och lösenord från
`.env` (eller miljövariabler) på samma sätt som JPA-delen, och öppnar anslutningen med
`DriverManager.getConnection(url, user, password)`. På så sätt använder båda klasserna samma
inloggningsuppgifter, och lösenordet behöver aldrig skrivas i koden.

`EntityManagerFactory` skapades tidigare direkt när klassen `Database` laddades. Då startade Hibernate
även när bara JDBC-klassen kördes. Nu skapas den först när `createEntityManager()` anropas första gången
(*lazy initialization*), så JDBC-klassen startar aldrig Hibernate.

**JDBC-klassen `ListPetsJdbc`:**

Med JDBC skriver jag SQL:en själv som en sträng, kör den och läser resultatet kolumn för kolumn
ur ett `ResultSet`. Anslutningen, satsen och resultatet ligger i en try-with-resources, så att alla tre
stängs automatiskt (i omvänd ordning) när blocket är slut.

```java
String sql = "SELECT pet_id, owner_id, name, species FROM pet";
try (Connection c = Database.getConnection();
     PreparedStatement stmt = c.prepareStatement(sql);
     ResultSet rs = stmt.executeQuery()) {
    while (rs.next()) {
        System.out.println(rs.getInt("pet_id") + " | " +
                rs.getInt("owner_id") + " | " + rs.getString("name") + " | " + rs.getString("species"));
    }
}
```

SQL:en som skickas till databasen är exakt den jag skrev:

```sql
SELECT pet_id, owner_id, name, species FROM pet
```

Utskrift (Rex tillhör Gösta, `owner_id` 5, efter transaktionen i uppgift 6):

```text
1 | 5 | Rex | Hund
2 | 1 | Misse | Katt
3 | 2 | Bella | Hund
4 | 3 | Pelle | Kanin
5 | 4 | Gekko | Kronbärande gecko
```

**Entiteten `Pet`:**

För JPA behövs en entitet: en Java-klass som Hibernate kopplar till tabellen `pet`. Varje objekt är en rad
och varje fält är en kolumn. Annoteringarna speglar `CREATE TABLE pet`:

```java
@Entity
@Table(name = "pet")
public class Pet {

    @Id                                                   // PRIMARY KEY
    @GeneratedValue(strategy = GenerationType.IDENTITY)   // AUTO_INCREMENT
    @Column(name = "pet_id")
    private Integer id;

    @Column(name = "owner_id")
    private Integer ownerId;

    @Column(name = "name")
    private String name;

    @Column(name = "species")
    private String species;

    protected Pet() { }   // JPA kräver en tom konstruktor

    // getters och toString()
}
```

| Kolumn i `pet`                    | Fält i `Pet`       | Annoteringar                           |
|-----------------------------------|--------------------|----------------------------------------|
| `pet_id INT AUTO_INCREMENT PRIMARY KEY` | `Integer id`  | `@Id`, `@GeneratedValue`, `@Column`    |
| `owner_id INT NOT NULL`           | `Integer ownerId`  | `@Column(name = "owner_id")`           |
| `name VARCHAR(50) NOT NULL`       | `String name`      | `@Column`                              |
| `species VARCHAR(30) NOT NULL`    | `String species`   | `@Column`                              |

Bara primärnyckeln har `@Id` och `@GeneratedValue`. De andra kolumnerna är vanliga värden som sätts när
djuret läggs in. `@Column(name = "owner_id")` behövs eftersom Java-fältet heter `ownerId` (camelCase),
medan kolumnen heter `owner_id`. Hibernate kräver en tom konstruktor för att kunna skapa `Pet`-objekt när
den läser rader från databasen.

Entiteten registreras i `persistence.xml`, annars känner Hibernate inte till den:

```xml
<class>org.example.vetclinic.Pet</class>
```

Eftersom `hbm2ddl.auto` är `validate` kontrollerar Hibernate vid start att `Pet` stämmer med tabellen
`pet`. Programmet startar utan fel, så kolumnnamn, typer och primärnyckel stämmer.

**JPA-klassen `ListPetsJpa`:**

Med JPA skriver jag ingen SQL. Jag skriver en JPQL-fråga mot klassen `Pet`, och Hibernate översätter den
till SQL. Svaret är en lista med färdiga `Pet`-objekt. `EntityManager` stängs av try-with-resources,
och `Database.close()` i `finally` stänger Hibernate när programmet är klart.

```java
try (EntityManager em = Database.createEntityManager()) {
    List<Pet> pets = em.createQuery("SELECT p FROM Pet p", Pet.class).getResultList();
    for (Pet pet : pets) {
        System.out.println(pet.getId() + " | " +
                pet.getOwnerId() + " | " + pet.getName() + " | " + pet.getSpecies());
    }
} finally {
    Database.close();
}
```

JPQL-frågan i koden:

```sql
SELECT p FROM Pet p
```

SQL:en som Hibernate genererar och skickar till databasen (från loggen, tack vare `show_sql` och `format_sql`):

```sql
select
    p1_0.pet_id,
    p1_0.name,
    p1_0.owner_id,
    p1_0.species 
from
    pet p1_0
```

Utskrift, samma fem djur som med JDBC:

```text
1 | 5 | Rex | Hund
2 | 1 | Misse | Katt
3 | 2 | Bella | Hund
4 | 3 | Pelle | Kanin
5 | 4 | Gekko | Kronbärande gecko
```

**Skillnader mellan JDBC och JPA:**

|                          | JDBC (`ListPetsJdbc`)                                  | JPA/Hibernate (`ListPetsJpa`)                                   |
|--------------------------|--------------------------------------------------------|-----------------------------------------------------------------|
| Vem skriver SQL:en       | Jag, som en sträng i koden                             | Hibernate, utifrån JPQL-frågan                                  |
| Frågan gäller            | Tabellen `pet` och dess kolumner                       | Klassen `Pet` och dess objekt                                   |
| SQL som skickas          | `SELECT pet_id, owner_id, name, species FROM pet`      | `select p1_0.pet_id, p1_0.name, p1_0.owner_id, p1_0.species from pet p1_0` |
| Alias                    | Inget                                                  | `p1_0` på tabellen och framför varje kolumn                     |
| Kolumnordning            | Den ordning jag skrev                                  | Id först, sedan fälten i bokstavsordning                        |
| Resultat                 | `ResultSet` som läses kolumn för kolumn                 | `List<Pet>` med färdiga objekt                                  |
| Läsa ett värde           | `rs.getString("name")` med kolumnnamnet som text        | `pet.getName()`, en vanlig metod                                |
| Koppling kolumn ↔ fält   | Görs för hand i koden                                  | Görs av annoteringarna i `Pet`                                  |
| Se SQL:en                | Står direkt i koden                                    | Syns bara med SQL-loggning (`show_sql`)                         |
| Uppstart                 | Bara en anslutning öppnas                              | Hibernate startar och validerar entiteterna först               |

Den största skillnaden är vem som gör jobbet. Med JDBC har jag full kontroll och ser exakt vilken SQL som
körs, men jag måste skriva SQL:en och flytta varje kolumn till Java för hand. Ett stavfel i ett kolumnnamn,
till exempel `"nmae"`, upptäcks först när programmet körs. Med JPA beskriver jag kopplingen en gång i
entiteten. Sedan skriver Hibernate SQL:en och skapar objekten åt mig, och `validate` kontrollerar redan
vid start att entiteten stämmer med tabellen.

Även om JPQL-frågan säger `SELECT p`, alltså hela objektet, räknar Hibernate upp varje kolumn i stället
för att använda `*`. Den vet exakt vilka fält `Pet` har. Aliaset `p1_0` genererar Hibernate själv, så att
kolumnnamnen aldrig kan krocka om frågan senare kopplas ihop med fler tabeller.

I grunden ställer båda klasserna samma fråga till databasen: hämta alla fyra kolumner för alla rader i
`pet`. Därför blir resultatet detsamma.

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
├── Database.java      # Ger anslutningar via JPA (EntityManager) och JDBC (Connection), läser inloggning från .env
├── Main.java          # Startpunkt – testar anslutningen mot databasen
├── ListPetsJdbc.java  # Uppgift 7: listar alla djur med ren JDBC
├── ListPetsJpa.java   # Uppgift 7: listar alla djur med JPA/Hibernate
└── Pet.java           # Uppgift 7: JPA-entitet för tabellen pet
src/main/resources/META-INF/
└── persistence.xml    # JPA-konfiguration (persistence unit "vetclinic")
sql/
└── vetclinic.sql      # Skapar databasen, tabellerna och datan (uppgift 2–6)
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

Tabellerna och datan skapas av SQL-skriptet [`sql/vetclinic.sql`](sql/vetclinic.sql), inte av Hibernate.
Kör det mot Docker-containern från projektroten:

```bash
docker exec -i mysql mysql -uvetclinic -p --force --default-character-set=utf8mb4 < sql/vetclinic.sql
```

`--force` behövs eftersom uppgift 5 innehåller två INSERT som ska misslyckas. Utan `--force` stoppar
`mysql` vid det första felet.

Hibernate kör med `hibernate.hbm2ddl.auto=validate`. Den ändrar alltså aldrig tabellerna, utan kontrollerar
bara vid start att entiteterna stämmer med dem. En ny entitet läggs till så här:

1. Skapa en klass med `@Entity` och `@Table(name = "...")`, där fälten matchar tabellens kolumner.
2. Registrera den i `persistence.xml`:
   ```xml
   <class>org.example.vetclinic.Pet</class>
   ```
3. Kör programmet. Om entiteten inte stämmer med tabellen stoppar Hibernate med ett valideringsfel.

## Visa databasen i IntelliJ

1. Öppna **Database**-panelen → **+** → **Data Source** → **MySQL**.
2. Host `localhost`, port `3306`, användare `vetclinic`, lösenord från `.env`, databas `vetclinic`.
3. **Test Connection** → **OK**.
4. Under fliken **Schemas**, kryssa i `vetclinic` och tryck på refresh (🔄).
