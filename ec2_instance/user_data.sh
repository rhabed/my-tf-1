#!/bin/bash


echo "robert" > /home/ec2-user/newfile.txt

echo ${var1} >> /home/ec2-user/newfile.txt
echo ${var2} >> /home/ec2-user/newfile.txt
LOG="/var/log/mylog.log"
variable="Rosto Abed"
time=$(date)
echo $time >> $LOG
echo $variable >> $LOG
echo ${var1} >> $LOG
echo ${var2} >> $LOG