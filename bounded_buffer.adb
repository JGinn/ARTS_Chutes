package body Bounded_Buffer is
  protected body Buffer is
    entry Place (Item : Element_T) when Num < Buffer_Size is
    begin
      Last := Last + 1;
      Buf(Last) := Item;
      Num := Num + 1;
    end Place;

    entry Take (Item : out Element_T) when Num > 0 is
    begin
      Item := Buf(First);
      First := First + 1;
      Num := Num - 1;
    end Take;

    entry Drop when Num > 0 is
    begin
      First := First + 1;
      Num := Num - 1;
    end Drop;

    function Peek return Element_Valid is
    begin
      if Num = 0 then
        return (Valid => False);
      else
        return (Valid => True,
               Data => Buf(First));
      end if;
    end Peek;
  end Buffer;
end Bounded_Buffer;
