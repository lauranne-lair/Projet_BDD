CREATE OR REPLACE PROCEDURE Test_T_rachat_stock AS
    volume_utilise_trimestre NUMBER; -- Variable pour stocker le volume utilis� ce trimestre
    stock_actuel NUMBER; -- Variable pour stocker le stock actuel de plaques
BEGIN
    -- Ins�rer des donn�es de test dans la table Plaque (simuler volume utilis� sur dernier trimestre)
    INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
    VALUES (1, 1, 96, 100, 'Utilis�e');

    -- Ins�rer des donn�es de test dans la table LOT (pour avoir un stock insuffisant)
    INSERT INTO LOT (ID_LOT, DATE_LIVRAISON_LOT, NB_PLAQUE)
    VALUES (1, TO_DATE('2024-03-28', 'YYYY-MM-DD'), 50);

    -- Ex�cuter le trigger en ins�rant une ligne dans la table plaque pour lancer le trigger
    INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
    VALUES (2, 2, 384, 100, 'Utilis�e');

    -- V�rification si bon ajout
    SELECT COUNT(*) INTO stock_actuel FROM LOT;
    SELECT SUM(NB_EXPERIENCE_PLAQUE) INTO volume_utilise_trimestre
    FROM PLAQUE
    WHERE ID_LOT IN (
        SELECT ID_LOT FROM LOT WHERE DATE_LIVRAISON_LOT >= TRUNC(ADD_MONTHS(TO_DATE('2024-03-28','YYYY-MM-DD'), -3), 'Q') AND DATE_LIVRAISON_LOT < TRUNC(TO_DATE('2024-03-28', 'YYYY-MM-DD'), 'Q')
    );

    -- V�rification si le stock est insuffisant
    IF stock_actuel < volume_utilise_trimestre THEN
        RAISE_APPLICATION_ERROR(-20022, 'Le stock de plaques est insuffisant, veuillez commander 80 plaques suppl�mentaires.');
    END IF;
    -- Supprimer les donn�es de test
    DELETE FROM PLAQUE WHERE ID_PLAQUE IN (1, 2);
    DELETE FROM LOT WHERE ID_LOT = 1;
END;
/
EXEC Test_T_rachat_stock;

CREATE OR REPLACE PROCEDURE Test_T_panne_appareil AS
    --D�claration des variables de test
    val_id_appareil APPAREIL.ID_APPAREIL%TYPE;
    val_id_experience EXPERIENCE.ID_EXPERIENCE%TYPE;
    val_statut_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE;
BEGIN
    --S�lection d�un appareil pour le test
    SELECT id_appareil INTO val_id_appareil FROM APPAREIL WHERE ROWNUM = 1;
    
    --Insertion d�une exp�rience programm�e qui utilise l�appareil s�lectionn�
    INSERT INTO EXPERIENCE (ID_EXPERIENCE, ID_APPAREIL, ETAT_EXPERIENCE) VALUES (1, val_id_appareil, 'Programm�e');

    --S�lection de l�identifiant de l�exp�rience ins�r�e
    SELECT ID_EXPERIENCE INTO val_id_experience FROM EXPERIENCE WHERE ROWNUM = 1;

    --Mettre la disponibilit� de l�appareil � �En panne�
    UPDATE APPAREIL SET ETAT_APPAREIL = 0 WHERE ID_APPAREIL = val_id_appareil;
    
    --V�rification de la mise � jour du statut de l�exp�rience qui doit �tre pass�e � �A programmer�
    SELECT ETAT_EXPERIENCE INTO val_statut_experience FROM EXPERIENCE WHERE ID_EXPERIENCE = val_id_experience;

    --V�rification du r�sultat du trigger
    IF val_statut_experience != 'A programmer' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Test du trigger T_panne_app est un �chec');
    END IF;

    ROLLBACK;
END;
/
EXEC Test_T_panne_appareil;

CREATE OR REPLACE PROCEDURE Test_T_refus_plaque AS
  val_id_plaque PLAQUE.ID_PLAQUE%TYPE; -- Variable pour stocker l'identifiant de la plaque
  val_id_exp EXPERIENCE.ID_EXPERIENCE%TYPE; -- Variable pour stocker l'identifiant de l'exp�rience
  val_etat_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE; -- Variable pour stocker le statut de l'exp�rience

