BEGIN;
SAVEPOINT testsf;

\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE id_film = 42;
\echo '====== Suppression du film 42 de la table Films ======';
DELETE FROM FILMS WHERE id_film = 42;
\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE id_film = 42;
\echo '====== Table Log_Films ======';
SELECT * FROM LOG_FILMS;
SELECT pg_sleep(5);

ROLLBACK TO SAVEPOINT testsf;
COMMIT;
