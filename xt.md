NULL            0  ⍝ P  data: [0]
INT             1  ⍝ -  data: [4]int
DOUBLE          2  ⍝ -  data: [8]double
STR             3  ⍝ P  data: [n]char null-term. strg.
LANG            4  ⍝ -  data: same as XT_LIST
SYM             5  ⍝ -  data: [n]char symbol name
BOOL            6  ⍝ -  data: [1]byte boolean (1=TRUE, 0=FALSE, 2=NA)
S4              7  ⍝ P  data: [0]
VECTOR         16  ⍝ P  data: [?]REXP,REXP,..
LIST           17  ⍝ -  X head, X vals, X tag (since 0.1-5)
CLOS           18  ⍝ P  X formals, X body  (closure; since 0.1-5)
SYMNAME        19  ⍝ s  same as XT_STR (since 0.5)
LIST_NOTAG     20  ⍝ s  same as XT_VECTOR (since 0.5)
LIST_TAG       21  ⍝ P  X tag, X val, Y tag, Y val, ... (since 0.5)
LANG_NOTAG     22  ⍝ s  same as XT_LIST_NOTAG (since 0.5)
LANG_TAG       23  ⍝ s  same as XT_LIST_TAG (since 0.5)
VECTOR_EXP     26  ⍝ s  same as XT_VECTOR (since 0.5)
VECTOR_STR     27  ⍝ -  same as XT_VECTOR (since 0.5 but unused, use XT_ARRAY_STR instead)
ARRAY_INT      32  ⍝ P  data: [n*4]int,int,..
ARRAY_DOUBLE   33  ⍝ P  data: [n*8]double,double,..
ARRAY_STR      34  ⍝ P  data: string,string,.. (string=byte,byte,...,0) padded with '\01'
ARRAY_BOOL_UA  35  ⍝ -  data: [n]byte,byte,..  (unaligned! NOT supported anymore)
ARRAY_BOOL     36  ⍝ P  data: int(n),byte,byte,...
RAW            37  ⍝ P  data: int(n),byte,byte,...
ARRAY_CPLX     38  ⍝ P  data: [n*16]double,double,... (Re,Im,Re,Im,...)
UNKNOWN        48  ⍝ P  data: [4]int - SEXP type (as from TYPEOF(x))                           