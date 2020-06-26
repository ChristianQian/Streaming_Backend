BEGIN;
SAVEPOINT testss;

\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
\echo '====== Mise à jour de la souscription ======';
SELECT maj_abo(2, 4);
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
\echo '====== Table Log_Souscrit ======';
SELECT * FROM LOG_SOUSCRIT;
SELECT pg_sleep(5);

\echo '====== Suppression de l\'abonnement de l\'utilisateur 1 ======';
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT WHERE id_util = 1;
SELECT eff_abo(1);
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT WHERE id_util = 1;
\echo '====== Table Log_Souscrit ======';
SELECT * FROM LOG_SOUSCRIT;
SELECT pg_sleep(5);

\echo '====== Souscription à un abonnement en ayant déjà un ======';
\echo '====== Une erreur doit se produire ======';
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
SELECT ajout_abo(2, 1);
SELECT pg_sleep(5);

ROLLBACK TO SAVEPOINT testss;
COMMIT;
