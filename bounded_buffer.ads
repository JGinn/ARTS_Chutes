generic
type Element_T is private;
package Bounded_Buffer is
  Buffer_Size : constant := 5;
  type index is mod Buffer_Size;
  type Buff is array (index) of Element_T;
  type Buffer_Count is Range 0..Buffer_Size;

  type Element_Valid (Valid : Boolean:= True) is      -- the discriminant must have a default value
    record
       case Valid is
          when True =>
            Data : Element_T;
          when False =>
            null;
       end case;
    end record;

  protected type Buffer is
    entry Place (Item : Element_T);
    entry Take (Item : out Element_T);
    entry Drop;
    function Peek return Element_Valid;
  private
    First : index := index'first;
    Last : index := index'last;
    Num : Buffer_Count := 0;
    Buf : Buff;
  end Buffer;
private
end Bounded_Buffer;
