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
DROP TRIGGER T_lancement_experience;
DROP TRIGGER T_slot_par_groupe;

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




-- Trigger nombre de slots par plaque : Erreur si le nombre de slots par plaque n'est pas équivalent 
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

    -- Obtenir le nombre de slots dans les autres groupes de la même expérience
    SELECT COUNT(*)
    INTO v_nb_slot_other
    FROM GROUPESLOT
    WHERE ID_EXPERIENCE = :NEW.ID_EXPERIENCE
      AND :NEW.ID_GROUPE <> ID_GROUPE;

    -- Vérifier si ce nombre de slots est différent du nombre de slots dans les autres groupes de cette expérience
    IF v_nb_slot != v_nb_slot_other THEN
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
    appareil_non_disponible EXCEPTION;
BEGIN
    IF :NEW.ID_APPAREIL < 0 OR :NEW.ID_LISTE < 0 OR :NEW.POSITION_APPAREIL < 0 THEN
        RAISE negative_value;
    END IF;

    -- Vérifier si l'appareil n'est pas disponible
    IF :NEW.ETAT_APPAREIL != 'Disponible' THEN
        RAISE appareil_non_disponible;
    END IF;

EXCEPTION
    WHEN negative_value THEN
        RAISE_APPLICATION_ERROR (-20002, 'La valeur ne peut pas être négative dans la table APPAREIL');
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
    
    -- Affichage du prix calculé (facultatif)
    DBMS_OUTPUT.PUT_LINE('Le prix calculé de l''expérience est : ' || prix);
END;
/


//Contrainte sur le changement d'état des expériences lorsque l'appareil est en panne
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


--Triger d'automatisation pour les expériences :
/*Quand une epérience est lancée par un chercheur (insert), le tehcnicien update son statut et le groupe de slot ainsi que les slots se remplisse automatiquement
Appareil fait update sur le slot qui va faire un update sur le groupe de slots qui va faire un update sur l'expérience (statut = valide ou pas ?) 
donc on doit pas faire les procédures de peuplement des groupes de slots et des slots
*/
CREATE OR REPLACE TRIGGER T_lancement_experience
AFTER UPDATE OF ETAT_EXPERIENCE ON EXPERIENCE
FOR EACH ROW
BEGIN
    FOR i IN 1..NB_GROUPE_SLOT_EXPERIENCE LOOP
        SELECT ID_PLAQUE INTO ID_PLAQUE_EXP FROM PLAQUE WHERE :NEW
        
        SELECT p.ID_PLAQUE, p.TYPE_PLAQUE 
        INTO ID_PLAQUE_GROUPE, TYPE_PLAQUE_GROUPE 
        FROM PLAQUE p 
        JOIN PLAQUELOT pl ON p.ID_LOT = pl.ID_LOT 
        JOIN STOCK s ON pl.ID_STOCK = s.ID_STOCK 
        WHERE (p.TYPE_PLAQUE = 384 AND s.Quantite_P384 != 0)
        OR (p.TYPE_PLAQUE = 96 AND s.Quantite_P96 != 0); -- On vérifie si le stock n'est pas à zéro selon le type de plaque nécessaire pour l'expérience
        

        IF 
        -- mettre à jour les stocks en enlevant 1 au stock de la plaque au nombre de puits correspondant si elle est nouvelle
        INSERT INTO GROUPESLOT(ID_EXPERIENCE, ID_PLAQUE) VALUES (ID_EXPERIENCE_GROUPE, ID_PLAQUE_GROUPE);
        -- attribuer une plaque et vérifier si le nombre de groupe de slots qu'on rajoute rentre dans la plaque selon son type (96 ou 384 puits)
        SELECT NB_SLOTS_PAR_GROUPE_EXPERIENCE INTO NB_SLOTS_PAR_GROUPE FROM EXPERIENCE;
        FOR i in 1..NB_SLOTS_PAR_GROUPE LOOP
            SELECT ID_GROUPE INTO ID_GROUPE_SLOT FROM GROUPESLOT;
            INSERT INTO SLOT(ID_GROUPE) VALUES (ID_GROUPE_SLOT);
            -- enregistrer chaque slot avec un identifiant et une position dans la plaque
        END LOOP;
    END LOOP;
END;
/


/*CREATE OR REPLACE TRIGGER T_validation_slot
AFTER UPDATE OF ... ON SLOT
BEGIN
 -- calcul des moyennes pour faire la remontée jusqu'à la validation ou non de l'expérience
END;
/
*/

CREATE OR REPLACE TRIGGER refus_plaque_trigger
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
  WHERE  val_id_plaque= val_id_exp;

  -- Ajouter l'expérience à renouveler
  INSERT INTO LISTEATTENTE()
  VALUES (val_id_exp);

    -- Commit pour valider les changements
    COMMIT;
EXCEPTION
    -- Gérer les exceptions
    WHEN OTHERS THEN
        -- Afficher l'erreur
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        -- Rollback pour annuler les changements en cas d'erreur
        ROLLBACK;
END;
/

-- Trigger qui met à jour le stock après l'arrivée d'un lot 
CREATE OR REPLACE TRIGGER T_arrivee_lot
AFTER INSERT ON LOT
FOR EACH ROW
DECLARE
    v_quantite_p96 INTEGER;
    v_quantite_p384 INTEGER;
BEGIN
    -- Récupérer la quantité de plaques à ajouter au stock
    IF :NEW.TYPE_PLAQUE_LOT = 96 THEN
        v_quantite_p96 := :NEW.NB_PLAQUE;
        v_quantite_p384 := 0;
    ELSIF :NEW.TYPE_PLAQUE_LOT = 384 THEN
        v_quantite_p96 := 0;
        v_quantite_p384 := :NEW.NB_PLAQUE;
    ELSE
        -- Type de plaque non pris en charge
        RAISE_APPLICATION_ERROR(-20001, 'Type de plaque non valide.');
    END IF;

    -- Mettre à jour le stock de plaques
    IF v_quantite_p96 > 0 THEN
        UPDATE STOCK
        SET QUANTITE_P96 = QUANTITE_P96 + v_quantite_p96
        WHERE ID_STOCK = :NEW.ID_STOCK;
    END IF;

    IF v_quantite_p384 > 0 THEN
        UPDATE STOCK
        SET QUANTITE_P384 = QUANTITE_P384 + v_quantite_p384
        WHERE ID_STOCK = :NEW.ID_STOCK;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- En cas d'erreur, afficher un message d'erreur
        DBMS_OUTPUT.PUT_LINE('Erreur lors de l''ajout des plaques au stock : ' || SQLERRM);
END;
/



/*==============================================================*/
/* Séquence pour l'autoincrémentation                           */
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
