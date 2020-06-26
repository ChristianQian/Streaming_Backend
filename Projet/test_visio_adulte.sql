BEGIN;
SAVEPOINT testva;

\echo '====== Connexion d\'un utilisateur mineur ======';
\echo '====== Table Utilisateurs ======';
SELECT * FROM UTILISATEURS WHERE date_nais > CURRENT_DATE - INTERVAL '18 years';
\echo '====== Ajout d\'une connexion à l\'utilisateur mineur ======';
SELECT ajout_connexion('mat', 'lefngol');
\echo '====== Table Connexion ======';
SELECT * FROM CONNEXION;
SELECT pg_sleep(5);

\echo '====== Visionnage d\'un film pour adulte par un mineur ======';
\echo '====== Une erreur doit se produire ======';
\echo '====== Ajout en visionnage du film pour adulte ======';
SELECT ajout_visionner((SELECT id_film FROM FILMS WHERE adulte = TRUE), 
					   (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 17) 
					   								 and id_util = 17));
\echo '====== Table Visionner ======';
SELECT * FROM VISIONNER WHERE clef = (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 17) 
					   								 and id_util = 17);
SELECT pg_sleep(5);

\echo '====== Visionnage d\'un film adulte par un adulte ======';
SELECT ajout_connexion('JC', 'johnny');
\echo '====== Table Connexion ======';
SELECT * FROM CONNEXION;
\echo '====== Ajout en visionnage du film pour adulte ======';
SELECT ajout_visionner((SELECT id_film FROM FILMS WHERE adulte = TRUE), 
					   (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) 
					   								 and id_util = 2));
\echo '====== Table Visionner ======';
SELECT * FROM VISIONNER WHERE clef = (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) 
					   								 and id_util = 2);
\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE adulte = TRUE;
SELECT pg_sleep(5);

ROLLBACK TO SAVEPOINT testva;
COMMIT;
