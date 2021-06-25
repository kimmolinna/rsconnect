@ECHO OFF
start /b "rserve" "C:\Users\kimmo\R-4.1.0\bin\x64\R" "CMD" "Rserve" --no-save --slave --RS-workdir c:\\users\\kimmo\\onedrive\\asiakirjat\\github\\rsconnect\\ --RS-port 6311 >Rserve.log
