DROP TRIGGER T_CHECK_DUREE_POSITIVE;
DROP TRIGGER T_check_nb_plaques_lot;
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


DROP SEQUENCE seq_id_acheter;
DROP SEQUENCE seq_id_appareil;
DROP SEQUENCE seq_id_chercheur;
DROP SEQUENCE seq_id_equipe;
DROP SEQUENCE seq_id_experience;
DROP SEQUENCE seq_id_facture;
DROP SEQUENCE seq_id_groupeslot;
DROP SEQUENCE seq_id_lot;
DROP SEQUENCE seq_id_plaque;
DROP SEQUENCE seq_id_slot;
DROP SEQUENCE seq_id_technicien;

-- Trigger Duree_Experience : Erreur si la durée n'est pas positive
CREATE OR REPLACE TRIGGER T_check_duree_positive
BEFORE INSERT ON EXPERIENCE
FOR EACH ROW
DECLARE
    DUREE INTEGER;
BEGIN
    DUREE := :NEW.FIN_EXPERIENCE - :NEW.DEB_EXPERIENCE;
    IF DUREE < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La durée ne doit pas être négative.');
    END IF;
END;
/

-- Trigger Valeur de biais A1 doit être inférieur ou égal à A2
CREATE OR REPLACE TRIGGER T_check_valeur_biais2
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW   
DECLARE
BEGIN
    IF :NEW.VALEUR_BIAIS_A2 < :NEW.VALEUR_BIAIS_A1 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'La valeur de biais a2 ne peut pas être inférieure à a1');
    END IF;
END; 
/


-- Trigger nombre de plaques par lot : Erreur si le nombre de plaques dans un lot n'est pas égal à 80 
CREATE OR REPLACE TRIGGER T_check_nb_plaques_lot
BEFORE INSERT ON LOT
FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.NB_PLAQUE != 80 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le nombre de plaque par lot doit être égal à 80.');
    END IF;
END;
/


-- Trigger nombre de slots par plaque : Erreur si le nombre de slots par plaque ne vaut pas 96 ou 384
CREATE OR REPLACE TRIGGER T_check_type_plaque
BEFORE INSERT ON PLAQUE
FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.TYPE_PLAQUE != 96 AND :NEW.TYPE_PLAQUE != 384 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le nombre de slots par plaque doit être de 96 ou 384.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER T_check_nb_slots_groupe
BEFORE INSERT OR UPDATE ON GROUPESLOT
FOR EACH ROW
DECLARE
    v_nb_slot INTEGER;
BEGIN
    -- Obtenir le nombre de slots pour ce groupe
    SELECT COUNT(*)
    INTO v_nb_slot
    FROM SLOT
    WHERE ID_GROUPE = :NEW.ID_GROUPE;

    -- Vérifier si ce nombre de slots est différent du nombre de slots dans les autres groupes de cette expérience
    IF v_nb_slot != (
        SELECT COUNT(*)
        FROM SLOT S
        JOIN GROUPESLOT G ON S.ID_GROUPE = G.ID_GROUPE
        WHERE G.ID_EXPERIENCE = :NEW.ID_EXPERIENCE
        GROUP BY G.ID_EXPERIENCE
    ) THEN
        RAISE_APPLICATION_ERROR(-20000, 'Chaque groupe de slots pour une même expérience doit avoir le même nombre de slots.');
    END IF;
END;
/


-- Trigger pour avoir aucun nombre négatif dans les tables 
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
        RAISE_APPLICATION_ERROR (-20001, 'La valeur ne peut pas être négative dans la table ACHETER');
END;
/

--
--APPAREIL
CREATE OR REPLACE TRIGGER T_chek_valpos_APPAREIL
BEFORE INSERT OR UPDATE ON APPAREIL
FOR EACH ROW
DECLARE
    negative_value EXCEPTION;
BEGIN
    IF :NEW.ID_APPAREIL < 0 OR :NEW.ID_LISTE < 0 OR :NEW.DISPO_APPAREIL < 0 OR :NEW.POSITION_APPAREIL < 0 THEN
        RAISE negative_value;
    END IF;
EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20002, 'La valeur ne peut pas être négative dans la table APPAREIL');
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
        RAISE_APPLICATION_ERROR (-20003, 'La valeur ne peut pas être négative dans la table CHERCHEUR');
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
        RAISE_APPLICATION_ERROR (-20005, 'La valeur ne peut pas être négative dans la table EXPERIENCE');
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
        RAISE_APPLICATION_ERROR (-20006, 'La valeur ne peut pas être négative dans la table FACTURE');
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
        RAISE_APPLICATION_ERROR (-20007, 'La valeur ne peut pas être négative dans la table FOURNISSEUR');
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
        RAISE_APPLICATION_ERROR (-20008, 'La valeur ne peut pas être négative dans la table GROUPESLOT');
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
        RAISE_APPLICATION_ERROR (-20009, 'La valeur ne peut pas être négative dans la table LISTEATTENTE');
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
        RAISE_APPLICATION_ERROR (-20010, 'La valeur ne peut pas être négative dans la table LOT');
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
        RAISE_APPLICATION_ERROR (-20010, 'La valeur ne peut pas être négative dans la table PLAQUE');
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
        RAISE_APPLICATION_ERROR (-20011, 'La valeur ne peut pas être négative dans la table SLOT');
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
        RAISE_APPLICATION_ERROR (-20012, 'La valeur ne peut pas être négative dans la table STOCK');
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
        RAISE_APPLICATION_ERROR (-20013, 'La valeur ne peut pas être négative dans la table TECHNICIEN');
END;
/


// CONTRAINTE SUR LE PRIX DE L'EXPERIENCE
CREATE OR REPLACE TRIGGER T_prix_experience
BEFORE INSERT OR UPDATE ON EXPERIENCE
FOR EACH ROW
DECLARE
    prix INTEGER;
BEGIN
    -- Calcul du prix de l'expérience selon la formule donnée
    prix := :NEW.PRIORITE_EXPERIENCE * (:NEW.NB_RENOUVELLEMENT_EXPERIENCE + :NEW.FREQUENCE_EXPERIENCE) / :NEW.NB_RENOUVELLEMENT_EXPERIENCE;
    
    -- Vérification que le prix calculé est conforme à la contrainte
    IF prix <> :NEW.PRIX_EXPERIENCE THEN
        RAISE_APPLICATION_ERROR(-20014, 'Le prix de l''expérience doit être égal à (n+d)/n * la priorité de l''expérience.');
    END IF;
END;
/


/*==============================================================*/
/* Séquence pour l'autoincrémentation                                      */
/*==============================================================*/
-- Création de séquences
CREATE SEQUENCE seq_id_acheter START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_appareil START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_chercheur START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_equipe START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_experience START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_facture START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_groupeslot START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_lot START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_plaque START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_slot START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_id_technicien START WITH 1 INCREMENT BY 1;

/*==============================================================*/
/* Modification des tables pour utiliser les séquences                                        */
/*==============================================================*/
ALTER TABLE ACHETER MODIFY (ID_FOURNISSEUR DEFAULT seq_id_acheter.NEXTVAL);
ALTER TABLE APPAREIL MODIFY (ID_APPAREIL DEFAULT seq_id_appareil.NEXTVAL);
ALTER TABLE CHERCHEUR MODIFY (ID_CHERCHEUR DEFAULT seq_id_chercheur.NEXTVAL);
ALTER TABLE EQUIPE MODIFY (ID_EQUIPE DEFAULT seq_id_equipe.NEXTVAL);
ALTER TABLE EXPERIENCE MODIFY (ID_EXPERIENCE DEFAULT seq_id_experience.NEXTVAL);
ALTER TABLE FACTURE MODIFY (ID_FACTURE DEFAULT seq_id_facture.NEXTVAL);
ALTER TABLE GROUPESLOT MODIFY (ID_GROUPE DEFAULT seq_id_groupeslot.NEXTVAL);
ALTER TABLE LOT MODIFY (ID_LOT DEFAULT seq_id_lot.NEXTVAL);
ALTER TABLE PLAQUE MODIFY (ID_PLAQUE DEFAULT seq_id_plaque.NEXTVAL);
ALTER TABLE SLOT MODIFY (ID_SLOT DEFAULT seq_id_slot.NEXTVAL);
ALTER TABLE TECHNICIEN MODIFY (ID_TECHNICIEN DEFAULT seq_id_technicien.NEXTVAL);
