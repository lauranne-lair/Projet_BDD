-- Supprimer tous les déclencheurs de votre liste
DROP TRIGGER T_type_plaque;
DROP TRIGGER T_check_valeur_biais2;
DROP TRIGGER T_nb_slots_groupe;
DROP TRIGGER T_valpos_ACHETER;
DROP TRIGGER T_valpos_APPAREIL;
DROP TRIGGER T_valpos_CHERCHEUR;
DROP TRIGGER T_valpos_EXPERIENCE;
DROP TRIGGER T_valpos_FACTURE;
DROP TRIGGER T_valpos_FOURNISSEUR;
DROP TRIGGER T_valpos_GROUPESLOT;
DROP TRIGGER T_valpos_LISTEATTENTE;
DROP TRIGGER T_valpos_LOT;
DROP TRIGGER T_valpos_PLAQUE;
DROP TRIGGER T_valpos_SLOT;
DROP TRIGGER T_valpos_STOCK;
DROP TRIGGER T_valpos_TECHNICIEN;
--Resultat
DROP TRIGGER T_resultat_experience;
-- GROUPESLOT--
DROP TRIGGER after_experience_update;
--LOT --
DROP TRIGGER T_arrivee_lot;
DROP TRIGGER T_stock_plaque;
-- Facture--
DROP TRIGGER T_FACTURE;
DROP TRIGGER UPDATE_SOLDE_EQUIPE;
-- Appareil
DROP TRIGGER T_APPAREIL;
DROP TRIGGER T_panne_app;
--Expérience --
DROP TRIGGER T_LISTE_ATTENTE;
--Expérience
DROP TRIGGER T_lancement_experience;
DROP TRIGGER T_prix_experience;
DROP TRIGGER Contrainte_nb_releves_photo;
DROP TRIGGER Acceptation_biais;
--DROP TRIGGER refus_plaque_trigger;



/*========================================*/
--              TRIGGER DE CHECK
/*========================================*/
CREATE OR REPLACE TRIGGER T_valeur_biais2
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    invalid_biais_value EXCEPTION;
BEGIN
    IF :NEW.VALEUR_BIAIS_A2 < :NEW.VALEUR_BIAIS_A1 THEN
        RAISE invalid_biais_value;
    END IF;
EXCEPTION
    WHEN invalid_biais_value THEN
        RAISE_APPLICATION_ERROR(-20001, 'La valeur de biais A2 doit être supérieure ou égale à la valeur de biais A1');
END;
/

-- Trigger nombre de slots par plaque : Erreur si le nombre de slots par plaque n'est pas équivalent 
CREATE OR REPLACE TRIGGER T_nb_slots_groupe
BEFORE INSERT OR UPDATE ON GROUPESLOT
FOR EACH ROW
DECLARE
    invalid_nb_slots EXCEPTION;
    v_type_plaque PLAQUE.TYPE_PLAQUE%TYPE;
BEGIN
    SELECT TYPE_PLAQUE INTO v_type_plaque FROM PLAQUE WHERE ID_PLAQUE = :NEW.ID_PLAQUE;
    IF v_type_plaque = 96 AND :NEW.NB_SLOTS NOT IN (1, 2, 3, 4, 6, 8, 12) THEN
        RAISE invalid_nb_slots;
    ELSIF v_type_plaque = 384 AND :NEW.NB_SLOTS NOT IN (1, 2, 3, 4, 6, 8, 12, 16, 24) THEN
        RAISE invalid_nb_slots;
    END IF;
EXCEPTION
    WHEN invalid_nb_slots THEN
        RAISE_APPLICATION_ERROR(-20002, 'Le nombre de slots par groupe doit être cohérent avec le type de plaque');
END;
/
-- Trigger pour avoir aucun nombre négatif dans les tables 
-- Table acheter : 
CREATE OR REPLACE TRIGGER T_valpos_ACHETER
BEFORE INSERT OR UPDATE ON ACHETER
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_FOURNISSEUR < 0 OR :NEW.ID_LOT < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20001, 'La valeur ne peut pas être négative dans la table ACHETER');
END;
/
--APPAREIL
CREATE OR REPLACE TRIGGER T_valpos_APPAREIL
BEFORE INSERT OR UPDATE ON APPAREIL
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
    appareil_non_disponible EXCEPTION;
BEGIN
    IF :NEW.ID_APPAREIL < 0 OR :NEW.ID_LISTE < 0 OR :NEW.POSITION_APPAREIL < 0 THEN
        RAISE negative_value;
    END IF;

EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20002, 'La valeur ne peut pas être négative dans la table APPAREIL');
    WHEN appareil_non_disponible THEN
        RAISE_APPLICATION_ERROR (-20003, 'L''appareil n''est pas disponible');
