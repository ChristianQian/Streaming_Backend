BEGIN;
SAVEPOINT test;

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

\echo '====== Connexion d\'un utilisateur mineur ======';
\echo '====== Table Utilisateurs ======';
SELECT * FROM UTILISATEURS WHERE date_nais > CURRENT_DATE - INTERVAL '18 years';
\echo '====== Ajout d\'une connexion à l\'utilisateur mineur ======';
SELECT ajout_connexion(17);
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
SELECT ajout_connexion(2);
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

\echo '====== Arrêter un visionnage ======';
\echo '====== Remplissage du log ======';
\echo '====== Récupération de la clef de l\'adulte ======';
SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) and id_util = 2;
\echo '====== Effacement du visionnage du film pour adulte ======';
SELECT eff_visionner((SELECT id_film FROM FILMS WHERE adulte = TRUE), 
					 (SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) and id_util = 2));
\echo '====== Table Visionner ======';
SELECT * FROM VISIONNER;
\echo '====== Table Log_Visionner ======';
SELECT * FROM LOG_VISIONNER;
SELECT pg_sleep(5);

\echo '====== Historique de visionnage de l\'utilisateur 2 ======';
SELECT get_historique('JC');
SELECT pg_sleep(5);

\echo '====== Recherche d\'un film d\'action de l\'année 2000 ======';
SELECT recherche_films_genre_note(gr => 'Action', an => 2000);
SELECT pg_sleep(5);

\echo '====== Souscription à un abonnement en ayant déjà un ======'
\echo '====== Une erreur doit se produire ======'
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
SELECT ajout_abo(2, 1);
\echo '====== Table Souscrit ======';
SELECT * FROM SOUSCRIT;
SELECT pg_sleep(5);

\echo '====== Effacer la dernière connexion de l\'utilisateur 2 ======'
\echo '====== Table Connexion ======';
SELECT * FROM CONNEXION;
SELECT eff_connexion((SELECT clef FROM CONNEXION WHERE horodatage = (SELECT max(horodatage) FROM CONNEXION WHERE id_util = 2) and id_util = 2));
\echo '====== Table Connexion ======';
SELECT * FROM CONNEXION;
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

ROLLBACK TO SAVEPOINT test;
COMMIT;