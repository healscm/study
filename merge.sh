#!/bin/bash
sh -x
if [[ $branch == '' ]];then
   echo "请输入分支名称："
   exit 1;
else
   echo "$branch">list
fi
[[ -f $WORKSPACE/result_info ]] &&  >$WORKSPACE/result_info
function end_out(){
  date_time=`date "+%Y-%m-%d %H:%M:%S"`
  echo "****************************************************"
  cat $WORKSPACE/result_info
  echo "完成时间： $date_time"
  echo "****************************************************"
}
function generate_branch()
{
    git branch -a | grep ${new_branch}
	if [ $? -eq 0 ]; then
	  echo "${new_branch}已经存在无需创建" >> $WORKSPACE/result_info
	else
	  echo "${new_branch}进行拉取创建" >> $WORKSPACE/result_info
	  git checkout -b ${new_branch} || { echo "#Error: 创建${new_branch}分支失败">>$WORKSPACE/result_info; end_out; exit ; }
	  git push --set-upstream origin ${new_branch} || { echo "#Error: 推送${new_branch}分支到远程失败">>$WORKSPACE/result_info; end_out; exit ; }
	fi
}


for branch_list in `cat list`;do
  cd $WORKSPACE
  app_name=${branch_list%%-*}
  date=${branch_list##*-}
  git_address="git@git.gungunqian.cn:qiangungun/${app_name}"
  new_branch=${app_name}-release-${date}
  
  if [ -d "${app_name}" ];then
      rm -rf ${app_name}
      git clone ${git_address} || { echo "#Error: Git库克隆失败" >>$WORKSPACE/result_info; end_out; exit; }
      cd ${app_name}
      generate_branch
  else
      git clone ${git_address} || { echo "#Error: Git库克隆失败" >>$WORKSPACE/result_info; end_out; exit; }
      cd ${app_name}
      generate_branch
  fi
  git checkout -f ${branch_list} || { echo "#Error: 拉取${branch_list}分支失败" >>$WORKSPACE/result_info; end_out; exit ; }
  git checkout master
  git merge -q ${branch_list} || { echo "#Error: 合并master分支失败" >>$WORKSPACE/result_info; end_out; exit; }
  git push origin master
  if [ $? -eq 0 ]; then
    echo "#Sucess:=======${app_name} push 成功！ ========" >>$WORKSPACE/result_info
  else
    echo "#Error:=======${app_name}  push 失败！请检查详细原因 ========" >>$WORKSPACE/result_info
    echo "#Error:"
    end_out
    exit
  fi
done 
end_out