END;
/
--CHERCHEUR 
CREATE OR REPLACE TRIGGER T_valpos_CHERCHEUR
BEFORE INSERT OR UPDATE ON CHERCHEUR
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_CHERCHEUR < 0 OR :NEW.ID_EQUIPE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20003, 'La valeur ne peut pas être négative dans la table CHERCHEUR');
END;
/
--EXPERIENCE
CREATE OR REPLACE TRIGGER T_valpos_EXPERIENCE
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_EXPERIENCE < 0 OR :NEW.ID_LISTE < 0 OR :NEW.ID_TECHNICIEN < 0 OR :NEW.ID_CHERCHEUR < 0 OR
       :NEW.DUREE_EXPERIENCE < 0 OR :NEW.PRIORITE_EXPERIENCE < 0 OR :NEW.FREQUENCE_EXPERIENCE < 0 OR
       :NEW.REPROGR_MAX_EXPERIENCE < 0 OR :NEW.COEFF_PRIX_PRIO_EXPERIENCE < 0 OR
       :NEW.VALEUR_BIAIS_A1 < 0.0 OR :NEW.VALEUR_BIAIS_A2 < 0.0 OR
       :NEW.VALEUR_BIAIS_A3 < 0.0 OR :NEW.MOYENNE_EXPERIENCE < 0 OR
       :NEW.ECART_TYPE_EXPERIENCE < 0 OR :NEW.NB_RENOUVELLEMENT_EXPERIENCE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20005, 'La valeur ne peut pas être négative dans la table EXPERIENCE');
END;
/
--FACTURE
CREATE OR REPLACE TRIGGER T_valpos_FACTURE
BEFORE INSERT OR UPDATE ON FACTURE
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_FACTURE < 0 OR :NEW.ID_EQUIPE < 0 OR :NEW.MONTANT_FACTURE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20006, 'La valeur ne peut pas être négative dans la table FACTURE');
END;
/
--FOURNISSEUR
CREATE OR REPLACE TRIGGER T_valpos_FOURNISSEUR
BEFORE INSERT OR UPDATE ON FOURNISSEUR
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_FOURNISSEUR < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20007, 'La valeur ne peut pas être négative dans la table FOURNISSEUR');
END;
/
--GROUPESLOT
CREATE OR REPLACE TRIGGER T_valpos_GROUPESLOT
BEFORE INSERT OR UPDATE ON GROUPESLOT
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_GROUPE < 0 OR :NEW.ID_EXPERIENCE < 0 OR :NEW.ID_PLAQUE < 0 OR
       :NEW.MOYENNE_GROUPE < 0 OR :NEW.ECART_TYPE_GROUPE < 0 OR :NEW.VALIDITE_GROUPE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20008, 'La valeur ne peut pas être négative dans la table GROUPESLOT');
END;
/
--LISTEATTENTE
CREATE OR REPLACE TRIGGER T_valpos_LISTEATTENTE
BEFORE INSERT OR UPDATE ON LISTEATTENTE
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_LISTE < 0 OR :NEW.NB_EXP_ATTENTE < 0 OR :NEW.EXPERIENCE < 0 OR :NEW.NB_EXP_DOUBLE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20009, 'La valeur ne peut pas être négative dans la table LISTEATTENTE');
END;
/
--LOT
CREATE OR REPLACE TRIGGER T_valpos_LOT
BEFORE INSERT OR UPDATE ON LOT
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_LOT < 0 OR :NEW.ID_STOCK < 0 OR :NEW.NB_PLAQUE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20010, 'La valeur ne peut pas être négative dans la table LOT');
END;
/
--PLAQUE
CREATE OR REPLACE TRIGGER T_valpos_PLAQUE
BEFORE INSERT OR UPDATE ON PLAQUE
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_PLAQUE < 0 OR :NEW.ID_LOT < 0 OR :NEW.TYPE_PLAQUE < 0 OR :NEW.NB_EXPERIENCE_PLAQUE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20010, 'La valeur ne peut pas être négative dans la table PLAQUE');
END;
/
--SLOT
CREATE OR REPLACE TRIGGER T_valpos_SLOT
BEFORE INSERT OR UPDATE ON SLOT
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_SLOT < 0 OR :NEW.ID_GROUPE < 0 OR :NEW.NUMERO_SLOT < 0 OR
       :NEW.POSITION_X_SLOT < 0 OR :NEW.POSITION_Y_SLOT < 0 OR :NEW.RM_SLOT < 0 OR
       :NEW.RD_SLOT < 0 OR :NEW.VM_SLOT < 0 OR :NEW.VD_SLOT < 0 OR
       :NEW.BM_SLOT < 0 OR :NEW.BD_SLOT < 0 OR :NEW.TM_SLOT < 0 OR :NEW.TD_SLOT < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20011, 'La valeur ne peut pas être négative dans la table SLOT');
