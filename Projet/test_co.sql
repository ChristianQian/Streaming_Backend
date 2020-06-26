BEGIN;
SAVEPOINT testco;

\echo '====== Effacer la dernière connexion de l\'utilisateur 2 ======';
\echo '====== Table Connexion ======';
SELECT ajout_connexion('JC', 'johnny');
SELECT * FROM CONNEXION;
SELECT eff_connexion((SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) and id_util = 2));
\echo '====== Table Connexion ======';
SELECT * FROM CONNEXION;
\echo '====== Table Log_Connexion ======';
SELECT * FROM LOG_CONNEXION;
SELECT pg_sleep(5);

\echo '====== Plus de connexions tentées que permis par l\'abonnement souscrit ======';
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
\echo '====== Table Abonnements ======';
SELECT * FROM ABONNEMENTS WHERE id_abo = (SELECT id_abo FROM SOUSCRIT WHERE id_util = 1);
\echo '====== Ajout d\'une première connexion ======';
SELECT ajout_connexion('vévère', 'abcdef1223');
\echo '====== Ajout d\'une seconde connexion ======';
\echo '====== Une erreur est censée se produire ======';
SELECT ajout_connexion('vévère', 'abcdef1223');

ROLLBACK TO SAVEPOINT testco;
COMMIT;