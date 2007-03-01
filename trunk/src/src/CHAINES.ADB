-- corps du paquetage CHAINES
-- Entreees sorties sur les chaines de caracteres

-- Utilisation de Text_Io pour les entrees sorties de String (Get_line et Put)
with Text_Io; use Text_Io;

package body CHAINES is

-- Saisie d'une chaine de caracteres
procedure GET (S : out CHAINE) is
begin
        Get_line (S.CH, S.LG);  -- Saisi les caracteres jusqu'à la fin de ligne et indique combien il y en a.
end GET;

-- Affichage d'une chaine de caracteres
procedure PUT ( S : in CHAINE) is
begin
        Put (S.CH (1 .. S.LG)); -- Affiche les S.LG premiers caracteres du String S.CH
end PUT;

-- Donne le nom d'une chaine de caracteres
function NOM_CHAINE (S : in CHAINE) return String is
begin
   return S.CH (1 .. S.LG);
end NOM_CHAINE;

-- Donne la longueur d'une chaine de caracteres
function LONGUEUR (S : in CHAINE) return Integer is
begin
      return S.LG;
end LONGUEUR;

-- Fonctions de comparaison de chaines de caracteres

function "=" (S1, S2 : in CHAINE) return boolean is
begin
      return S1.CH(1..S1.LG) = S2.CH(1..S2.LG);
end "=";

function "<" (S1, S2 : in CHAINE) return boolean is
begin
      return S1.CH(1..S1.LG) < S2.CH(1..S2.LG);
end "<";

function "<=" (S1, S2 : in CHAINE) return boolean is
begin
      return S1.CH(1..S1.LG) <= S2.CH(1..S2.LG);
end "<=";

function ">" (S1, S2 : in CHAINE) return boolean is
begin
      return S1.CH(1..S1.LG) > S2.CH(1..S2.LG);
end ">";

function ">=" (S1, S2 : in CHAINE) return boolean is
begin
      return S1.CH(1..S1.LG) >= S2.CH(1..S2.LG);
end ">=";


end CHAINES;