END;
/
--STOCK
CREATE OR REPLACE TRIGGER T_valpos_STOCK
BEFORE INSERT OR UPDATE ON STOCK
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_STOCK < 0 OR :NEW.QUANTITE_P384 < 0 OR :NEW.QUANTITE_P96 < 0 OR
       :NEW.VOL_DERNIER_TRI_P384 < 0 OR :NEW.VOL_DERNIER_TRI_P96 < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20012, 'La valeur ne peut pas être négative dans la table STOCK');
END;
/
--TECHNICIEN
CREATE OR REPLACE TRIGGER T_valpos_TECHNICIEN
BEFORE INSERT OR UPDATE ON TECHNICIEN
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_TECHNICIEN < 0 OR :NEW.ID_EQUIPE < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20013, 'La valeur ne peut pas être négative dans la table TECHNICIEN');
END;
/

/*========================================*/
--              TRIGGER
/*========================================*/

-- RESULTAT--
-- Trigger selon le résultat d'une expérience
CREATE OR REPLACE TRIGGER T_resultat_experience
AFTER INSERT OR UPDATE ON RESULTAT_EXPERIENCE
FOR EACH ROW
DECLARE
    v_id_experience RESULTAT_EXPERIENCE.ID_EXPERIENCE%TYPE;
    v_nb_resultats_refuses NUMBER;
    v_nb_resultats_totaux NUMBER;
BEGIN
    SELECT ID_EXPERIENCE INTO v_id_experience FROM RESULTAT_EXPERIENCE WHERE ID_RESULTAT = :NEW.ID_RESULTAT;
    SELECT COUNT(*) INTO v_nb_resultats_refuses FROM RESULTAT_EXPERIENCE WHERE ID_EXPERIENCE = v_id_experience AND MOYENNE < 10; -- Exemple d'un critère pour déterminer un résultat refusé
    SELECT COUNT(*) INTO v_nb_resultats_totaux FROM RESULTAT_EXPERIENCE WHERE ID_EXPERIENCE = v_id_experience;
    IF v_nb_resultats_refuses = 0 THEN
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'validée' WHERE ID_EXPERIENCE = v_id_experience;
    ELSIF v_nb_resultats_refuses / v_nb_resultats_totaux > 0.3 THEN
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'ratéé' WHERE ID_EXPERIENCE = v_id_experience;
    ELSE
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'à vérifier' WHERE ID_EXPERIENCE = v_id_experience; 
    END IF;
END;
/

-- GROUPESLOT--
-- Trigger de validation de l'expérience en passant tout d'abord par la validation des slots et des groupes de slots
CREATE OR REPLACE TRIGGER after_experience_update
AFTER UPDATE OF VALIDITE_GROUPE ON GROUPESLOT
FOR EACH ROW
DECLARE
  v_nb_groupes_valides NUMBER;
  v_nb_groupes_necessaires NUMBER;
  v_nb_slots_valides NUMBER;
  v_nb_slots_necessaires NUMBER;
BEGIN
  -- Vérifier que tous les groupes de slots nécessaires ont été validés
  SELECT COUNT(*), COUNT(CASE WHEN g.VALIDITE_GROUPE = 'validée' THEN 1 END)
  INTO v_nb_groupes_necessaires, v_nb_groupes_valides
  FROM GROUPESLOT g
  JOIN EXPERIENCE e ON g.ID_EXPERIENCE = e.ID_EXPERIENCE
  WHERE e.ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

  IF v_nb_groupes_valides < v_nb_groupes_necessaires THEN
    RAISE_APPLICATION_ERROR(-20001, 'Tous les groupes de slots nécessaires n''ont pas été validés.');
  END IF;

  -- Vérifier que tous les slots nécessaires ont été validés
  SELECT COUNT(*), COUNT(CASE WHEN s.VALIDE = 'validée' THEN 1 END)
  INTO v_nb_slots_necessaires, v_nb_slots_valides
  FROM SLOT s
  JOIN GROUPESLOT g ON s.ID_GROUPE = g.ID_GROUPE
  JOIN EXPERIENCE e ON g.ID_EXPERIENCE = e.ID_EXPERIENCE
  WHERE e.ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

  IF v_nb_slots_valides < v_nb_slots_necessaires THEN
    RAISE_APPLICATION_ERROR(-20002, 'Tous les slots nécessaires n''ont pas été validés.');
  END IF;

  -- Si tous les groupes de slots et slots nécessaires ont été validés, mettre à jour l'état de l'expérience en conséquence
  UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'validée' WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
