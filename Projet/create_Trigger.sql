CREATE OR REPLACE FUNCTION maj_moy() RETURNS TRIGGER AS
$BODY$
DECLARE
	tmp INTEGER;
BEGIN
	tmp = (SELECT id_film FROM FILMS WHERE id_film = NEW.id_film FOR UPDATE);
	UPDATE FILMS SET nb_note = (SELECT COUNT(note) 
								 FROM NOTE 
								WHERE id_film = NEW.id_film), moy_note = (SELECT COALESCE(AVG(note), 0)
							      						  					FROM NOTE
							     						 				   WHERE id_film = NEW.id_film)
	 WHERE id_film = NEW.id_film;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER ajout_maj_note_films
AFTER INSERT OR UPDATE ON NOTE
FOR EACH ROW
EXECUTE PROCEDURE maj_moy();


CREATE OR REPLACE FUNCTION maj_dec_note() RETURNS TRIGGER AS
$BODY$
DECLARE
	tmp INTEGER;
BEGIN
	tmp = (SELECT id_film FROM FILMS WHERE id_film = NEW.id_film FOR UPDATE);
	UPDATE FILMS SET nb_note = nb_note - 1, moy_note = (SELECT COALESCE(AVG(note), 0)
							      						  FROM NOTE
							     						 WHERE id_film = OLD.id_film)
	 WHERE id_film = OLD.id_film;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER effacer_note_films
AFTER DELETE ON NOTE
FOR EACH ROW
EXECUTE PROCEDURE maj_dec_note();


CREATE OR REPLACE FUNCTION ajout_util(n VARCHAR(50), 
				      pr VARCHAR(50),
				      dn DATE,
				      pd VARCHAR(10),
				      mdp VARCHAR(20)) 
RETURNS VOID AS $$
BEGIN
	INSERT INTO UTILISATEURS(nom, prenom, date_nais, pseudo, mdp) VALUES (n,pr,dn,pd,mdp);
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_nb_sessions()
RETURNS TRIGGER AS
$BODY$
BEGIN
	IF (SELECT COUNT(*)
	      FROM CONNEXION
	     WHERE id_util = NEW.id_util) >= (SELECT nb_ses
						FROM ABONNEMENTS
					       WHERE id_abo = (SELECT id_abo
								 FROM SOUSCRIT
								WHERE id_util = NEW.id_util))
	THEN
		RAISE NOTICE 'nombre de sessions limite atteint';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER nb_sessions
BEFORE INSERT ON CONNEXION
FOR EACH ROW
EXECUTE PROCEDURE check_nb_sessions();

CREATE OR REPLACE FUNCTION clef_generator()
RETURNS VARCHAR(50) AS $$
DECLARE
	c VARCHAR(50);
BEGIN
	c = (SELECT MD5(random()::text));
	WHILE c IN (SELECT * FROM SESSIONS) LOOP
		c = (SELECT MD5(random()::text));
	END LOOP;
	RETURN c;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ajout_connexion(psd VARCHAR(10), m VARCHAR(20))
RETURNS VOID AS
$$
DECLARE
	c VARCHAR(50);
	id INTEGER;
BEGIN
	id := (SELECT id_util
		  	 FROM UTILISATEURS
		 	WHERE pseudo = psd and mdp = m);
	IF id IS NULL THEN
		RAISE NOTICE 'Mauvais identifiants';
		RETURN;
	END IF;
	c := clef_generator();
	INSERT INTO SESSIONS VALUES (c);
	INSERT INTO CONNEXION VALUES(id, c);
	IF (id,c) NOT IN (SELECT id_util, clef FROM CONNEXION) THEN
		DELETE FROM SESSIONS WHERE clef = c;
	END IF;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_adulte()
RETURNS TRIGGER AS 
$BODY$
DECLARE
	id INTEGER;
	dn DATE;
BEGIN
	id = (SELECT id_util
		FROM CONNEXION
	       WHERE clef = NEW.clef);
	dn = (SELECT date_nais
		FROM UTILISATEURS
	       WHERE id_util = id);
	IF dn BETWEEN CURRENT_DATE - INTERVAL '17 years' AND CURRENT_DATE THEN
		RAISE NOTICE 'Trop jeune pour regarder';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER visionnage_adulte
BEFORE INSERT ON VISIONNER
FOR EACH ROW
EXECUTE PROCEDURE check_adulte();


