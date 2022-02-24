/* -- 0 -- */

CREATE TABLE Parent (
    name VARCHAR PRIMARY KEY NOT NULL,
    city VARCHAR NOT NULL,
    marriedTo VARCHAR REFERENCES Parent(name) NULL
);

CREATE TABLE Child (
    name VARCHAR PRIMARY KEY NOT NULL,
    age INTEGER NOT NULL
);

CREATE TABLE Parent_Child (
    parent_name VARCHAR NOT NULL,
    child_name VARCHAR NOT NULL,
    CONSTRAINT fk_parent
        FOREIGN KEY (parent_name)
        REFERENCES Parent(name)
        ON DELETE CASCADE,
    CONSTRAINT fk_child
        FOREIGN KEY (child_name)
        REFERENCES Child(name)
        ON DELETE CASCADE,
    UNIQUE (parent_name, child_name)
);

/** -- 1 -- */
/* First weddings */
BEGIN TRANSACTION;

/* Alice and Bob are married */
INSERT INTO Parent ("name", "city") VALUES ("Alice", "Stockholm");
INSERT INTO Parent ("name", "city") VALUES ("Bob", "Stockholm");
UPDATE Parent SET marriedTo = "Bob" WHERE name = "Alice";
UPDATE Parent SET marriedTo = "Alice" WHERE name = "Bob";

/* Charlie and Dorothy are married */
INSERT INTO Parent ("name", "city") VALUES ("Charlie", "Helsinki");
INSERT INTO Parent ("name", "city") VALUES ("Dorothy", "Helsinki");
UPDATE Parent SET marriedTo = "Dorothy" WHERE name = "Charlie";
UPDATE Parent SET marriedTo = "Charlie" WHERE name = "Dorothy";

COMMIT TRANSACTION;

/* -- 2 -- */
/* Kids arrive */
BEGIN TRANSACTION;

/* Alice and Bob */
INSERT INTO Child (name, age) VALUES ("Alma", 14);
INSERT INTO Child (name, age) VALUES ("Bill", 12);
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Alice", "Alma");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Alice", "Bill");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Bob", "Alma");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Bob", "Bill");

/* Charlie and Dorothy */
INSERT INTO Child (name, age) VALUES ("Charlotte", 5);
INSERT INTO Child (name, age) VALUES ("Dillon", 8);
INSERT INTO Child (name, age) VALUES ("Chuck", 11);
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Charlotte", "Charlie");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Dillon", "Charlie");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Chuck", "Charlie");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Charlotte", "Dorothy");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Dillon", "Dorothy");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Chuck", "Dorothy");

COMMIT TRANSACTION;

/* -- 3 -- */
/* Alice and Bob split up */
BEGIN TRANSACTION;

UPDATE Parent SET marriedTo = NULL WHERE name = "Alice";
UPDATE Parent SET marriedTo = NULL WHERE name = "Bob";

COMMIT TRANSACTION;

/* -- 4 -- */
/* Alice meets Eric and they move to Oslo */
BEGIN TRANSACTION;

INSERT INTO Parent (name, city, marriedTo) VALUES ("Eric", "Oslo", "Alice");
UPDATE Parent SET city = "Oslo", marriedTo = "Eric" WHERE name = "Alice";

COMMIT TRANSACTION;

/* -- 5 -- */
/* Alice and Eric have a child */
BEGIN TRANSACTION;

INSERT INTO Child (name, age) VALUES ("Ellen", 1);
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Alice", "Ellen");
INSERT INTO Parent_Child (parent_name, child_name) VALUES ("Eric", "Ellen");

COMMIT TRANSACTION;

/* -- 6 -- */
/* 15 years pass */
BEGIN TRANSACTION;

UPDATE Child SET age = age + 15;

COMMIT TRANSACTION;

/* -- 7 -- */
/* Alice dies */
BEGIN TRANSACTION;

DELETE FROM Parent WHERE name = "Alice";
UPDATE Parent SET marriedTo = NULL WHERE marriedTo = "Alice";
DELETE FROM Parent_Child WHERE parent_name = "Alice"; /* doesn't cascacing deletes work? */

COMMIT TRANSACTION;

/* -- 8 -- */
/* Queries */

/* Children with only one parent */
SELECT Child.name, age
FROM Child
JOIN Parent_Child
ON Child.name = child_name
WHERE parent_name IN
    (SELECT parent_name
     FROM Parent_Child
     GROUP BY child_name
     HAVING COUNT(parent_name) = 1);

/* Unmarried parents */
SELECT name, marriedTo FROM Parent WHERE marriedTo IS NULL;