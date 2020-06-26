BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
\echo '====== Ajout d\'une note au film 1 par utilisateur 1 ======';
SELECT ajout_note(1, 1, 5);
\echo '====== Table Note ======';
SELECT * FROM NOTE;
\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE id_film = 1;

\echo '====== En attente d\'un commit ======';
