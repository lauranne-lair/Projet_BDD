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
DROP TRIGGER after_experience_update;
DROP TRIGGER refus_plaque_trigger;
DROP TRIGGER T_arrivee_lot;
DROP TRIGGER T_FACTURE;
DROP TRIGGER T_APPAREIL;
DROP TRIGGER T_LISTE_ATTENTE;
DROP TRIGGER CALCUL_FREQUENCE_OBSERVATION;
DROP TRIGGER UPDATE_SOLDE_EQUIPE;
DROP TRIGGER Contrainte_statut_experience;


-- Trigger Valeur de biais A1 doit �tre inf�rieur ou �gal � A2
CREATE OR REPLACE TRIGGER T_check_valeur_biais2
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW   
DECLARE
BEGIN
    IF :NEW.VALEUR_BIAIS_A2 < :NEW.VALEUR_BIAIS_A1 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'La valeur de biais a2 ne peut pas �tre inf�rieure � a1');
    END IF;
END; 
/

-- Trigger nombre de slots par plaque : Erreur si le nombre de slots par plaque n'est pas �quivalent 
CREATE OR REPLACE TRIGGER T_check_nb_slots_groupe
BEFORE INSERT OR UPDATE ON GROUPESLOT
FOR EACH ROW
DECLARE
    v_nb_slot INTEGER;
    v_nb_slot_other INTEGER;
BEGIN
    -- Obtenir le nombre de slots pour ce groupe
    SELECT COUNT(*)
    INTO v_nb_slot
    FROM SLOT
    WHERE ID_GROUPE = :NEW.ID_GROUPE;

    -- Obtenir le nombre de slots dans les autres groupes de la m�me exp�rience
    SELECT COUNT(*)
    INTO v_nb_slot_other
    FROM GROUPESLOT
    WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE
      AND :NEW.ID_GROUPE <> ID_GROUPE;

    -- V�rifier si ce nombre de slots est diff�rent du nombre de slots dans les autres groupes de cette exp�rience
    IF v_nb_slot != v_nb_slot_other THEN
        RAISE_APPLICATION_ERROR(-20000, 'Chaque groupe de slots pour une m�me exp�rience doit avoir le m�me nombre de slots.');
    END IF;
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
    prix INTEGER;
BEGIN
    -- Calcul du prix de l'exp�rience selon la formule donn�e
    prix := :NEW.PRIORITE_EXPERIENCE * (:NEW.NB_RENOUVELLEMENT_EXPERIENCE + :NEW.FREQUENCE_EXPERIENCE) / :NEW.NB_RENOUVELLEMENT_EXPERIENCE;
    
    -- Affichage du prix calcul� (facultatif)
    DBMS_OUTPUT.PUT_LINE('Le prix calcul� de l''exp�rience est : ' || prix);
END;
/


//Contrainte sur le changement d'�tat des exp�riences lorsque l'appareil est en panne
CREATE OR REPLACE TRIGGER T_panne_app
AFTER UPDATE OF ETAT_APPAREIL ON APPAREIL
FOR EACH ROW
BEGIN
    IF :OLD.ETAT_APPAREIL <> 'En panne' AND :NEW.ETAT_APPAREIL = 'En panne' THEN
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'A programmer'
        WHERE ID_APPAREIL = :NEW.ID_APPAREIL
        AND ETAT_EXPERIENCE <> 'A programmer';
    END IF;
END;
/


--Triger d'automatisation pour les exp�riences :
/*Quand une ep�rience est lanc�e par un chercheur (insert), le tehcnicien update son statut et le groupe de slot ainsi que les slots se remplisse automatiquement
Appareil fait update sur le slot qui va faire un update sur le groupe de slots qui va faire un update sur l'exp�rience (statut = valide ou pas ?) 
donc on doit pas faire les proc�dures de peuplement des groupes de slots et des slots
*/
CREATE OR REPLACE TRIGGER T_lancement_experience
AFTER UPDATE OF ETAT_EXPERIENCE ON EXPERIENCE
FOR EACH ROW
DECLARE
    TYPE_PLAQUE_EXP PLAQUE.TYPE_PLAQUE%TYPE;
    NB_GROUPE_EXP NUMBER;
    ID_PLAQUE_EXP PLAQUE.ID_PLAQUE%TYPE;
    NB_SLOTS_PAR_GROUPE NUMBER;
