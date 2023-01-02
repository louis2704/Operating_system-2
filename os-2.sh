#!/bin/bash                                                                                                                                                                 
url='https://api.binance.com/api/v1/ticker/price'                                                                                                                           
output=beta.txt                                                                                                                                                             
touch $output value.txt                                                                                                                                                     
curl -o $output $url                                                                                                                                                        
grep -oP '(?<="ETHBTC","price":").*?(?="},{)' $output>>value.txt                                                                                                            
#less value.txt                                                                                                                                                            
Msg=$(head -n 1 value.txt)                                                                                                                                                  
sqlite3 scrap.db  "create table if not exists Datas(price DECIMAL(9,8) NOT NULL, date DATETIME NOT NULL);"                                                                  
sqlite3 scrap.db  "create table if not exists Anomalie(price_ano DECIMAL(9,8) NOT NULL, date DATETIME NOT NULL);"                                                           
date=$(date '+%Y-%m-%d %H:%M:%S')                                                                                                                                           
sqlite3 scrap.db  "INSERT INTO Datas(price, date) VALUES($Msg, '$date');"                                                                                                   
#echo "DONE : INSERT INTO Datas(price, date) VALUES($Msg, '$date');"                                                                                                        
#processing                                                                                                                                                                 
length=$(sqlite3 scrap.db "SELECT COUNT(*) From Datas;")                                                                                                                    
mean=$(sqlite3 scrap.db "SELECT avg(price) From Datas;")                                                                                                                    
#echo $length                                                                                                                                                               
printf "%.8f \n" $mean >>mean.txt                                                                                                                                           
mean=$(head -n 1 mean.txt)                                                                                                                                                  
sous=$(comm -1 <(sort value.txt) <(sort mean.txt))                                                                                                                          
#echo "$sous"                                                                                                                                                               
cent=100                                                                                                                                                                    
percantage=$(echo $sous*$cent | bc)                                                                                                                                         
echo $percantage                                                                                                                                                            
Token="YOUR-TOKEN-HERE"                                                                                                                      
ID="YOUR-ID-HERE"                                                                                                                                                             
ano=7.00000000                                                                                                                                                              
if (($(echo "$percantage>$ano" | bc -l) ));                                                                                                                                 
then                                                                                                                                                                                
curl -s "https://api.telegram.org/bot$Token/sendMessage?chat_id=$ID&text=AnomalyAlert!"                                                                                     
curl -s "https://api.telegram.org/bot$Token/sendMessage?chat_id=$ID&text=http://localhost:8080/"                                                                                              
sqlite3 scrap.db  "INSERT INTO Anomalie(price_ano, date) VALUES($Msg, '$date');"                                                                                    
fi                                                                                
rm value.txt
rm mean.txt