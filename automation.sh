#!/bin/bash
#Declaring variables
echo -e "Enter your name"
read my_name

echo -e "Enter the Bucket name"
read bucket_name

#Writing a script to install WebServer on Ubuntu Machine with automated maintainence activity
echo "Updating all the package"
sudo apt update -y

echo -e "Installing aws-cli for backing to S3"
sudo apt install awscli

echo "Checking for apache2 installed or not"
dpkg --list | grep apache2

if [ $? -ne 0 ]
then
    echo "Apache2 is not installed, hence installing the package"
    sudo apt install apache2
    echo "Stopping & Starting apache2 service"
    sudo systemctl stop apache2.service
    sudo systemctl start apache2.service
    sudo systemctl enable apache2.service
    sudo systemctl status apache2 | grep -iw "running"
    if [ $? -eq 0 ]
    then
        echo "Apache2 is successfully installed"
    else
        echo "Please check - Apache2 is not installed properly"
    fi 
else
    echo "Apache2 is already installed"
fi

#Tar file creation for logfiles
#Changing directory to apache2 log directory
cd /var/log/apache2

echo "Creating tar file for log files"
tar -cf venkat-httpd-logs-$(date '+%d%m%Y-%H%M%S')-access.log.tar access.log
tar -cf venkat-httpd-logs-$(date '+%d%m%Y-%H%M%S')-error.log.tar error.log

mkdir /tmp/logfiles
mv *.log.tar /tmp/logfiles
echo -e "Moved all tar files to /tmp/logfiles"

#Creating S3 bucket
aws s3api create-bucket --bucket $my_name-$bucket_name --region us-east-1
bucket=$(aws s3 ls | grep $bucket_name | awk '{print $3}')

echo -e "Uploading all log tar files to S3 bucket"
aws s3 sync /tmp/logfiles/ s3://$bucket

#Creating/Checking the inventory file for logs which are moving to S3 bucket"
if [ -f "/var/www/html/inventory.html" ];
then
    echo "inventory is already exists"
else
    echo -e "Log Type\tDate Created\t\tType\t\tSize\t\tLog Name" > /var/www/html/inventory.html
fi

#Updating inventory doc with Log details of the files moved to S3 bucket
aws s3 ls --human-readable s3://$bucket | tail -n +1 | awk -F'[-" ""."]' '{print $11 "-"  $12 "\t" $13 "-" $14 "\t\t" $17 "\t\t" $7"."$8 $9 "\t\t" $15"-" $16}' >> /var/www/html/inventory.html

#Empyting the logfiles directory as all the files are copied to S3 bucket
sudo rm -rf /tmp/logfiles/*.tar

#Listing the files uploaded into S3 Bucket
echo -e "List of Files uploaded in s3 bucket are"
aws s3 ls s3://$bucket

#Configuring the cronjob for this task
var1=$(find /etc/cron.d/ -type f -name "automation" -exec grep -l "automation.sh" {} \;)
var2=$(sudo service cron status | grep running | wc -l)

if [ $var2 == "0" -o "$var1" != "/etc/cron.d/automation" ];
then
    echo "* 10 * * *   root   bash  /root/Automation_Project/automation.sh" > /etc/cron.d/automation
    sudo service cron restart
    echo "CronJob configured for automation script"
else
    echo "CronJob is already running"
fi