BEGIN
    -- Stocker les valeurs de NEW.TYPE_PLAQUE et NEW.NB_GROUPE_SLOT_EXPERIENCE dans des variables
    TYPE_PLAQUE_EXP := :NEW.TYPE_PLAQUE;
    NB_GROUPE_EXP := :NEW.NB_GROUPE_SLOT_EXPERIENCE;
    
    FOR i IN 1..NB_GROUPE_EXP LOOP
        IF i = 1 THEN
            -- S�lectionner l'ID_PLAQUE correspondant au TYPE_PLAQUE de l'exp�rience mise � jour
            SELECT ID_PLAQUE INTO ID_PLAQUE_EXP
            FROM PLAQUE
            WHERE TYPE_PLAQUE = TYPE_PLAQUE_EXP AND ROWNUM = 1;
            
            -- Mettre � jour les stocks en enlevant 1 au stock de la plaque pour le TYPE_PLAQUE correspondant
            IF TYPE_PLAQUE_EXP = 384 THEN
                UPDATE STOCK
                SET Quantite_P384 = Quantite_P384 - 1
                WHERE ID_STOCK = (SELECT ID_STOCK FROM PLAQUELOT WHERE ID_PLAQUE = ID_PLAQUE_EXP);
            ELSIF TYPE_PLAQUE_EXP = 96 THEN
                UPDATE STOCK
                SET Quantite_P96 = Quantite_P96 - 1
                WHERE ID_STOCK = (SELECT ID_STOCK FROM PLAQUELOT WHERE ID_PLAQUE = ID_PLAQUE_EXP);
            END IF;
        END IF;
        -- Ins�rer le groupe de slot pour l'exp�rience
        INSERT INTO GROUPESLOT(ID_EXPERIENCE, ID_PLAQUE) VALUES (:NEW.ID_EXPERIENCE, ID_PLAQUE_EXP);
        -- S�lectionner le nombre de slots par groupe pour l'exp�rience
        SELECT NB_SLOTS_PAR_GROUPE_EXPERIENCE INTO NB_SLOTS_PAR_GROUPE FROM EXPERIENCE WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
        -- Ins�rer des slots pour chaque groupe
        FOR j IN 1..NB_SLOTS_PAR_GROUPE LOOP
            INSERT INTO SLOT(ID_GROUPE) VALUES ((SELECT ID_GROUPE FROM GROUPESLOT WHERE ROWNUM = 1)); -- Vous devrez ajuster cette partie pour s�lectionner l'ID_GROUPE correctement
            -- Enregistrer chaque slot avec un identifiant et une position dans la plaque
        END LOOP;
    END LOOP;
END;
/

-- Trigger de validation de l'exp�rience en passant tout d'abord par la validation des slots et des groupes de slots
CREATE OR REPLACE TRIGGER after_experience_update
AFTER UPDATE OF ETAT_EXPERIENCE ON EXPERIENCE
FOR EACH ROW
WHEN (NEW.ETAT_EXPERIENCE = 'effectu�e')
DECLARE
    TYPE TYPE_EXPERIENCE_TABLE IS TABLE OF EXPERIENCE.TYPE_EXPERIENCE%TYPE INDEX BY BINARY_INTEGER;
    TYPE_EXPERIENCES TYPE_EXPERIENCE_TABLE;
    TYPE NB_SLOTS_TABLE IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
    NB_SLOTS_PAR_GROUPE NB_SLOTS_TABLE;
    TYPE VALIDATED_GROUP_TABLE IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
    GROUP_VALIDATION VALIDATED_GROUP_TABLE;
    NB_REJECTED_RESULTS INTEGER := 0;
    NB_TOTAL_RESULTS INTEGER := 0;
    A1 CONSTANT FLOAT := 0.2; -- Valeur de a1 sp�cifi�e dans le protocole
    A2 CONSTANT FLOAT := 0.5; -- Valeur de a2 sp�cifi�e dans le protocole
    A3 CONSTANT FLOAT := 0.1; -- Valeur de a3 sp�cifi�e dans le protocole
