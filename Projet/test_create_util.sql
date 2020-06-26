BEGIN;
SAVEPOINT testcu;

SELECT * FROM UTILISATEURS;
\echo '====== Créer un utilisateur ======';
\echo '====== Giselle Lefemur 1975-05-14 gigi zertyd ======';
SELECT ajout_util('Lefemur', 'Giselle', '1975-05-14', 'gigi', 'zertyd');
\echo '====== Table Utilisateurs ======';
SELECT * FROM UTILISATEURS WHERE pseudo = 'gigi';
SELECT pg_sleep(5);

\echo '====== Souscription à un abonnement ======';
\echo '====== Table Abonnements ======';
SELECT * FROM ABONNEMENTS;
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
SELECT pg_sleep(5);
\echo '====== Ajout de l\'abonnement 2 à Giselle ======';
SELECT ajout_abo((SELECT id_util FROM UTILISATEURS WHERE pseudo = 'gigi'), 2);
\echo '====== Table Soucscrit ======';
SELECT * FROM SOUSCRIT;
SELECT pg_sleep(5);

ROLLBACK TO SAVEPOINT testcu;
COMMIT;
