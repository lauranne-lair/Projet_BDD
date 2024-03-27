drop trigger T_CHECK_DUREE_POSITIVE;
drop trigger T_check_nb_plaques_lot;
drop trigger T_check_type_plaque;
drop trigger T_check_valeur_biais2;
drop trigger T_check_nb_slots_groupe;

drop sequence seq_id_acheter;
drop SEQUENCE seq_id_appareil;
drop SEQUENCE seq_id_chercheur;
drop SEQUENCE seq_id_equipe;
drop SEQUENCE seq_id_experience;
drop SEQUENCE seq_id_facture;
drop SEQUENCE seq_id_groupeslot;
drop SEQUENCE seq_id_lot;
drop SEQUENCE seq_id_plaque;
drop SEQUENCE seq_id_slot;
drop SEQUENCE seq_id_technicien;

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
