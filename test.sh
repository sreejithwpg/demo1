#!/bin/bash

connaxis_add() {
clear; 
echo -e "Welcome to Connaxis Website setup: Wizard \n=======================\n"
domain_status='1'
while [ $domain_status ]; do 
  read -p "Enter Domain name:`echo $'\t'`" domain_name
  if [ -f /etc/nginx/sites-enabled/$domain_name.conf ]; then
  domain_status='1'
  echo "Domain already exists. Try another domain"
  elif [ "$domain_name" = "" ]; then
  echo "Domain name cannot be blank"
  domain_status='1'
  else
  domain_status='0';break;
  fi
  done;

  username_status='1'
  while [ $username_status ]; do
  read -p "Enter Username:`echo $'\t'`" user_name
  user_temp=`cat /etc/passwd| grep $user_name -c 2>/dev/null`
  if [ "$user_name" = "" ]; then
  echo "Username name cannot be blank"
  username_status='1';
  elif [ "$user_temp" != "0" ]; then
  username_status='1'
  echo "Username already exists. Try another domain"
  else
  username_status='0';break;
  fi
done;

pass_word=`mkpasswd -l 16`

echo -e "\n\nShall we confirm the details given below:"
echo -e "-----------\nDomain name: $domain_name\nUsername: $user_name \n\n"

read -p "Confirm? (yes/no):`echo $'\t'`" confirm

if [ "$confirm" = "no" ] || [ "$confirm" = "NO" ] ; then
 echo "Thank you for using the setup wizard. Bye!!!"
 exit

elif [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ] ; then

echo "Creating User"
useradd $user_name;
echo $pass_word | passwd $user_name --stdin
echo "Creating FTP user"
echo $pass_word | pure-pw useradd $user_name -u $user_name -g $user_name -d /home/$user_name
pure-pw mkdb

mkdir /home/$user_name/public_html /home/$user_name/logs
chown $user_name. /home/$user_name/

cp /etc/connaxis-template/httpd.template /etc/httpd/sites-enabled/$domain_name.conf
cp /etc/connaxis-template/php-fpm.template /etc/php-fpm.d/$domain_name.conf
cp /etc/connaxis-template/varnish.template /etc/varnish/conf.d/$domain_name.conf
cp /etc/connaxis-template/nginx.template /etc/nginx/sites-enabled/$domain_name.conf

sed -i "s/dxxxn/$domain_name/g" /etc/httpd/sites-enabled/$domain_name.conf /etc/php-fpm.d/$domain_name.conf /etc/varnish/conf.d/$domain_name.conf /etc/nginx/sites-enabled/$domain_name.conf;

sed -i "s/uxxxn/$user_name/g" /etc/httpd/sites-enabled/$domain_name.conf /etc/php-fpm.d/$domain_name.conf /etc/varnish/conf.d/$domain_name.conf /etc/nginx/sites-enabled/$domain_name.conf;


 echo -e "\n\nCongratulations!!! Website added. Info given below:"
 echo -e "-----------\nDomain name: $domain_name\nUsername: $user_name\nPassword: $pass_word"
 #echo -e "Home direcory: /home/$user_name"

else

 echo -e "Invalid option..Exiting the setup wizard now. Please try again."

fi
}



# Read Arguments
options=$1

# Check arguments validity

case $options in 

 create )
   connaxis_add;;

 remove )
   echo remove;;

 modify )
   echo modify;;

 help )
   echo help;;

 * )
   echo invalid option. check help;;
esac


