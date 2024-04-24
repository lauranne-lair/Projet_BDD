DROP TRIGGER T_check_type_plaque;
DROP TRIGGER T_check_valeur_biais2;
DROP TRIGGER T_check_nb_slots_groupe;
DROP TRIGGER T_chek_valpos_ACHETER;
DROP TRIGGER T_chek_valpos_APPAREIL;
DROP TRIGGER T_chek_valpos_CHERCHEUR;
DROP TRIGGER T_chek_valpos_EQUIPE;
DROP TRIGGER T_chek_valpos_EXPERIENCE;
DROP TRIGGER T_chek_valpos_FACTURE;
DROP TRIGGER T_chek_valpos_FOURNISSEUR;
DROP TRIGGER T_chek_valpos_GROUPESLOT;
DROP TRIGGER T_chek_valpos_LISTEATTENTE;
DROP TRIGGER T_chek_valpos_LOT;
DROP TRIGGER T_chek_valpos_PLAQUE;
DROP TRIGGER T_chek_valpos_SLOT;
DROP TRIGGER T_chek_valpos_STOCK;
DROP TRIGGER T_chek_valpos_TECHNICIEN;
DROP TRIGGER T_slot_par_groupe;
DROP TRIGGER T_prix_experience;
DROP TRIGGER T_panne_app;
DROP TRIGGER T_lancement_experience;
DROP TRIGGER T_resultat_experience;
DROP TRIGGER after_experience_update;
DROP TRIGGER refus_plaque_trigger;
DROP TRIGGER T_arrivee_lot;
DROP TRIGGER T_stock_plaque;
DROP TRIGGER T_FACTURE;
DROP TRIGGER T_APPAREIL;
DROP TRIGGER T_LISTE_ATTENTE;
DROP TRIGGER CALCUL_FREQUENCE_OBSERVATION;
DROP TRIGGER UPDATE_SOLDE_EQUIPE;
DROP TRIGGER Contrainte_statut_experience;
DROP TRIGGER T_suppression_plaque;
DROP TRIGGER T_suppression_appareil;

CREATE OR REPLACE TRIGGER T_check_type_plaque
BEFORE INSERT OR UPDATE ON PLAQUE
FOR EACH ROW
DECLARE
    invalid_type_plaque EXCEPTION;
BEGIN
    IF :NEW.TYPE_PLAQUE NOT IN (96, 384) THEN
        RAISE invalid_type_plaque;
    END IF;
EXCEPTION
    WHEN invalid_type_plaque THEN
        RAISE_APPLICATION_ERROR(-20000, 'Le type de plaque doit �tre 96 ou 384');
END;
/

CREATE OR REPLACE TRIGGER T_check_valeur_biais2
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
        RAISE_APPLICATION_ERROR(-20001, 'La valeur de biais A2 doit �tre sup�rieure ou �gale � la valeur de biais A1');
END;
/

-- Trigger nombre de slots par plaque : Erreur si le nombre de slots par plaque n'est pas �quivalent 
CREATE OR REPLACE TRIGGER T_check_nb_slots_groupe
BEFORE INSERT OR UPDATE ON GROUPESLOT
FOR EACH ROW
DECLARE
    invalid_nb_slots EXCEPTION;
    v_type_plaque PLAQUE.TYPE_PLAQUE%TYPE;
BEGIN
    SELECT TYPE_PLAQUE INTO v_type_plaque FROM PLAQUE WHERE ID_PLAQUE = :NEW.ID_PLAQUE;
    IF v_type_plaque = 96 AND :NEW.NB_SLOTS_PAR_GROUPE_EXPERIENCE NOT IN (1, 2, 3, 4, 6, 8, 12) THEN
        RAISE invalid_nb_slots;
    ELSIF v_type_plaque = 384 AND :NEW.NB_SLOTS_PAR_GROUPE_EXPERIENCE NOT IN (1, 2, 3, 4, 6, 8, 12, 16, 24) THEN
        RAISE invalid_nb_slots;
    END IF;
