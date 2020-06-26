BEGIN;
SAVEPOINT testmn;

\echo '====== Mise à jour d\'une note au film 1230 par utilisateur 2 ======';
\echo '====== Table Note ======';
SELECT * FROM NOTE;
SELECT maj_note(1230, 2, 5);
\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE id_film = 1230;
SELECT pg_sleep(5);

\echo '====== Suppression de la note de l\'utilisateur 2 au film 1230 ======';
DELETE FROM NOTE WHERE id_util = 2 and id_film = 1230;
\echo '====== Table Note ======';
SELECT * FROM NOTE;
\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE id_film = 1230;
SELECT pg_sleep(5);

ROLLBACK TO SAVEPOINT testmn;
COMMIT;
