newPackage(
        "FractionalIdeals",
        Version => "0.1", 
        Date => "6 June 2009",
        Authors => {{Name => "Mike Stillman", 
                  Email => "mike@math.cornell.edu", 
                  HomePage => "http://www.math.cornell.edu/~mike"}},
        Headline => "fractional ideals given a domain in Noether normal position",
        DebuggingMode => true
        )

-- Requires at least M2 version 1.3.

export {FractionalIdeal, 
     fractionalIdeal,
     disc, -- this name will change!
     newDenominator,
     simplify,
     integralClosureHypersurface
     }

if instance(FractionalIdeal, Symbol) then
FractionalIdeal = new Type of List

-- major assumption/restriction: the ring of a FractionalIdeal F
-- should be of the form R = S/I, where S is a polynomial ring with a product order
-- and such that if A is the polynomial ring generated by the variables not occuring in
-- the first block, then A --> S/I should be a Noether normalization.

-- A fractional ideal of R is repesented by a  list {f,I}
-- representing 1/f I contained in K(R), and f is in the subpolynomial ring A
-- (see above).
--
-- If this is a ring (or known to be one), then I_0 will be f

debug IntegralClosure

ring FractionalIdeal := (F) -> ring F#0

chooseNZD = method()
chooseNZD FractionalIdeal := (F) -> (
     -- find an element of the subpolynomial ring which is in the
     -- ideal L of F = 1/f L.  Although this element is in A, its
     -- ring is R = ring F.
     -- we compute the intersection with the subring, and then take a
     -- reasonable element there (reasonable: small degree, or small size, ...)
     L := ideal selectInSubring(1, gens gb F#1);
     if L == 0 then error "no non-zero element in the subpolynomial ring found";
     findSmallGen L
     )

ends := (F) -> (
     -- returns the FractionalIdeal Hom_R(F,F)
     I := F#1;
     f := chooseNZD F;
     timing(H1 := (f*I):I);
     H := compress ((gens H1) % f);
     new FractionalIdeal from {f,ideal(matrix{{f}} | H)}
     )

Hom(FractionalIdeal, FractionalIdeal) := (F,G) -> (
     if F === G 
       then ends F
       else error "not implemented yet"
     )

simplify = method()
simplify FractionalIdeal := (F) -> (
     -- return the FractionalIdeal equal to F, but
     -- whose representation is minimal: there is no nontrivial common factor 
     -- between the denominator and all of "y"-coefficients of the numerator.
     -- Assumption: the monomial order is a product order
     -- giving the Noether normalization
     R := ring F;
     basevars := flatten entries selectInSubring(1,vars R);
     fibervars := toList(set gens R - set basevars);
     (mns, cfs) := coefficients(gens F#1, Variables=>fibervars);
     G := gcd prepend(F#0, flatten entries cfs);
     new FractionalIdeal from {F#0//G, ideal(mns * (cfs//G))}
     )

fractionalIdeal = method()
fractionalIdeal Ideal := (I) -> (
     R := ring I;
     new FractionalIdeal from {1_R, I}
     )

fractionalIdeal(RingElement, Ideal) := (F,I) -> (
     R := ring I;
     if ring F =!= R then error "expected denominator in the same ring as ideal";
     simplify new FractionalIdeal from {F, I}
     )

ringFromFractions FractionalIdeal := opts -> (F) -> (
     -- assuming that F is a subring of K(R), this computes the quotient ring presenting F
     -- if it is not a ring, then what kind of error will it return?
     -- ASSUMPTION (possibly a bad one): F#0 is the first element of F#1
     f := F#0;
     I := F#1;
     H := submatrix(gens I, 1..numgens I - 1);
     target first ringFromFractions(H,f,opts)
     )

isIdeal(FractionalIdeal,FractionalIdeal) := (F,R1) -> (
     -- is F an ideal in R1?
     -- R1 = 1/f L, F = 1/g J
     -- F willl be an ideal if 
     --  (1) it is contained in R1
     --  (2) R1*F is contained in F  1/fg * LJ \subset 1/g J
     --       i.e.: L*J \subset (f)J
     -- MES: not yet correct
     << "isIdeal: not correct" << endl;
     (gens (R1#1 * F#1)) % (R1#0 * F#1) == 0
     )

isSubset(FractionalIdeal,FractionalIdeal) := (F,G) -> (
     (gens (G#1 * F#1)) % (F#0 * G#1) == 0
     )

FractionalIdeal * FractionalIdeal := (F,G) -> (
     FG := simplify new FractionalIdeal from {F#0 * G#0, trim(F#1*G#1)};
     new FractionalIdeal from {FG#0, trim FG#1}
     )

FractionalIdeal == FractionalIdeal := (F,G) -> F#0 * G#1 == G#0 * F#1

newDenominator = method()
newDenominator(FractionalIdeal, RingElement) := (F,g) -> (
     R := ring F;
     S := ring ideal R;
     a := lift(F#0, S);
     b := lift(g, S);
     if b % a != 0 then error "cannot change to desired denominator";
     new FractionalIdeal from {b, promote(b//a,R) * F#1}
     )

radical(FractionalIdeal, FractionalIdeal) := opts -> (F,R1) -> (
     -- Assumption: R1 is a ring
     -- F is an ideal of R1
     -- compute a presentation A of R1
     R1' := ringFromFractions(R1, Variable=>symbol w); -- the generators correspond to elements of R1#1 (except the first, which 
          -- corresponds to the unit).
     -- map F into A.  We need to know how to represent elements of F as elements in R1
     -- we assume: F = 1/g J \subset R1 = 1/f L
     --   i.e. J \subset g/f L
     S' := ring ideal R1';
     R := ring R1#0;
     M := gens (R1#0 * F#1) // (gens (F#0 * R1#1));
     newvars := (vars S')_{0..numgens R1'-numgens R-1};
     v := matrix{{1_R1'}} | promote(newvars,R1');
     vS' := matrix{{1_S'}} | newvars;
     J := ideal(v * sub(M, R1'));
     -- do the radical
     Jcomps := decompose J;
     << " rad components codims " << (Jcomps/codim) << endl;
     << " rad components " << netList Jcomps << endl;
     Jrad := trim radical J; -- note: these are all linear in the new vars
     Jrad = lift(gens Jrad, S');
     (mn,cf) := coefficients(Jrad, Monomials => vS', Variables=>flatten entries newvars);
     Jid := (gens R1#1) * sub(cf,R);
     (Jrad, R1 * new FractionalIdeal from {R1#0, ideal Jid})
     )

disc = method()
disc QuotientRing := (R) -> (
     I := ideal R;
     if numgens I > 1 then error "disc expected a quotient by a single monic polynomial";
     F := I_0;
     S := ring F;
     x := S_0; -- F should be monic in this variable MES: put in a test for this!!
     d := degree_x F;
     if first degree contract(x^d, F) > 0 then error "expected monic polynomial";
     ds := factor discriminant(F, x);
     dfactors := select((toList ds)/toList, m -> m#1 > 1);
     dfactors/(f -> {f#0, f#1//2})
     )
disc(RingElement,RingElement) := (F,x) -> (
     if ring F =!= ring x then error "expected variable and polynomial to be in the same ring";
     if index x === null then error "expected indeterminate in ring";
     d := degree_x F;
     if first degree contract(x^d, F) > 0 then error "expected monic polynomial";
     ds := factor discriminant(F, x);
     dfactors := select((toList ds)/toList, m -> m#1 > 1);
     dfactors/(f -> {f#0, f#1//2})
     )

integralClosureHypersurface = method()
integralClosureHypersurface Ring := (R) -> (
     -- assumption: R is in Noether normal position
     -- as required above.
     D := (disc R)/first//product;
     e1 := fractionalIdeal ideal 1_R;
     time j := fractionalIdeal trim radical ideal promote(D,R);
     time e := End j;
     while e != e1 do (
	  e1 = e;
	  time (k,j) = radical(j,e1);
	  time e = End j;
	  );
     simplify e)

step1 = (j) -> (e := End j; (e*j, e))
step2 = (j,e) -> (radical(j,e))_1

-- need: a similar routine for non-hypersurfaces

beginDocumentation()

doc ///
Key
  FractionalIdeals
Headline
  manipulation of fractional ideals in a domain in Noether normal position
Description
  Text
  Example
Caveat
SeeAlso
///

end

doc ///
Key
Headline
Inputs
Outputs
Consequences
Description
  Text
  Example
Caveat
SeeAlso
///

TEST ///
-- test code and assertions here
-- may have as many TEST sections as needed
///


--boehm19
restart
loadPackage "FractionalIdeals"
S = QQ[u,v, MonomialOrder=>{1,1}]
F = 5*v^6+7*v^2*u^4+6*u^6+21*v^2*u^3+12*u^5+21*v^2*u^2+6*u^4+7*v^2*u
R = S/F

-- working on this bug:
rj3 = fractionalIdeal(v^3, ideal(v^4,u^2*v^3+u*v^3,u^3*v^2+u^2*v^2,u^5*v+u^4*v))
r3 = fractionalIdeal(v^3, ideal(v^3,u^3*v^2+u^2*v^2,u^4*v+u^3*v,6*u^5+6*u^4+7*u^2*v^2+7*u*v^2))
rj3/ring
r3/ring
r3*r3 == r3 -- true 
isSubset(rj3,r3) -- true
rj3*r3 == rj3 -- true
(k4,j4) = radical(rj3,r3)
isSubset(rj3,j4) -- true

A = ringFromFractions(r3)
see ideal A
gens A
J = ideal(v, u^2+u, w_(0,0), u*w_(0,1))
Jrad = trim radical  J
isSubset(J, Jrad)


D = first first disc R
r1 = fractionalIdeal ideal(1_R)
j1 = fractionalIdeal trim radical ideal sub(D,R)
e1 = End j1
(k2,j2) = radical(j1, e1)
r2 = End j2
isSubset(r1,r2)
(k3,j3) = radical(j2,r2)
r3 = End j3
isSubset(r2,r3)
isSubset(j3,r3)
r3*j3 == j3
rj3 = newDenominator(j3, r3#0)
(k4,j4) = radical(rj3,r3)

isSubset(rj3,j4) -- true
isSubset(j3,j4) -- true

r4 = End j4
isSubset(j1,j2)
isSubset(j2,j3)
isSubset(j3,j4)
isSubset(j3,r3)
isSubset(r3,r4)
(k5,j5) = radical(newDenominator(j4, r4#0), r4)
r5 = End j5
r4 == r5 -- true
A = ringFromFractions r4
see ideal gens gb ideal A
u
fractionalIdeal

-- example of Doug Leonard
-- NOT WORKING YET: I have to remember how this code works! (6/27/09)
R=ZZ/2[x,y,z, MonomialOrder=>{1,2}]
I=ideal(x^6+x^3*z-y^3*z^2)
S=R/I
time integralClosureHypersurface S
F = I_0

D = disc(S)
D = D/first//product
j1 = fractionalIdeal trim radical ideal sub(D,S)
e1 = End j1
(k2,j2) = radical(j1,e1)
e2 = End j2
(k3,j3) = radical(j2,e2)
e3 = End j3
(k4,j4) = radical(j3,e3)
e4 = End j4 -- this is the answer
A = ringFromFractions e4
prune A
e4

gens gb ideal oo
transpose oo
time P=presentation(integralClosure(S))
icFractions S
