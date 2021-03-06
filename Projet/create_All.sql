CREATE TABLE UTILISATEURS (
	id_util SERIAL PRIMARY KEY,
	nom VARCHAR(50) NOT NULL,
	prenom VARCHAR(50) NOT NULL,
	date_nais DATE NOT NULL CHECK(date_nais BETWEEN CURRENT_DATE - INTERVAL '150 years' AND CURRENT_DATE - INTERVAL '5 years'),
	pseudo VARCHAR(10) UNIQUE NOT NULL,
	mdp VARCHAR(20) NOT NULL CHECK(LENGTH(mdp) >= 5)
);

CREATE TABLE FILMS (
	id_film SERIAL PRIMARY KEY,
	titre VARCHAR(100) NOT NULL,
	annee NUMERIC NOT NULL CHECK(annee = CAST(annee AS INTEGER)),
	adulte BOOLEAN NOT NULL DEFAULT FALSE,
	nb_note INTEGER NOT NULL DEFAULT 0 CHECK(nb_note >= 0),
	moy_note NUMERIC(4, 2) NOT NULL DEFAULT 0 CHECK(moy_note BETWEEN 0 AND 10)
);

CREATE INDEX titre_ind ON FILMS USING HASH(titre);

CREATE TABLE ABONNEMENTS (
	id_abo SERIAL PRIMARY KEY,
	nb_ses NUMERIC NOT NULL CHECK(nb_ses > 0 AND nb_ses = CAST(nb_ses AS INTEGER)),
	qualite INTEGER NOT NULL CHECK(qualite IN (360, 480, 720, 1080, 2160)),
	tarif NUMERIC(5, 2) NOT NULL CHECK(tarif > 0)
);

CREATE TABLE SESSIONS (
	clef VARCHAR(50) PRIMARY KEY
);

CREATE TABLE SOUSCRIT (
	id_util INTEGER UNIQUE,
	id_abo INTEGER,
	PRIMARY KEY (id_util, id_abo),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE,
	FOREIGN KEY (id_abo) REFERENCES ABONNEMENTS(id_abo) ON DELETE CASCADE
);

CREATE TABLE CONNEXION (
	id_util INTEGER,
	clef VARCHAR(50),
	horodatage TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id_util, clef),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE,
	FOREIGN KEY (clef) REFERENCES SESSIONS(clef) ON DELETE CASCADE
);

CREATE TABLE TAGS (
	id_film INTEGER,
	id_util INTEGER,
	tag VARCHAR(20) NOT NULL,
	horodatage TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id_film, id_util),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE,
	FOREIGN KEY (id_film) REFERENCES FILMS(id_film) ON DELETE CASCADE
);

CREATE INDEX tag_hash ON TAGS USING HASH(tag);

CREATE TABLE NOTE (
	id_film INTEGER,
	id_util INTEGER,
	note NUMERIC(4, 2) NOT NULL,
	horodatage TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id_film, id_util),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE,
	FOREIGN KEY (id_film) REFERENCES FILMS(id_film) ON DELETE CASCADE
);

CREATE TABLE VISIONNER (
	id_film INTEGER,
	clef VARCHAR(50),
	PRIMARY KEY (id_film, clef),
	FOREIGN KEY (id_film) REFERENCES FILMS(id_film) ON DELETE CASCADE,
	FOREIGN KEY (clef) REFERENCES SESSIONS(clef) ON DELETE CASCADE
);

CREATE TABLE GENRES (
	genre VARCHAR(20) PRIMARY KEY
);

CREATE TABLE APPARTIENT (
	id_film INTEGER,
	genre VARCHAR(20) ,
	PRIMARY KEY (id_film, genre),
	FOREIGN KEY (id_film) REFERENCES FILMS(id_film) ON DELETE CASCADE,
	FOREIGN KEY (genre) REFERENCES GENRES(genre) ON DELETE CASCADE
);

CREATE TABLE LOG_VISIONNER (
	id_film INTEGER,
	id_util INTEGER,
	horodatage TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id_film, id_util, horodatage),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE
);

CREATE TABLE LOG_FILMS (
	id_film INTEGER,
	titre VARCHAR(100) NOT NULL,
	annee NUMERIC NOT NULL CHECK(annee = CAST(annee AS INTEGER)),
	adulte BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY (id_film)
);

CREATE TABLE LOG_SOUSCRIT (
	id_util INTEGER,
	id_abo INTEGER,
	horodatage TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id_util, id_abo, horodatage),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE
);

CREATE TABLE LOG_CONNEXION (
	id_util INTEGER,
	clef VARCHAR(50),
	horodatage TIMESTAMP NOT NULL,
	PRIMARY KEY (id_util, clef, horodatage),
	FOREIGN KEY (id_util) REFERENCES UTILISATEURS(id_util) ON DELETE CASCADE
);
