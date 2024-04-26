
/*==============================================================*/
/* Peuplement des tables                                        */
/*==============================================================*/
-- FOURNISEUR ------------------------------------------------------------------
TRUNCATE TABLE FOURNISSEUR;
CREATE OR REPLACE PROCEDURE peuplement_fournisseur AS
BEGIN
  INSERT INTO FOURNISSEUR (ID_FOURNISSEUR, NOM_FOURNISSEUR)
  VALUES (1, 'Labo Inc.');

  INSERT INTO FOURNISSEUR (ID_FOURNISSEUR, NOM_FOURNISSEUR)
  VALUES (2, 'BioTech SARL');

  COMMIT;
END peuplement_fournisseur;
/

exec peuplement_fournisseur;

--STOCK ------------------------------------------------------------------------
-- Cette procédure de peuplement crée 5 stocks différents vides
CREATE OR REPLACE PROCEDURE P_stock deterministic AS
BEGIN
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (seq_id_stock.NEXTVAL, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (seq_id_stock.NEXTVAL, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (seq_id_stock.NEXTVAL, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (seq_id_stock.NEXTVAL, 0, 0, 0, 0);
    INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96) VALUES (seq_id_stock.NEXTVAL, 0, 0, 0, 0);
END;
/
exec P_stock;

--LOT --------------------------------------------------------------------------
-- Cette procédure permet de créer 2 lots dans le stock 1 
CREATE OR REPLACE PROCEDURE peupler_table_lot AS
    v_id_stock NUMBER;
BEGIN
    FOR i IN 1..10 LOOP -- Changer 10 au nombre de lignes que vous souhaitez insérer
        SELECT ID_STOCK INTO v_id_stock FROM STOCK WHERE ROWNUM = 1; -- Sélectionner une valeur existante pour ID_STOCK
        INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
        VALUES (LLAIR.SEQ_ID_LOT.NEXTVAL, v_id_stock, SYSDATE, 80, CASE FLOOR(DBMS_RANDOM.VALUE(1, 2))
                                                                        WHEN 1 THEN 96
                                                                        ELSE 384
                                                                     END);
    END LOOP;
    COMMIT; -- Valider les changements
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- En cas d'erreur, annuler les changements
        RAISE; -- Propager l'exception pour la gestion externe
END peupler_table_lot;
/
exec peupler_table_lot;

Exec P_Lot;
--------------------------------------------------------------------------------

--PLAQUE
TRUNCATE TABLE PLAQUE;
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
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- En cas d'erreur, annuler les changements
        RAISE; -- Propager l'exception pour la gestion externe
END peupler_table_plaques;
/
exec peupler_table_plaques;

--CHERCHEUR
TRUNCATE TABLE CHERCHEUR;
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

--TECHNICIEN
TRUNCATE TABLE TECHNICIEN;
CREATE OR REPLACE PROCEDURE peuple_technicien(nb_lignes IN NUMBER) DETERMINISTIC AS
    id_technicien TECHNICIEN.ID_TECHNICIEN%TYPE;
    id_equipe TECHNICIEN.ID_EQUIPE%TYPE;
    nom_technicien TECHNICIEN.NOM_TECHNICIEN%TYPE;
    prenom_technicien TECHNICIEN.PRENOM_TECHNICIEN%TYPE;
BEGIN
    FOR i IN 1..nb_lignes LOOP
        SELECT seq_id_technicien.NEXTVAL INTO id_technicien FROM DUAL;

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
exec peuple_technicien(15);


-- FACTURE
TRUNCATE TABLE FACTURE;
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

--ACHETER
--INSERT INTO ACHETER (ID_FOURNISSEUR, ID_LOT) VALUES (1, 1);
--INSERT INTO ACHETER (ID_FOURNISSEUR, ID_LOT) VALUES (2, 2);

--LISTE ATTENTE
CREATE OR REPLACE PROCEDURE P_ListeAttente AS
BEGIN
  INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
  VALUES (1, 10, 1, 5);

  INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
  VALUES (2, 8, 2, 4);

  INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
  VALUES (3, 12, 3, 6);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors du peuplement de la table LISTEATTENTE : ' || SQLERRM);
    ROLLBACK;
END P_ListeAttente;
/
exec P_ListeAttente;

--EXPERIENCE
TRUNCATE TABLE EXPERIENCE;
CREATE OR REPLACE PROCEDURE PEUPLE_EXPERIENCE(nb_lignes IN NUMBER) AS
    id_technicien EXPERIENCE.ID_TECHNICIEN%TYPE;
    id_chercheur EXPERIENCE.ID_CHERCHEUR%TYPE;
    id_liste LISTEATTENTE.ID_LISTE%TYPE;
    id_plaque PLAQUE.ID_PLAQUE%TYPE;
    type_plaque PLAQUE.TYPE_PLAQUE%TYPE;
    nb_groupe_slot_experience NUMBER;
    nb_slots_par_groupe_experience NUMBER;
    type_experience VARCHAR2(20);
    etat_experience VARCHAR2(20);
    duree_experience NUMBER;
    date_demande_experience DATE;
    date_transmission_resultat DATE;
    priorite_experience NUMBER;
    frequence_experience NUMBER;
    reprogr_max_experience NUMBER;
    coeff_prix_prio_experience NUMBER;
    valeur_biais_a1 NUMBER;
    valeur_biais_a2 NUMBER;
    valeur_biais_a3 NUMBER;
    moyenne_experience NUMBER;
    ecart_type_experience NUMBER;
    nb_renouvellement_experience NUMBER;
    v_nb_exp_doublees NUMBER;
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
        nb_groupe_slot_experience := TRUNC(DBMS_RANDOM.VALUE(1, 10));

        -- Générer un nombre aléatoire de slots par groupe pour l'expérience
        nb_slots_par_groupe_experience := TRUNC(DBMS_RANDOM.VALUE(1, 10));

        -- Générer un type d'expérience aléatoire
        type_experience := CASE TRUNC(DBMS_RANDOM.VALUE(1, 2))
                             WHEN 1 THEN 'Colorimétrique'
                             ELSE 'Opacimétrique'
                          END;

        -- Générer un état d'expérience aléatoire
        etat_experience := CASE TRUNC(DBMS_RANDOM.VALUE(1, 5))
                    WHEN 1 THEN 'en cours'
                    WHEN 2 THEN 'à programmer'
                    WHEN 3 THEN 'effectuée'
                    WHEN 4 THEN 'validée'
                    ELSE 'ratée'
                    END;

        -- Générer une durée d'expérience aléatoire entre 1 et 10 jours
        duree_experience := TRUNC(DBMS_RANDOM.VALUE(1, 10));

        -- Générer une date de demande d'expérience aléatoire dans les 30 derniers jours
        date_demande_experience := TRUNC(SYSDATE) - TRUNC(DBMS_RANDOM.VALUE(1, 30));

        -- Générer une date de transmission de résultat aléatoire dans les 10 prochains jours
        date_transmission_resultat := TRUNC(SYSDATE) + TRUNC(DBMS_RANDOM.VALUE(1, 10));

        -- Générer une priorité d'expérience aléatoire entre 1 et 5
        priorite_experience := TRUNC(DBMS_RANDOM.VALUE(1, 5));

        -- Générer une fréquence d'expérience aléatoire entre 1 et 10
        frequence_experience := TRUNC(DBMS_RANDOM.VALUE(1, 10));

        -- Générer un nombre maximal de reprogrammations d'expérience aléatoire entre 0 et 3
        reprogr_max_experience := TRUNC(DBMS_RANDOM.VALUE(0, 3));

        -- Générer un coefficient de prix prioritaire d'expérience aléatoire entre 1 et 5
        IF priorite_experience > 1 THEN
            -- Calculer le coefficient de prix prioritaire en fonction des expériences en attente
            SELECT COUNT(*) INTO coeff_prix_prio_experience FROM EXPERIENCE WHERE ETAT_EXPERIENCE = 'en attente';
            IF coeff_prix_prio_experience = 0 THEN
                coeff_prix_prio_experience := 1; -- Affecter une valeur par défaut si aucun enregistrement en attente
            ELSE
                coeff_prix_prio_experience := (coeff_prix_prio_experience + v_nb_exp_doublees) / coeff_prix_prio_experience;
            END IF;
        ELSE
            coeff_prix_prio_experience := 1;
        END IF;

        -- Générer des valeurs de biais aléatoires pour l'expérience
        valeur_biais_a1 := DBMS_RANDOM.VALUE(0.0, 1.0);
        valeur_biais_a2 := DBMS_RANDOM.VALUE(valeur_biais_a1, 1.0);
        valeur_biais_a3 := DBMS_RANDOM.VALUE(0.0, 1.0);

        -- Générer une moyenne d'expérience aléatoire entre 0 et 100
        moyenne_experience := TRUNC(DBMS_RANDOM.VALUE(0, 100));

        -- Générer un écart type d'expérience aléatoire entre 0 et 20
        ecart_type_experience := TRUNC(DBMS_RANDOM.VALUE(0, 20));

        -- Générer un nombre de renouvellements d'expérience aléatoire entre 0 et 3
        nb_renouvellement_experience := TRUNC(DBMS_RANDOM.VALUE(0, 3));

        -- Insérer des données aléatoires dans la table EXPERIENCE
        INSERT INTO EXPERIENCE(ID_EXPERIENCE, ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, ID_PLAQUE, TYPE_EXPERIENCE, ETAT_EXPERIENCE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, DEB_EXPERIENCE, FIN_EXPERIENCE, DUREE_EXPERIENCE, DATE_DEMANDE_EXPERIENCE, DATE_TRANSMISSION_RESULTAT, PRIORITE_EXPERIENCE, FREQUENCE_EXPERIENCE, REPROGR_MAX_EXPERIENCE, COEFF_PRIX_PRIO_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3, MOYENNE_EXPERIENCE, ECART_TYPE_EXPERIENCE, NB_RENOUVELLEMENT_EXPERIENCE)
        VALUES(seq_id_experience.NEXTVAL, id_liste, id_technicien, id_chercheur, type_plaque, id_plaque, type_experience, etat_experience, nb_groupe_slot_experience, nb_slots_par_groupe_experience, SYSDATE, SYSDATE + duree_experience, duree_experience, date_demande_experience, date_transmission_resultat, priorite_experience, frequence_experience, reprogr_max_experience, coeff_prix_prio_experience, valeur_biais_a1, valeur_biais_a2, valeur_biais_a3, moyenne_experience, ecart_type_experience, nb_renouvellement_experience);
    END LOOP;
COMMIT;
END PEUPLE_EXPERIENCE;
/


EXEC PEUPLE_EXPERIENCE(10);

--APPAREIL
TRUNCATE TABLE APPAREIL;
CREATE OR REPLACE PROCEDURE PEUPLEMENT_APPAREIL AS
  v_next_id_appareil NUMBER;
BEGIN
  SELECT NVL(MAX(ID_APPAREIL), 0) + 1 INTO v_next_id_appareil FROM APPAREIL;

  FOR i IN 1..10 LOOP -- Insérer 10 enregistrements, vous pouvez ajuster ce nombre
    INSERT INTO APPAREIL (ID_APPAREIL, ID_LISTE, ETAT_APPAREIL, POSITION_APPAREIL)
    VALUES (v_next_id_appareil, 1, 'Disponible', v_next_id_appareil); -- Vous pouvez ajuster les valeurs ici

    v_next_id_appareil := v_next_id_appareil + 1;
  END LOOP;

END PEUPLEMENT_APPAREIL;
/
EXEC PEUPLEMENT_APPAREIL;



/*TRUNCATE TABLE LOT;
TRUNCATE TABLE STOCK;
TRUNCATE TABLE PLAQUE;
begin
P_stock();
P_Lot();
peupler_table_plaques;
end; 
/


INSERT INTO stock (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96)VALUES (1,0,0,0,0);
    
ALTER TRIGGER T_arrivee_lot COMPILE;

INSERT INTO lot (id_stock, date_livraison_lot, nb_plaque, type_plaque_lot)
        VALUES (1, SYSDATE, 80, 96); 
        
*/





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