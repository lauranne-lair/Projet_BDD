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