CREATE OR REPLACE FUNCTION eff_connexion(cf VARCHAR(50)) 
RETURNS VOID AS $$
BEGIN
	DELETE FROM SESSIONS WHERE clef = cf;
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_log_connexion() 
RETURNS TRIGGER AS
$BODY$
BEGIN
	INSERT INTO LOG_CONNEXION SELECT OLD.*;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER maj_log_connexion
AFTER DELETE ON CONNEXION
FOR EACH ROW
EXECUTE PROCEDURE insert_log_connexion();


CREATE OR REPLACE FUNCTION insert_eff_log_souscrit()
RETURNS TRIGGER AS
$BODY$
BEGIN
	IF (SELECT id_util FROM UTILISATEURS WHERE id_util = OLD.id_util) IS NOT NULL THEN
		INSERT INTO LOG_SOUSCRIT SELECT OLD.*, CURRENT_TIMESTAMP;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER on_eff_log_souscrit 
AFTER DELETE ON SOUSCRIT
FOR EACH ROW
EXECUTE PROCEDURE insert_eff_log_souscrit();

CREATE OR REPLACE FUNCTION insert_maj_log_souscrit()
RETURNS TRIGGER AS
$BODY$
BEGIN
	IF (SELECT id_util FROM UTILISATEURS WHERE id_util = NEW.id_util) IS NOT NULL THEN
		INSERT INTO LOG_SOUSCRIT SELECT OLD.*, CURRENT_TIMESTAMP;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER maj_log_souscrit 
AFTER UPDATE ON SOUSCRIT
FOR EACH ROW
EXECUTE PROCEDURE insert_maj_log_souscrit();

CREATE OR REPLACE FUNCTION insert_log_films()
RETURNS TRIGGER AS
$BODY$
BEGIN
	INSERT INTO LOG_FILMS VALUES(OLD.id_film, OLD.titre, OLD.annee, OLD.adulte);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER maj_log_films
AFTER DELETE ON FILMS
FOR EACH ROW
EXECUTE PROCEDURE insert_log_films();


CREATE OR REPLACE FUNCTION insert_log_visionner()
RETURNS TRIGGER AS
$BODY$
DECLARE
	idtmp INTEGER;
BEGIN
	idtmp = (SELECT id_util FROM LOG_CONNEXION WHERE clef = OLD.clef);
	IF idtmp IS NULL THEN
		idtmp = (SELECT id_util FROM CONNEXION WHERE clef = OLD.clef);
	END IF;
	INSERT INTO LOG_VISIONNER VALUES(OLD.id_film, idtmp);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER maj_log_visionner
AFTER DELETE ON VISIONNER
FOR EACH ROW
EXECUTE PROCEDURE insert_log_visionner();


CREATE OR REPLACE FUNCTION eff_util(id NUMERIC)
RETURNS VOID AS
$$
BEGIN
	PERFORM eff_connexion(clef) FROM CONNEXION WHERE id_util = id;
	DELETE FROM UTILISATEURS WHERE id_util = id;
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ajout_tag(id_f NUMERIC,
				     id_u NUMERIC,
				     tag VARCHAR(20))
RETURNS VOID AS
$$
BEGIN
	INSERT INTO TAGS(id_film, id_util, tag) VALUES (id_f, id_u, tag);
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ajout_note(id_f NUMERIC,
				     id_u NUMERIC,
				     note NUMERIC(4,2))
RETURNS VOID AS
$$
BEGIN
	INSERT INTO NOTE(id_film, id_util, note) VALUES (id_f, id_u, note);
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ajout_film(title VARCHAR(100),
				      an NUMERIC,
				      adult BOOLEAN)
RETURNS VOID AS
$$
DECLARE
	tmpid INTEGER;
BEGIN
	tmpid = (SELECT id_film FROM LOG_FILMS WHERE titre = title AND an = annee AND adulte = adult);
	IF tmpid IS NULL THEN
		INSERT INTO FILMS(titre, annee, adulte, nb_note, moy_note) VALUES (title, an, adult, 0, 0);
	ELSE
		INSERT INTO FILMS VALUES (tmpid, title, an, adult, 0, 0);
		DELETE FROM LOG_FILMS WHERE id_film = tmpid;
	END IF;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ajout_abo(id_u NUMERIC,
				     id_a NUMERIC)
