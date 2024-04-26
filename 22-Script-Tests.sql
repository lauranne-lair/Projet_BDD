CREATE OR REPLACE PROCEDURE Test_T_rachat_stock AS
    volume_utilise_trimestre NUMBER; -- Variable pour stocker le volume utilisé ce trimestre
    stock_actuel NUMBER; -- Variable pour stocker le stock actuel de plaques
BEGIN
    -- Insérer des données de test dans la table Plaque (simuler volume utilisé sur dernier trimestre)
    INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
    VALUES (1, 1, 96, 100, 'Utilisée');

    -- Insérer des données de test dans la table LOT (pour avoir un stock insuffisant)
    INSERT INTO LOT (ID_LOT, DATE_LIVRAISON_LOT, NB_PLAQUE)
    VALUES (1, TO_DATE('2024-03-28', 'YYYY-MM-DD'), 50);

    -- Exécuter le trigger en insérant une ligne dans la table plaque pour lancer le trigger
    INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
    VALUES (2, 2, 384, 100, 'Utilisée');

    -- Vérification si bon ajout
    SELECT COUNT(*) INTO stock_actuel FROM LOT;
    SELECT SUM(NB_EXPERIENCE_PLAQUE) INTO volume_utilise_trimestre
    FROM PLAQUE
    WHERE ID_LOT IN (
        SELECT ID_LOT FROM LOT WHERE DATE_LIVRAISON_LOT >= TRUNC(ADD_MONTHS(TO_DATE('2024-03-28','YYYY-MM-DD'), -3), 'Q') AND DATE_LIVRAISON_LOT < TRUNC(TO_DATE('2024-03-28', 'YYYY-MM-DD'), 'Q')
    );

    -- Vérification si le stock est insuffisant
    IF stock_actuel < volume_utilise_trimestre THEN
        RAISE_APPLICATION_ERROR(-20022, 'Le stock de plaques est insuffisant, veuillez commander 80 plaques supplémentaires.');
    END IF;
    -- Supprimer les données de test
    DELETE FROM PLAQUE WHERE ID_PLAQUE IN (1, 2);
    DELETE FROM LOT WHERE ID_LOT = 1;
END;
/
EXEC Test_T_rachat_stock;

CREATE OR REPLACE PROCEDURE Test_T_panne_appareil AS
    --Déclaration des variables de test
    val_id_appareil APPAREIL.ID_APPAREIL%TYPE;
    val_id_experience EXPERIENCE.ID_EXPERIENCE%TYPE;
    val_statut_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE;
BEGIN
    --Sélection d’un appareil pour le test
    SELECT id_appareil INTO val_id_appareil FROM APPAREIL WHERE ROWNUM = 1;
    
    --Insertion d’une expérience programmée qui utilise l’appareil sélectionné
    INSERT INTO EXPERIENCE (ID_EXPERIENCE, ID_APPAREIL, ETAT_EXPERIENCE) VALUES (1, val_id_appareil, 'Programmée');

    --Sélection de l’identifiant de l’expérience insérée
    SELECT ID_EXPERIENCE INTO val_id_experience FROM EXPERIENCE WHERE ROWNUM = 1;

    --Mettre la disponibilité de l’appareil à ‘En panne’
    UPDATE APPAREIL SET ETAT_APPAREIL = 0 WHERE ID_APPAREIL = val_id_appareil;
    
    --Vérification de la mise à jour du statut de l’expérience qui doit être passée à ‘A programmer’
    SELECT ETAT_EXPERIENCE INTO val_statut_experience FROM EXPERIENCE WHERE ID_EXPERIENCE = val_id_experience;

    --Vérification du résultat du trigger
    IF val_statut_experience != 'A programmer' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Test du trigger T_panne_app est un échec');
    END IF;

    ROLLBACK;
END;
/
EXEC Test_T_panne_appareil;

CREATE OR REPLACE PROCEDURE Test_T_refus_plaque AS
  val_id_plaque PLAQUE.ID_PLAQUE%TYPE; -- Variable pour stocker l'identifiant de la plaque
  val_id_exp EXPERIENCE.ID_EXPERIENCE%TYPE; -- Variable pour stocker l'identifiant de l'expérience
  val_etat_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE; -- Variable pour stocker le statut de l'expérience

