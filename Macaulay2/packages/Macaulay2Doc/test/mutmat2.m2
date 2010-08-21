m = mutableMatrix {{1,3,5},{12,1,5},{3,2,5}}
rowSwap(m, 1, 2)
assert( m == mutableMatrix {{1, 3, 5}, {3, 2, 5}, {12, 1, 5}} )
columnSwap(m, 0, 2)
assert( m == mutableMatrix {{5, 3, 1}, {5, 2, 3}, {5, 1, 12}} )
rowPermute(m,0,{1,2,0})
assert( m == mutableMatrix {{5, 2, 3}, {5, 1, 12}, {5, 3, 1}} )
columnPermute(m,0,{1,2,0})
assert( m == mutableMatrix {{2, 3, 5}, {1, 12, 5}, {3, 1, 5}} )
rowMult(m,1,-1)
assert( m == mutableMatrix {{2, 3, 5}, {-1, -12, -5}, {3, 1, 5}} )
columnMult(m,2,-1)
assert( m == mutableMatrix {{2, 3, -5}, {-1, -12, 5}, {3, 1, -5}} )
rowAdd(m,1,-1,0)
assert( m == mutableMatrix {{2, 3, -5}, {-3, -15, 10}, {3, 1, -5}} )
columnAdd(m,2,-1,1)
assert( m == mutableMatrix {{2, 3, -8}, {-3, -15, 25}, {3, 1, -6}} )