Linux:
```apl
]load /home/kimmo/rsconnect/rserve.dyalog
or
2 ⎕FIX 'file:///home/kimmo/rsconnect/rserve.dyalog'
```
Windows:
```apl
]load '/users/kimmo/onedrive/asiakirjat/github/rsconnect/rserve.dyalog'
or
2 ⎕FIX 'file:///users/kimmo/onedrive/asiakirjat/github/rsconnect/rserve.dyalog'
```
A test set:
```apl
r←⎕new RS.Rserve
]boxing on
⎕ml←1
r.eval '1+2'
r.eval 'c(1,2,3)*c(10,20,30)'
(r.eval 'matrix(1:12,3)').value
(r.eval 'matrix(1:12,3,byrow=TRUE)').value
1⍕10↑normAPL←r.eval 'rnorm(1000,100,1)'
'normR' r.set normAPL
1⍕10↑r.eval 'normR'
(r.eval 'summary(normR)').value
x←¯10 10 {⍺[1]++\0,⍵⍴(|-/⍺)÷⍵} 50
z←x∘.{{10×(1○⍵)÷⍵}((⍺*2)+⍵*2)*.5}x
('x' 'z') r.set (x z)
expr←'persp(x,x,z,theta=30,phi=30,expand=0.5,'
expr,←'xlab="X",ylab="Y",zlab="Z")'
r.eval expr
r.eval 'graphics.off()'
co2←r.eval 'co2'
co2.attributes[]
co2.attributes[⊂'class']
co2.attributes[⊂'tsp']  
co2.value[⍳8;]
r.eval 'age <-18:20'
'height' r.set (76.1 77 78.1)
v←r.eval 'village <-data.frame(age=age,height=height)'
v.attributes[]
v[;]
v.value
obj←⎕new #.RS.robject
obj.attributes['tsp' 'class']←(2014(2014+11÷12)12) 'ts'
obj.data←?12⍴100
'myts' r.set obj
(r.eval 'summary(myts)').value
mydf←⎕new #.RS.robject
mydf.attributes['class' 'names']←'data.frame' ('xx' 'square')
mydf.data←↓[1]((⍳12)∘.*1 2)
'mydf' r.set mydf
(r.eval'summary(mydf)').value
a←r.eval'iris'
'out' r.set a
a.value≡(r.eval 'out').value
```
Responses:
```apl
]boxing on
Was ON
⎕ml←1
r.eval '1+2'
3
r.eval 'c(1,2,3)*c(10,20,30)'
10 40 90
(r.eval 'matrix(1:12,3)').value
1 4 7 10
2 5 8 11
3 6 9 12
(r.eval 'matrix(1:12,3,byrow=TRUE)').value
1  2  3  4
5  6  7  8
9 10 11 12
1⍕10↑normAPL←r.eval 'rnorm(1000,100,1)'
 100.1 98.6 100.3 101.0 99.6 100.5 97.3 98.0 99.7 99.6
'normR' r.set normAPL
1
1⍕10↑r.eval 'normR'
 100.1 98.6 100.3 101.0 99.6 100.5 97.3 98.0 99.7 99.6
(r.eval 'summary(normR)').value
┌───────────┬───────────┬───────────┬──────────┬───────────┬───────────┐
│Min.       │1st Qu.    │Median     │Mean      │3rd Qu.    │Max.       │
├───────────┼───────────┼───────────┼──────────┼───────────┼───────────┤
│96.16940257│99.30228086│100.0571833│100.032433│100.7173424│102.9860109│
└───────────┴───────────┴───────────┴──────────┴───────────┴───────────┘
x←¯10 10 {⍺[1]++\0,⍵⍴(|-/⍺)÷⍵} 50
z←x∘.{{10×(1○⍵)÷⍵}((⍺*2)+⍵*2)*.5}x
('x' 'z') r.set (x z)
1 1
expr←'persp(x,x,z,theta=30,phi=30,expand=0.5,'
expr,←'xlab="X",ylab="Y",zlab="Z")'
r.eval expr
#.[Rserve].[robject]
r.eval 'graphics.off()'
[Null]
co2←r.eval 'co2'
co2.attributes[]
┌─────┬───┐
│class│tsp│
└─────┴───┘
co2.attributes[⊂'class']
┌──┐
│ts│
└──┘
co2.attributes[⊂'tsp']  
┌───────────────────┐
│1959 1997.916667 12│
└───────────────────┘
co2.value[⍳8;]
1959 1 315.42
1959 2 316.31
1959 3 316.5 
1959 4 317.56
1959 5 318.13
1959 6 318   
1959 7 316.39
1959 8 314.65
r.eval 'age <-18:20'
18 19 20
'height' r.set (76.1 77 78.1)
1
v←r.eval 'village <-data.frame(age=age,height=height)'
v.attributes[]
┌─────┬─────┬─────────┐
│names│class│row.names│
└─────┴─────┴─────────┘
v[;]
┌───┬──────┐
│age│height│
├───┼──────┤
│18 │76.1  │
├───┼──────┤
│19 │77    │
├───┼──────┤
│20 │78.1  │
└───┴──────┘
v.value
┌───┬──────┐
│age│height│
├───┼──────┤
│18 │76.1  │
├───┼──────┤
│19 │77    │
├───┼──────┤
│20 │78.1  │
└───┴──────┘
obj←⎕new #.RS.robject
obj.attributes['tsp' 'class']←(2014(2014+11÷12)12) 'ts'
obj.data←?12⍴100
'myts' r.set obj
1
(r.eval 'summary(myts)').value
┌────┬───────┬──────┬───────────┬───────┬────┐
│Min.│1st Qu.│Median│Mean       │3rd Qu.│Max.│
├────┼───────┼──────┼───────────┼───────┼────┤
│5   │24     │50.5  │48.58333333│75.5   │84  │
└────┴───────┴──────┴───────────┴───────┴────┘
mydf←⎕new #.RS.robject
mydf.attributes['class' 'names']←'data.frame' ('xx' 'square')
mydf.data←↓[1]((⍳12)∘.*1 2)
'mydf' r.set mydf
1
(r.eval'summary(mydf)').value
┌───────────────┬────────────────┐
│      xx       │    square      │
├───────────────┼────────────────┤
│Min.   : 1.00  │Min.   :  1.00  │
├───────────────┼────────────────┤
│1st Qu.: 3.75  │1st Qu.: 14.25  │
├───────────────┼────────────────┤
│Median : 6.50  │Median : 42.50  │
├───────────────┼────────────────┤
│Mean   : 6.50  │Mean   : 54.17  │
├───────────────┼────────────────┤
│3rd Qu.: 9.25  │3rd Qu.: 85.75  │
├───────────────┼────────────────┤
│Max.   :12.00  │Max.   :144.00  │
└───────────────┴────────────────┘
a←r.eval'iris'
'out' r.set a
1
a.value≡(r.eval 'out').value
1   
```