EXCEPTION
    WHEN invalid_nb_slots THEN
        RAISE_APPLICATION_ERROR(-20002, 'Le nombre de slots par groupe doit �tre coh�rent avec le type de plaque');
END;
/

-- Trigger pour avoir aucun nombre n�gatif dans les tables 
-- Table acheter : 
CREATE OR REPLACE TRIGGER T_chek_valpos_ACHETER
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
        RAISE_APPLICATION_ERROR (-20001, 'La valeur ne peut pas �tre n�gative dans la table ACHETER');
END;
/

--
--APPAREIL
CREATE OR REPLACE TRIGGER T_chek_valpos_APPAREIL
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
        RAISE_APPLICATION_ERROR (-20002, 'La valeur ne peut pas �tre n�gative dans la table APPAREIL');
    WHEN appareil_non_disponible THEN
        RAISE_APPLICATION_ERROR (-20003, 'L''appareil n''est pas disponible');
END;
/


--
--CHERCHEUR 
CREATE OR REPLACE TRIGGER T_chek_valpos_CHERCHEUR
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
        RAISE_APPLICATION_ERROR (-20003, 'La valeur ne peut pas �tre n�gative dans la table CHERCHEUR');
END;
/

--
--EXPERIENCE
CREATE OR REPLACE TRIGGER T_chek_valpos_EXPERIENCE
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
        RAISE_APPLICATION_ERROR (-20005, 'La valeur ne peut pas �tre n�gative dans la table EXPERIENCE');
END;
/

--
--FACTURE
CREATE OR REPLACE TRIGGER T_chek_valpos_FACTURE
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
        RAISE_APPLICATION_ERROR (-20006, 'La valeur ne peut pas �tre n�gative dans la table FACTURE');
END;
/

--
--FOURNISSEUR
CREATE OR REPLACE TRIGGER T_chek_valpos_FOURNISSEUR
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
        RAISE_APPLICATION_ERROR (-20007, 'La valeur ne peut pas �tre n�gative dans la table FOURNISSEUR');
END;
/

--
--GROUPESLOT
CREATE OR REPLACE TRIGGER T_chek_valpos_GROUPESLOT
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
        RAISE_APPLICATION_ERROR (-20008, 'La valeur ne peut pas �tre n�gative dans la table GROUPESLOT');
END;
/

--
--LISTEATTENTE
CREATE OR REPLACE TRIGGER T_chek_valpos_LISTEATTENTE
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
        RAISE_APPLICATION_ERROR (-20009, 'La valeur ne peut pas �tre n�gative dans la table LISTEATTENTE');
END;
/

--
--LOT
CREATE OR REPLACE TRIGGER T_chek_valpos_LOT
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
        RAISE_APPLICATION_ERROR (-20010, 'La valeur ne peut pas �tre n�gative dans la table LOT');
END;
/

--
--PLAQUE
CREATE OR REPLACE TRIGGER T_chek_valpos_PLAQUE
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
        RAISE_APPLICATION_ERROR (-20010, 'La valeur ne peut pas �tre n�gative dans la table PLAQUE');
END;
/

--
--SLOT
CREATE OR REPLACE TRIGGER T_chek_valpos_SLOT
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
        RAISE_APPLICATION_ERROR (-20011, 'La valeur ne peut pas �tre n�gative dans la table SLOT');
END;
/

--
--STOCK
CREATE OR REPLACE TRIGGER T_chek_valpos_STOCK
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
        RAISE_APPLICATION_ERROR (-20012, 'La valeur ne peut pas �tre n�gative dans la table STOCK');
END;
/

--
--TECHNICIEN
CREATE OR REPLACE TRIGGER T_chek_valpos_TECHNICIEN
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
        RAISE_APPLICATION_ERROR (-20013, 'La valeur ne peut pas �tre n�gative dans la table TECHNICIEN');