END;
/

--LOT --
-- Trigger d'automatisation qui met à jour le stock suite à l'ajout d'un lot à la BDD   
--CREATE OR REPLACE TRIGGER T_arrivee_lot
--AFTER INSERT ON LOT
--FOR EACH ROW
--DECLARE
--    v_quantite_stock PLS_INTEGER := 0;
--BEGIN
--    IF :NEW.TYPE_PLAQUE_LOT = 96 THEN
--        SELECT QUANTITE_P96 INTO v_quantite_stock
--        FROM STOCK
--        WHERE ID_STOCK = :NEW.ID_STOCK;
--
--        IF v_quantite_stock IS NULL OR v_quantite_stock = 0 THEN
--            RAISE_APPLICATION_ERROR(-20001, 'Le stock sélectionné ne contient pas de plaques 96 slots.');
--        ELSE
--            UPDATE STOCK
--            SET QUANTITE_P96 = QUANTITE_P96 + :NEW.NB_PLAQUE
--            WHERE ID_STOCK = :NEW.ID_STOCK;
--        END IF;
--    ELSIF :NEW.TYPE_PLAQUE_LOT = 384 THEN
--        SELECT QUANTITE_P384 INTO v_quantite_stock
--        FROM STOCK
--        WHERE ID_STOCK = :NEW.ID_STOCK;
--
--        -- Initialiser v_quantite_stock à zéro avant la requête SELECT
--        v_quantite_stock := 0;
--
--        IF v_quantite_stock IS NULL OR v_quantite_stock = 0 THEN
--            RAISE_APPLICATION_ERROR(-20002, 'Le stock sélectionné ne contient pas de plaques 384 slots.');
--        ELSE
--            UPDATE STOCK
--            SET QUANTITE_P384 = QUANTITE_P384 + :NEW.NB_PLAQUE
--            WHERE ID_STOCK = :NEW.ID_STOCK;
--        END IF;
--    ELSE
--        RAISE_APPLICATION_ERROR(-20003, 'Le type de plaque du lot ajouté est invalide.');
--    END IF;
--END;
--/

CREATE OR REPLACE TRIGGER T_arrivee_lot
AFTER INSERT ON LOT
FOR EACH ROW
BEGIN
    IF :NEW.TYPE_PLAQUE_LOT = 96 THEN
        UPDATE STOCK
        SET QUANTITE_P96 = QUANTITE_P96 + 80 
        WHERE ID_STOCK = :NEW.ID_STOCK;
    ELSIF :NEW.TYPE_PLAQUE_LOT = 384 THEN
        UPDATE STOCK
        SET QUANTITE_P384 = QUANTITE_P384 + 80
        WHERE ID_STOCK = :NEW.ID_STOCK;
    ELSE 
        RAISE_APPLICATION_ERROR(-20001, 'Erreur stockage nouveau lot ');
    END IF;
END;
/



-- FACTURE --
-- Trigger Facture, date non nul et égale a 01 uniquement, equipe non null      --ok
CREATE OR REPLACE TRIGGER T_FACTURE
BEFORE INSERT ON FACTURE
FOR EACH ROW
BEGIN
  IF :NEW.MONTANT_FACTURE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20004, 'Le montant de la facture ne peut pas être nul.');
  END IF;

  IF :NEW.DATE_FACTURE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'La date de facturation ne peut pas être nulle.');
  END IF;

  IF TO_CHAR(:NEW.DATE_FACTURE, 'DD') != '01' THEN
    RAISE_APPLICATION_ERROR(-20000, 'La date de facturation doit être le premier jour du mois.');
  END IF;
END;
/
-- Trigger modification du solde équipe   ok          
CREATE OR REPLACE TRIGGER UPDATE_SOLDE_EQUIPE
AFTER INSERT ON FACTURE
FOR EACH ROW
BEGIN
  UPDATE EQUIPE
     SET SOLDE_EQUIPE = SOLDE_EQUIPE + :NEW.MONTANT_FACTURE
   WHERE ID_EQUIPE = :NEW.ID_EQUIPE;
END;
/

-- APPAREIL --
-- Trigger appareil ok                
CREATE OR REPLACE TRIGGER T_APPAREIL
BEFORE INSERT ON APPAREIL
FOR EACH ROW
DECLARE
   LAST_RANG INTEGER;
