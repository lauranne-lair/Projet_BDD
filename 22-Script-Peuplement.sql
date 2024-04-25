
/*==============================================================*/
/* Peuplement des tables                                        */
/*==============================================================*/
-- FOURNISEUR ------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE peuplement_fournisseur AS
BEGIN
  INSERT INTO FOURNISSEUR (ID_FOURNISSEUR, NOM_FOURNISSEUR, ADRESSE_FOURNISSEUR, TELEPHONE_FOURNISSEUR, EMAIL_FOURNISSEUR)
  VALUES (1, 'Labo Inc.', '123 rue des Sciences', '555-1234', 'contact@labo-inc.com');

  INSERT INTO FOURNISSEUR (ID_FOURNISSEUR, NOM_FOURNISSEUR, ADRESSE_FOURNISSEUR, TELEPHONE_FOURNISSEUR, EMAIL_FOURNISSEUR)
  VALUES (2, 'BioTech SARL', '456 avenue de la Recherche', '555-5678', 'contact@biotech-sarl.com');

  COMMIT;
END peuplement_fournisseur;
/

--STOCK ------------------------------------------------------------------------
-- Cette procédure de peuplement crée 5 stocks différents vides 
CREATE OR REPLACE PROCEDURE P_stock deterministic AS
BEGIN
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (1, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (2, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (3, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (4, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (5, 0, 0, 0, 0);
END;
/

--LOT --------------------------------------------------------------------------
-- Cette procédure permet de créer 2 lots dans le stock 1 
TRUNCATE TABLE LOT;
CREATE OR REPLACE PROCEDURE P_Lot AS
    v_type_plaque INTEGER;  -- Déclarer une variable pour stocker le type de plaque
    
BEGIN
    FOR i IN 1..5 LOOP
        -- Générer un nombre aléatoire entre 1 et 2 pour choisir le type de plaque
        IF ROUND(DBMS_RANDOM.VALUE(1, 2)) = 1 THEN
            v_type_plaque := 96;  -- Si le nombre est 1, choisir le type 96
        ELSE
            v_type_plaque := 384; -- Sinon, choisir le type 384
        END IF;

        -- Insérer une ligne dans la table lot avec le type de plaque aléatoire
        INSERT INTO lot (id_lot, id_stock, date_livraison_lot, nb_plaque, type_plaque_lot)
        VALUES (i, 1, SYSDATE, 80, v_type_plaque); 
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- En cas d'erreur, afficher le message d'erreur
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Annuler les modifications en cas d'erreur
END;
/

Exec P_Lot(5);
--------------------------------------------------------------------------------

--ACHETER
--INSERT INTO ACHETER (ID_FOURNISSEUR, ID_LOT) VALUES (1, 1);
--INSERT INTO ACHETER (ID_FOURNISSEUR, ID_LOT) VALUES (2, 2);


--CHERCHEUR
CREATE OR REPLACE PROCEDURE PEUPLE_CHERCHEUR(nb_lignes IN NUMBER) AS
    id_equipe EQUIPE.ID_EQUIPE%TYPE;
    nom_c VARCHAR2(25);
    prenom_c VARCHAR2(25);
BEGIN
    FOR i IN 1..nb_lignes LOOP
        SELECT ID_EQUIPE INTO id_equipe FROM (SELECT ID_EQUIPE FROM EQUIPE ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;
        nom_c := DBMS_RANDOM.STRING('A', 10);
        prenom_c := DBMS_RANDOM.STRING('A', 10);
        
        IF ASCII(SUBSTR(nom_c, 1, 1)) BETWEEN 97 AND 122 THEN
            nom_c := INITCAP(nom_c);
        END IF;
    
        IF ASCII(SUBSTR(prenom_c, 1, 1)) BETWEEN 97 AND 122 THEN
            prenom_c := INITCAP(prenom_c);
        END IF;
    
        INSERT INTO CHERCHEUR(ID_CHERCHEUR, ID_EQUIPE, NOM_CHERCHEUR, PRENOM_CHERCHEUR)
        VALUES(SEQ_ID_CHERCHEUR.NEXTVAL, id_equipe, nom_c, prenom_c);
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

EXEC PEUPLE_CHERCHEUR(10);

--EQUIPE
CREATE OR REPLACE PROCEDURE INSERER_EQUIPE_ALEATOIRE (
  p_nb_equipes IN NUMBER
) IS
  p_adresse_equipe VARCHAR2(50);
  p_solde_equipe NUMBER;
BEGIN
  FOR i IN 1..p_nb_equipes LOOP
    -- Générer une adresse aléatoire
    p_adresse_equipe := DBMS_RANDOM.STRING('A', 10) || ' ' || DBMS_RANDOM.STRING('A', 10) || ' ' || DBMS_RANDOM.STRING('N', 4);

    -- Générer un solde aléatoire entre 1000 et 10000
    p_solde_equipe := TRUNC(DBMS_RANDOM.VALUE(1000, 10001));

    -- Insérer une nouvelle équipe avec des valeurs aléatoires
    INSERT INTO EQUIPE (ID_EQUIPE, ADRESSE_EQUIPE, SOLDE_EQUIPE)
    VALUES (SEQ_ID_EQUIPE.NEXTVAL, p_adresse_equipe, p_solde_equipe);
  END LOOP;

  COMMIT; -- Optionnel : commettre la transaction immédiatement après l'insertion
EXCEPTION
  WHEN OTHERS THEN
    -- Vous pouvez ajouter un traitement des erreurs personnalisé ici, comme la journalisation des erreurs
    RAISE; -- Re-lever l'exception pour propager l'erreur à l'appelant
END INSERER_EQUIPE_ALEATOIRE;
/

EXEC INSERER_EQUIPE_ALEATOIRE(10);

-- FACTURE
CREATE OR REPLACE PROCEDURE PEUPLE_FACTURE(nb_lignes IN NUMBER) DETERMINISTIC AS 
    id_equipe FACTURE.ID_EQUIPE%TYPE; 
BEGIN 
    FOR i IN 1..nb_lignes LOOP 
        SELECT ID_EQUIPE INTO id_equipe FROM (SELECT ID_EQUIPE FROM EQUIPE ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1; 
        INSERT INTO FACTURE(ID_FACTURE, ID_EQUIPE, DATE_FACTURE, MONTANT_FACTURE) 
        VALUES(SEQ_ID_FACTURE.NEXTVAL, id_equipe, TRUNC(SYSDATE, 'MM'), ROUND(DBMS_RANDOM.VALUE(1000, 10000))); 
    END LOOP; 
    COMMIT; 
END;
/
EXEC PEUPLE_FACTURE(10);

--TECHNICIEN
CREATE OR REPLACE PROCEDURE peuple_technicien(nb_lignes IN NUMBER) DETERMINISTIC AS
    id_technicien TECHNICIEN.ID_TECHNICIEN%TYPE;
    id_equipe TECHNICIEN.ID_EQUIPE%TYPE;
    nom_technicien TECHNICIEN.NOM_TECHNICIEN%TYPE;
    prenom_technicien TECHNICIEN.PRENOM_TECHNICIEN%TYPE;
BEGIN
    FOR i IN 1..nb_lignes LOOP
        id_technicien := i;

        SELECT ID_EQUIPE INTO id_equipe
        FROM EQUIPE
        WHERE ROWNUM = 1
        ORDER BY DBMS_RANDOM.VALUE;

        nom_technicien := 'Technicien' || i;
        prenom_technicien := 'Prénom' || i;

        -- Insertion des valeurs générées dans la table TECHNICIEN
        INSERT INTO TECHNICIEN (ID_TECHNICIEN, ID_EQUIPE, NOM_TECHNICIEN, PRENOM_TECHNICIEN)
        VALUES (id_technicien, id_equipe, nom_technicien, prenom_technicien);
    END LOOP;
    COMMIT; 
END;
/

--LISTE ATTENTE
INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE) VALUES (1, 10, 1, 5);

--APPAREIL
CREATE OR REPLACE PROCEDURE PEUPLEMENT_APPAREIL AS
  v_next_id_appareil NUMBER;
BEGIN
  SELECT NVL(MAX(ID_APPAREIL), 0) + 1 INTO v_next_id_appareil FROM APPAREIL;

  FOR i IN 1..10 LOOP -- Insérer 10 enregistrements, vous pouvez ajuster ce nombre
    INSERT INTO APPAREIL (ID_APPAREIL, ID_LISTE, ETAT_APPAREIL, POSITION_APPAREIL)
    VALUES (v_next_id_appareil, 1, 'Disponible', v_next_id_appareil); -- Vous pouvez ajuster les valeurs ici

    v_next_id_appareil := v_next_id_appareil + 1;
  END LOOP;

  COMMIT;
END PEUPLEMENT_APPAREIL;
/

EXEC PEUPLEMENT_APPAREIL;



--EXPERIENCE
CREATE OR REPLACE PROCEDURE PEUPLE_EXPERIENCE(nb_lignes IN NUMBER) AS
    id_technicien EXPERIENCE.ID_TECHNICIEN%TYPE;
    id_chercheur EXPERIENCE.ID_CHERCHEUR%TYPE;
    id_liste EXPERIENCE.ID_LISTE%TYPE;
    id_plaque EXPERIENCE.ID_PLAQUE%TYPE;
    type_plaque EXPERIENCE.TYPE_PLAQUE%TYPE;
    nb_groupe_slot_experience EXPERIENCE.NB_GROUPE_SLOT_EXPERIENCE%TYPE;
    nb_slots_par_groupe_experience EXPERIENCE.NB_SLOTS_PAR_GROUPE_EXPERIENCE%TYPE;
BEGIN
    FOR i IN 1..nb_lignes LOOP
        -- Sélectionner un ID_TECHNICIEN aléatoire
        SELECT ID_TECHNICIEN INTO id_technicien FROM TECHNICIEN ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY;

        -- Sélectionner un ID_CHERCHEUR aléatoire
        SELECT ID_CHERCHEUR INTO id_chercheur FROM CHERCHEUR ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY;

        -- Sélectionner un ID_LISTE aléatoire
        SELECT ID_LISTE INTO id_liste FROM LISTEATTENTE ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY;

        -- Sélectionner un ID_PLAQUE aléatoire
        SELECT ID_PLAQUE INTO id_plaque FROM PLAQUE ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY;

        -- Sélectionner un TYPE_PLAQUE aléatoire
        SELECT TYPE_PLAQUE INTO type_plaque FROM PLAQUE ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROWS ONLY;

        -- Générer un nombre aléatoire de groupes de slots pour l'expérience
        nb_groupe_slot_experience := DBMS_RANDOM.VALUE(1, 10);

        -- Générer un nombre aléatoire de slots par groupe pour l'expérience
        nb_slots_par_groupe_experience := DBMS_RANDOM.VALUE(1, 10);

        -- Insérer des données aléatoires dans la table EXPERIENCE
        INSERT INTO EXPERIENCE(ID_EXPERIENCE, ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, ID_PLAQUE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, DUREE_EXPERIENCE, DATE_DEMANDE_EXPERIENCE,
                               DATE_TRANSMISSION_RESULTAT, PRIORITE_EXPERIENCE, FREQUENCE_EXPERIENCE,
                               REPROGR_MAX_EXPERIENCE, COEFF_PRIX_PRIO_EXPERIENCE, VALEUR_BIAIS_A1,
                               VALEUR_BIAIS_A2, VALEUR_BIAIS_A3, MOYENNE_EXPERIENCE, ECART_TYPE_EXPERIENCE,
                               NB_RENOUVELLEMENT_EXPERIENCE)
        VALUES(seq_id_experience.NEXTVAL, id_liste, id_technicien, id_chercheur, type_plaque, id_plaque, nb_groupe_slot_experience, nb_slots_par_groupe_experience, 10,
               TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-10', 'YYYY-MM-DD'), 1,
               DBMS_RANDOM.VALUE(1, 10), 1, 1, 0.5, 0.7, 0.2, 50, 5, 3);
    END LOOP;
    COMMIT;
END PEUPLE_EXPERIENCE;
/

EXECUTE PEUPLE_EXPERIENCE(10);


--PLAQUE
CREATE OR REPLACE PROCEDURE peupler_table_plaques AS
    v_id_lot NUMBER;
    v_type_plaque NUMBER;
    v_nb_experience_plaque NUMBER;
    v_etat_plaque VARCHAR2(25);
BEGIN
    FOR i IN 1..10 LOOP -- Changer 10 au nombre de lignes que vous souhaitez insérer
        SELECT ID_LOT INTO v_id_lot FROM LOT WHERE ROWNUM = 1; -- Sélectionner une valeur existante pour ID_LOT
        v_type_plaque := CASE FLOOR(DBMS_RANDOM.VALUE(1, 2))
                            WHEN 1 THEN 96
                            ELSE 384
                         END;
        v_nb_experience_plaque := FLOOR(DBMS_RANDOM.VALUE(1, 100)); -- Remplacer 100 par le nombre maximum pour NB_EXPERIENCE_PLAQUE
        v_etat_plaque := CASE MOD(i, 3) -- Générer un état aléatoire
                            WHEN 0 THEN 'Bon'
                            WHEN 1 THEN 'Moyen'
                            ELSE 'Mauvais'
                         END;
        INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
        VALUES (LLAIR.SEQ_ID_PLAQUE.NEXTVAL, v_id_lot, v_type_plaque, v_nb_experience_plaque, v_etat_plaque);
    END LOOP;
    COMMIT; -- Valider les changements
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- En cas d'erreur, annuler les changements
        RAISE; -- Propager l'exception pour la gestion externe
END peupler_table_plaques;



TRUNCATE TABLE LOT;
TRUNCATE TABLE STOCK;
TRUNCATE TABLE PLAQUE;
begin
P_stock();
P_Lot();
peupler_table_plaques;
end; 
/






-- test insertion acceptation biais 
--INSERT INTO ListeAttente (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
--VALUES (2, 0, null, 0);

--exp ok :
--INSERT INTO Experience (ID_EXPERIENCE, ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, TYPE_EXPERIENCE, ETAT_EXPERIENCE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3, ECART_TYPE_EXPERIENCE)
--VALUES (1, 1, 1, 1, 'P96', 'Test', 'En cours', 1, 1, 0.5, 1.5, 0.4, 0.4);


--exp pas ok
--INSERT INTO Experience (ID_EXPERIENCE, ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, TYPE_EXPERIENCE, ETAT_EXPERIENCE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3, ECART_TYPE_EXPERIENCE)
--VALUES (2, 1, 1, 1, 'P96', 'Test', 'En cours', 1, 1, 0.5, 1.5, 0.8, 1.2);



--SELECT ID_EXPERIENCE, ETAT_EXPERIENCE FROM Experience;

Commit;