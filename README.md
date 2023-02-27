Automation_Project : Writing a Bash Script to configure the Virtual Machine for hosting a web server and later automating some maintainance tasks

Task 1: Configure Web Server and Automating some Maintainance tasks

1. Hosting Web Server: The first step is to set up a web server on the EC2 instance for hosting a website. It is also important to ensure that the apache2 server is running and it restarts automatically in case the EC2 instance reboots.

<detail><summary>Steps to be Followed</summary>

    a. Perform an update of the package details and the package list at the start of the script.

        sudo apt update -y

    b. Install the apache2 package if it is not already installed.

    c. Ensure that the apache2 service is running. 

    d. apache2 should runs as soon as our machine reboots.

</detail>

2. Archiving Logs: Daily requests to web servers generate lots of access logs. These log files serve as an important tool for troubleshooting. However, these logs can also result in the servers running out of disk space and can make them stop working. To avoid this, one of the best practices is to create a backup of these logs by compressing the logs directory and archiving it to the s3 bucket (Storage).

<detail><summary>Steps to be Followed</summary>

    a. Create a tar archive of apache2 access logs and error logs that are present in the /var/log/apache2/ directory 

    b. Place the tar into the /tmp/ directory.

    c. The name of tar archive should have following format:

        <your _name>-httpd-logs-<timestamp>.tar

        Ex: Ritik-httpd-logs-01212021-101010.tar
      
        Hint : use timestamp=$(date '+%d%m%Y-%H%M%S') )

    d. Copy the archive to the s3 bucket.

</detail>

Task 2: Need to improve two significant areas of our previous script.
1. Bookkeeping: When the script is executed, it should create /var/www/html/inventory.html with the proper header and append detail of copied Tar file in the next line. The script should never overwrite the present content of the file.

<detail><summary>Ex: Your inventory file should look like the following after multiple runs:</summary>

    cat /var/www/html/inventory.html
    Log Type               Date Created             Type      Size
    httpd-logs          010120201-100510            tar        10K
    httpd-logs          020120201-100510            tar        40K
    httpd-logs          030120201-100510            tar        4K
    httpd-logs          040120201-100510            tar        6K

</detail>

2. Run a Cron Job: The script should schedule a cron job that runs the same script automatically at an interval of 1 day as a root user. (It means the script will create a cron-file in /etc/cron.d/ directory with the correct content.)

    Note: Automation script is supposed to check if a cron job is scheduled or not; if not, then it should schedule a cron job by creating a cron file in the /etc/cron.d/ folder.

    The script should be placed in the root directory.

    Example: Git repository should be named ‘Automation_Project’, the cron job will then run the script present in /root/Automation_Project/automation.sh

Branches to be created
1. Master

2. Dev

Note : Tag for Task 1 should be Automation-v0.1 and Tag for Task 2 should be Automation-v0.2 then merge it with master branch