BEGIN
  SELECT MAX(POSITION_APPAREIL) INTO  LAST_RANG FROM APPAREIL;
  IF  LAST_RANG IS NULL THEN
     LAST_RANG := 0;
  END IF;
  :NEW.POSITION_APPAREIL :=  LAST_RANG + 1;
  :NEW.ETAT_APPAREIL := 'disponible';
END;
/
/*Contrainte sur le changement d'état des expériences lorsque l'appareil est en panne a faire*/
CREATE OR REPLACE TRIGGER T_panne_app
BEFORE UPDATE OF ETAT_APPAREIL ON APPAREIL
FOR EACH ROW
BEGIN
    IF :OLD.ETAT_APPAREIL != 'en panne' AND :NEW.ETAT_APPAREIL = 'en panne' THEN
        UPDATE EXPERIENCE
        SET ETAT_EXPERIENCE = 'à programmer'
        WHERE ID_APPAREIL = :NEW.ID_APPAREIL
        AND ETAT_EXPERIENCE = 'programmée';
    END IF;
END;
/

-- EXPERIENCE
--liste d'attente 
--ok
CREATE OR REPLACE TRIGGER T_LISTE_ATTENTE
AFTER INSERT ON EXPERIENCE
FOR EACH ROW
DECLARE
  v_nb_exp_attente  NUMBER;
BEGIN
  -- Récupérer le nombre actuel d'expériences en attente pour la liste concernée
  SELECT NB_EXP_ATTENTE
  INTO v_nb_exp_attente
  FROM LISTEATTENTE
  WHERE ID_LISTE = :NEW.ID_LISTE;

  -- Mettre à jour le nombre d'expériences en attente pour la liste concernée
  UPDATE LISTEATTENTE
  SET NB_EXP_ATTENTE = v_nb_exp_attente + 1
  WHERE ID_LISTE = :NEW.ID_LISTE;
END;
/
--Triger d'automatisation pour les expériences :
-- ok
CREATE OR REPLACE TRIGGER T_lancement_experience
AFTER INSERT ON EXPERIENCE
FOR EACH ROW
DECLARE
  v_id_plaque PLAQUE.ID_PLAQUE%TYPE;
  v_type_plaque PLAQUE.TYPE_PLAQUE%TYPE;
