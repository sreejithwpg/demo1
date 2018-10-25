#!/bin/bash
mkdir -p /home/dbbackups 
path="/home/dbbackups"
today=`date +%F`                                                                                                                                                     
dow=`date +%a`                                                                                                                                                       
# List all databases in server                                                                                                                                       
                                                                                                                                                                     
mysql -e "show databases"  | egrep -vw "(Database|information_schema|performance_schema)" > $path/dblist.txt                                                         
                                                                                                                                                                     
rm -fv $path/dbfailed.txt                                                                                                                                            
rm -fv $path/dbfailed-tmp.txt                                                                                                                                        
rm -fv $path/dbfailed-mail.txt
mkdir -p $path/$dow
/usr/bin/mysqldump --events mysql > $path/$dow/mysql.sql

if [ $? -ne 0 ] ; 
then 
        mysqlcheck -r mysql ; 
        /usr/bin/mysqldump --events mysql > $path/$dow/mysql.sql
        if [ $? -ne 0 ] ; 
        then 
                echo "mysql" > $path/dbfailed.txt; 
        fi  
fi

for i in `cat $path/dblist.txt` ; 
do 
        sleep 2; 
        echo "Creating dbbackup of $i" ; 
        /usr/bin/mysqldump $i > $path/$dow/$i.sql ; 
        if [ $? -ne 0 ] ; 
        then 
                echo $i >> $path/dbfailed-tmp.txt; 
        fi; 
done

if [ -f $path/dbfailed-tmp.txt ] 
then

        for i in `cat $path/dbfailed-tmp.txt`
        do
                mysqlcheck -r $i
                /usr/bin/mysqldump $i > $path/$dow/$i.sql ;
                if [ $? -ne 0 ] ; 
                then    
                        echo $i >> $path/dbfailed.txt;
                fi;
        done
fi

if [ -f $path/dbfailed.txt ]; 
then 
        echo -e " Corrupted/Failed Dbs!! Try the following Commands in Server \n" > $path/dbfailed-mail.txt
        echo -e "===================================================== \n" >> $path/dbfailed-mail.txt
        for i in `cat $path/dbfailed.txt`
        do
                echo "mysqldump $i > $path/$dow/$i.sql " >> $path/dbfailed-mail.txt
        done
        sleep 5;
        cat $path/dbfailed-mail.txt | mail -s "DB backup report of `hostname` on `date +%F`" xtremo@xieles.com
else

        echo "Db Backup Completed"  | mail -s "DB backup Completed - `hostname` on `date +%F`" xtremo@xieles.com

fi