END;
/


// CONTRAINTE SUR LE PRIX DE L'EXPERIENCE
CREATE OR REPLACE TRIGGER T_prix_experience
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    v_nb_exp_en_attente NUMBER;
    v_nb_exp_doublees NUMBER;
    v_coeff_prix_prio NUMBER;F
BEGIN
    SELECT COUNT(*) INTO v_nb_exp_en_attente FROM EXPERIENCE WHERE ETAT_EXPERIENCE = 'en attente';
    SELECT COUNT(*) INTO v_nb_exp_doublees FROM EXPERIENCE WHERE ETAT_EXPERIENCE = 'en attente' AND PRIORITE_EXPERIENCE > :NEW.PRIORITE_EXPERIENCE;
    IF :NEW.PRIORITE_EXPERIENCE > 1 THEN
        v_coeff_prix_prio := (v_nb_exp_en_attente + v_nb_exp_doublees) / v_nb_exp_en_attente;
    ELSE
        v_coeff_prix_prio := 1;
    END IF;
    :NEW.COEFF_PRIX_PRIO_EXPERIENCE := v_coeff_prix_prio;
END;
/


//Contrainte sur le changement d'�tat des exp�riences lorsque l'appareil est en panne
CREATE OR REPLACE TRIGGER T_panne_app
AFTER UPDATE OF ETAT_APPAREIL ON APPAREIL
FOR EACH ROW
DECLARE
    v_id_experience EXPERIENCE.ID_EXPERIENCE%TYPE;
BEGIN
    IF :OLD.ETAT_APPAREIL = 'disponible' AND :NEW.ETAT_APPAREIL = 'en panne' THEN
        FOR r IN (SELECT ID_EXPERIENCE FROM EXPERIENCE WHERE ID_APPAREIL = :OLD.ID_APPAREIL AND ETAT_EXPERIENCE = '� programmer') LOOP
            UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'en attente' WHERE ID_EXPERIENCE = r.ID_EXPERIENCE;
        END LOOP;
    END IF;
END;
/


--Triger d'automatisation pour les exp�riences :
/*Quand une ep�rience est lanc�e par un chercheur (insert), le tehcnicien update son statut et le groupe de slot ainsi que les slots se remplisse automatiquement
Appareil fait update sur le slot qui va faire un update sur le groupe de slots qui va faire un update sur l'exp�rience (statut = valide ou pas ?) 
donc on doit pas faire les proc�dures de peuplement des groupes de slots et des slots
*/
CREATE OR REPLACE TRIGGER T_lancement_experience
AFTER INSERT ON EXPERIENCE
FOR EACH ROW
DECLARE
  v_id_plaque PLAQUE.ID_PLAQUE%TYPE;
  v_type_plaque PLAQUE.TYPE_PLAQUE%TYPE;