BEGIN
  -- Supposons que le refus de plaque ou de groupe soit détecté
  -- Nous affectons arbitrairement une plaque et une expérience existante
  -- aux variables val_id_plaque et val_id_exp respectivement

  -- Sélection d'une plaque existante
    SELECT ID_PLAQUE INTO val_id_plaque
    FROM PLAQUE
    WHERE ID_PLAQUE = 1; -- Supposons que nous sélectionnons la première plaque
    
      -- Sélection d'une expérience existante
    SELECT ID_EXPERIENCE INTO val_id_exp
    FROM EXPERIENCE
    WHERE ID_EXPERIENCE = 1; -- Supposons que nous sélectionnons la première expérience
    
      -- Simuler un refus de plaque ou de groupe en mettant à jour le statut de l'expérience
    UPDATE EXPERIENCE
    SET ETAT_EXPERIENCE = 'ratée'
    WHERE ID_EXPERIENCE = val_id_exp
    AND ID_PLAQUE = val_id_plaque;
    
      -- Ajouter l'expérience à renouveler
    INSERT INTO LISTEATTENTE(ID_EXPERIENCE)
    VALUES (val_id_exp);
    
      -- Vérification du résultat du trigger
    SELECT ETAT_EXPERIENCE INTO val_etat_experience
    FROM EXPERIENCE
    WHERE ID_EXPERIENCE = val_id_exp;
    
    IF val_etat_experience != 'ratée' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Test du trigger T_refus_plaque est un échec');
    END IF;
    
    ROLLBACK;
END;
/
EXEC Test_T_refus_plaque;

/*----------------------------------------------------------------------------*\
--- PROCEDURE DE TEST T_ARRIVEE_LOT ------------------------------------------*\
/*----------------------------------------------------------------------------*\
-- Procédure de Test Positive (Ajout d'un Lot avec Type de Plaque Valide)
CREATE OR REPLACE PROCEDURE test_automatisation_lot_positive AS
    test96 integer ;

BEGIN
    INSERT INTO STOCK (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96)VALUES (1,0,0,0,0);

    -- Insérer un nouveau lot avec un type de plaque valide (96 ou 384)
    INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
    VALUES (1, 1, SYSDATE, 80, 96); -- Exemple avec un type de plaque 96

    -- Sélectionner les informations mises à jour du stock pour vérification
    SELECT QUANTITE_P96 INTO test96
    FROM STOCK
    WHERE ID_STOCK = 1; -- ID_STOCK correspondant au lot inséré
    
    -- Vérification si le stock est insuffisant
    IF test96 = 0 THEN
        RAISE_APPLICATION_ERROR(-20023, 'Erreur le stock n a pas été mis à jour');
    END IF;
ROLLBACK;
END;
/

-- Procédure de Test Négative (Ajout d'un Lot avec Type de Plaque Non Valide)
CREATE OR REPLACE PROCEDURE test_automatisation_lot_negative AS
    test96 INTEGER ;

BEGIN
    INSERT INTO STOCK (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96)VALUES (1,0,0,0,0);

    -- Tentative d'insérer un nouveau lot avec un type de plaque non pris en charge
    INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
    VALUES (1, 1, SYSDATE, 80, 96); -- Exemple avec un type de plaque non valide (200)
    INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
    VALUES (2, 1, SYSDATE, 80, 384); -- Exemple avec un type de plaque non valide (200)

    -- Sélectionner les informations mises à jour du stock pour vérification
    SELECT QUANTITE_P96 INTO test96
    FROM STOCK
    WHERE ID_STOCK = 1; -- ID_STOCK correspondant au lot inséré
    
    -- Vérification si le stock est rempli 
    IF test96 = 160 THEN
        RAISE_APPLICATION_ERROR(-20024, 'Erreur le stock n a pas été mis à jour correctement');
    END IF;
ROLLBACK;
END;
/

TRUNCATE TABLE LOT;
TRUNCATE TABLE STOCK; 
begin 
    test_automatisation_lot_positive();
    test_automatisation_lot_negative(); 
    commit;
end; 
/

/*Procédure de tests autour de l'expérience*/
CREATE OR REPLACE PROCEDURE test_creer_experience AS
  v_id_experience NUMBER;
  v_count_groupeslot INTEGER;
  v_count_slot INTEGER;
