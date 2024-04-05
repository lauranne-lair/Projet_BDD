/*==============================================================*/
/* Nom de SGBD :  ORACLE Version 11g                            */
/* Date de création :  15/03/2024 08:29:11                      */
/*==============================================================*/
alter table ACHETER
   drop constraint FK_ACHETER_ACHETER_FOURNISS;
alter table ACHETER
   drop constraint FK_ACHETER_ACHETER2_LOT;
alter table APPAREIL
   drop constraint FK_APPAREIL_CONTENIR_LISTEATT;
alter table CHERCHEUR
   drop constraint FK_CHERCHEU_DESIGNER_EQUIPE;
alter table EXPERIENCE
   drop constraint FK_EXPERIEN_ASSOCIATI_LISTEATT;
alter table EXPERIENCE
   drop constraint FK_EXPERIEN_COMMANDER_CHERCHEU;
alter table EXPERIENCE
   drop constraint FK_EXPERIEN_REALISER_TECHNICI;
alter table FACTURE
   drop constraint FK_FACTURE_PAYER_EQUIPE;
alter table GROUPESLOT
   drop constraint FK_GROUPESL_POSSEDER_PLAQUE;
alter table GROUPESLOT
   drop constraint FK_GROUPESL_REGROUPER_EXPERIEN;
alter table LOT
   drop constraint FK_LOT_STOCKER_STOCK;
alter table LOT 
    drop CONSTRAINT check_nb_plaques;
alter table PLAQUE
   drop constraint FK_PLAQUE_PROVENIR_LOT;
alter table SLOT
   drop constraint FK_SLOT_ASSEMBLER_GROUPESL;
alter table TECHNICIEN
   drop constraint FK_TECHNICI_APPARTENI_EQUIPE;
ALTER TABLE EXPERIENCE 
    DROP CONSTRAINT check_duree;  
ALTER TABLE EXPERIENCE    
    DROP CONSTRAINT check_biais3; 
ALTER TABLE EXPERIENCE
    DROP CONSTRAINT check_biais1; 
ALTER TABLE EXPERIENCE
    DROP CONSTRAINT check_biais2;

drop index ACHETER2_FK;
drop index ACHETER_FK;
drop table ACHETER cascade constraints;
drop index CONTENIR_FK;
drop table APPAREIL cascade constraints;
drop index DESIGNER_FK;
drop table CHERCHEUR cascade constraints;
drop table EQUIPE cascade constraints;
drop index ASSOCIATION_13_FK;
drop index COMMANDER_FK;
drop index REALISER_FK;
drop table EXPERIENCE cascade constraints;
drop index PAYER_FK;
drop table FACTURE cascade constraints;
drop table FOURNISSEUR cascade constraints;
drop index REGROUPER_FK;
drop index POSSEDER_FK;
drop table GROUPESLOT cascade constraints;
drop table LISTEATTENTE cascade constraints;
drop index STOCKER_FK;
drop table LOT cascade constraints;
drop index PROVENIR_FK;
drop table PLAQUE cascade constraints;
drop index ASSEMBLER_FK;
drop table SLOT cascade constraints;
drop table STOCK cascade constraints;
drop index APPARTENIR_FK;
drop table TECHNICIEN cascade constraints;


/*==============================================================*/
/* Table : ACHETER                                              */
/*==============================================================*/
create table ACHETER 
(
   ID_FOURNISSEUR       INTEGER              not null,
   ID_LOT               INTEGER              not null,
   constraint PK_ACHETER primary key (ID_FOURNISSEUR, ID_LOT)
);

/*==============================================================*/
/* Index : ACHETER_FK                                           */
/*==============================================================*/
create index ACHETER_FK on ACHETER (
   ID_FOURNISSEUR ASC
);

/*==============================================================*/
/* Index : ACHETER2_FK                                          */
/*==============================================================*/
create index ACHETER2_FK on ACHETER (
   ID_LOT ASC
);