BEGIN
    -- R�cup�rer les types d'exp�rience associ�s � chaque groupe de slots
    FOR i IN 1..:NEW.NB_GROUPE_SLOT_EXPERIENCE LOOP
        SELECT TYPE_EXPERIENCE INTO TYPE_EXPERIENCES(i)
        FROM GROUPESLOT
        WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE AND ROWNUM = i;
        
        -- Calculer le nombre de slots par groupe pour chaque type d'exp�rience
        IF TYPE_EXPERIENCES(i) = 'colorim�trique' THEN
            NB_SLOTS_PAR_GROUPE(i) := :NEW.NB_SLOTS_PAR_GROUPE_EXPERIENCE;
        ELSIF TYPE_EXPERIENCES(i) = 'opacim�trique' THEN
            NB_SLOTS_PAR_GROUPE(i) := :NEW.NB_SLOTS_PAR_GROUPE_EXPERIENCE;
        END IF;
        
        -- Initialiser la table de validation des groupes � TRUE
        GROUP_VALIDATION(i) := TRUE;
        
        -- Pour chaque slot du groupe
        FOR j IN 1..NB_SLOTS_PAR_GROUPE(i) LOOP
            -- Calculs de moyenne et d'�cart-type pour chaque slot en fonction du type d'exp�rience
            IF TYPE_EXPERIENCES(i) = 'colorim�trique' THEN
                IF (:NEW.COULEUR_SLOT = 'violet' AND :NEW.BM_SLOT > 0) OR
                   (:NEW.COULEUR_SLOT = 'jaune' AND :NEW.BM_SLOT = 0) THEN
                    NB_TOTAL_RESULTS := NB_TOTAL_RESULTS + 1;
                    IF :NEW.ECART_TYPE_GROUPE > A2 THEN
                        NB_REJECTED_RESULTS := NB_REJECTED_RESULTS + 1;
                    END IF;
                END IF;
            ELSIF TYPE_EXPERIENCES(i) = 'opacim�trique' THEN
                IF :NEW.RM_SLOT > 0 THEN
                    NB_TOTAL_RESULTS := NB_TOTAL_RESULTS + 1;
                    IF :NEW.ECART_TYPE_GROUPE > A2 THEN
                        NB_REJECTED_RESULTS := NB_REJECTED_RESULTS + 1;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
    -- Mettre en �uvre les r�gles de validation des r�sultats pour l'ensemble de l'exp�rience selon le protocole sp�cifi�
    IF NB_REJECTED_RESULTS <= A3 * NB_TOTAL_RESULTS THEN
        FOR k IN 1..:NEW.NB_GROUPE_SLOT_EXPERIENCE LOOP
            IF GROUP_VALIDATION(k) = FALSE THEN
                NB_REJECTED_RESULTS := NB_REJECTED_RESULTS + 1;
            END IF;
        END LOOP;
        IF NB_REJECTED_RESULTS <= A3 * :NEW.NB_GROUPE_SLOT_EXPERIENCE THEN
            -- Mettre � jour l'�tat de l'exp�rience en cons�quence (exp�rience accept�e)
            UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'valid�e' WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
        ELSE
            -- Mettre � jour l'�tat de l'exp�rience en cons�quence (exp�rience refus�e)
            UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'refus�e' WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
        END IF;
    ELSE
        -- Mettre � jour l'�tat de l'exp�rience en cons�quence (exp�rience refus�e)
        UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'refus�e' WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
    END IF;
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
    v_quantite_p96 INTEGER;
    v_quantite_p384 INTEGER;
    
BEGIN
    -- R�cup�rer la quantit� de plaques � ajouter au stock
    IF :NEW.TYPE_PLAQUE_LOT = 96 THEN
        UPDATE STOCK
        SET QUANTITE_P96 = QUANTITE_P96 + 80
        WHERE ID_STOCK = :NEW.ID_STOCK;
    ELSIF :NEW.TYPE_PLAQUE_LOT = 384 THEN
        UPDATE STOCK
        SET QUANTITE_P384 = QUANTITE_P384 + 80
        WHERE ID_STOCK = :NEW.ID_STOCK;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- En cas d'erreur, afficher un message d'erreur
        DBMS_OUTPUT.PUT_LINE('Erreur lors de l''ajout des plaques au stock : ' || SQLERRM);
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
CREATE OR REPLACE FUNCTION CALCUL_FREQUENCE_OBSERVATION(d IN NUMBER, f IN NUMBER)
RETURN NUMBER IS
  result NUMBER;
BEGIN
  result := TRUNC(d / f);
  RETURN result;
END CALCUL_FREQUENCE_OBSERVATION;
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
/* Trigger exp�rience echou�e ajt liste renouveler + coefficient de surco�t                  */
/*==============================================================*/
CREATE OR REPLACE TRIGGER Contrainte_statut_experience
AFTER INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    v_new_etat_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE;
    v_coefficient_surcout NUMBER;
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
    IF (v_new_etat_experience = 'Echou�e') THEN
        -- R�cup�rer le coefficient de surco�t actuel
        SELECT COEFFICIENT_SURCOUT INTO v_coefficient_surcout FROM FACTURE WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;

        -- Code pour recalculer le coefficient de surco�t en fonction des donn�es de la table FACTURE
        -- Par exemple :
        -- v_coefficient_surcout := v_coefficient_surcout * 1.1;

        -- Mettre � jour le coefficient de surco�t dans la table FACTURE
        UPDATE FACTURE SET COEFFICIENT_SURCOUT = v_coefficient_surcout WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE;
    END IF;
END;
/


