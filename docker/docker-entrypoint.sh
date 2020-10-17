#!/bin/sh

## 修改日期：2020-10-17
## 作者：Evine Deng <evinedeng@foxmail.com>

set -e

RootDir="/root"
ShellDir="${RootDir}/shell"
LogDir="${RootDir}/log"
ScriptsDir="${RootDir}/scripts"


if [ ! -d ${LogDir} ]; then
  echo "检测到日志目录不存在，现在创建..."
  echo
  mkdir ${LogDir}
fi


echo "启动crond定时任务守护程序，日志文件重定向至/root/log/crond.log..."
echo
crond -L ${LogDir}/crond.log


if [ -s ${RootDir}/crontab.list ] && [ -d ${ShellDir} ] && [ -d ${ScriptsDir} ]
then
  echo "发现映射目录/root下存在crontab.list文件，现从该文件自动恢复定时任务..."
  echo
  crontab ${RootDir}/crontab.list
  echo "自动恢复定时任务如下："
  echo
  crontab -l
  echo  
else
  echo "${ShellDir}不存在或${ScriptsDir}不存在或${RootDir}/crontab.list不存在..."
  echo
  echo "可能是首次启动容器，跳过恢复定时任务..."
  echo
  echo "请后续进入容器并做好配置后，再使用 crontab ${RootDir}/crontab.list 添加..."
  echo
fi


if [ ! -d ${ScriptsDir} ]
then
  echo "${ScriptsDir} 目录不存在，开始克隆..."
  echo
  cd ${RootDir}
  git clone https://github.com/lxk0301/scripts
  echo
else
  echo "${ScriptsDir} 目录已存在，跳过克隆..."
  echo
fi


if [ ! d ${ShellDir} ]
then
  echo "${ShellDir} 不存在，开始克隆..."
  echo
  cd ${RootDir}
  git clone https://github.com/EvineDeng/jd-base shell
  echo
else
  echo "${ShellDir} 已存在，跳过克隆..."
  echo
fi


if [ -d ${ScriptsDir}/.github/workflows ]; then
  List=$(ls ${ScriptsDir}/.github/workflows | sed "s|\.yml||" | sed "/sync/d")
  echo "js脚本清单如下："
  echo
  echo $List
  echo
fi


if [ $List ]
then
  for i in $List; do
    if [ ! -d ${LogDir}/$i ]
    then
      echo "创建 ${LogDir}/$i 目录..."
      echo
      mkdir -p ${LogDir}/$i
    else 
      echo "目录 ${LogDir}/$i 已存在，跳过创建..."
      echo
    fi
    
    if [ -s ${ScriptsDir}/jd.sample.sh ]
    then
      echo "创建 ${ScriptsDir}/$i.sh 脚本"
      cp -f "${ScriptsDir}/jd.sample.sh" "${ScriptsDir}/$i.sh"
      echo
    else
      echo "${ScriptsDir}/jd.sample.sh 不存在，可能shell脚本克隆不正常，请手动克隆..."
      echo
    fi
  done
else
  echo "js脚本获取不正常，请手动克隆..."
fi


if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"