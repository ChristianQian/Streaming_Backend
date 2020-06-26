BEGIN;
SAVEPOINT testhv;

\echo '====== Visionnage d\'un film ======';
SELECT ajout_connexion('JC', 'johnny');
\echo '====== Table Connexion ======';
SELECT * FROM CONNEXION;
\echo '====== Ajout en visionnage du film ======';
SELECT ajout_visionner(1, 
					   (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) 
					   								 and id_util = 2));
\echo '====== Table Visionner ======';
SELECT * FROM VISIONNER WHERE clef = (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) 
					   								 and id_util = 2);
\echo '====== Table Films ======';
SELECT * FROM FILMS WHERE id_film = 1;
SELECT pg_sleep(5);

\echo '====== Arrêt du visionnage du film 1 ======';
SELECT eff_visionner(1, (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) 
					   								 and id_util = 2));


\echo '====== Historique de visionnage de l\'utilisateur 2 ======';
SELECT get_historique('JC');
\echo '====== Table Log_Visionner ======';
SELECT * FROM LOG_VISIONNER;
SELECT pg_sleep(5);

ROLLBACK TO SAVEPOINT testhv;
COMMIT;
