#!/bin/bash

replSetName=${1:-"iars"}
secondaryNodes=${2:-2}
zabbixServer=$3
mongoAdminUser=${4:-"dbanurun"}
mongoAdminPasswd=${5:-"nurun123!"}
staticIp=${6:-"172.24.7.22"}

install_mongo3() {

  if [ "!", "-f", "/etc/yum.repos.d/mongodb-org-3.2.repo" ];then
        echo "create mongo repo /etc/yum.repos.d/mongodb-org-3.2.repo"
        cat > /etc/yum.repos.d/mongodb-org-3.2.repo <<EOF
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1
EOF
        else
                echo "/etc/yum.repos.d/mongodb-org-3.2.repo already exists!"
        fi
        #install
        yum install -y mongodb-org

        #ignore update
        # sed -i '$a exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools' /etc/yum.conf

        #disable selinux
        sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
        sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
        setenforce 0

        #kernel settings
        if [[ -f /sys/kernel/mm/transparent_hugepage/enabled ]];then
                echo never > /sys/kernel/mm/transparent_hugepage/enabled
        fi
        if [[ -f /sys/kernel/mm/transparent_hugepage/defrag ]];then
                echo never > /sys/kernel/mm/transparent_hugepage/defrag
        fi

        #configure
        sed -i 's/\(bindIp\)/#\1/' /etc/mongod.conf
}

deinstall_mongo()
{
        echo "yum erase mongodb-org*"
        MongoPid=`ps -ef |grep -v grep |grep mongod|awk '{print $2}'`
        if [ $? -eq 0 -a "$MongoPid" != "" ];then
                echo "kill $MongoPid"
                kill $MongoPid
        fi
        yum -y erase mongodb-org*
}

which mongo
if [[ $? -ne 0 ]]; then
        install_mongo3
else
        deinstall_mongo
fi
