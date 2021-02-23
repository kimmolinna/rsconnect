]load /home/kimmo/dyalog/rserve/rserve
)copy conga Conga
⎕path←'↑ ⎕se.Dyalog.Utils'
r←⎕new RServe.client

⎕SH'R CMD Rserve --no-save >~/Rserve.log 2>&1'
⎕sh 'kill -9 ',⍕⎕SH'pidof Rserve'


library(remotes)
install_local("/home/kimmo/Downloads/rscproxy_2.0-6.tar.gz")


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
co2.attributes
co2.class
co2.tsp  
8↑co2.value
co2.value[2 4 6]
r.eval 'age <-18:20'
'height' r.set (76.1 77 78.1)
v←r.eval 'village <-data.frame(age=age,height=height)'
]boxing on
v.attributes
v.value
obj←⎕new #.RServe.robject
obj.tsp←2014(2014+11÷12)12
obj.class←'ts'
obj.data←?12⍴100
'myts' r.set obj
(r.eval 'summary(myts)').value
mydf←⎕new #.RServe.robject
mydf.class←'data.frame'
mydf.names←'xx' 'square'
mydf.data←↓[1]((⍳12)∘.*1 2)
'mydf' r.set mydf
(r.eval'summary(mydf)').value

Response
   ]load /home/kimmo/dyalog/R/R
#.R
]LINK.create rserve /home/kimmo/dyalog/rserve
Linked: #.rserve ←→ /home/kimmo/dyalog/rserve
)copy conga Conga
/opt/mdyalog/18.0/64/unicode/ws/conga.dws saved Fri Dec 11 03:11:01 2020
⎕path←'↑ ⎕se.Dyalog.Utils'
      r←⎕new R

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
 98.5 100.3 99.1 100.0 98.5 100.6 99.5 100.4 99.6 100.7
'normR' r.set normAPL
1
1⍕10↑r.eval 'normR'
 98.5 100.3 99.1 100.0 98.5 100.6 99.5 100.4 99.6 100.7
(r.eval 'summary(normR)').value
┌───────────┬───────────┬───────────┬──────────┬───────────┬───────────┐
│Min.       │1st Qu.    │Median     │Mean      │3rd Qu.    │Max.       │
├───────────┼───────────┼───────────┼──────────┼───────────┼───────────┤
│96.96542886│99.30733807│99.96416949│100.001958│100.6613411│103.4399716│
└───────────┴───────────┴───────────┴──────────┴───────────┴───────────┘
x← ¯10 10 {⍺[1]++\0,⍵⍴(|-/⍺)÷⍵} 50
z←x∘.{{10×(1○⍵)÷⍵}((⍺*2)+⍵*2)*.5}x
('x' 'z') r.set (x z)
1 1
expr←'persp(x,x,z,theta=30,phi=30,expand=0.5,'
expr,←'xlab="X",ylab="Y",zlab="Z")'
r.eval expr
#.[R].[robject]
r.eval 'graphics.off()'
#.[R].[robject]
co2←r.eval 'co2'
co2.attributes
┌─────┬───────────────────┐
│class│ts                 │
├─────┼───────────────────┤
│tsp  │1959 1997.916667 12│
└─────┴───────────────────┘
co2.class
ts
co2.tsp  
1959 1997.916667 12
8↑co2.value
315.42 316.31 316.5 317.56 318.13 318 316.39 314.65
co2.value[2 4 6]
316.31 317.56 318
r.eval 'age <-18:20'
18 19 20
'height' r.set (76.1 77 78.1)
1
v←r.eval 'village <-data.frame(age=age,height=height)'
]boxing on
Was ON
v.attributes
┌─────────┬────────────┐
│names    │┌───┬──────┐│
│         ││age│height││
│         │└───┴──────┘│
├─────────┼────────────┤
│class    │data.frame  │
├─────────┼────────────┤
│row.names│1 2 3       │
└─────────┴────────────┘
v.value
18 76.1
19 77  
20 78.1
obj←⎕new #.rserve.robject
obj.tsp←2014(2014+11÷12)12
obj.class←'ts'
obj.data←?12⍴100
'myts' r.set obj
1
(r.eval 'summary(myts)').value
┌────┬───────┬──────┬─────┬───────┬────┐
│Min.│1st Qu.│Median│Mean │3rd Qu.│Max.│
├────┼───────┼──────┼─────┼───────┼────┤
│1   │18     │48.5  │42.75│62.75  │83  │
└────┴───────┴──────┴─────┴───────┴────┘
mydf←⎕new #.rserve.robject
mydf.class←'data.frame'
mydf.names←'xx' 'square'
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