BEGIN
  -- S�lectionner une plaque disponible en fonction du type de plaque requis par l'exp�rience
  SELECT p.ID_PLAQUE, p.TYPE_PLAQUE
  INTO v_id_plaque, v_type_plaque
  FROM PLAQUE p
  JOIN LOT l ON p.ID_LOT = l.ID_LOT
  WHERE p.ETAT_PLAQUE = 'Disponible'
  AND l.TYPE_PLAQUE_LOT = :NEW.TYPE_PLAQUE
  ORDER BY l.DATE_LIVRAISON_LOT ASC
  FETCH FIRST 1 ROWS ONLY;

  -- Mettre � jour l'�tat de la plaque s�lectionn�e
  UPDATE PLAQUE SET ETAT_PLAQUE = 'Utilis�e' WHERE ID_PLAQUE = v_id_plaque;

  -- Ins�rer un groupe de slots pour chaque groupe de slots n�cessaire pour l'exp�rience
  FOR i IN 1..:NEW.NB_GROUPE_SLOT_EXPERIENCE LOOP
    INSERT INTO GROUPESLOT (ID_EXPERIENCE, ID_PLAQUE, MOYENNE_GROUPE, ECART_TYPE_GROUPE, VALIDITE_GROUPE)
    VALUES (:NEW.ID_EXPERIENCE, v_id_plaque, NULL, NULL, 'Non valid�');

    -- Ins�rer des slots pour chaque slot n�cessaire dans le groupe de slots
    FOR j IN 1..:NEW.NB_SLOTS_PAR_GROUPE_EXPERIENCE LOOP
      INSERT INTO SLOT (ID_GROUPE, COULEUR_SLOT, NUMERO_SLOT, POSITION_X_SLOT, POSITION_Y_SLOT, RM_SLOT, RD_SLOT, VM_SLOT, VD_SLOT, BM_SLOT, BD_SLOT, TM_SLOT, TD_SLOT, VALIDITE_SLOT)
      VALUES (seq_id_groupeslot.CURRVAL, NULL, j, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Non valid�');
    END LOOP;
  END LOOP;
END;

/

-- Trigger selon le r�sultat d'une exp�rience
CREATE OR REPLACE TRIGGER T_resultat_experience
AFTER INSERT OR UPDATE ON RESULTAT
FOR EACH ROW
DECLARE
    v_id_experience RESULTAT.ID_EXPERIENCE%TYPE;
    v_nb_resultats_refuses NUMBER;
    v_nb_resultats_totaux NUMBER;
BEGIN
    SELECT ID_EXPERIENCE INTO v_id_experience FROM RESULTAT WHERE ID_RESULTAT = :NEW.ID_RESULTAT;
    SELECT COUNT(*) INTO v_nb_resultats_refuses FROM RESULTAT WHERE ID_EXPERIENCE = v_id_experience AND RESULTAT_VALIDE = 'N';
    SELECT COUNT(*) INTO v_nb_resultats_totaux FROM RESULTAT WHERE ID_EXPERIENCE = v_id_experience;
    IF v_nb_resultats_refuses = 0 THEN
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'valid�e' WHERE ID_EXPERIENCE = v_id_experience;
    ELSIF v_nb_resultats_refuses / v_nb_resultats_totaux > 0.3 THEN
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'refus�e' WHERE ID_EXPERIENCE = v_id_experience;
    ELSE
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = '� v�rifier' WHERE ID_EXPERIENCE = v_id_experience;
    END IF;
END;
/

-- Trigger de validation de l'exp�rience en passant tout d'abord par la validation des slots et des groupes de slots
CREATE OR REPLACE TRIGGER after_experience_update
AFTER UPDATE OF VALIDITE_GROUPE ON GROUPESLOT
FOR EACH ROW
DECLARE
  v_nb_groupes_valides NUMBER;
  v_nb_groupes_necessaires NUMBER;
  v_nb_slots_valides NUMBER;
  v_nb_slots_necessaires NUMBER;
BEGIN
  -- V�rifier que tous les groupes de slots n�cessaires ont �t� valid�s
  SELECT COUNT(*), COUNT(CASE WHEN g.VALIDITE_GROUPE = 'Valid�' THEN 1 END)
  INTO v_nb_groupes_necessaires, v_nb_groupes_valides
  FROM GROUPESLOT g
  JOIN EXPERIENCE e ON g.ID_EXPERIENCE = e.ID_EXPERIENCE
  WHERE e.ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

  IF v_nb_groupes_valides < v_nb_groupes_necessaires THEN
    RAISE_APPLICATION_ERROR(-20001, 'Tous les groupes de slots n�cessaires n''ont pas �t� valid�s.');
  END IF;

  -- V�rifier que tous les slots n�cessaires ont �t� valid�s
  SELECT COUNT(*), COUNT(CASE WHEN s.VALIDITE_SLOT = 'Valid�' THEN 1 END)
  INTO v_nb_slots_necessaires, v_nb_slots_valides
  FROM SLOT s
  JOIN GROUPESLOT g ON s.ID_GROUPE = g.ID_GROUPE
  JOIN EXPERIENCE e ON g.ID_EXPERIENCE = e.ID_EXPERIENCE
  WHERE e.ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

  IF v_nb_slots_valides < v_nb_slots_necessaires THEN
    RAISE_APPLICATION_ERROR(-20002, 'Tous les slots n�cessaires n''ont pas �t� valid�s.');
  END IF;

  -- Si tous les groupes de slots et slots n�cessaires ont �t� valid�s, mettre � jour l'�tat de l'exp�rience en cons�quence
  UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'Valid�e' WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
END;
/

/*----------------------------------------------------------------------------*\
/ --Trigger qui g�re le refus d'une plaque 
/*----------------------------------------------------------------------------*\
CREATE OR REPLACE TRIGGER refus_plaque_trigger
AFTER INSERT ON T_refus_plaque
FOR EACH ROW
DECLARE
    v_experience_id NUMBER;
BEGIN
    -- R�cup�rer l'identifiant de l'exp�rience associ�e au refus
    v_experience_id := :NEW.experience_id;

    -- Simuler un refus de plaque ou de groupe en mettant � jour le statut de l'exp�rience
    UPDATE EXPERIENCE
    SET statut = 'Echou�'
    WHERE ID_EXPERIENCE = v_experience_id;

    -- Ajouter l'exp�rience � renouveler
    INSERT INTO LISTEATTENTE (ID_EXPERIENCE, NB_EXP_ATTENTE)
    VALUES (v_experience_id, 1);

    -- Commit pour valider les changements
    COMMIT;
EXCEPTION
    -- G�rer les exceptions
    WHEN OTHERS THEN
        -- Afficher l'erreur
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        -- Rollback pour annuler les changements en cas d'erreur
        ROLLBACK;
END;
/
--------------------------------------------------------------------------------

/*============================================================================*/
/*  Trigger d'automatisation qui met � jour le stock suite � l'ajout d'un lot � la BDD         /*
/*============================================================================*/
CREATE OR REPLACE TRIGGER T_arrivee_lot
AFTER INSERT ON LOT
FOR EACH ROW
DECLARE
    v_quantite_stock PLS_INTEGER;
BEGIN
    IF :NEW.TYPE_PLAQUE_LOT = 96 THEN
        SELECT S.QUANTITE_P96 INTO v_quantite_stock
        FROM STOCK S
        WHERE S.ID_STOCK = :NEW.ID_STOCK;

        IF v_quantite_stock IS NULL OR v_quantite_stock = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Le stock s�lectionn� ne contient pas de plaques 96 slots.');
        ELSE
            UPDATE STOCK
            SET QUANTITE_P96 = QUANTITE_P96 + :NEW.NB_PLAQUES
            WHERE ID_STOCK = :NEW.ID_STOCK;
        END IF;
    ELSIF :NEW.TYPE_PLAQUE_LOT = 384 THEN
        SELECT S.QUANTITE_P384 INTO v_quantite_stock
        FROM STOCK S
        WHERE S.ID_STOCK = :NEW.ID_STOCK;

        IF v_quantite_stock IS NULL OR v_quantite_stock = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Le stock s�lectionn� ne contient pas de plaques 384 slots.');
        ELSE
            UPDATE STOCK
            SET QUANTITE_P384 = QUANTITE_P384 + :NEW.NB_PLAQUES
            WHERE ID_STOCK = :NEW.ID_STOCK;
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Le type de plaque du lot ajout� est invalide.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER T_stock_plaque
AFTER INSERT OR DELETE ON LOT
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_nb_plaques NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := '+';
        v_nb_plaques := :NEW.NB_PLAQUES;
    ELSIF DELETING THEN
        v_operation := '-';
        v_nb_plaques := :OLD.NB_PLAQUES;
    END IF;
    UPDATE STOCK SET QUANTITE_P96 = QUANTITE_P96 || v_operation || v_nb_plaques WHERE TYPE_PLAQUE = 96;
    UPDATE STOCK SET QUANTITE_P384 = QUANTITE_P384 || v_operation || v_nb_plaques WHERE TYPE_PLAQUE = 384;
END;
/
--------------------------------------------------------------------------------

/*==============================================================*/
/* Trigger Facture, date non nul et �gale a 01 uniquement, equipe non null                         */
/*==============================================================*/
CREATE OR REPLACE TRIGGER T_FACTURE
BEFORE INSERT ON FACTURE
FOR EACH ROW
BEGIN
  IF :NEW.MONTANT_FACTURE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20004, 'Le montant de la facture ne peut pas �tre nul');
  END IF;

  IF :NEW.DATE_FACTURE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'La date de facturation ne peut pas �tre nulle');
  END IF;

  IF TO_CHAR(:NEW.DATE_FACTURE, 'DD') != '01' THEN
    RAISE_APPLICATION_ERROR(-20000, 'La date de facturation doit �tre le premier jour du mois.');
  END IF;
