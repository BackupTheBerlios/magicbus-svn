with text_io,CHAINES;
use text_io,CHAINES;

procedure speed_control is
NB_PLACES : constant := 3;
type T is array (1..NB_PLACES) of boolean;
	protected Speed_Motor is
		entry ACCELERER;
		entry DECELERER;
		entry START;
		entry STOP;
		procedure ReturnSpeed (current_speed : out integer);
	private
		speed : integer:=0;
	end Speed_Motor;
	protected body Speed_Motor is 
		entry ACCELERER when speed < 50 is
		begin
			speed:=speed + 5;
			put("speed : ") ;
			put_line(integer'image(speed));
		end ACCELERER;
		
		entry DECELERER when speed > 5 is
		begin
			speed:=speed - 5;
			put("speed : ") ;
			put_line(integer'image(speed));
		end DECELERER;
		
		entry START when speed = 0 is
		begin
			speed:=25;
			put("speed : ") ;
			put_line(integer'image(speed));
		end START;
		
		entry STOP when speed > 0 is
		begin
			put_line("arret du bus ...");
			while(speed > 0) loop
				speed:= speed - 5;
				put("speed : ") ;
				put_line(integer'image(speed));
			end loop; 		
		end STOP;
		
		procedure ReturnSpeed (current_speed : out integer) is
		begin
			current_speed := speed;
		end ReturnSpeed;
	end Speed_Motor;
	
    -- TACHE DE TEST POUR VERIFIER QUE LE SPEED_CONTROL MARCHE
    -- CETTE PARTIE SERA SUPPRIME QUAND LE DRIVER SERA REELLEMENT IMPLEMENTE!!!!
	task type Driver is
	end Driver;
	task body Driver is
	i:integer:=0;
	Seconde : constant duration := 1.0;
	begin
		Speed_Motor.START;
		while(i<15) loop
			select
				Speed_Motor.ACCELERER;
			else
				put_line("limite de vitesse atteinte");
				delay(1*Seconde);
				Speed_Motor.DECELERER;	
			end select;
				
			i:=i+1;
		end loop;
		delay(2*Seconde);
			Speed_Motor.STOP;
			
		exception
			when others=>put_line("erreur");		
	end Driver;
	-- FIN DE LA PRTIE QUI SERA SUPPRIME

D1 : Driver;
begin			
	put_line("C parti!");				
end speed_control;