BEGIN
  -- Supposons que le refus de plaque ou de groupe soit d�tect�
  -- Nous affectons arbitrairement une plaque et une exp�rience existante
  -- aux variables val_id_plaque et val_id_exp respectivement

  -- S�lection d'une plaque existante
    SELECT ID_PLAQUE INTO val_id_plaque
    FROM PLAQUE
    WHERE ID_PLAQUE = 1; -- Supposons que nous s�lectionnons la premi�re plaque
    
      -- S�lection d'une exp�rience existante
    SELECT ID_EXPERIENCE INTO val_id_exp
    FROM EXPERIENCE
    WHERE ID_EXPERIENCE = 1; -- Supposons que nous s�lectionnons la premi�re exp�rience
    
      -- Simuler un refus de plaque ou de groupe en mettant � jour le statut de l'exp�rience
    UPDATE EXPERIENCE
    SET ETAT_EXPERIENCE = 'rat�e'
    WHERE ID_EXPERIENCE = val_id_exp
    AND ID_PLAQUE = val_id_plaque;
    
      -- Ajouter l'exp�rience � renouveler
    INSERT INTO LISTEATTENTE(ID_EXPERIENCE)
    VALUES (val_id_exp);
    
      -- V�rification du r�sultat du trigger
    SELECT ETAT_EXPERIENCE INTO val_etat_experience
    FROM EXPERIENCE
    WHERE ID_EXPERIENCE = val_id_exp;
    
    IF val_etat_experience != 'rat�e' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Test du trigger T_refus_plaque est un �chec');
    END IF;
    
    ROLLBACK;
END;
/
EXEC Test_T_refus_plaque;

/*----------------------------------------------------------------------------*\
--- PROCEDURE DE TEST T_ARRIVEE_LOT ------------------------------------------*\
/*----------------------------------------------------------------------------*\
-- Proc�dure de Test Positive (Ajout d'un Lot avec Type de Plaque Valide)
CREATE OR REPLACE PROCEDURE test_automatisation_lot_positive AS
    test96 integer ;

BEGIN
    INSERT INTO STOCK (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96)VALUES (1,0,0,0,0);

    -- Ins�rer un nouveau lot avec un type de plaque valide (96 ou 384)
    INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
    VALUES (1, 1, SYSDATE, 80, 96); -- Exemple avec un type de plaque 96

    -- S�lectionner les informations mises � jour du stock pour v�rification
    SELECT QUANTITE_P96 INTO test96
    FROM STOCK
    WHERE ID_STOCK = 1; -- ID_STOCK correspondant au lot ins�r�
    
    -- V�rification si le stock est insuffisant
    IF test96 = 0 THEN
        RAISE_APPLICATION_ERROR(-20023, 'Erreur le stock n a pas �t� mis � jour');
    END IF;
ROLLBACK;
END;
/

-- Proc�dure de Test N�gative (Ajout d'un Lot avec Type de Plaque Non Valide)
CREATE OR REPLACE PROCEDURE test_automatisation_lot_negative AS
    test96 INTEGER ;

BEGIN
    INSERT INTO STOCK (id_stock, quantite_p384, quantite_p96, vol_dernier_tri_p384, vol_dernier_tri_p96)VALUES (1,0,0,0,0);

    -- Tentative d'ins�rer un nouveau lot avec un type de plaque non pris en charge
    INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
    VALUES (1, 1, SYSDATE, 80, 96); -- Exemple avec un type de plaque non valide (200)
    INSERT INTO LOT (ID_LOT, ID_STOCK, DATE_LIVRAISON_LOT, NB_PLAQUE, TYPE_PLAQUE_LOT)
    VALUES (2, 1, SYSDATE, 80, 384); -- Exemple avec un type de plaque non valide (200)

    -- S�lectionner les informations mises � jour du stock pour v�rification
    SELECT QUANTITE_P96 INTO test96
    FROM STOCK
    WHERE ID_STOCK = 1; -- ID_STOCK correspondant au lot ins�r�
    
    -- V�rification si le stock est rempli 
    IF test96 = 160 THEN
        RAISE_APPLICATION_ERROR(-20024, 'Erreur le stock n a pas �t� mis � jour correctement');
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

/*Proc�dure de tests autour de l'exp�rience*/
CREATE OR REPLACE PROCEDURE test_creer_experience AS
  v_id_experience NUMBER;
  v_count_groupeslot INTEGER;
  v_count_slot INTEGER;