/*==============================================================*/
/* Table : APPAREIL                                             */
/*==============================================================*/
create table APPAREIL 
(
   ID_APPAREIL          INTEGER              not null,
   ID_LISTE             INTEGER,
   ETAT_APPAREIL        VARCHAR2(10),
   POSITION_APPAREIL    INTEGER,
   constraint PK_APPAREIL primary key (ID_APPAREIL)
);

/*==============================================================*/
/* Index : CONTENIR_FK                                          */
/*==============================================================*/
create index CONTENIR_FK on APPAREIL (
   ID_LISTE ASC
);

/*==============================================================*/
/* Table : CHERCHEUR                                            */
/*==============================================================*/
create table CHERCHEUR 
(
   ID_CHERCHEUR         INTEGER              not null,
   ID_EQUIPE            INTEGER              not null,
   NOM_CHERCHEUR        VARCHAR2(25),
   PRENOM_CHERCHEUR     VARCHAR2(25),
   constraint PK_CHERCHEUR primary key (ID_CHERCHEUR)
);

/*==============================================================*/
/* Index : DESIGNER_FK                                          */
/*==============================================================*/
create index DESIGNER_FK on CHERCHEUR (
   ID_EQUIPE ASC
);

/*==============================================================*/
/* Table : EQUIPE                                               */
/*==============================================================*/
create table EQUIPE 
(
   ID_EQUIPE            INTEGER              not null,
   ADRESSE_EQUIPE       VARCHAR2(50),
   SOLDE_EQUIPE         INTEGER,
   constraint PK_EQUIPE primary key (ID_EQUIPE)
);

/*==============================================================*/
/* Table : EXPERIENCE                                           */
/*==============================================================*/
create table EXPERIENCE 
(
   ID_EXPERIENCE        INTEGER              not null,
   ID_LISTE             INTEGER,
   ID_TECHNICIEN        INTEGER              not null,
   ID_CHERCHEUR         INTEGER              not null,
   TYPE_EXPERIENCE      VARCHAR2(14),
   ETAT_EXPERIENCE      VARCHAR2(25),
   NB_GROUPE_SLOT_EXPERIENCE INTEGER,
   NB_SLOTS_PAR_GROUPE_EXPERIENCE   INTEGER,
   DEB_EXPERIENCE       DATE,
   FIN_EXPERIENCE       DATE,
   DUREE_EXPERIENCE     INTEGER,
   DATE_DEMANDE_EXPERIENCE DATE,
   DATE_TRANSMISSION_RESULTAT DATE,
   PRIORITE_EXPERIENCE  INTEGER,
   FREQUENCE_EXPERIENCE INTEGER,
   REPROGR_MAX_EXPERIENCE INTEGER,
   COEFF_PRIX_PRIO_EXPERIENCE INTEGER,
   VALEUR_BIAIS_A1      FLOAT,
   VALEUR_BIAIS_A2      FLOAT,
   VALEUR_BIAIS_A3      FLOAT,
   MOYENNE_EXPERIENCE   INTEGER,
   ECART_TYPE_EXPERIENCE INTEGER,
   NB_RENOUVELLEMENT_EXPERIENCE INTEGER,
   constraint PK_EXPERIENCE primary key (ID_EXPERIENCE),
   CONSTRAINT check_duree CHECK (DUREE_EXPERIENCE > 0 ),
   CONSTRAINT check_biais3 CHECK (VALEUR_BIAIS_A3 BETWEEN 0.0 AND 1.0 ),
   CONSTRAINT check_biais1 CHECK (VALEUR_BIAIS_A1 > 0.0 ),
   CONSTRAINT check_biais2 CHECK (VALEUR_BIAIS_A2 > 0.0 )
);

    
/*==============================================================*/
/* Index : REALISER_FK                                          */
/*==============================================================*/
create index REALISER_FK on EXPERIENCE (
   ID_TECHNICIEN ASC
);

/*==============================================================*/
/* Index : COMMANDER_FK                                         */
/*==============================================================*/
create index COMMANDER_FK on EXPERIENCE (
   ID_CHERCHEUR ASC
);

/*==============================================================*/
/* Index : ASSOCIATION_13_FK                                    */
/*==============================================================*/
create index ASSOCIATION_13_FK on EXPERIENCE (
   ID_LISTE ASC
);