RETURNS VOID AS
$$
BEGIN
	INSERT INTO SOUSCRIT VALUES (id_u, id_a);
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION eff_abo(id_u NUMERIC)
RETURNS VOID AS
$$
BEGIN
	DELETE FROM SOUSCRIT WHERE id_util = id_u;
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION maj_note(id_f NUMERIC,
				    id_u NUMERIC,
				    n NUMERIC(4,2))
RETURNS VOID AS
$$
BEGIN
	UPDATE NOTE SET note = n WHERE id_util = id_u AND id_film = id_f;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maj_abo(id_u INTEGER, newid_a INTEGER)
RETURNS VOID AS
$$
BEGIN
	UPDATE SOUSCRIT SET id_abo = newid_a WHERE id_util = id_u;
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION recherche_films_genre_note(gr VARCHAR(20) = NULL,note NUMERIC = NULL,an NUMERIC = NULL)
RETURNS TABLE(film_titre VARCHAR(100), film_annee NUMERIC, film_moy_note NUMERIC) AS
$BODY$
BEGIN
	IF gr IS NOT NULL THEN
		IF note IS NOT NULL THEN
			IF an IS NOT NULL THEN
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE annee = an AND moy_note >= note
							  AND id_film IN (SELECT id_film FROM APPARTIENT WHERE genre = gr)
                  				ORDER BY nb_note DESC);
			ELSE 
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE moy_note >= note AND id_film IN 
                 			(SELECT id_film FROM APPARTIENT WHERE genre = gr)
                  			ORDER BY nb_note DESC, annee DESC);
			END IF;
		ELSE
			IF an IS NOT NULL THEN
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE annee = an
								AND id_film IN (SELECT id_film FROM APPARTIENT WHERE genre = gr)
                  				ORDER BY moy_note DESC,nb_note DESC);
			ELSE 
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE id_film IN 
                 			(SELECT id_film FROM APPARTIENT WHERE genre = gr)
                  			ORDER BY moy_note DESC, nb_note DESC, annee DESC);
			END IF;
		END IF;
	ELSE
		IF note IS NOT NULL THEN
			IF an IS NOT NULL THEN
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE annee = an AND moy_note >= note
							ORDER BY nb_note DESC);
			ELSE
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE moy_note >= note 
					  		ORDER BY nb_note DESC, annee DESC);
			END IF;
		ELSE
			IF an IS NOT NULL THEN
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS WHERE annee = an
                			ORDER BY nb_note DESC);
			ELSE
				RETURN QUERY (SELECT titre, annee, moy_note FROM FILMS  
                  ORDER BY moy_note DESC, nb_note DESC, annee DESC);
			END IF;
		END IF;	
	END IF;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ajout_visionner(id_f INTEGER, clef_co VARCHAR(50))
RETURNS VOID AS
$$
BEGIN
	INSERT INTO VISIONNER VALUES(id_f, clef_co);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION eff_visionner(id_f INTEGER, clef_co VARCHAR(50))
RETURNS VOID AS
$$
BEGIN
	DELETE FROM VISIONNER WHERE id_film = id_f and clef = clef_co;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_historique(p_util VARCHAR(10))
RETURNS TABLE(titre VARCHAR(100), annee NUMERIC) AS
$$
BEGIN
	RETURN QUERY (SELECT f.titre, f.annee
  	  				FROM (SELECT f1.id_film, f1.titre, f1.annee FROM FILMS as f1
	      	 			   UNION 
	     				  SELECT f2.id_film, f2.titre, f2.annee FROM LOG_FILMS as f2) as f, 
						 LOG_VISIONNER as v
 	 			   WHERE f.id_film = v.id_film 
				     AND v.id_util = (SELECT id_util FROM UTILISATEURS WHERE pseudo = p_util)
				   ORDER BY v.horodatage DESC);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION recherche_films_tag(tg VARCHAR(20))
RETURNS TABLE(titre VARCHAR(100), annee NUMERIC) AS
$$
BEGIN
	RETURN QUERY (SELECT f.titre, f.annee
					FROM FILMS f, TAGS t
				   WHERE t.tag ~ tg
					 AND t.id_film = f.id_film);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION meilleurs_films()
RETURNS TABLE(titre VARCHAR(100), annee NUMERIC, moy_note NUMERIC, nb_note INTEGER) AS
$$
BEGIN
	RETURN QUERY (SELECT f.titre, f.annee, f.moy_note, f.nb_note
				    FROM FILMS f
				   ORDER BY f.moy_note DESC, f.nb_note DESC);
END;
$$
LANGUAGE plpgsql;
