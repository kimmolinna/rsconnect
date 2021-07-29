@ECHO OFF
start /b "rserve" "C:\Program Files\R\R-4.1.0\bin\x64\R" "CMD" "Rserve" --no-save --slave --RS-workdir c:/Users/kimmo/rsconnect/ --RS-port 6311 >Rserve.log