END;

/*==============================================================*/
/* Trigger modification du solde �quipe                   */
/*==============================================================*/
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

CREATE OR REPLACE TRIGGER T_LISTE_ATTENTE
AFTER INSERT ON EXPERIENCE
FOR EACH ROW
DECLARE
  v_nb_exp_attente  NUMBER;
BEGIN
  -- R�cup�rer le nombre actuel d'exp�riences en attente pour la liste concern�e
  SELECT NB_EXP_ATTENTE
  INTO v_nb_exp_attente
  FROM LISTEATTENTE
  WHERE ID_LISTE = :NEW.ID_LISTE;

  -- Mettre � jour le nombre d'exp�riences en attente pour la liste concern�e
  UPDATE LISTEATTENTE
  SET NB_EXP_ATTENTE = v_nb_exp_attente + 1
  WHERE ID_LISTE = :NEW.ID_LISTE;
END;
/




/*==============================================================*/
/* Trigger modification du solde �quipe                   */
/*==============================================================*/
CREATE OR REPLACE TRIGGER UPDATE_SOLDE_EQUIPE
AFTER INSERT ON FACTURE
FOR EACH ROW
BEGIN
  UPDATE EQUIPE
     SET SOLDE_EQUIPE = SOLDE_EQUIPE + :NEW.MONTANT_FACTURE
   WHERE ID_EQUIPE = :NEW.ID_EQUIPE;
