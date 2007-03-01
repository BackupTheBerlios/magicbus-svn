with text_io,common_types,Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions,text_io,common_types;

procedure Bus is
    type T_direction : CHAINE;
    protected Driver is
        entry changeLine(new_line : in integer);
        entry changeDirection;
        entry setListBusStop(listBusStop : in T_busStopList);
        entry calculateSpeed(delay_time:in float);
        
        private
            id_line : integer;
            direction : T_direction;
            listOfBusStop : T_busStopList;
            lastBusStop :T_busStop;
            nextBusStop:T_busStop;
    end Driver;
    
  protected body Driver is 
        entry changeLine (new_line : in integer)when  id_line=1 is
            begin
                id_line:= new_line;
            end changeLine;
      
        entry changeDirection when  id_line=1 is
            begin
                if(direction="ALLER")then
                    direction:="RETOUR";
                else
                    direction:="ALLER";
                end if;
            end changeDirection;
        
    
        entry setListBusStop(listBusStop : in T_busStopList) when  id_line=1 is
           begin
            for K in 1..50 loop
                listOfBusStop(K):=listBusStop(K);
            end loop;
        end setListBusStop;
        
        entry calculateSpeed(delay_time:in float) when  id_line=1 is
            lastBusStop : T_busStop;
            distanceAParcourir : float;
            distanceParcourue : float;
            begin
                lastBusStop:=Sensor.getLastBusStopCapted;
                Odometer.returnDistance(distanceParcourue);
                
                
                
            
        end calculateSpeed;
       
     end Driver;
begin         
  put_line("C parti!");                   
end Bus;