BEGIN
  -- Sélectionner une plaque disponible en fonction du type de plaque requis par l'expérience
  SELECT p.ID_PLAQUE, p.TYPE_PLAQUE
  INTO v_id_plaque, v_type_plaque
  FROM PLAQUE p
  JOIN LOT l ON p.ID_LOT = l.ID_LOT
  WHERE p.ETAT_PLAQUE = 'Disponible'
  AND l.TYPE_PLAQUE_LOT = :NEW.TYPE_PLAQUE
  ORDER BY l.DATE_LIVRAISON_LOT ASC
  FETCH FIRST 1 ROWS ONLY;

  -- Mettre à jour l'état de la plaque sélectionnée
  UPDATE PLAQUE SET ETAT_PLAQUE = 'Utilisée' WHERE ID_PLAQUE = v_id_plaque;

  -- Insérer un groupe de slots pour chaque groupe de slots nécessaire pour l'expérience
  FOR i IN 1..:NEW.NB_GROUPE_SLOT_EXPERIENCE LOOP
    INSERT INTO GROUPESLOT (ID_EXPERIENCE, ID_PLAQUE, MOYENNE_GROUPE, ECART_TYPE_GROUPE, VALIDITE_GROUPE)
    VALUES (:NEW.ID_EXPERIENCE, v_id_plaque, NULL, NULL, 'Non validé');

    -- Insérer des slots pour chaque slot nécessaire dans le groupe de slots
    FOR j IN 1..:NEW.NB_SLOTS_PAR_GROUPE_EXPERIENCE LOOP
      INSERT INTO SLOT (ID_GROUPE, COULEUR_SLOT, NUMERO_SLOT, POSITION_X_SLOT, POSITION_Y_SLOT, RM_SLOT, RD_SLOT, VM_SLOT, VD_SLOT, BM_SLOT, BD_SLOT, TM_SLOT, TD_SLOT, VALIDE)
      VALUES (seq_id_groupeslot.CURRVAL, NULL, j, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Non validé');
    END LOOP;
  END LOOP;
END;
/


// CONTRAINTE SUR LE PRIX DE L'EXPERIENCE
--ok
CREATE OR REPLACE TRIGGER T_prix_experience
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    v_nb_exp_en_attente NUMBER;
    v_nb_exp_doublees NUMBER;
    v_coeff_prix_prio NUMBER; 
BEGIN
    SELECT COUNT(*) INTO v_nb_exp_en_attente FROM EXPERIENCE WHERE ETAT_EXPERIENCE = 'en cours';
    SELECT COUNT(*) INTO v_nb_exp_doublees FROM EXPERIENCE WHERE ETAT_EXPERIENCE = 'en cours' AND PRIORITE_EXPERIENCE > :NEW.PRIORITE_EXPERIENCE;
    IF :NEW.PRIORITE_EXPERIENCE > 1 THEN
        v_coeff_prix_prio := (v_nb_exp_en_attente + v_nb_exp_doublees) / v_nb_exp_en_attente;
    ELSE
        v_coeff_prix_prio := 1;
    END IF;
    :NEW.COEFF_PRIX_PRIO_EXPERIENCE := v_coeff_prix_prio;
END;
/

--Vérifie si le produit du nombre de renouvellements d'expérience par la valeur du biais A3  est inférieur à la valeur du biais A3. 
--En fonction du résultat, il met à jour l'état de l'expérience  en 'Acceptée' ou 'Refusée'.   
--ok
CREATE OR REPLACE TRIGGER Contrainte_nb_releves_photo
BEFORE INSERT OR UPDATE ON Experience
FOR EACH ROW
DECLARE
    d NUMBER;
    f NUMBER;
    a3 NUMBER;
    n NUMBER;
    rejected_count NUMBER;
    accepted_count NUMBER;
    mean NUMBER;
    stddev NUMBER;
    result NUMBER;
BEGIN
    -- Retrieve the values of d, f, and a3 from the current row
    d := :NEW.DUREE_EXPERIENCE;
    f := :NEW.FREQUENCE_EXPERIENCE;
    a3 := :NEW.VALEUR_BIAIS_A3;

    -- Calculate the total number of photometric results
    n := ROUND(d / f);

    -- Calculate the mean and standard deviation of the photometric results
    SELECT AVG(result), STDDEV(result)
    INTO mean, stddev
    FROM (
        SELECT result
        FROM (
            SELECT :NEW.ID_EXPERIENCE id_experience,
                   DEB_EXPERIENCE + (ROW_NUMBER() OVER (ORDER BY DEB_EXPERIENCE) - 1) * (:NEW.DUREE_EXPERIENCE / :NEW.FREQUENCE_EXPERIENCE) / (24 * 60) date_resultat,
                   CASE
                       WHEN TYPE_EXPERIENCE = 'Cinétique' THEN
                           MOYENNE_EXPERIENCE + VALEUR_BIAIS_A1 * (:NEW.DUREE_EXPERIENCE - (ROW_NUMBER() OVER (ORDER BY DEB_EXPERIENCE) - 1) * (:NEW.DUREE_EXPERIENCE / :NEW.FREQUENCE_EXPERIENCE)) + VALEUR_BIAIS_A2 * POWER((:NEW.DUREE_EXPERIENCE - (ROW_NUMBER() OVER (ORDER BY DEB_EXPERIENCE) - 1) * (:NEW.DUREE_EXPERIENCE / :NEW.FREQUENCE_EXPERIENCE)), 2)
                       ELSE
                           MOYENNE_EXPERIENCE
                   END result
            FROM Experience
            WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE
            ORDER BY DEB_EXPERIENCE
        )
        WHERE ROWNUM <= n
    );

    -- Calculate the number of accepted and rejected photometric results
    SELECT COUNT(CASE
                WHEN result BETWEEN mean - stddev AND mean + stddev THEN 1
              END) accepted_count,
           COUNT(CASE
                WHEN result NOT BETWEEN mean - stddev AND mean + stddev THEN 1
              END) rejected_count
    INTO accepted_count, rejected_count
    FROM (
        SELECT result
        FROM (
            SELECT :NEW.ID_EXPERIENCE id_experience,
                   DEB_EXPERIENCE + (ROW_NUMBER() OVER (ORDER BY DEB_EXPERIENCE) - 1) * (:NEW.DUREE_EXPERIENCE / :NEW.FREQUENCE_EXPERIENCE) / (24 * 60) date_resultat,
                   CASE
                       WHEN TYPE_EXPERIENCE = 'Cinétique' THEN
                           MOYENNE_EXPERIENCE + VALEUR_BIAIS_A1 * (:NEW.DUREE_EXPERIENCE - (ROW_NUMBER() OVER (ORDER BY DEB_EXPERIENCE) - 1) * (:NEW.DUREE_EXPERIENCE / :NEW.FREQUENCE_EXPERIENCE)) + VALEUR_BIAIS_A2 * POWER((:NEW.DUREE_EXPERIENCE - (ROW_NUMBER() OVER (ORDER BY DEB_EXPERIENCE) - 1) * (:NEW.DUREE_EXPERIENCE / :NEW.FREQUENCE_EXPERIENCE)), 2)
                       ELSE
                           MOYENNE_EXPERIENCE
                   END result
            FROM Experience
            WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE
            ORDER BY DEB_EXPERIENCE
        )
        WHERE ROWNUM <= n
    );

    -- Check if the number of rejected results is less than a3N
    IF rejected_count < a3 * n THEN
        :NEW.ETAT_EXPERIENCE := 'Acceptée';
    ELSE
        :NEW.ETAT_EXPERIENCE := 'Refusée';
    END IF;
END;
/

-- Trigger pour respecter les règles imposées sur les valeurs entre les biais 
--ok
CREATE OR REPLACE TRIGGER Acceptation_biais
BEFORE INSERT OR UPDATE OF VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3, ECART_TYPE_EXPERIENCE ON Experience
FOR EACH ROW
DECLARE
  v_resultat_experience VARCHAR2(25);
BEGIN
  IF :NEW.ECART_TYPE_EXPERIENCE < :NEW.VALEUR_BIAIS_A1 THEN
    v_resultat_experience := 'Accepté';
  ELSIF :NEW.VALEUR_BIAIS_A1 <= :NEW.ECART_TYPE_EXPERIENCE AND :NEW.ECART_TYPE_EXPERIENCE <= :NEW.VALEUR_BIAIS_A2 THEN
    v_resultat_experience := 'Refusé';
  ELSIF :NEW.VALEUR_BIAIS_A2 < :NEW.ECART_TYPE_EXPERIENCE THEN
    v_resultat_experience := 'Plaque refusée';
  END IF;

  :NEW.ETAT_EXPERIENCE := v_resultat_experience;
END;
/

-- Trigger freq observation  ok
CREATE OR REPLACE PROCEDURE Calcul_frequence_observation(
    p_id_experience IN NUMBER,
    p_result OUT NUMBER
) AS
    d NUMBER;
    f NUMBER;
BEGIN
    -- Retrieve the values of d and f from the Experience table
    SELECT DUREE_EXPERIENCE, FREQUENCE_EXPERIENCE
    INTO d, f
    FROM Experience
    WHERE ID_EXPERIENCE = p_id_experience;

    -- Calculate the result as d/f rounded to the nearest integer
    p_result := ROUND(d / f);

    -- Check if the result is an integer
    IF p_result != TRUNC(p_result) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Valeur de fréquence invalide: ' || p_result);
    END IF;
END;
/

/*CREATE OR REPLACE TRIGGER refus_plaque_trigger
AFTER INSERT ON T_refus_plaque
FOR EACH ROW
DECLARE
    v_experience_id NUMBER;
BEGIN
    -- Récupérer l'identifiant de l'expérience associée au refus
    v_experience_id := :NEW.experience_id;

    -- Simuler un refus de plaque ou de groupe en mettant à jour le statut de l'expérience
    UPDATE EXPERIENCE
    SET statut = 'Echoué'
    WHERE ID_EXPERIENCE = v_experience_id;

    -- Ajouter l'expérience à renouveler
    INSERT INTO LISTEATTENTE (ID_EXPERIENCE, NB_EXP_ATTENTE)
    VALUES (v_experience_id, 1);

    COMMIT;
EXCEPTION
    -- Gérer les exceptions
    WHEN OTHERS THEN
        -- Afficher l'erreur
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        -- Rollback pour annuler les changements en cas d'erreur
        ROLLBACK;
END;
/ */


/*----------------------------------------------------------------------------*\
/* Trigger qui permet le rachat de lots automatiquement si le stock est inférieure au volume consommé le trimestre d'avant
/*----------------------------------------------------------------------------*\
CREATE OR REPLACE TRIGGER T_rachat_stock 
AFTER UPDATE OR DELETE ON STOCK
FOR EACH ROW 
DECLARE 
    VOL96   integer ;
    VOL384  integer; 

BEGIN 
    SELECT VOL_DERNIER_TRI_P96 
    INTO VOL96
    FROM STOCK 
    WHERE ID_STOCK = :NEW.ID_STOCK; 
    
    SELECT VOL_DERNIER_TRI_P384 
    INTO VOL384
    FROM STOCK 
    WHERE ID_STOCK = :NEW.ID_STOCK;
    
    IF :NEW.QUANTITE_P96 < VOL96 THEN 
        INSERT INTO lot (id_stock, date_livraison_lot, nb_plaque, type_plaque_lot)
        VALUES (1, SYSDATE, 80, 96); 
    END IF;
    IF :NEW.QUANTITE_P384 < VOL384 THEN 
        INSERT INTO lot (id_stock, date_livraison_lot, nb_plaque, type_plaque_lot)
        VALUES (1, SYSDATE, 80, 384); 
    END IF;
END;
/


-- A REPRENDRE SI TEMPS OK 

/*==============================================================*/
/* Trigger expérience echouée ajt liste renouveler ok + coefficient de surcoût    à faire               */
/*==============================================================*/
/*CREATE OR REPLACE TRIGGER Contrainte_statut_experience
AFTER INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    v_new_etat_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE;
BEGIN
    -- Vérifier si la plaque ou le groupe a été refusé
    IF (:NEW.VALEUR_BIAIS_A1 IS NULL OR :NEW.VALEUR_BIAIS_A2 IS NULL OR :NEW.VALEUR_BIAIS_A3 IS NULL) THEN
        v_new_etat_experience := 'Echouée';
        -- Ajouter l'expérience à la liste des expériences à renouveler
        INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
        VALUES (:NEW.ID_LISTE, 1, :NEW.ID_EXPERIENCE, 0);
    ELSIF (:NEW.VALEUR_BIAIS_A1 > :NEW.VALEUR_BIAIS_A2 OR :NEW.VALEUR_BIAIS_A2 > :NEW.VALEUR_BIAIS_A3) THEN
        v_new_etat_experience := 'Echouée';
        -- Ajouter l'expérience à la liste des expériences à renouveler
        INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
        VALUES (:NEW.ID_LISTE, 1, :NEW.ID_EXPERIENCE, 0);
    ELSE
        v_new_etat_experience := 'Réussie';
    END IF;

    -- Mettre à jour l'état de l'expérience
    UPDATE EXPERIENCE SET ETAT_EXPERIENCE = v_new_etat_experience WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

    -- Recalculer le coefficient de surcoût si nécessaire
    --IF (v_new_etat_experience = 'Echouée') THEN
        -- Code pour recalculer le coefficient de surcoût en fonction des données de la table FACTURE
        -- Par exemple :
        -- v_coefficient_surcout := v_coefficient_surcout * 1.1; -- à modifier

        -- Mettre à jour le coefficient de surcoût dans la table FACTURE
        -- UPDATE FACTURE SET COEFFICIENT_SURCOUT = v_coefficient_surcout WHERE ID_EQUIPE = :NEW.ID_EQUIPE;
    --END IF;

END;
/
*/


/*
-- Suppression des groupes de slots et des slots associés à une plaque lorsque celle-ci est supprimée
CREATE OR REPLACE TRIGGER T_suppression_plaque
BEFORE DELETE ON PLAQUE
FOR EACH ROW
BEGIN
    DELETE FROM GROUPESLOT WHERE ID_PLAQUE = :OLD.ID_PLAQUE;
    DELETE FROM SLOT WHERE ID_PLAQUE = :OLD.ID_PLAQUE;
END;
/
*/



--  trigger met à jour l'état de l'expérience et recalcule le coefficient de surcoût lorsqu'une plaque ou un groupe est refusé
/*CREATE OR REPLACE TRIGGER Contrainte_statut_experience_plaque
AFTER UPDATE OF etat_plaque ON plaque
FOR EACH ROW
DECLARE
  v_experience_id experience.id_experience%TYPE;
  v_refus_count NUMBER;
  v_total_count NUMBER;
BEGIN
  -- Vérifier si la mise à jour concerne un refus
  IF :NEW.etat_plaque = 'REFUS' THEN
    -- Récupérer l'ID de l'expérience concernée
    SELECT e.id_experience INTO v_experience_id
    FROM experience e
    JOIN groupeslot g ON e.id_experience = g.id_experience
    JOIN slot s ON g.id_groupe = s.id_groupe
    JOIN plaque p ON s.id_plaque = p.id_plaque -- Ajouter cette ligne
    WHERE p.id_plaque = :NEW.id_plaque;

    -- Compter le nombre total de plaques et groupes, ainsi que le nombre de refus
    SELECT COUNT(*), SUM(CASE WHEN p.etat_plaque = 'REFUS' OR g.validite_groupe = 0 THEN 1 ELSE 0 END)
    INTO v_total_count, v_refus_count
    FROM groupeslot g
    JOIN slot s ON g.id_groupe = s.id_groupe
    JOIN plaque p ON s.id_plaque = p.id_plaque
    WHERE g.id_experience = v_experience_id;

    -- Mettre à jour le statut de l'expérience et recalculer le coefficient de surcoût
    UPDATE experience
    SET etat_experience = 'ECHOUEE',
        coeff_prix_prio_experience = v_refus_count / v_total_count
    WHERE id_experience = v_experience_id;
  END IF;
END;
/

*/






