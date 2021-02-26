﻿:Namespace RS
  :class robject
    ⎕ML←1 ⋄ ⎕IO←1 ⋄ ⎕PP←34
    :Field Public data←⍬
    :field private _a←⊂''
    :field private ga←⍬
    :property keyed attributes
    :access public

    ∇ r←Get args 
        :if args.IndexersSpecified
          r←{0=≢⍵:⊂''⋄⍵[ga⍳⊃args.Indexers]}_a
        :else
          r←{0=≢⍵:,⊂''⋄ ga{b←⍸~_a∊⊂'' ⋄ ⍺[b]{⍺ ⍵}¨⍵[b]}⍵}_a
        :endif
      ∇
    ∇ Set args
    :if (⊂'')≡_a ⋄ _a←(⊂'')⍴⍨≢ga ⋄ :endif
      _a[ga⍳⊃args.Indexers]←args.NewValue
    ∇
    :endproperty

    :property default value
    :Access Public
    ∇ r←Get args
      r←{1=≢data:,⍵ ⋄ ⍵}{attributes[⊂'class']≡⊂'factor':⍉attributes[⊂'levels'][⍵]
        ∨/( {1=≡⊃⍵:⍵⋄⊃⍵}attributes[⊂'class'])∊⊂'table':⍵{~⊃attributes[⊂'dim']≡⊂'':⍵⍪⍉(⌽⊃attributes[⊂'dim'])⍴⍺⋄ ⍵,[0.5]⍺}⊃attributes[⊂'names']{⍺≢⊂'':⍺⋄⍵}attributes[⊂'dimnames']
        ~attributes[⊂'dim']≡⊂'':⍉(⌽⊃attributes[⊂'dim'])⍴⍵
        ⍉↑{≡⍵:⍵ ⋄ (⊃⍵.attributes[⊂'levels'])[⍵.data]}¨{1=≡⍵:⊂⍵ ⋄ ⍵}⍵
        }data
    ∇
    :endproperty

    ∇ Make2 arg
      :Access Public
      :Implements Constructor
      ga←#.settings.r.attributes
      attributes[⊃⊃arg]←2⊃⊃arg
      data←{1=≢⍵:,↑⍵ ⋄ ⍵}2⊃arg
      ∇

    ∇ Make0
      :Access Public
      :Implements Constructor
      ga←#.settings.r.attributes
      ∇
    
  :endclass

  :Class Rserve
    ⍝ Interface from Dyalog APL to RServe
    ⍝ Currently asssumes existence of #.Conga
    ⎕ML←1 ⋄ ⎕IO←0 ⋄ ⎕PP←34
    :Field Public CLT←''         ⍝ Public for debugging
    :Field Private LittleEndian
    :field private error←⍬
    :field private command←⍬
    :field private type←⍬
    :field private sexp←⍬
    :field private ga←⍬
    :field private mac←0
    :field private win←0
    :field private bit64←0
    :field private process←⍬

    prop←{83=⎕dr ⍵:⊂(⍺.name,⊂⍬)[⍺.code⍳⍵] ⋄ (⍺.code,0)[⍺.name⍳⊃⍵]}

    :property keyed ERR
    :access public  
    ∇ r←get args
      r←error prop args.Indexers
    ∇
    :endproperty

    :property keyed XT
    :access public  
    ∇ r←get args
      r←sexp prop args.Indexers
    ∇
    :endproperty

    :property keyed CMD
    :access public
    ∇ r←get args
      r←command prop args.Indexers
    ∇
    :endproperty
    
    :property keyed DT
    :access public
    ∇ r←get args
      r←type prop args.Indexers
    ∇
    :endproperty

    split←{a←⍺⋄''{0=⍴⍵:⍺ ⋄ ⍺,(⊂a↑⍵)∇(a↓⍵)}⍵}
    IntToBytes←{⎕FR←(⍺=8)⊃645 1287 ⋄ ⍺↑⎕UCS 80 ⎕DR(×⍵)×((2*(8×⍺))-1)⌊|⍵}
    b2i←{(⍺⍴256)⊥⌽⍵}
    ld←{⍵,⍨3 IntToBytes≢⍵}
    evalOut←{0,⍨DT[⊂'STRING'],ld{⍵↑⍨4×⌈(≢⍵)÷4}10,⍨⎕UCS ⍵}
    strOut←{DT[⊂'STRING'],ld{⍵↑⍨4×⌈(≢⍵)÷4}0,⍨⎕UCS ⍵}
    headData←{z←DRC.Send CLT(∊{4 IntToBytes ⍵}¨⍺(≢⍵)0 0) ⋄ SendWait ⍵}

    ∇ r←kill
      :access public
      :if bit64
        r←⎕sh 'kill -9 ',⍕⎕SH'pidof Rserve'
      :elseif win

      :endif
    ∇
    ∇ o←eval s;b;d;dh;hdr;r;s;t;xt;z
      :Access Public
      s←{1=≡⍵:,⊂⍵ ⋄ ⍵}s
      b←{CMD[⊂'eval'] headData evalOut ⍵}¨s
      o←{1=≢⍵:⊃⍵ ⋄ ⍵}{(⍵≡,⊂⍬)∨('Err'≡3↑⍵)∨(1=≡⍵)∨1=≢∪¯1↑¨⍕¨⎕dr¨⍵:⍵ ⋄ object ⍵}¨decode¨b
    ∇


    ∇ o←object i;attr;b;data;in;xt
      attr←(⊂'')⍴⍨≢ga ⋄ data←⍬ ⋄ xt←⊃i ⋄ i←1↓i
      :If xt∊128+XT['ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR'] ⋄ i←⊃i ⋄ :EndIf
      :for in :in i
        :if (xt=128+XT[⊂'VECTOR'])
        :andIf 0>≡in
        :andIf ∨/{⍵≡⊃⊃in}¨128+XT['ARRAY_INT' 'ARRAY_DOUBLE']
          data,←object in
          in←⍬
        :endIf
        :while 0≠⍴in
          :if ∨/b←ga∊in[1]
            attr[⍸b]←⊂(⊃in){'row.names'≡⍵:{¯2147483648≡⊃⍵:1+⍳|1⊃⍵⋄⍵}⍺⋄⍺}1⊃in
            in←2↓in
          :else
            data,←{xt∊128+XT[⊂'ARRAY_STR']:⍵⋄⊂⍵}in⋄in←⍬
          :EndIf
        :EndWhile
      :EndFor

      o←⎕NEW robject ((ga attr) data)
    ∇

    ∇ o←decode i;h;s;xt
      o←⍬ ⋄ h←16↑i ⋄ i←16↓i
      :If 1≠⊃h
        o←('Error'),⍕⊃ERR[3⊃h] ⋄ →0
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

    ∇ o←{ty}SEXPout i;a;at;b;d;dim;dt;in;ts;ty
      :If 0=⎕NC'ty' ⋄ ty←⎕DR i ⋄ :EndIf
      :Select ty
      :Caselist XT['SYMNAME' 'ARRAY_STR']
        o←ty,ld{⍵,1⍴⍨4-4|≢⍵}∊{0,⍨⎕UCS ⍵}¨i
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
        ts←∨/i.attributes[⊂'class']∊⊂'ts'

        :If ts
          d←XT[⊂'ARRAY_DOUBLE'] SEXPout¨{1=≡⍵:,⊂⍵ ⋄ ⍵}i.data
        :Else
          d←SEXPout¨{1=≡⍵:,⊂⍵ ⋄ ⍵}i.data
        :EndIf

        at←i.attributes[]

        :If (⊂'')≢i.attributes[⊂'row.names']
        :AndIf {⎕IO←1 ⋄ ⍵≡⍳¯1↑⍵}⊃i.attributes[⊂'row.names']
          b←¯1↑⊃i.attributes[⊂'row.names']
          at[{⍵⍳⊂'row.names'}0⊃¨at]←⊂(⊂'row.names'),⊂¯2147483648 b
        :EndIf

        a←∊{{(⊃⍵)SEXPout(1↓⍵)}¨({
            (XT['ARRAY_INT' 'ARRAY_DOUBLE' 'ARRAY_STR']⊃⍨323 645 80⍳⎕DR∊⍵),{
                1=≡⍵:⊂⍵ ⋄ ⍵}⍵}1⊃⍵)(XT[⊂'SYMNAME'],⍵[0])}¨at
        :If (⍴d)<total
          d←∊d ⋄ dt←⊃d
          o←(128+dt),ld(4↓d),⍨XT[⊂'LIST_TAG'],ld a
        :Else
          o←(128+XT[⊂'VECTOR']),ld(∊d),⍨XT[⊂'LIST_TAG'],ld a
        :EndIf
      :Caselist XT[⊂'ARRAY_DOUBLE'],163 323 645 
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

    ∇ o←t SEXPin i;a;b;class;d;dh;dim;dt;hdr;ii;in;levels;names;out;row;s;save;st;ty;xt
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
    
    ∇ Make;a;b;f;h;out;p;r;rc;step;z;si;c;wf
      :Access public
      :Implements constructor
      wf←⊃⎕nparts #.RS{⍺{0=≢⍵:⍺.SALT_Data.SourceFile ⋄ ⍵}' '~⍨⊃⍵{⍵[⍸(⊂⍺){∨/⍺⍷⍵}¨⍵]}⊃¨5176⌶⍬}'rserve.dyalog'
      #.settings←⎕json⊃⎕nget wf,'settings.json'
      mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂⊃'.'⎕WG'APLVersion'
      error←#.settings.r.error ⋄ command←#.settings.r.command
      sexp←#.settings.r.sexp ⋄ type←#.settings.r.type
      ga←#.settings.r.attributes
      
      :if (mac⍱win)   ⍝ linux
        :if 0=≢⎕SH'pidof Rserve;exit 0'
          ⎕SH'R CMD Rserve --no-save --RS-port ',(⍕#.settings.rserve.port),' >~/Rserve.log 2>&1'
        :endif
      :elseif win 
        :trap 0
          ⎕USING←,⊂'System.Diagnostics',',',#.settings.dotnet.framework,#.settings.dotnet.lib 
          si←⎕NEW ProcessStartInfo(⊂#.settings.r.home,'bin\x64\Rserve.exe') 
          si.Arguments←'--slave --RS-port ',⍕#.settings.rserve.port 
          si.WindowStyle←ProcessWindowStyle.Hidden 
          si.CreateNoWindow←1 
          process←Process.Start si 
        :else
          a←⎕CMD 'taskkill /IM Rserve.exe /F'
          c←'start /b "rserve" ',('/'⎕R'\\') '"',#.settings.r.home
          c,←'bin\x64\Rserve.exe" --no-save --slave --RS-port '
          c,←(⍕#.settings.rserve.port),' >Rserve.log'
          (⊂'@ECHO OFF' c) ⎕NPUT (wf,'Windows\start.bat') 1
          a←⎕cmd (wf,'Windows\start.bat') 'hidden'         
        :endtrap
      :elseif mac
        ∘ ⍝ my macbook is broken
      :endif

      :if 0=⎕nc 'RS.DRC' 
        :if 0=⎕nc '#.Conga'⋄'Conga' #.⎕CY 'conga' ⋄ :endif
        DRC←#.Conga.Init'' 
      :endif

      :If 0=0⊃z←DRC.Clt'' #.settings.rserve.address #.settings.rserve.port'Raw'⊣step←'Connection'
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

    ∇ UnMake;a
      :Implements destructor
      :Trap 0 ⍝ Ignore errors in teardown
        :if win 
          :if ⍬≢process
            process.Kill '' 
          :else
             a←⎕CMD 'taskkill /IM Rserve.exe /F'
          :endif
        :endif
        :If 0≠≢DRC.Names'' ⋄ {}DRC.Close¨DRC.Names'' ⋄ :EndIf
      :EndTrap
    ∇
  :endclass
:EndNamespace