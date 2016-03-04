pragma Task_Dispatching_Policy(FIFO_Within_Priorities);
with MaRTE_OS;
with Text_IO; use Text_IO;
with System; use System;
with Chute; use Chute;
with Ada.Calendar; use Ada.Calendar;
with Bounded_Buffer;

procedure main is
  B : Ball_Sensed;
  T : Time;
  Hopper_Load_Time : Duration := 0.1;
  Transfer_Time : Duration := 1.1;
  Release_Frequency : Duration := 0.6;

  package Time_Buffer is new Bounded_Buffer(Element_T => Time);

  protected Watch_Dog is
    procedure Keep_Alive;
    entry Check_Alive;
    procedure Stop;
    entry Going;
    private
    alive, still_going: Boolean := True;
  end Watch_Dog;

  task Watch_Dog_Controller;

  Task Releaser is
    pragma Priority(System.Priority'First);
  end Releaser;

  Task Sorter is
    pragma Priority(System.Priority'Last);
  end Sorter;

  protected body Watch_Dog is
    procedure Keep_Alive is
    begin
      alive := True;
    end Keep_Alive;

    entry Check_Alive when alive is
    begin
      alive := False;
    end Check_Alive;

    procedure Stop is
    begin
      still_going := False;
    end Stop;

    entry Going when not still_going is
    begin
      null;
    end Going;
  end Watch_Dog;

  task body Watch_Dog_Controller is
    died : Boolean := False;
    watch_dog_time_out : exception;
  begin
    loop
      select Watch_Dog.Check_Alive;
      then abort
        delay 3.0;
        Put_Line("Ended###################################");
        died := True;
      end select;
      exit when died;
    end loop;
    Put_Line("DU-DU ... DU ... DU-DU TERMINATE!!!!!!!!!!");
    Watch_Dog.Stop;
    raise watch_dog_time_out;
  end Watch_Dog_Controller;

  Task body Releaser is
  begin
    New_Line;
    Put_Line("Sorter Close.");
    Sorter_Close;

    select Watch_Dog.Going;
    then abort
      while true loop
        Put_Line("Hopper_Load");
        Hopper_Load;
        delay Hopper_Load_Time;

        New_Line (1);
        Put ("Hopper_Unload");
        Hopper_Unload;

        delay release_frequency;
      end loop;
    end select;
  exception
    when others => Put_Line("I've dropped the ball! :,(");
  end Releaser;

  Task body Sorter is
    Metal_Buffer : Time_Buffer.Buffer;
    element: Time_Buffer.Element_Valid;
  begin
    select Watch_Dog.Going;
    then abort
      while true loop
        Watch_Dog.Keep_Alive;
        Get_Next_Sensed_Ball(B, T);

        if (B = Metal) then
          Metal_Buffer.Place(T);
        else
          element := Metal_Buffer.Peek;
          if element.Valid and then (T - element.Data > Transfer_Time) then
            Metal_Buffer.Drop;
            Sorter_Metal;
          else
            Sorter_Glass;
          end if;
        end if;

        Put_Line("Ball Sensed: ");
        Put_Line(Ball_Sensed'Image(B));
      end loop;
    end select;
  end Sorter;

begin
  null;
exception
  when others => Put_Line("Oops");
end main;
