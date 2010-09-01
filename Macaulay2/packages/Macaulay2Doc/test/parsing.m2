use Parsing
debug Classic
parse = (p,s) -> (p : charAnalyzer) s
assert( parse(symbolP, "x") === x )
assert( parse(symbolP, "y") === y )
assert( parse(NNParser, "234") === 234 )
assert( parse(QQParser, "234/131") === 234/131 )
assert( parse(QQParser, "-234/131") === -234/131 )
assert( parse(optP constParser "-", "") === nil )
assert( parse(andP(optP constParser "-",optP constParser "+"), "") === (nil,nil) )
assert( parse(andP(optP constParser "-",optP constParser "+"), "+") === (nil,"+") )
assert( parse(andP(optP constParser "-",optP constParser "+"), "-") === ("-",nil) )
assert( parse(andP(optP constParser "-",optP constParser "+"), "-+") === ("-","+") )
assert( (try parse(andP(optP constParser "-",optP constParser "+"), "+-") else oops) === oops )
assert( parse(ZZParser, "234") === 234 )
assert( parse(ZZParser, "-234") === -234 )
assert( parse(ZZParser, "+234") === 234 )
assert( parse(orP(NNParser,constParser "ab"), "234") === 234 )
assert( parse(orP(NNParser,constParser "ab"), "ab") === "ab" )
assert( (try parse(orP(NNParser,constParser "ab"), "a") else oops) === oops )
assert( (try parse(orP(NNParser,constParser "ab"), "abc") else oops) === oops )
assert( (try parse(andP(NNParser,constParser "ab"), "234a") else oops) === oops )
assert( (try parse(andP(NNParser,constParser "ab"), "234b") else oops) === oops )
assert( parse(andP(NNParser,constParser "ab"), "234ab") === (234,"ab") )
assert( (try parse(andP(NNParser,constParser "ab"), "234abc") else oops) === oops )
assert( parse(* andP(constParser ",", NNParser), ",33,4") === ((",",33),(",",4)) )
R = QQ[a..t,x_0 .. x_9, y_(0,0) .. y_(3,3)]
assert( parse(ringVariableP, "t") === t )
assert( parse(ringVariableP, "x[3]") === x_3 )
assert( parse(ringVariableP, "y[2,3]") === y_(2,3) )
assert( parse(powerP, "t12") === t^12 )
assert( parse(powerP, "x[3]12") === x_3^12 )
assert( parse(powerP, "y[2,3]12") === y_(2,3)^12 )
assert( parse(parenExprP, "(y[2,3]12)") === y_(2,3)^12 )
assert( parse(monomialP, "3x[2]y[2,3]3") === 3*x_2*y_(2,3)^3 )
assert( parse(monomialP, "x[2]y[2,3]3") === x_2*y_(2,3)^3 )
assert( parse(monomialP, "3(x[2]y[2,3])3") === 3*x_2^3*y_(2,3)^3 )
assert( parse(monomialP, "3(-2x[2]y[2,3])3") === -24*x_2^3*y_(2,3)^3 )
assert( parse(polyP, "3x[2]y[2,3]3") === 3*x_2*y_(2,3)^3 )
assert( parse(polyP, "x[2]y[2,3]3") === x_2*y_(2,3)^3 )
assert( parse(polyP, "3(x[2]y[2,3])3") === 3*x_2^3*y_(2,3)^3 )
assert( parse(polyP, "3(-2x[2]y[2,3]+3t)3") === -24*x_2^3*y_(2,3)^3+108*t*x_2^2*y_(2,3)^2-162*t^2*x_2*y_(2,3)+81*t^3 )
assert( parse(polyP, "(1-2/3a)5") === -32/243*a^5+80/81*a^4-80/27*a^3+40/9*a^2-10/3*a+1 )
assert( parse(arrayPolyP, "a") === {{a}} )
assert( parse(arrayPolyP, "(a+1)5,b,c;d,e,f2-g") === {{a^5+5*a^4+10*a^3+10*a^2+5*a+1, b, c}, {d, e, f^2-g}} )
i=3
assert( ideal "a,b,c" === ideal(a,b,c) )
assert( matrix "a,b,c;d,e,f" === matrix( {{a, b, c}, {d, e, f}}) )
assert( matrix "a,b,c;d,x[i]5,(f-1)4" === matrix( {{a, b, c}, {d, x_3^5, f^4-4*f^3+6*f^2-4*f+1}}) )