END;
/

/*==============================================================*/
/* Trigger exp�rience echou�e ajt liste renouveler + coefficient de surco�t    � faire               */
/*==============================================================*/
/*CREATE OR REPLACE TRIGGER Contrainte_statut_experience
AFTER INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    v_new_etat_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE;
BEGIN
    -- V�rifier si la plaque ou le groupe a �t� refus�
    IF (:NEW.VALEUR_BIAIS_A1 IS NULL OR :NEW.VALEUR_BIAIS_A2 IS NULL OR :NEW.VALEUR_BIAIS_A3 IS NULL) THEN
        v_new_etat_experience := 'Echou�e';
        -- Ajouter l'exp�rience � la liste des exp�riences � renouveler
        INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
        VALUES (:NEW.ID_LISTE, 1, :NEW.ID_EXPERIENCE, 0);
    ELSIF (:NEW.VALEUR_BIAIS_A1 > :NEW.VALEUR_BIAIS_A2 OR :NEW.VALEUR_BIAIS_A2 > :NEW.VALEUR_BIAIS_A3) THEN
        v_new_etat_experience := 'Echou�e';
        -- Ajouter l'exp�rience � la liste des exp�riences � renouveler
        INSERT INTO LISTEATTENTE (ID_LISTE, NB_EXP_ATTENTE, EXPERIENCE, NB_EXP_DOUBLE)
        VALUES (:NEW.ID_LISTE, 1, :NEW.ID_EXPERIENCE, 0);
    ELSE
        v_new_etat_experience := 'R�ussie';
    END IF;

    -- Mettre � jour l'�tat de l'exp�rience
    UPDATE EXPERIENCE SET ETAT_EXPERIENCE = v_new_etat_experience WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

    -- Recalculer le coefficient de surco�t si n�cessaire
    --IF (v_new_etat_experience = 'Echou�e') THEN
        -- Code pour recalculer le coefficient de surco�t en fonction des donn�es de la table FACTURE
        -- Par exemple :
        -- v_coefficient_surcout := v_coefficient_surcout * 1.1; -- � modifier

        -- Mettre � jour le coefficient de surco�t dans la table FACTURE
        -- UPDATE FACTURE SET COEFFICIENT_SURCOUT = v_coefficient_surcout WHERE ID_EQUIPE = :NEW.ID_EQUIPE;
    --END IF;

END;
/
*/



