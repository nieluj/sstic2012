#!/usr/bin/env python2.5

from sets import Set
import marshal, time, struct, types, inspect, pprint
import binascii, pickle, sys, random
from binascii import a2b_hex
from math import floor, log

pp = pprint.PrettyPrinter(indent=4)

def enc(): pass
def dec(): pass
def subkey(): pass
def F(): pass
def IP(): pass
def IPinv(): pass
def PC1(): pass
def PC2(): pass
def E(): pass
def P(): pass
def S(): pass
def tmp(): pass

class MyWhiteDES:
	def FX(self, v):
		res = Bits(0, 96)
		for b in range(96):
			t = v & self.tM2[b]
			# hw = hamming weight of the object (count of 1s)
			res[b] = t.hw() % 2
		return res

	def _cipher(self, M, d):
		if M.size != 64:
			raise AssertionError
		if d != 1:
			if d == -1:
				raise NotImplementedError
			else:
				return 0

		blk = M[self.tM1]
		for r in range(16):
			t = 0
			for n in range(12):
				nt = t + 8
				i = blk[t:nt].ival
				blk[t:nt] = self.KT[r][n][i]
				t = nt
			blk = self.FX(blk)
		return blk[self.tM3]

	def _cipher_only_first_round(self, M):
		if M.size != 64:
			raise AssertionError
		blk = M[self.tM1]
		t = 0
		for n in range(12):
			nt = t + 8
			i = blk[t:nt].ival
			blk[t:nt] = self.KT[0][n][i]
			t = nt
		return self.FX(blk)

def _PC1(K):
    table = [ 56, 48, 40, 32, 24, 16,  8,  0,
    	      57, 49, 41, 33, 25, 17,  9,  1,
    	      58, 50, 42, 34, 26, 18, 10,  2,
    	      59, 51, 43, 35, 62, 54, 46, 38,
    	      30, 22, 14,  6, 61, 53, 45, 37,
    	      29, 21, 13,  5, 60, 52, 44, 36,
    	      28, 20, 12, 4, 27, 19, 11,  3 ]
    return K[table]

def _PC2(K):
    table = [ 13, 16, 10, 23,  0,  4,  2, 27,
    	      14,  5, 20,  9, 22, 18, 11,  3,
    	      25,  7, 15,  6, 26, 19, 12,  1,
    	      40, 51, 30, 36, 46, 54, 29, 39,
    	      50, 44, 32, 47, 43, 48, 38, 55,
    	      33, 52, 45, 41, 49, 35, 28, 31 ]
    return K[table]

def _IP(M):
    if M.size != 64:
    	raise AssertionError
    table = [ 57, 49, 41, 33, 25, 17,  9,  1,
    	      59, 51, 43, 35, 27, 19, 11,  3,
    	      61, 53, 45, 37, 29, 21, 13,  5,
    	      63, 55, 47, 39, 31, 23, 15,  7,
    	      56, 48, 40, 32, 24, 16,  8,  0,
    	      58, 50, 42, 34, 26, 18, 10,  2,
    	      60, 52, 44, 36, 28, 20, 12,  4,
    	      62, 54, 46, 38, 30, 22, 14,  6 ]
    return M[table]

def _IPinv(M):
    if M.size != 64:
    	raise AssertionError
    table = [ 39,  7, 47, 15, 55, 23, 63, 31,
    	      38,  6, 46, 14, 54, 22, 62, 30,
    	      37,  5, 45, 13, 53, 21, 61, 29,
    	      36,  4, 44, 12, 52, 20, 60, 28,
    	      35,  3, 43, 11, 51, 19, 59, 27,
    	      34,  2, 42, 10, 50, 18, 58, 26,
    	      33,  1, 41,  9, 49, 17, 57, 25,
    	      32,  0, 40,  8, 48, 16, 56, 24 ]
    return M[table]

def _E(L):
    if L.size != 32:
    	raise AssertionError
    table = [ 31,  0,  1,  2,  3,  4,  3,  4,
    	       5,  6,  7,  8,  7,  8,  9, 10,
    	      11, 12, 11, 12, 13, 14, 15, 16,
    	      15, 16, 17, 18, 19, 20, 19, 20,
    	      21, 22, 23, 24, 23, 24, 25, 26,
    	      27, 28, 27, 28, 29, 30, 31,  0 ]
    return L[table]

