MODULE Example;
  IMPORT Out, SYSTEM;

  TYPE
    R1 = RECORD
      a: INTEGER
    END;
    R2 = RECORD (R1)
      b: INTEGER
    END;

  VAR
    i: SYSTEM.CARD16 := 65535;
    j: SYSTEM.CARD8 := 0;
    r1: R1;
    r2: R2;

  PROCEDURE (VAR r: R1) Print;
  BEGIN
    Out.String ("R1.a = "); Out.Int (r.a, 0); Out.Ln;
  END Print;

  PROCEDURE (VAR r: R2) Print;
  BEGIN
    r.Print^;
    Out.String ("R2.b = "); Out.Int (r.b, 0); Out.Ln;
  END Print;

  PROCEDURE f1;
    PROCEDURE f2;
    BEGIN
      Out.String ("f2"); Out.Ln;
    END f2;
    PROCEDURE f3;
    BEGIN
      Out.String ("f3"); Out.Ln;
    END f3;
  BEGIN
    Out.String ("f1"); Out.Ln;
    f2;
  END f1;
  

BEGIN
  Out.Card (i, 0); Out.Ln;
  j := SYSTEM.VAL (SYSTEM.CARD8, i);
  Out.Card (j, 0); Out.Ln;
  r1.a := 1; r1.Print;
  r2.a := 2; r2.b := 3; r2.Print;
END Example.
