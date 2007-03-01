with text_io;
use text_io;

procedure Park is
NB_PLACES : constant := 3;
type T is array (1..NB_PLACES) of boolean;
	protected Parking is
		entry RENTRER (num : out natural);
		procedure SORTIR (num : in natural);
	private
		
		NB_PLACES_LIBRES : natural := NB_PLACES;
		OCCUPE : T := (others=>false);
	end Parking;
	protected body Parking is 
		entry RENTRER (num : out natural) when NB_PLACES_LIBRES > 0 is
		i : natural := 1;
		trouve : boolean := false;
		begin
			NB_PLACES_LIBRES:= NB_PLACES_LIBRES - 1;
			while (i <= NB_PLACES and not trouve)loop
				if (not OCCUPE(i)) then
					trouve := true;
				else i := i+1;
				end if;
			end loop;
			put_line("Voiture rentree!");
			OCCUPE(i):=true;
			num:=i;
			
		end RENTRER;
		
		procedure SORTIR (num : in natural) is
		begin
			NB_PLACES_LIBRES:= NB_PLACES_LIBRES + 1;
			OCCUPE(num) := false;
			put_line("Voiture sortie!");
		end SORTIR;
	end Parking;
	
	task type Voiture is
	end Voiture;
	task body Voiture is
	num_place : natural:=0;
	Seconde : constant duration := 1.0;
	begin
		select
			Parking.RENTRER(num_place);
		else
				put_line("parking plein!");
				delay(12*Seconde);
				Parking.RENTRER(num_place);	
		end select;
			delay(7*Seconde);
			Parking.SORTIR(num_place);
		exception
			when others=>put_line("erreur");		
	end Voiture;
			
V1 : Voiture;
V2 : Voiture;
V3 : Voiture;
V4 : Voiture;
V5 : Voiture;
begin			
	put_line("C parti!");				
end Park;
