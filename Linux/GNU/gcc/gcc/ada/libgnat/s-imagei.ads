------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . I M A G E _ I                        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 1992-2025, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This package provides the subprograms supporting the ``Image`` attribute
--  and ``Ada.Text_IO.Integer_IO`` conversions routines for signed integer
--  types.

--  Preconditions in this unit are meant for analysis only, not for run-time
--  checking, so that the expected exceptions are raised. This is enforced by
--  setting the corresponding assertion policy to Ignore. Postconditions and
--  contract cases should not be executed at runtime as well, in order not to
--  slow down the execution of these functions.

pragma Assertion_Policy (Pre                => Ignore,
                         Post               => Ignore,
                         Contract_Cases     => Ignore,
                         Ghost              => Ignore,
                         Subprogram_Variant => Ignore);

with System.Value_I_Spec;
with System.Value_U_Spec;

generic
   type Int is range <>;
   type Uns is mod <>;

   --  Additional parameters for ghost subprograms used inside contracts

   with package U_Spec is new System.Value_U_Spec (Uns => Uns) with Ghost;
   with package I_Spec is new System.Value_I_Spec
     (Int => Int, Uns => Uns, U_Spec => U_Spec) with Ghost;

package System.Image_I is
   package IP renames I_Spec;
   package UP renames U_Spec;
   use type UP.Uns_Option;

   Unsigned_Width_Ghost : constant Natural := U_Spec.Max_Log10 + 2 with Ghost;

   procedure Image_Integer
     (V : Int;
      S : in out String;
      P : out Natural)
   with
     Pre  => S'First = 1
       and then S'Last < Integer'Last
       and then S'Last >= Unsigned_Width_Ghost,
     Post => P in S'Range
       and then IP.Is_Value_Integer_Ghost (S (1 .. P), V);
   --  Computes Int'Image (V) and stores the result in S (1 .. P)
   --  setting the resulting value of P. The caller guarantees that S
   --  is long enough to hold the result, and that S'First is 1.

   procedure Set_Image_Integer
     (V : Int;
      S : in out String;
      P : in out Natural)
   with
     Pre  => P < Integer'Last
       and then S'Last < Integer'Last
       and then S'First <= P + 1
       and then S'First <= S'Last
       and then
         (if V >= 0 then
            P <= S'Last - Unsigned_Width_Ghost + 1
          else
            P <= S'Last - Unsigned_Width_Ghost),
     Post => S (S'First .. P'Old) = S'Old (S'First .. P'Old)
       and then
         (declare
            Minus  : constant Boolean := S (P'Old + 1) = '-';
            Offset : constant Positive := (if V >= 0 then 1 else 2);
            Abs_V  : constant Uns := IP.Abs_Uns_Of_Int (V);
          begin
            Minus = (V < 0)
              and then P in P'Old + Offset .. S'Last
              and then UP.Only_Decimal_Ghost
                (S, From => P'Old + Offset, To => P)
              and then UP.Scan_Based_Number_Ghost
                (S, From => P'Old + Offset, To => P)
                = UP.Wrap_Option (Abs_V));
   --  Stores the image of V in S starting at S (P + 1), P is updated to point
   --  to the last character stored. The value stored is identical to the value
   --  of Int'Image (V) except that no leading space is stored when V is
   --  non-negative. The caller guarantees that S is long enough to hold the
   --  result. S need not have a lower bound of 1.

end System.Image_I;
