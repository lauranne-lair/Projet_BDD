CREATE OR REPLACE PROCEDURE Test_T_rachat_stock AS 
    volume_utilise_trimestre NUMBER; -- Variable pour stocker le volume utilis� ce trimestre
    stock_actuel NUMBER; -- Variable pour stocker le stock actuel de plaques
BEGIN
    -- Ins�rer des donn�es de test dans la table Plaque (simuler volume utilis� sur dernier trimestre)
    INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
    VALUES (1, 1, '1', 100, 'Utilis�e');

    -- Ins�rer des donn�es de test dans la table LOT (pour avoir un stock insuffisant)
    INSERT INTO LOT (ID_LOT, DATE_LIVRAISON_LOT, NB_PLAQUE)
    VALUES (1, TO_DATE('2024-03-28', 'YYYY-MM-DD'), 50);

    -- Ex�cuter le trigger en ins�rant une ligne dans la table plaque pour lancer le trigger 
    INSERT INTO PLAQUE (ID_PLAQUE, ID_LOT, TYPE_PLAQUE, NB_EXPERIENCE_PLAQUE, ETAT_PLAQUE)
    VALUES (2, 2, '1', 100, 'Utilis�e'); 

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
ROLLBACK;
END;
/

CREATE OR REPLACE PROCEDURE Test_T_panne_appareil AS
	--D�claration des variables de test
	val_id_appareil APPAREIL.ID_APPAREIL%TYPE;
	val_id_experience EXPERIENCE.ID_EXPERIENCE%TYPE;
val_statut_experience EXPERIENCE.ETAT_EXPERIENCE%TYPE;
BEGIN
	--S�lection d�un appareil pour le test
	SELECT id_appareil INTO val_id_appareil FROM APPAREIL WHERE ROWNUM = 1;
	--Insertion d�une exp�rience programm�e qui utilise l�appareil s�lectionn�
	INSERT INTO EXPERIENCE (ID_EXPERIENCE, ID_APPAREIL, ETAT_EXPERIENCE) VALUES (1, val_id_appareil, �Programm�e�);

	--S�lection de l�identifiant de l�exp�rience ins�r�e
	SELECT ID_EXPERIENCE INTO val_id_experience FROM EXPERIENCE WHERE ROWNUM = 1;

	--Mettre la disponibilit� de l�appareil � �En panne�
	UPDATE APPAREIL SET DISPO_APPAREIL = 0 WHERE ID_APPREIL = val_id_appareil;
	--V�rification de la mise � jour du statut de l�exp�rience qui doit �tre pass�e � �A programmer�
	SELECT ETAT_EXPERIENCE INTO val_statut_experience FROM EXPERIENCE WHERE ID_EXPERIENCE = val_id_experience;

	--V�rification du r�sultat du trigger
	IF val_statut_experience != �A programmer� THEN
		RAISE_APPLICATION_ERROR(-20001, �Test du trigger T_panne_app est un �chec�);
	END IF;
ROLLBACK;
END;
/

CREATE OR REPLACE PROCEDURE Test_T_refus_plaque AS
  val_id_plaque VARCHAR2(100); -- Variable pour stocker l'identifiant de la plaque
  val_id_exp INTEGER; -- Variable pour stocker l'identifiant de l'exp�rience

BEGIN
  -- Supposons que le refus de plaque ou de groupe soit d�tect�
  -- Nous affectons arbitrairement une plaque et une exp�rience existante
  -- aux variables val_id_plaque et val_id_exp respectivement

  -- S�lection d'une plaque existante
  SELECT ID_PLAQUE INTO val_id_plaque
  FROM PLAQUE
  WHERE ID_PLAQUE= 1; -- Supposons que nous s�lectionnons la premi�re plaque

  -- S�lection d'une exp�rience existante
  SELECT ID_EXPERIENCE INTO val_id_exp
  FROM EXPERIENCE
  WHERE ID_EXPERIENCE = 1; -- Supposons que nous s�lectionnons la premi�re exp�rience

  -- Simuler un refus de plaque ou de groupe en mettant � jour le statut de l'exp�rience
  UPDATE EXPERIENCE
  SET statut = 'Echou�'
  WHERE  val_id_plaque= val_id_exp;

  -- Ajouter l'exp�rience � renouveler
  INSERT INTO LISTEATTENTE()
  VALUES (val_id_exp);


--V�rification du r�sultat du trigger
	IF val_statut_experience != ��chou� THEN
		RAISE_APPLICATION_ERROR(-20001, �Test du trigger T_refus_plaque est un �chec�);
	END IF;
ROLLBACK; 
END;
/



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
end; 
/
    
    