def _subkey(k, r):
    C = k[0:28]
    D = k[28:56]
    shifts = [ 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1 ]
    i = r + 1
    s = sum(shifts[:i])
    C = (C >> s) | (C << (28 - s))
    D = (D >> s) | (D << (28 - s))
    return _PC2( C // D )

def _S(n, x):
    # 0 <= n < 8, 0 <= x < 64
    s0 = [ 14,  4, 13,  1,  2, 15, 11,  8,
    	    3, 10,  6, 12,  5,  9,  0,  7,
    	    0, 15,  7,  4, 14,  2, 13,  1,
    	   10,  6, 12, 11,  9,  5,  3,  8,
    	    4,  1, 14,  8, 13,  6,  2, 11,
    	   15, 12,  9,  7,  3, 10,  5,  0,
    	   15, 12,  8,  2,  4,  9,  1,  7,
    	    5, 11,  3, 14, 10,  0,  6, 13 ]
    s1 = [ 15,  1,  8, 14,  6, 11,  3,  4,
    	    9,  7,  2, 13, 12,  0,  5, 10,
    	    3, 13,  4,  7, 15,  2,  8, 14,
    	   12,  0,  1, 10,  6,  9, 11,  5,
    	    0, 14,  7, 11, 10,  4, 13,  1,
    	    5,  8, 12,  6,  9,  3,  2, 15,
    	   13,  8, 10,  1,  3, 15,  4,  2,
    	   11,  6,  7, 12,  0,  5, 14,  9 ]
    s2 = [ 10,  0,  9, 14,  6,  3, 15,  5,
    	    1, 13, 12,  7, 11,  4,  2,  8,
    	   13,  7,  0,  9,  3,  4,  6, 10,
    	    2,  8,  5, 14, 12, 11, 15,  1,
    	   13,  6,  4,  9,  8, 15,  3,  0,
    	   11,  1,  2, 12,  5, 10, 14,  7,
    	    1, 10, 13,  0,  6,  9,  8,  7,
    	    4, 15, 14,  3, 11,  5,  2, 12 ]
    s3 = [  7, 13, 14,  3,  0,  6,  9, 10,
    	    1,  2,  8,  5, 11, 12,  4, 15,
    	   13,  8, 11,  5,  6, 15,  0,  3,
    	    4,  7,  2, 12,  1, 10, 14,  9,
    	   10,  6,  9,  0, 12, 11,  7, 13,
    	   15,  1,  3, 14,  5,  2,  8,  4,
    	    3, 15,  0,  6, 10,  1, 13,  8,
    	    9,  4,  5, 11, 12,  7,  2, 14 ]
    s4 = [  2, 12,  4,  1,  7, 10, 11,  6,
    	    8,  5,  3, 15, 13,  0, 14,  9,
    	   14, 11,  2, 12,  4,  7, 13,  1,
    	    5,  0, 15, 10,  3,  9,  8,  6,
    	    4,  2,  1, 11, 10, 13,  7,  8,
    	   15,  9, 12,  5,  6,  3,  0, 14,
    	   11,  8, 12,  7,  1, 14,  2, 13,
    	    6, 15,  0,  9, 10,  4,  5, 3 ]
    s5 = [ 12,  1, 10, 15,  9,  2,  6,  8,
    	    0, 13,  3,  4, 14,  7,  5, 11,
    	   10, 15,  4,  2,  7, 12,  9,  5,
    	    6,  1, 13, 14,  0, 11,  3,  8,
    	    9, 14, 15,  5,  2,  8, 12,  3,
    	    7,  0,  4, 10,  1, 13, 11,  6,
    	    4,  3,  2, 12,  9,  5, 15, 10,
    	   11, 14,  1,  7,  6,  0,  8, 13 ]
    s6 = [  4, 11,  2, 14, 15,  0,  8, 13,
    	    3, 12,  9,  7,  5, 10,  6,  1,
    	   13,  0, 11,  7,  4,  9,  1, 10,
    	   14,  3,  5, 12,  2, 15,  8,  6,
    	    1,  4, 11, 13, 12,  3,  7, 14,
    	   10, 15,  6,  8,  0,  5,  9,  2,
    	    6, 11, 13,  8,  1,  4, 10,  7,
    	    9,  5,  0, 15, 14,  2,  3, 12 ]
    s7 = [ 13,  2,  8,  4,  6, 15, 11,  1,
    	   10,  9,  3, 14,  5,  0, 12,  7,
    	    1, 15, 13,  8, 10,  3,  7,  4,
    	   12,  5,  6, 11,  0, 14,  9,  2,
    	    7, 11,  4,  1,  9, 12, 14,  2,
    	    0,  6, 10, 13, 15,  3,  5,  8,
    	    2,  1, 14,  7,  4, 10,  8, 13,
    	    15, 12,  9,  0,  3,  5,  6, 11 ]

    boxes = [ s0, s1, s2, s3, s4, s5, s6, s7 ]

    return Bits( boxes[n][x], 4 )

def _P(s):
    if s.size != 32:
    	raise AssertionError
    table = [ 15,  6, 19, 20, 28, 11, 27, 16,
    	       0, 14, 22, 25,  4, 17, 30,  9,
    	       1,  7, 23, 13, 31, 26,  2,  8,
    	      18, 12, 29,  5, 21, 10,  3, 24 ]
    return s[table]

def _F(R, k, r):
    RE = _E(R)
    Z = Bits(0, 32)
    fk = _subkey(k, r)
    s = RE ^ fk
    ri, ro = 0, 0
    for n in range(8):
    	nri = ri + 6
    	nro = ro + 4
	x = s[ri:nri]
	i = x[ (5, 0) ].ival
	j = x[ (4, 3, 2, 1) ].ival
	Z[ro:nro] = Bits( _S(n, (i << 4) + j) , 4 )[ slice(None, None, -1) ]
	ri = nri
	ro = nro
    return _P(Z)

def _enc(K, M):
    if M.size != 64:
    	raise AssertionError
    k = _PC1(K)
    blk = _IP(M)
    L = blk[0:32]
    R = blk[32:64]
    for r in range(16):
    	fout = _F(R, k, r)
    	L = L ^ fout
    	L, R = R, L
    L, R = R, L
    C = Bits(0, 64)
    C[0:32] = L
    C[32:64] = R
    return _IPinv(C)

# additional needed methods for cryptanalysis
def _PC2inv(K):
	table = [ 13, 16, 10, 23,  0,  4,  2, 27,
		14,  5, 20,  9, 22, 18, 11,  3,
		25,  7, 15,  6, 26, 19, 12,  1,
		40, 51, 30, 36, 46, 54, 29, 39,
		50, 44, 32, 47, 43, 48, 38, 55,
		33, 52, 45, 41, 49, 35, 28, 31 ]
	rtable = [ None for x in range(56) ]
	for position, item in enumerate(table):
		rtable[item] = position

	ret = [ ]
	for x in rtable:
		if x == None:
			ret.append(None)
			continue
		ret.append(K[x].ival)
  
	return ret

def reverse_subkey(sk):
	# only for r == 0
	# sk is 48 bits long
	ret = _PC2inv(sk)
	C = ret[0:28]
	D = ret[28:56]
	#print " C = %s" % (C)
	#print " D = %s" % (D)
	#print "C[27:1] + C[0:27] = %s + %s" % (C[27:28], C[0:27])
	C = [ C[27] ] + C[0:27]
	D = [ D[27] ] + D[0:27]
	return C + D

def _F_with_subkey(R, subkey):
    RE = _E(R)
    Z = Bits(0, 32)
    fk = subkey
    s = RE ^ fk
    ri, ro = 0, 0
    for n in range(8):
    	nri = ri + 6
    	nro = ro + 4
	x = s[ri:nri]
	i = x[ (5, 0) ].ival
	j = x[ (4, 3, 2, 1) ].ival
	Z[ro:nro] = Bits( _S(n, (i << 4) + j) , 4 )[ slice(None, None, -1) ]
	ri = nri
	ro = nro
    return _P(Z)

# si est le numero de la subkey pour laquelle on cherche des
# candidats
def find_candidates_for_subkey(X, si, wt):
    modifs = [ ]
    # S1
    modifs.append( [ 2, 3 ] )
    # S2
    modifs.append( [ 6, 7 ] )
    # S3
    modifs.append( [ 10, 11 ] )
    # S4
    modifs.append( [ 14, 15 ] )
    # S5
    modifs.append( [ 18, 19 ] )
    # S6
    modifs.append( [ 22, 23 ] )
    # S7
    modifs.append( [ 26, 27 ] )
    # S8 
    modifs.append( [ 30, 31 ] )
    blk = _IP(X)
    L0 = blk[0:32]
    R0 = blk[32:64]
    delta = Bits(0, 32)
    for m in modifs[si]:
    	delta[m-1] = 1
    #print "delta = %s" % ( delta.__str__())
    R0P = R0 ^ delta
    #print "L0 : %s" % ( L0.__str__() )
    #print "R0 : %s" % ( R0.__str__() )
    #print "R0P: %s" % ( R0P.__str__() )
    candidates = []
    K = Bits(0, 48)
    # de 0 a 63
    for i in range(2**6):
    	index = si * 6
    	nindex = index + 6
	K[index:nindex] = i
	#print "index = %d, K = %s" % (index, K.__str__())
    	L0P = L0 ^ ( _F_with_subkey(R0, K) ^ _F_with_subkey(R0P, K) )
    	TMP = Bits(0, 64)
    	TMP[0:32] = L0P
    	TMP[32:64] = R0P

    	XP = _IPinv(TMP)
	#print "K(%d) : %s" % (i, K )
    	#print "L0P   : %s" % ( L0P.__str__() )
    	#print "XP    : %s" % ( XP.__str__() )

    	Y = wt._cipher_only_first_round(X)
    	YP = wt._cipher_only_first_round(XP)
    	#print "Y  : %s" % ( Y.__str__() )
    	#print "YP : %s" % ( YP.__str__() )
	count, r = 0, 0
	for j in range(12):
	    nr = r + 8
	    v1, v2 = Y[r:nr], YP[r:nr]
	    #print "v1(%s) != v2(%s) ?" % (v1.__str__(), v2.__str__())
	    if v1 != v2:
	    	#print "true!"
	    	count += 1
	    r += 8
	#print "diff count = %d" % ( count )
	if count <= 2:
	    candidates.append(i)
    
    return candidates

def find_candidates():
	result = []
	myWT = MyWhiteDES()
	myWT.KT = WT.KT
	myWT.tM1 = WT.tM1
	myWT.tM2 = WT.tM2
	myWT.tM3 = WT.tM3

	L = Bits(random.getrandbits(32), 32)

	# pour chaque subkey
	for i in range(8):
		#candidates = [0 for x in range(64)]
		candidates = Set( [] )
		# on fait 8 essais
		for j in range(8):
			R = Bits(random.getrandbits(32), 32)
			X = Bits(0, 64)
			X[0:32] = L
			X[32:64] = R

			print "[%d:%d], X = %s" % (i, j, X.__str__())
			tmp = find_candidates_for_subkey(X, i, myWT)
			if len(candidates) == 0:
				candidates = Set(tmp)
			else:
				# on realise l'intersection avec les subkeys candidates deja trouvees
				candidates &= Set(tmp)
			pp.pprint(candidates)
		result.append(candidates)

	return result


def do_init():
	main_locals = inspect.currentframe().f_back.f_locals
	f = open('../data/check.pyc', 'rb')
	magic = f.read(4)
	moddate = f.read(4)
	modtime = time.asctime(time.localtime(struct.unpack('<L', moddate)[0]))
	print "magic %s" % (magic.encode('hex'))
	print "moddate %s (%s)" % (moddate.encode('hex'), modtime)
	code = marshal.load(f)
	f.close

	for const in code.co_consts:
		if type(const) == types.CodeType:
			if const.co_name == 'Bits':
				tmp.func_code = const
				#Bits = type('Bits', (), tmp())
				main_locals['Bits'] = type('Bits', (), tmp())
				continue

			if const.co_name == 'ECB':
				tmp.func_code = const
				main_locals['ECB'] = type('ECB', (object, ), tmp())
				continue

			if const.co_name == 'WhiteDES':
				tmp.func_code = const
				main_locals['WhiteDES'] = type('WhiteDES', (ECB,), tmp())
				continue

			tmpf = main_locals[const.co_name]
			if tmpf:
				print "creating function %s" % (const.co_name)
				tmpf.func_code = const

	WT = pickle.loads(code.co_consts[22])
	return WT
    
def check_reverse(WT):
	M = Bits(random.getrandbits(64), 64)
	K = Bits(random.getrandbits(64), 64)

	if hex(_enc(K, M)) == hex(enc(K, M)):
	    print "_enc(K, M) == enc(K, M)"
	else:
	    print "_enc(K, M) != enc(K, M)"
	    exit(1)

	myWT = MyWhiteDES()
	myWT.KT = WT.KT
	myWT.tM1 = WT.tM1
	myWT.tM2 = WT.tM2
	myWT.tM3 = WT.tM3

	if hex(myWT._cipher(M,1)) == hex(WT._cipher(M, 1)):
	    print "myWT._cipher(M,1) == WT._cipher(M, 1)"
	else:
	    print "myWT._cipher(M,1) != WT._cipher(M, 1)"
	    exit(1)

def print_comments(klass):
	for name, method in inspect.getmembers(klass, predicate=inspect.ismethod):
		print "%s: %s" % (name, method.func_doc)

def test_key(key):
	key_data = binascii.a2b_hex(key)
	K = Bits(key_data, 64)
	r = range(7, 64, 8)
	t = K[r]

	if t != 175:
		raise AssertionError

	M = Bits(random.getrandbits(64), 64)
	if hex(WT._cipher(M, 1)) == hex(enc(K, M)):
		exit(0)
	else:
		exit(1)




if __name__ == '__main__':
	if len(sys.argv) == 1:
		print 'Usage: python check.pyc <key>'
		print '   - key: a 64 bits hexlify-ed string'
		print 'Example: python check.pyc 0123456789abcdef'
		exit(1)

	WT = do_init()
	check_reverse(WT)
	pp.pprint(find_candidates())
#	print_comments(Bits)
	test_key(sys.argv[1])