BEGIN
  -- Ins�rer une exp�rience dans la table EXPERIENCE
  INSERT INTO EXPERIENCE (ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, DUREE_EXPERIENCE, PRIORITE_EXPERIENCE, FREQUENCE_EXPERIENCE, REPROGR_MAX_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3)
  VALUES (1, 1, 1, '96', 2, 3, 10, 1, 2, 1, 0.1, 0.2, 0.3)
  RETURNING ID_EXPERIENCE INTO v_id_experience;

  -- V�rifier que l'exp�rience a �t� cr��e en r�cup�rant son ID
  IF v_id_experience IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, '�chec de la cr�ation de l''exp�rience');
  END IF;

  -- V�rifier que le trigger T_lancement_experience a bien cr�� les groupes de slots et les slots correspondants
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
  -- Ins�rer une exp�rience dans la table EXPERIENCE
  INSERT INTO EXPERIENCE (ID_LISTE, ID_TECHNICIEN, ID_CHERCHEUR, TYPE_PLAQUE, NB_GROUPE_SLOT_EXPERIENCE, NB_SLOTS_PAR_GROUPE_EXPERIENCE, DUREE_EXPERIENCE, PRIORITE_EXPERIENCE, FREQUENCE_EXPERIENCE, REPROGR_MAX_EXPERIENCE, VALEUR_BIAIS_A1, VALEUR_BIAIS_A2, VALEUR_BIAIS_A3)
  VALUES (1, 1, 1, 96, 2, 3, 10, 1, 2, 1, 0.1, 0.2, 0.3)
  RETURNING ID_EXPERIENCE INTO v_id_experience;

  -- Mettre � jour le statut de l'exp�rience
  UPDATE EXPERIENCE SET ETAT_EXPERIENCE = 'effectu�e' WHERE ID_EXPERIENCE = v_id_experience;

  -- V�rifier que le statut a bien �t� mis � jour
  SELECT ETAT_EXPERIENCE INTO v_etat_experience FROM EXPERIENCE WHERE ID_EXPERIENCE = v_id_experience;
  IF v_etat_experience != 'effectu�e' THEN
    RAISE_APPLICATION_ERROR(-20000, 'Echec de la mise � jour du statut de l exp�rience');
  END IF;
END;
/
EXEC test_maj_statut_experience;

CREATE OR REPLACE PROCEDURE test_supp_experience AS
  v_experience_id experience.id_experience%TYPE;
  v_count_groupeslot INTEGER;
  v_count_slot INTEGER;
BEGIN
  -- Ins�rer une exp�rience � supprimer
  INSERT INTO experience(id_liste, id_technicien, id_chercheur, type_plaque, nb_groupe_slot_experience, nb_slots_par_groupe_experience, duree_experience, priorite_experience, frequence_experience, reprogr_max_experience, valeur_biais_a1, valeur_biais_a2, valeur_biais_a3)
  VALUES (1, 1, 1, '96', 1, 1, 1, 1, 1, 1, 0.1, 0.2, 0.3)
  RETURNING id_experience INTO v_experience_id;

  -- Supprimer l'exp�rience
  DELETE FROM experience WHERE id_experience = v_experience_id;

  -- V�rifier que l'exp�rience a �t� supprim�e
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, '�chec de la suppression de l''exp�rience');
  END IF;

  -- V�rifier que les groupes de slots associ�s ont �t� supprim�s
  SELECT COUNT(*) INTO v_count_groupeslot FROM groupeslot WHERE id_experience = v_experience_id;
  IF v_count_groupeslot != 0 THEN
    RAISE_APPLICATION_ERROR(-20002, '�chec de la suppression des groupes de slots associ�s � l''exp�rience');
  END IF;

  -- V�rifier que les slots associ�s aux groupes de slots ont �t� supprim�s
  SELECT COUNT(*) INTO v_count_slot FROM slot WHERE id_groupe IN (SELECT id_groupe FROM groupeslot WHERE id_experience = v_experience_id);
  IF v_count_slot != 0 THEN
    RAISE_APPLICATION_ERROR(-20003, '�chec de la suppression des slots associ�s aux groupes de slots de l''exp�rience');
  END IF;
END;
/
EXEC test_supp_experience;
   
    