-- Suppression des groupes de slots et des slots associ�s � une plaque lorsque celle-ci est supprim�e
CREATE OR REPLACE TRIGGER T_suppression_plaque
BEFORE DELETE ON PLAQUE
FOR EACH ROW
BEGIN
    DELETE FROM GROUPESLOT WHERE ID_PLAQUE = :OLD.ID_PLAQUE;
    DELETE FROM SLOT WHERE ID_PLAQUE = :OLD.ID_PLAQUE;
END;

-- Mise � jour ou suppression des exp�riences associ�es � un appareil lorsque celui-ci est supprim�
CREATE OR REPLACE TRIGGER T_suppression_appareil
BEFORE DELETE ON APPAREIL
FOR EACH ROW
BEGIN
    UPDATE EXPERIENCE SET ID_APPAREIL = NULL WHERE ID_APPAREIL = :OLD.ID_APPAREIL;
    -- Si vous souhaitez supprimer les exp�riences associ�es � l'appareil au lieu de les mettre � jour, utilisez la ligne suivante :
    -- DELETE FROM EXPERIENCE WHERE ID_APPAREIL = :OLD.ID_APPAREIL;
END;

-- Trigger pourrespecter les r�gle impos� sur les valeurs entre les biais
CREATE OR REPLACE TRIGGER Acceptation_biais
BEFORE INSERT OR UPDATE OF VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3, ECART_TYPE_EXPERIENCE ON Experience
FOR EACH ROW
DECLARE
  v_resultat_experience VARCHAR2(25);
BEGIN
  IF :NEW.ECART_TYPE_EXPERIENCE < :NEW.VALEUR_BIAIS_A1 THEN
    v_resultat_experience := 'Accept�';
  ELSIF :NEW.VALEUR_BIAIS_A1 <= :NEW.ECART_TYPE_EXPERIENCE AND :NEW.ECART_TYPE_EXPERIENCE <= :NEW.VALEUR_BIAIS_A2 THEN
    v_resultat_experience := 'Refus�';
  ELSIF :NEW.VALEUR_BIAIS_A2 < :NEW.ECART_TYPE_EXPERIENCE THEN
    v_resultat_experience := 'Plaque refus�e';
  END IF;

  :NEW.ETAT_EXPERIENCE := v_resultat_experience;
END;
/



--  trigger met � jour l'�tat de l'exp�rience et recalcule le coefficient de surco�t lorsqu'une plaque ou un groupe est refus�
CREATE OR REPLACE TRIGGER Contrainte_statut_experience_plaque
AFTER UPDATE OF etat_plaque ON plaque
FOR EACH ROW
DECLARE
  v_experience_id experience.id_experience%TYPE;
  v_refus_count NUMBER;
  v_total_count NUMBER;