/*==============================================================*/
/* Table : FACTURE                                              */
/*==============================================================*/
create table FACTURE 
(
   ID_FACTURE           INTEGER              not null,
   ID_EQUIPE            INTEGER              not null,
   MONTANT_FACTURE      INTEGER,
   DATE_FACTURE         DATE,
   constraint PK_FACTURE primary key (ID_FACTURE)
);

/*==============================================================*/
/* Index : PAYER_FK                                             */
/*==============================================================*/
create index PAYER_FK on FACTURE (
   ID_EQUIPE ASC
);

/*==============================================================*/
/* Table : FOURNISSEUR                                          */
/*==============================================================*/
create table FOURNISSEUR 
(
   ID_FOURNISSEUR       INTEGER              not null,
   NOM_FOURNISSEUR      VARCHAR2(25),
   constraint PK_FOURNISSEUR primary key (ID_FOURNISSEUR)
);

/*==============================================================*/
/* Table : GROUPESLOT                                           */
/*==============================================================*/
create table GROUPESLOT 
(
   ID_GROUPE            INTEGER              not null,
   ID_EXPERIENCE        INTEGER              not null,
   ID_PLAQUE            INTEGER              not null,
   MOYENNE_GROUPE       INTEGER,
   ECART_TYPE_GROUPE    INTEGER,
   VALIDITE_GROUPE      INTEGER,
   constraint PK_GROUPESLOT primary key (ID_GROUPE)
);

/*==============================================================*/
/* Index : POSSEDER_FK                                          */
/*==============================================================*/
create index POSSEDER_FK on GROUPESLOT (
   ID_PLAQUE ASC
);

/*==============================================================*/
/* Index : REGROUPER_FK                                         */
/*==============================================================*/
create index REGROUPER_FK on GROUPESLOT (
   ID_EXPERIENCE ASC
);

/*==============================================================*/
/* Table : LISTEATTENTE                                         */
/*==============================================================*/
create table LISTEATTENTE 
(
   ID_LISTE             INTEGER              not null,
   NB_EXP_ATTENTE       INTEGER,
   EXPERIENCE           INTEGER,
   NB_EXP_DOUBLE        INTEGER,
   constraint PK_LISTEATTENTE primary key (ID_LISTE)
);

/*==============================================================*/
/* Table : LOT                                                  */
/*==============================================================*/
create table LOT 
(
   ID_LOT               INTEGER              not null,
   ID_STOCK             INTEGER              not null,
   DATE_LIVRAISON_LOT   DATE,
   NB_PLAQUE            INTEGER, 
   constraint PK_LOT primary key (ID_LOT),
   CONSTRAINT check_nb_plaques CHECK (NB_plaque = 80)
);

/*==============================================================*/
/* Index : STOCKER_FK                                           */
/*==============================================================*/
create index STOCKER_FK on LOT (
   ID_STOCK ASC
);

/*==============================================================*/
/* Table : PLAQUE                                               */
/*==============================================================*/
create table PLAQUE 
(
   ID_PLAQUE            INTEGER              not null,
   ID_LOT               INTEGER              not null,
   TYPE_PLAQUE          INTEGER,
   NB_EXPERIENCE_PLAQUE INTEGER,
   ETAT_PLAQUE          VARCHAR2(25),
   constraint PK_PLAQUE primary key (ID_PLAQUE)
);


/*==============================================================*/
/* Index : PROVENIR_FK                                          */
/*==============================================================*/
create index PROVENIR_FK on PLAQUE (
   ID_LOT ASC
);

/*==============================================================*/
/* Table : SLOT                                                 */
/*==============================================================*/
create table SLOT 
(
   ID_SLOT              INTEGER              not null,
   ID_GROUPE            INTEGER              not null,
   COULEUR_SLOT         VARCHAR2(25),
   NUMERO_SLOT          INTEGER,
   POSITION_X_SLOT      INTEGER,
   POSITION_Y_SLOT      INTEGER,
   RM_SLOT              INTEGER,
   RD_SLOT              INTEGER,
   VM_SLOT              INTEGER,
   VD_SLOT              INTEGER,
   BM_SLOT              INTEGER,
   BD_SLOT              INTEGER,
   TM_SLOT              INTEGER,
   TD_SLOT              INTEGER,
   constraint PK_SLOT primary key (ID_SLOT)
);

