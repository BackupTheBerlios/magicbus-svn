-- Specification du paquetage CHAINES
-- Contient toutes les opérations usuelles sur les chaînes de caractères.
-- Definition des chaines de caracteres, et des operations d'entrees sorties sur des chaines
package CHAINES is

-- Definition de constante
      LONGUEUR_CHAINE : constant Integer := 256;      -- Longueur maximum d'une chaine de caractere

-- Definition du type CHAINE
      type CHAINE is record
         CH : String (1 .. LONGUEUR_CHAINE);     -- Les caracteres de la chaine
         LG : Integer;   -- La longueur reelle de la chaine
      end record;

-- Saisie d'une chaine de caracteres
      procedure GET (S : out CHAINE);
-- Affichage d'une chaine de caracteres
      procedure PUT (S : in CHAINE);
-- Donne le nom d'une chaine de caracteres
      function NOM_CHAINE (S : in CHAINE) return String;
-- Donne la longueur d'une chaine de caracteres
      function LONGUEUR (S : in CHAINE) return Integer;
-- Fonctions de comparaison de chaines de caracteres
      function "=" (S1, S2 : in CHAINE) return boolean;
      function "<" (S1, S2 : in CHAINE) return boolean;
      function "<=" (S1, S2 : in CHAINE) return boolean;
      function ">" (S1, S2 : in CHAINE) return boolean;
      function ">=" (S1, S2 : in CHAINE) return boolean;


end CHAINES;