BEGIN
  -- V�rifier si la mise � jour concerne un refus
  IF :NEW.etat_plaque = 'REFUS' THEN
    -- R�cup�rer l'ID de l'exp�rience concern�e
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

    -- Mettre � jour le statut de l'exp�rience et recalculer le coefficient de surco�t
    UPDATE experience
    SET etat_experience = 'ECHOUEE',
        coeff_prix_prio_experience = v_refus_count / v_total_count
    WHERE id_experience = v_experience_id;
  END IF;
END;
/



/*==============================================================*/
--V�rifie si le produit du nombre de renouvellements d'exp�rience par la valeur du biais A3  est inf�rieur � la valeur du biais A3. 
--En fonction du r�sultat, il met � jour l'�tat de l'exp�rience  en 'Accept�e' ou 'Refus�e'.
/*==============================================================*/
CREATE OR REPLACE TRIGGER Contrainte_nb_releves_photo
BEFORE INSERT OR UPDATE OF NB_RENOUVELLEMENT_EXPERIENCE ON Experience
FOR EACH ROW
DECLARE
  v_etat_experience VARCHAR2(20);
  v_f NUMBER;
BEGIN
  -- R�cup�rer la valeur de f � partir de la table Parametres
  SELECT p.valeur INTO v_f
  FROM Parametres p
  WHERE p.nom = 'FREQUENCE_OBSERVATION';

  -- Calculer le nombre de r�sultats photom�triques refus�s (a3N)
  v_etat_experience := :NEW.ETAT_EXPERIENCE;

  -- V�rifier si le nombre de r�sultats refus�s est inf�rieur � a3N
  IF :NEW.VALEUR_BIAIS_A3 * :NEW.NB_RENOUVELLEMENT_EXPERIENCE < v_f THEN
    v_etat_experience := 'Accept�e';
  ELSE
    v_etat_experience := 'Refus�e';
  END IF;

  -- Mettre � jour l'�tat de l'exp�rience avant l'insertion ou la mise � jour
  :NEW.ETAT_EXPERIENCE := v_etat_experience;
END;
/
-- a finir


/*==============================================================*/
/* Trigger modification du solde �quipe                   */
/*==============================================================*/
CREATE OR REPLACE FUNCTION Calcul_frequence_observation(
    p_id_experience IN NUMBER
) RETURN NUMBER IS
    d NUMBER;
    f NUMBER;
    result NUMBER;
BEGIN
    -- Retrieve the values of d and f from the Experience table
    SELECT DUREE_EXPERIENCE, FREQUENCE_EXPERIENCE
    INTO d, f
    FROM Experience
    WHERE ID_EXPERIENCE = p_id_experience;

    -- Calculate the result as d/f rounded to the nearest integer
    result := ROUND(d / f);

    -- Check if the result is an integer
    IF result != TRUNC(result) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid frequency value: ' || result);
    END IF;

    -- Return the result
    RETURN result;
END;
/


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
BEGIN
    -- Retrieve the values of d, f, and a3 from the current row
    d := :NEW.DUREE_EXPERIENCE;
    f := :NEW.FREQUENCE_EXPERIENCE;
    a3 := :NEW.VALEUR_BIAIS_A3;

    -- Calculate the total number of photometric results
    n := ROUND(d / f);

    -- Calculate the number of accepted and rejected photometric results
    SELECT COUNT(CASE
                WHEN some_other_column IS NOT NULL THEN 1
              END) accepted_count,
           COUNT(CASE
                WHEN some_other_column IS NULL THEN 1
              END) rejected_count
    INTO accepted_count, rejected_count
    FROM (
        SELECT some_other_column
        FROM Experience
        WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE
        ORDER BY DEB_EXPERIENCE
    )
    WHERE ROWNUM <= n;

    -- Check if the number of rejected results is less than a3N
    IF rejected_count < a3 * n THEN
        :NEW.ETAT_EXPERIENCE := 'Accept�e';
    ELSE
        :NEW.ETAT_EXPERIENCE := 'Refus�e';
    END IF;
END;
/








