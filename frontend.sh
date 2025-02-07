
#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# "-p" → Ensures that parent directories are created if they don’t exist and prevents errors if the directory already exists.
sudo mkdir -$LOGS_FOLDER

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf install nginx -y 
VALIDATE $? "Installing Nginx Server"

systemctl enable nginx
VALIDATE $? "Enabling Nginx Server"

systemctl start nginx
VALIDATE $? "Starting Nginx Server"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading Latesh code"

cd /usr/share/nginx/html
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip
VALIDATE $? "Unzipping the frontend code"

# cp /etc/nginx/default.d/expense.conf
# cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
# VALIDATE $? 

systemctl restart nginx
VALIDATE $? "Restarting Nginx Server"