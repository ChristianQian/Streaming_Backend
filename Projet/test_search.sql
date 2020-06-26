BEGIN;

\echo '====== Recherche d\'un film d\'action de l\'année 2000 ======';
SELECT recherche_films_genre_note(gr => 'Action', an => 2000);
SELECT pg_sleep(5);
\echo '====== Recherche des meilleurs films ======';
SELECT meilleurs_films();
SELECT pg_sleep(5);
\echo '====== Recherche des films avec un tag contenant les caractères Ro ======';
SELECT recherche_films_tag('Ro');
SELECT pg_sleep(5);

COMMIT;
