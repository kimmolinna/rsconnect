# RSconnect - R connection for DyalogAPL with Rserve
"Rserve (see [www.rforge.net/Rserve/](www.rforge.net/Rserve/)) is a TCP/IP server which allows other programs to use facilities of R (see [www.r-project.org](https://www.r-project.org)) from various languages without the need to initialize R or link against R library. Every connection has a separate workspace and working directory." This is true for Linux and Mac but "Windows lacks important features that make the separation of namespaces possible, therefore Rserve for Windows works in cooperative mode only, that is only one connection at a time is allowed and all subsequent connections share the same namespace." 


## Installation of Rserve
### Linux
The best way to install Rserve is to install it from a source package which you can download from <https://www.rforge.net/Rserve/files/>

Login with enough privileges to add R packages and run in shell: 
```bash
R CMD INSTALL Rserve_1.8-8.tar.gz
```
### Windows
The easiest way to install Rserve is to just copy binaries from [Windows/libs](./Windows/libs) folder to to the directory containing `R.DLL`. 
In the default installation the folder is `C:/Program Files/R/R-4.1.0/`

If it's something else you should change it in a [settings.json](./settings.json) file

```json
"r": {
    "home": "C:/Program Files/R/R-4.1.0/",
```
You have to set `R_HOME` environmental variable which should point to `\bin`-folder like `C:\Program Files\R\R-4.1.0\bin`

If you want to install Rserve from source you need [Rtools](https://cran.r-project.org/bin/windows/Rtools/) for build R packages with C/C++/Fortran code.

## Use in Dyalog
The tool tries to start Rserve automatically so you load it simply by using command
```apl
]load rserve.dyalog
or
2 ⎕FIX 'file://rserve.dyalog' 
```
Then you should start a Rserve TCP/IP server. You can do this manually or by using the command
```apl
RS.start
```
And then you are ready to go
```apl
r←⎕NEW #.RS.Rserve
  r.eval 'Hello World!'
Error 1
  r.eval '"Hello World!"'
Hello World!
```
At this point there is only two functions in use `eval` for evaluation and `set` for setting.
```apl
  a←r.eval'iris'
  'out' r.set a
1
  a.value≡(r.eval 'out').value
1
```
You can find examples in a [rsconnect_test.md](./rsconnect_test.md) file. It includes basically all the same examples than in a rconnect (rscproxy-connection.)

A main element in RSconnect is robject. The tool reads R-structures to Robject and each Robject has `data`-field and `value`(default) and `attributes` properties. I use lowercases because of R.   

```apl
  r.eval 'iris'
#.[Rserve].[robject]
  (r.eval 'iris')[⍳3;]
 (r.eval'iris')[⍳3;]
┌────────────┬───────────┬────────────┬───────────┬───────┐
│Sepal.Length│Sepal.Width│Petal.Length│Petal.Width│Species│
├────────────┼───────────┼────────────┼───────────┼───────┤
│5.1         │3.5        │1.4         │0.2        │setosa │
├────────────┼───────────┼────────────┼───────────┼───────┤
│4.9         │3          │1.4         │0.2        │setosa │
└────────────┴───────────┴────────────┴───────────┴───────┘
```
You can create robjecct quite easily by yourself and then use R for example for summaries.
```apl
mydf←⎕new #.RS.robject
mydf.attributes['class' 'names']←'data.frame' ('xx' 'square')
mydf.data←↓[1]((⍳12)∘.*1 2)
'mydf' r.set mydf 
1
  mydf.attributes[]
┌─────┬─────┐
│names│class│
└─────┴─────┘
  mydf.attributes[⊂'class']
┌──────────┐
│data.frame│
└──────────┘
  (r.eval 'summary(mydf)').value
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
  (r.eval 'summary(mydf$xx)').value
┌────┬───────┬──────┬────┬───────┬────┐
│Min.│1st Qu.│Median│Mean│3rd Qu.│Max.│
├────┼───────┼──────┼────┼───────┼────┤
│1   │3.75   │6.5   │6.5 │9.25   │12  │
└────┴───────┴──────┴────┴───────┴────┘
  (r.eval 'summary(mydf$xx)').data
1 3.75 6.5 6.5 9.25 12
```

### Settings
You can change address and port for Rserve in the [settings.json](./settings.json) file. These are affecting for server and client side. Presently I assume that that you are using local rserve.

```json
 "rserve":{
    "address": "localhost",
    "port": 6311,
    "timeout": 2000
  },
```
You can specify .NET framework and file for `System.Drawings` in the [settings.json](./settings.json) file.
```json
  "dotnet": {
    "use": 1,
    "framework": "C:/Program Files/dotnet/packs/NETStandard.Library.Ref/2.1.0/ref/netstandard2.1/",
    "lib": "System.Diagnostics.Process.dll"
  },
```
In Linux the tool uses shell script to start the Rserve and in Windows .NET, but there is also a backup which uses ⎕CMD. In the future I will change the code so that the default way is .NET in all environments.