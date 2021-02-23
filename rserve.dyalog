:Namespace RServe
  :class robject
    :field Public names←⍬
    :field Public dim←⍬
    :field public dimnames←⍬
    :Field Public row_names←⍬
    :Field Public class←⍬
    :Field Public levels←⍬
    :Field Public tsp←⍬
    :Field Public data←⍬

    ∇ MakeAny arg
      :Access Public
      :Implements Constructor
      (names class levels row_names dim dimnames tsp data)←arg
    ∇

    ∇ Make0
      :Access Public
      :Implements Constructor
    ∇

    ∇ r←value
      :Access Public
      ⎕IO←1
      r←{1=≢data:,⍵ ⋄ ⍵}{class≡'factor':⍉levels[⍵]
        ∨/({1=≡⍵:,⊂⍵⋄⍵}class)∊⊂'table':⍵{~dim≡⍬:⍵⍪⍉(⌽dim)⍴⍺⋄{⍵⍴⍨2,(≢⍵)÷2}⍵,⍺}names{⍺≢⍬:⍺⋄⍵}dimnames
        ~dim≡⍬:⍉(⌽dim)⍴⍵
        ⍉↑{≡⍵:⍵ ⋄ ⍵.levels[⍵.data]}¨{1=≡⍵:⊂⍵ ⋄ ⍵}⍵
        }data
    ∇

    ∇ r←attributes
      :Access Public
      ⎕IO←1
      r←⍉2 5⍴('names' 'class' 'row.names' 'tsp' 'levels'),names class row_names tsp levels
      r←r[⍸~r[;2]∊⊂⍬;]
    ∇
  :endclass

  :Class client
    ⍝ Interface from Dyalog APL to R
    ⍝ Currently asssumes existence of #.DRC
    ⎕ML←1 ⋄ ⎕IO←0 ⋄ ⎕PP←34
    :Field Public CLT←''         ⍝ Public for debugging
    :Field Private LittleEndian
    :field Private err←⍬
    :field Private err_code←⍬  
    :field Private sxt←⍬
    :field Private sxt_code←⍬  
    :field Private cmd←⍬
    :field Private cmd_code←⍬  
    :field Private dat←⍬
    :field Private dat_code←⍬

    :property keyed ERR
    :access public
      
      ∇ r←get args
        r←{83=⎕dr ⍵:⊂(err,⊂⍬)[err_code⍳⍵] ⋄ (err_code,0)[err⍳⊃⍵]}args.Indexers
      ∇
    :endproperty

    :property keyed XT
    :access public
      
      ∇ r←get args
        r←{83=⎕dr ⍵:⊂(sxt,⊂⍬)[sxt_code⍳⍵] ⋄ (sxt_code,0)[sxt⍳⊃⍵]}args.Indexers
      ∇
    :endproperty

    :property keyed CMD
    :access public
      
      ∇ r←get args
        r←{83=⎕dr ⍵:⊂(cmd,⊂⍬)[cmd_code⍳⍵] ⋄ (cmd_code,0)[cmd⍳⊃⍵]}args.Indexers
      ∇
    :endproperty
    
    :property keyed DT
    :access public
      
      ∇ r←get args
        r←{83=⎕dr ⍵:⊂(dat,⊂⍬)[dat_code⍳⍵] ⋄ (dat_code,0)[dat⍳⊃⍵]}args.Indexers
      ∇
    :endproperty

    cols←{(((⍴⍵)÷⍺),⍺)⍴⍵} ⍝ 4 cols ⍵ reshapes to have 4 cols
    fromsym←{z←¯1⌽⍵ ⋄ 1↓¨(z=⎕UCS 0)⊂z}
    to64Int←{{⊃⍵:-2⊥~⍵⋄2⊥⍵},⌽[0]8 8⍴11 ⎕DR ⍵} ⍝ thanks VMJ for pimping my code
    toReal←{(sign×exp×frac),⊖[0]4 8⍴11 ⎕DR ⍵} ⍝ thanks VMJ for pimping my code
    frac←{⎕io←1⋄1++/2*-(9↓⍵)/⍳23}
    exp←{2*127-⍨+/2*(⌽8↑1↓⍵)/⍳8}
    sign←{¯1*1↑⍵}
    split←{a←⍺⋄''{0=⍴⍵:⍺ ⋄ ⍺,(⊂a↑⍵)∇(a↓⍵)}⍵}
    rnd←{a←10*⍺ ⋄ a÷⍨⌊0.5+a×⍵}
    IntToBytes←{⎕FR←(⍺=8)⊃645 1287 ⋄ ⍺↑⎕UCS 80 ⎕DR(×⍵)×((2*(8×⍺))-1)⌊|⍵}
    b2i←{(⍺⍴256)⊥⌽⍵}
    ld←{⍵,⍨3 IntToBytes≢⍵}
    evalOut←{0,⍨DT[⊂'STRING'],ld{⍵↑⍨4×⌈(≢⍵)÷4}10,⍨⎕UCS ⍵}
    strOut←{DT[⊂'STRING'],ld{⍵↑⍨4×⌈(≢⍵)÷4}0,⍨⎕UCS ⍵}
    headData←{z←DRC.Send CLT(∊{4 IntToBytes ⍵}¨⍺(≢⍵)0 0) ⋄ SendWait ⍵}
    
    ∇ o←eval s;b;d;dh;hdr;r;s;t;xt;z
      :Access Public
      s←{1=≡⍵:,⊂⍵ ⋄ ⍵}s
      b←{CMD[⊂'eval'] headData evalOut ⍵}¨s
      o←{1=≢⍵:⊃⍵ ⋄ ⍵}{(⍵≡,⊂⍬)∨('Err'≡3↑⍵)∨(1=≡⍵)∨1=≢∪¯1↑¨⍕¨⎕dr¨⍵:⍵ ⋄ object ⍵}¨decode¨b
    ∇


    ∇ o←object i;at;class;data;di;dim;dimnames;in;levels;names;out;row_names;tsp;xt
      names←class←levels←row_names←dim←dimnames←tsp←data←⍬
      xt←⊃i ⋄ i←1↓i
      at←'names' 'class' 'levels' 'row.names' 'dim' 'dimnames' 'tsp'
      :If xt∊128+XT['ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR'] ⋄ i←⊃i ⋄ :EndIf
      :for in :in i
        :if (xt=128+XT[⊂'VECTOR'])
        :andIf 0>≡in
        :andIf ∨/{⍵≡⊃⊃in}¨XT['ARRAY_INT' 'ARRAY_DOUBLE']
          data,←object in
          in←⍬
        :endIf
        :while 0≠⍴in
          :if in[1]∊at
            :select 1⊃in
            :case 'row.names'
              :if ¯2147483648≡⊃⊃in
                row_names←1+⍳|1⊃⊃in
              :else
                row_names←⊃in
              :endIf
            :else 
              ⍎(1⊃in),'←⊃in'
            :EndSelect
            in←2↓in
          :else
            data,←{xt∊128+XT[⊂'ARRAY_STR']:⍵⋄⊂⍵}in⋄in←⍬
          :EndIf
        :EndWhile
      :EndFor

      out←(names class levels row_names dim dimnames tsp ({1=≢⍵:⊃⍵ ⋄⍵ }data))  
      o←⎕NEW robject out
    ∇

    ∇ o←decode i;h;s;xt
      o←⍬ ⋄ h←16↑i ⋄ i←16↓i
      :If 1≠⊃h
        o←'Error',⊃ERR[3⊃h] ⋄ →0
      :endif

      :While 0≠≢i
        o,←(⊃i)SEXPin(4↓i)↑⍨l←3 b2i i[1 2 3] ⋄ i←(4+l)↓i
      :End

      :If 1=⍴o ⋄ o←⊃o ⋄ :EndIf
    ∇

    ∇ o←s set i;o;d
      :Access public
      o←⍬ ⋄ (s i)←s{(2>≡⍵)∨((1=≢⍵)∧326=⎕DR ⍵):(,⊂⍺)(,⊂⍵) ⋄ ⍺ ⍵}i
      d←s{total←{326=⎕dr ⍵:≢⍵.data ⋄ 0}⍵ ⋄ (strOut ⍺),DT[⊂'SEXP'],ld(SEXPout ⍵)}¨i
      o←⊃¨{z←DRC.Send CLT(∊({4 IntToBytes ⍵}¨CMD[⊂'setSEXP'],(≢⍵)0 0))
        SendWait ⍵}¨d
    ∇

    ∇ o←{type}SEXPout i;a;at;b;d;dim;dt;in;ts;type
      :If 0=⎕NC'type' ⋄ type←⎕DR i ⋄ :EndIf
      :Select type
      :Caselist XT['SYMNAME' 'ARRAY_STR']
        o←type,ld{⍵,1⍴⍨4-4|≢⍵}∊{0,⍨⎕UCS ⍵}¨i
      :Caselist XT[⊂'ARRAY_INT'],83
        :If 1=≢⍴i ⍝ vector
          o←XT[⊂'ARRAY_INT'],ld∊4 IntToBytes¨{1=≢⍵:⊃⍵ ⋄ ⍵}i
        :Else     ⍝ matrix
          dim←⌽⍴i ⋄ d←∊4 IntToBytes¨∊i
          li←XT[⊂'SYMNAME'],1↓strOut'dim'
          li←li,⍨XT[⊂'ARRAY_STR'],ld∊4 IntToBytes¨dim
          li←li,⍨XT[⊂'LIST_TAG'],3 IntToBytes≢li
          o←(128+XT[⊂'ARRAY_INT']),ld li,d
        :EndIf
      :Case 326     ⍝ robjects
        ts←{∨/⍵[⍵[;0]⍳⊂'class';1]∊⊂'ts'}i.attributes

        :If ts
          d←XT[⊂'ARRAY_DOUBLE'] SEXPout¨{1=≡⍵:,⊂⍵ ⋄ ⍵}i.data
        :Else
          d←SEXPout¨{1=≡⍵:,⊂⍵ ⋄ ⍵}i.data
        :EndIf

        at←i.attributes

        :If ∨/b←at[;0]∊⊂'row.names'
        :AndIf {⎕IO←1 ⋄ ⍵≡⍳¯1↑⍵}⊃at[in←⍸b;1]
          b←¯1↑⊃at[in;1]
          at[in;1]←⊂¯2147483648,b
        :EndIf

        a←∊{{(⊃⍵)SEXPout(1↓⍵)}¨({
            (XT['ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR']⊃⍨323 645 80⍳⎕DR∊⍵),{
                1=≡⍵:⊂⍵ ⋄ ⍵}⍵}1⊃⍵)(XT[⊂'SYMNAME'],⍵[0])}¨↓at
        :If (⍴d)<total
          d←∊d ⋄ dt←⊃d
          o←(128+dt),ld(4↓d),⍨XT[⊂'LIST_TAG'],ld a
        :Else
          o←(128+XT[⊂'VECTOR']),ld(∊d),⍨XT[⊂'LIST_TAG'],ld a
        :EndIf
      :Caselist XT[⊂'ARRAY_DOUBLE'],163 323 645     ⍝ doubles
        :If 1=≢⍴i
          o←XT[⊂'ARRAY_DOUBLE'],ld ⎕UCS 80 ⎕DR{645≠⎕DR ⍵:⊃0 645 ⎕DR ⍵ ⋄ ⍵}∊i
        :Else
          dim←⌽⍴i ⋄ d←⎕UCS 80 ⎕DR∊i
          li←XT[⊂'SYMNAME'],1↓strOut'dim'
          li←li,⍨XT[⊂'ARRAY_INT'],ld∊4 IntToBytes¨dim
          li←li,⍨XT[⊂'LIST_TAG'],3 IntToBytes≢li
          o←(128+XT[⊂'ARRAY_DOUBLE']),ld li,d
        :End
      :Else
        ∘
      :EndSelect
    ∇

    ∇ o←t SEXPin i;a;b;class;d;dh;dim;dt;hdr;ii;in;levels;names;out;row;s;save;st;type;xt
      o←⍬ ⋄ d←⍬
      :While (0≠≢i)∧(0≠+/i)
        xt←⊃i ⋄ s←(3 b2i i[1 2 3]) ⋄ i←4↓i ⋄ ii←s↑i
        :If 0=≢i ⋄ o←1 ⋄ →0 ⋄ :EndIf
        :Select xt
        :case 0    
        :Case XT[⊂'VECTOR']
          d←⊃xt SEXPin ii
        :Case XT[⊂'SYMNAME']
          d←⎕UCS{⍵/⍨(~⍵∊1)∧⌽∨\~0∊⍨⌽⍵}ii
        :Caselist XT['LIST_TAG' 'LANG_TAG']  
          d←xt SEXPin ii
            :If t∊128+XT['ARRAY_INT' 'ARRAY_DOUBLE']
              (a b)←(t-160)⊃(323 4)(645 8)
              d←d(∊{a ⎕DR ⎕UCS ⍵}¨b split s↓i) ⋄ s←≢i
            :elseif t∊128+XT[⊂'ARRAY_STR'] 
              d←d(⎕UCS¨{⍵⊆⍨~⍵∊0}{⍵↓⍨-1+0⍳⍨⌽⍵}s↓i) ⋄ s←≢i
            :EndIf
        :Case XT[⊂'ARRAY_INT']
            d←∊{323 ⎕DR ⎕UCS ⍵}¨4 split ii
        :Case XT[⊂'ARRAY_DOUBLE']
            d←∊{645 ⎕DR ⎕UCS ⍵}¨8 split ii
        :Case XT[⊂'ARRAY_STR']
            d←{1=≢⍵:⊃⍵ ⋄ ⍵}⎕UCS¨{⍵⊆⍨~⍵∊0}{⍵↓⍨-1+0⍳⍨⌽⍵}ii
        :Case XT[⊂'ARRAY_BOOL']      ⍝ logical
            d←4↓ii~255
        :Case XT[⊂'ARRAY_CPLX']
            d←{a←2÷⍨≢⍵ ⋄ (a↑⍵)+(a↓⍵)×¯1*0.5}∊{645 ⎕DR ⎕UCS ⍵}¨8 split ii
        :Case 128⋄→0
        :Caselist 128+XT['VECTOR' 'ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR']   
            d←xt,(xt SEXPin ii)
        :Else
            ∘
        :EndSelect

        :if 0≠≢d ⋄ o,←⊂d ⋄ i←s↓i ⋄ :endif
    :EndWhile
    ∇

    ∇ o←SendWait d;z;done;length
      :If 0≠0⊃z←DRC.Send CLT d
        ('Send failed: ',,⍕z)⎕SIGNAL 11
      :EndIf

      r←⍬ ⋄ done←0 ⋄ length←¯1
      :Repeat
        :If 0=0⊃z←DRC.Wait CLT
          d←3⊃z
          :If length=¯1 ⍝ First block
            length←16+4⊃d
            o←d
          :Else
            o,←d
          :EndIf
          done←length≤⍴o
        :Else
          ∘ ⍝ Transfer failed
        :EndIf
      :Until done
    ∇
    
    ∇ Make;a;address;b;h;out;port;r;rc;step;z
      :Access public
      :Implements constructor
      a←'auth_failed' 'conn_broken' 'inv_cmd' 'inv_par'
      a,←'Rerror' 'IOerror' 'not_open' 'access_denied' 
      a,←'unsupported_cmd' 'unknown_cmd' 'data_overflow'
      a,←'object_too_big' 'out_of_mem' 'ctrl_closed'
      a,←'session_busy' 'detach_failed'
      b←65 66 67 68 69 70 71 72 73 74 75 76 77 78 80 81
      err err_code←a b   
      a←'NULL' 'INT' 'DOUBLE' 'STR' 'LANG' 'SYM' 'BOOL'
      a,←'S4' 'VECTOR' 'LIST' 'CLOS' 'SYMNAME' 'LIST_NOTAG'
      a,←'LIST_TAG' 'LANG_NOTAG' 'LANG_TAG' 'VECTOR_EXP'
      a,←'VECTOR_STR' 'ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR'
      a,←'ARRAY_BOOL_UA' 'ARRAY_BOOL' 'RAW' 'ARRAY_CPLX' 'UNKNOWN'
      b←0 1 2 3 4 5 6 7 16 17 18 19 20 21 22 23 26 27
      b,← 32 33 34 35 36 37 38 48 
      (sxt sxt_code)←a b
      a←'login' 'voidEval' 'eval' 'shutdown' 'openFile'
      a,←'createFile' 'closeFile' 'readFile' 'writeFile'
      a,←'removeFile' 'setSEXP' 'assignSEXP' 'setBufferSize'
      a,←'setEncoding' 'detachSession' 'detachedVoidEval'
      a,←'attachSession' 'ctrlEval' 'ctrlSource' 'ctrlShutdown' 
      b←1 2 3 4 16 17 18 19 20 21 32 33 129 130 48 49 50 66 69 68
      (cmd cmd_code)←a b 
      a←'INT' 'CHAR' 'DOUBLE' 'STRING' 'BYTESTREAM' 'SEXP'
      a,←'ARRAY' 'LARGE' 
      b←1 2 3 4 5 10 11 64
      (dat dat_code)←a b
      (address port)←'localhost' 6311
      ⍝'Credentials must be single-byte char'⎕SIGNAL(80≠⎕DR credentials)/11
      DRC←#.Conga.Init''
      :If 0=0⊃z←DRC.Clt''address port'Raw'⊣step←'Connection'
        CLT←1⊃z
      :AndIf 0=0⊃z←DRC.Wait CLT 32⊣step←'Wait for confirmation'
      :AndIf 32=≢h←⎕UCS 3⊃z⊣step←'Check R header'
      :AndIf 'Rsrv'≡4↑h⊣step←'Check R header for protocol'
      :AndIf 'QAP1'≡h[8+⍳4]⊣step←'Check R header for transfer protocol'
        ⍝ Then you should check authentication protocol
      :Else
        ('Failed at step ',step,': ',,⍕z)⎕SIGNAL 11
      :EndIf
    ∇

    ∇ UnMake
      :Implements destructor
      :Trap 0 ⍝ Ignore errors in teardown
     ∘
        :If 0≠≢DRC.Names'' ⋄ {}DRC.Close¨DRC.Names'' ⋄ :EndIf
      :EndTrap
    ∇
  :endclass
:EndNamespace
