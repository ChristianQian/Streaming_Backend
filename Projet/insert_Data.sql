-- \copy ne marche pas sur pgadmin, à remplacer par COPY si nécessaire
\copy FILMS FROM './movies14k.csv' DELIMITER ',' CSV HEADER;
\copy GENRES FROM './genres.csv' CSV HEADER;
\copy APPARTIENT FROM './appartient.csv' DELIMITER ',' CSV HEADER;


SELECT ajout_util('Dumont', 'Hervé', '1964-09-23', 'vévère', 'abcdef1223');
SELECT ajout_util('Convenant', 'Jean-Claude', '1961-12-20', 'JC', 'johnny');
SELECT ajout_util('Convenant', 'Jason', '1988-03-14', 'JCJ', 'razeer');
SELECT ajout_util('Bignon', 'Jeanne', '1966-02-02', 'jeanette', 'lecode');
SELECT ajout_util('Capucin', 'Maéva', '1969-07-23', 'eva', 'madmoizelle');
SELECT ajout_util('Muller', 'Sylvain', '1963-08-18', 'sylvain', 'scrable');
SELECT ajout_util('Gatin', 'Philippe', '1968-05-14', 'filou', 'bichon');
SELECT ajout_util('Convenant', 'Veronique', '1962-04-30', 'vero', 'cachet');
SELECT ajout_util('Castelli', 'Frederique', '1975-12-14', 'fred', 'drogue');
SELECT ajout_util('Lecointre', 'Jean-Guy', '1946-01-11', 'drh', 'pacman');
SELECT ajout_util('Touati', 'Serge', '1961-02-08', 'psy', 'jeanne');
SELECT ajout_util('Markowicz', 'Andre', '1972-02-29', 'monsieur', 'lescoups');
SELECT ajout_util('Langeais', 'Nancy', '1976-03-05', 'sisi', 'ourpo');
SELECT ajout_util('Dussier-Belmont', 'Carole', '1964-05-09', 'ray', 'ezsgz');
SELECT ajout_util('Hassan', 'Julie', '1976-12-13', 'juju', 'zgeaaz');
SELECT ajout_util('Schneider', 'Vincent', '1972-12-10', 'vince','seghs');
SELECT ajout_util('Convenant', 'Mathéo', '2003-10-23', 'mat', 'lefngol');

INSERT INTO ABONNEMENTS(nb_ses, qualite, tarif) VALUES (1, 360, 4.99);
INSERT INTO ABONNEMENTS(nb_ses, qualite, tarif) VALUES (2, 480, 8.99);
INSERT INTO ABONNEMENTS(nb_ses, qualite, tarif) VALUES (4, 720, 13.99);
INSERT INTO ABONNEMENTS(nb_ses, qualite, tarif) VALUES (10, 1080, 16.99);
INSERT INTO ABONNEMENTS(nb_ses, qualite, tarif) VALUES (10, 2160, 19.99);

SELECT ajout_note(1230, 1, 8);
SELECT ajout_note(1230, 2, 3);
SELECT ajout_note(1230, 6, 10);
SELECT ajout_note(1230, 13, 7);
SELECT ajout_note(1230, 14, 5);
SELECT ajout_note(1230, 5, 10);
SELECT ajout_note(1230, 11, 9);
SELECT ajout_note(1230, 4, 7);
SELECT ajout_note(64969, 1, 5);
SELECT ajout_note(64969, 4, 7);
SELECT ajout_note(64969, 7, 8);
SELECT ajout_note(296, 1, 8);
SELECT ajout_note(296, 2, 8);
SELECT ajout_note(296, 4, 7);
SELECT ajout_note(296, 5, 5);
SELECT ajout_note(296, 6, 10);
SELECT ajout_note(296, 7, 9);
SELECT ajout_note(296, 8, 6);
SELECT ajout_note(296, 13, 9);
SELECT ajout_note(356, 1, 7);
SELECT ajout_note(356, 13, 9);
SELECT ajout_note(356, 7, 6);
SELECT ajout_note(119063, 1, 10);
SELECT ajout_note(119063, 2, 10);

SELECT ajout_tag(296, 1, 'Humour');
SELECT ajout_tag(296, 6, 'Drogue');
SELECT ajout_tag(1230, 1, 'Romance');
SELECT ajout_tag(356, 1, 'Drame');
SELECT ajout_tag(64969, 1, 'Romance');

SELECT ajout_abo(1, 1);
SELECT ajout_abo(2, 3);
SELECT ajout_abo(6, 2);
SELECT ajout_abo(7, 4);