/*==============================================================*/
/* Index : ASSEMBLER_FK                                         */
/*==============================================================*/
create index ASSEMBLER_FK on SLOT (
   ID_GROUPE ASC
);

/*==============================================================*/
/* Table : STOCK                                                */
/*==============================================================*/
create table STOCK 
(
   ID_STOCK             INTEGER              not null,
   QUANTITE_P384        INTEGER,
   QUANTITE_P96         INTEGER,
   VOL_DERNIER_TRI_P384 INTEGER,
   VOL_DERNIER_TRI_P96  INTEGER,
   constraint PK_STOCK primary key (ID_STOCK)
);

/*==============================================================*/
/* Table : TECHNICIEN                                           */
/*==============================================================*/
create table TECHNICIEN 
(
   ID_TECHNICIEN        INTEGER              not null,
   ID_EQUIPE            INTEGER              not null,
   NOM_TECHNICIEN       VARCHAR2(25),
   PRENOM_TECHNICIEN    VARCHAR2(25),
   constraint PK_TECHNICIEN primary key (ID_TECHNICIEN)
);

/*==============================================================*/
/* Index : APPARTENIR_FK                                        */
/*==============================================================*/
create index APPARTENIR_FK on TECHNICIEN (
   ID_EQUIPE ASC
);

alter table ACHETER
   add constraint FK_ACHETER_ACHETER_FOURNISS foreign key (ID_FOURNISSEUR)
      references FOURNISSEUR (ID_FOURNISSEUR);

alter table ACHETER
   add constraint FK_ACHETER_ACHETER2_LOT foreign key (ID_LOT)
      references LOT (ID_LOT);

alter table APPAREIL
   add constraint FK_APPAREIL_CONTENIR_LISTEATT foreign key (ID_LISTE)
      references LISTEATTENTE (ID_LISTE);

alter table CHERCHEUR
   add constraint FK_CHERCHEU_DESIGNER_EQUIPE foreign key (ID_EQUIPE)
      references EQUIPE (ID_EQUIPE);

alter table EXPERIENCE
   add constraint FK_EXPERIEN_ASSOCIATI_LISTEATT foreign key (ID_LISTE)
      references LISTEATTENTE (ID_LISTE);

alter table EXPERIENCE
   add constraint FK_EXPERIEN_COMMANDER_CHERCHEU foreign key (ID_CHERCHEUR)
      references CHERCHEUR (ID_CHERCHEUR);

alter table EXPERIENCE
   add constraint FK_EXPERIEN_REALISER_TECHNICI foreign key (ID_TECHNICIEN)
      references TECHNICIEN (ID_TECHNICIEN);

alter table FACTURE
   add constraint FK_FACTURE_PAYER_EQUIPE foreign key (ID_EQUIPE)
      references EQUIPE (ID_EQUIPE);

alter table GROUPESLOT
   add constraint FK_GROUPESL_POSSEDER_PLAQUE foreign key (ID_PLAQUE)
      references PLAQUE (ID_PLAQUE);

alter table GROUPESLOT
   add constraint FK_GROUPESL_REGROUPER_EXPERIEN foreign key (ID_EXPERIENCE)
      references EXPERIENCE (ID_EXPERIENCE);

alter table LOT
   add constraint FK_LOT_STOCKER_STOCK foreign key (ID_STOCK)
      references STOCK (ID_STOCK);

alter table PLAQUE
   add constraint FK_PLAQUE_PROVENIR_LOT foreign key (ID_LOT)
      references LOT (ID_LOT);

alter table SLOT
   add constraint FK_SLOT_ASSEMBLER_GROUPESL foreign key (ID_GROUPE)
      references GROUPESLOT (ID_GROUPE);

alter table TECHNICIEN
   add constraint FK_TECHNICI_APPARTENI_EQUIPE foreign key (ID_EQUIPE)
      references EQUIPE (ID_EQUIPE);



Commit;
