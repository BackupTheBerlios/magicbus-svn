with text_io;
use text_io;

procedure Park is
NB_PLACES : constant := 10;
type T is array (1..NB_PLACES) of boolean;
	protected Parking is
		entry RENTRER (num : out natural);
		entry SORTIR (num : in natural);
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
				if (OCCUPE(i)) then
					trouve := true;
				end if;
				i := i+1;
			end loop;
			num:=i;
		end RENTRER;
		
		entry SORTIR (num : in natural) when NB_PLACES_LIBRES > 0 is
		begin
			NB_PLACES_LIBRES:= NB_PLACES_LIBRES + 1;
			OCCUPE(num) := false;
		end SORTIR;
	end Parking;
begin			
	put_line("C parti!");					
end Park;