BEGIN
  -- Insérer une expérience dans la table EXPERIENCE
  INSERT INTO EXPERIENCE (ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, DUREE_EXPERIENCE, PRIORITE_EXPERIENCE, FREQUENCE_EXPERIENCE, REPROGR_MAX_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3)
  VALUES (1, 1, 1, '96', 2, 3, 10, 1, 2, 1, 0.1, 0.2, 0.3)
  RETURNING ID_EXPERIENCE INTO v_id_experience;

  -- Vérifier que l'expérience a été créée en récupérant son ID
  IF v_id_experience IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'Échec de la création de l''expérience');
  END IF;

  -- Vérifier que le trigger T_lancement_experience a bien créé les groupes de slots et les slots correspondants
  SELECT COUNT(*) INTO v_count_groupeslot FROM GROUPESLOT WHERE ID_EXPERIENCE = v_id_experience;
  IF v_count_groupeslot != 2 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nombre de groupes de slots incorrect');
  END IF;

  SELECT COUNT(*) INTO v_count_slot FROM SLOT WHERE ID_GROUPE IN (SELECT ID_GROUPE FROM GROUPESLOT WHERE ID_EXPERIENCE = v_id_experience);
  IF v_count_slot != 6 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Nombre de slots incorrect');
  END IF;
END;
/
EXEC test_creer_experience;

CREATE OR REPLACE PROCEDURE test_maj_statut_experience AS
  v_id_experience NUMBER;
  v_etat_experience VARCHAR2(25);
BEGIN
  -- Insérer une expérience dans la table EXPERIENCE
  INSERT INTO EXPERIENCE (ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, DUREE_EXPERIENCE, PRIORITE_EXPERIENCE, FREQUENCE_EXPERIENCE, REPROGR_MAX_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3)
  VALUES (1, 1, 1, 96, 2, 3, 10, 1, 2, 1, 0.1, 0.2, 0.3)
  RETURNING ID_EXPERIENCE INTO v_id_experience;

  -- Mettre à jour le statut de l'expérience
  UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'effectuée' WHERE ID_EXPERIENCE = v_id_experience;

  -- Vérifier que le statut a bien été mis à jour
  SELECT ETAT_EXPERIENCE INTO v_etat_experience FROM EXPERIENCE WHERE ID_EXPERIENCE = v_id_experience;
  IF v_etat_experience != 'effectuée' THEN
    RAISE_APPLICATION_ERROR(-20000, 'Echec de la mise à jour du statut de l expérience');
  END IF;
END;
/
EXEC test_maj_statut_experience;

CREATE OR REPLACE PROCEDURE test_supp_experience AS
  v_experience_id experience.id_experience%TYPE;
  v_count_groupeslot INTEGER;
  v_count_slot INTEGER;
BEGIN
  -- Insérer une expérience à supprimer
  INSERT INTO experience(id_liste, id_technicien, id_chercheur, type_plaque, nb_groupe_slot_experience, nb_slots_par_groupe_experience, duree_experience, priorite_experience, frequence_experience, reprogr_max_experience, valeur_biais_a1, valeur_biais_a2, valeur_biais_a3)
  VALUES (1, 1, 1, '96', 1, 1, 1, 1, 1, 1, 0.1, 0.2, 0.3)
  RETURNING id_experience INTO v_experience_id;

  -- Supprimer l'expérience
  DELETE FROM experience WHERE id_experience = v_experience_id;

  -- Vérifier que l'expérience a été supprimée
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Échec de la suppression de l''expérience');
  END IF;

  -- Vérifier que les groupes de slots associés ont été supprimés
  SELECT COUNT(*) INTO v_count_groupeslot FROM groupeslot WHERE id_experience = v_experience_id;
  IF v_count_groupeslot != 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Échec de la suppression des groupes de slots associés à l''expérience');
  END IF;

  -- Vérifier que les slots associés aux groupes de slots ont été supprimés
  SELECT COUNT(*) INTO v_count_slot FROM slot WHERE id_groupe IN (SELECT id_groupe FROM groupeslot WHERE id_experience = v_experience_id);
  IF v_count_slot != 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Échec de la suppression des slots associés aux groupes de slots de l''expérience');
  END IF;
END;
/
EXEC test_supp_experience;
   
    