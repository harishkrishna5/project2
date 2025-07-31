#!/usr/bin/env bash
# App: op5Plugins
# Version: R60A01
################################################################################
#
# NAME:
#   arm_monitor_wrapper.sh
#
# PURPOSE:
#   This wrapper script will be invoked by check_mk service for monitoring the ARM service checks and this script
#   will invoke appropriate check based on the few and simple arguments passed to the wrapper. Complete arguments
#   required for the checks needs to be placed in the wrapper instead of expecting from monitoring service to allow
#   the control of thresholds of the checks with in ARM service.
# USAGE:
#   arm_monitor_wrapper.sh [check_name] [extra_parameters]
#
################################################################################
be_path=/local/armdata/scripts/check_mk
fe_path=/local/armdata/scripts/check_mk

if [ -f ${be_path}/.creds/monitoring.creds ]
then
    armonitor_user=`cat ${be_path}/.creds/monitoring.creds | awk -F '=' '{print $1}'`
    armonitor_password=`cat ${be_path}/.creds/monitoring.creds | awk -F '=' '{print $2}'`
elif [ -f ${fe_path}/.creds/monitoring.creds ]
then
    armonitor_user=`cat ${fe_path}/.creds/monitoring.creds | awk -F '=' '{print $1}'`
    armonitor_password=`cat ${fe_path}/.creds/monitoring.creds | awk -F '=' '{print $2}'`
fi


usage() {
    echo "$0 [check_name] [extra_parameters]";
    echo "where   [check_name]  is the name of the check that needs to executed"
    echo "where   [extra_parameters]  is the extra parameters that needs to be passed to the script"
    echo ""
    exit 1;
}

if [ $# -lt 1 ]
   then
    echo "Please check the arguments passed"
    usage
fi

# Read arguments passed to the wrapper
check_name=$1
shift


get_check_command() {
    case $check_name in
        #Check to monitor the SSL certificate expiry date for all the FQDNs.
        "check_single_san_cert") exec_command="$fe_path/check_single_san_cert.sh";;

        # Check to monitor the SSL certificate expiry date. ARM FQDN needs to be passed as an argument
        #  Note: The check will fail if -haproxy argument is present and if haproxy is not installed or started.
        "check_ssl_certificate") exec_command="$fe_path/check_ssl_certificate.sh -fqdn $1 -httpd -haproxy -C 30";;

        # Check to monitor end user experience of Artifactory login page . ARM FQDN needs to be passed as an argument
        "check_login_Page_from_end-users") exec_command="$fe_path/check_http -H $1 -u /ui -w 3 -c 60 -S -e 200";;

        # Check to monitor end user experience of Artifactory login page . ARM FQDN needs to be passed as an argument
        "check_login_localdocker_from_end-users") exec_command="$fe_path/check_http -H $1 -u /artifactory/api/docker/v2 -w 3 -c 60 -S -e 200";;

        # Check to monitor end user experience of Artifactory login page . ARM FQDN needs to be passed as an argument
        "check_login_globaldocker_from_end-users") exec_command="$fe_path/check_http -H $1 -u /artifactory/api/docker/v2 -w 3 -c 60 -S -e 200";;

        # Check to monitor netowork utilization and error rate on FE servers
        "check_fe_network_utilization_and_error_rate") exec_command="$fe_path/check_linux_net.sh -i ens192 -ei 100 -Ei 200 -eo 100 -Eo 200 -di 100 -Di 200 -S 'DATA_IN,DATA_OUT,PKT_IN,PKT_OUT,ERR_IN,ERR_OUT,DROP'" ;;

        # Check to monitor keepalived service in frontend servers
        "check_keepalived_service") exec_command="$fe_path/check_keepalived_service.sh";;

        # Check to monitor httpd service in frontend servers
        "check_apache_httpd_service") exec_command="$fe_path/check_httpd_service.sh";;

        # Check to monitor filesystem permission on FE servers
        "check_fe_filesystem_perm") exec_command="$fe_path/check_fs_config.sh $fe_path/fs_check_targets.csv FE";;

        # Check to monitor disk utilization on FE servers
        "check_fe_disk_utilization_general") exec_command="$fe_path/check_disk -w 15 -c 5 -p / -p /local -p /local/armdata";;

        # Check to monitor apache http connection.
        "check_apache_http_connection")  exec_command="$fe_path/check_http -H `hostname -f` -w 3 -c 60 -S -e 200";;

        #Check to monitor login page from the FE servers.
        "check_login_page_through_frontend")  exec_command="$fe_path/check_http -H `hostname -f` -u /ui -w 3 -c 60 -S -e 200";;

        #Check to monitor  artifactory configuration changes.
        "check_artifactory_general_config")  exec_command="$be_path/check_artifactory_config.py --baseUrl http://localhost:8081 --username ${armonitor_user} --password ${armonitor_password} --checkType config";;

        # Check to monitor artifactory security configuration changes.
        "check_artifactory_security_config")  exec_command="$be_path/check_artifactory_config.py --baseUrl http://localhost:8081 --username ${armonitor_user} --password ${armonitor_password} --checkType security";;

        # Check to monitor artifactor download performance. Check needs the FQDN of ARM service as first argument and backend id as second argument.
        "check_download") exec_command="$be_path/check_http_speed_cookie.pl -u http://${armonitor_user}:${armonitor_password}@localhost:8081/artifactory/proj-arm-monitoring-local/com/ericsson/arm/testFile10MB-`hostname`.dat -w 4 -c 60";;

        # Check to monitor artifactor upload performance. Check needs the FQDN of ARM service as first argument and backend id as second argument.
        "check_upload") exec_command="$be_path/check_artifactory_upload.sh -u http://${armonitor_user}:${armonitor_password}@localhost:8081/artifactory/proj-arm-monitoring-local/com/ericsson/arm/testFile10MB-`hostname`.dat -w 4 -c 60";;

        # Check to monitor filesystem permission changes on BE servers. role of the server either MASTER/SLAVE argument needs to be passed as an argument.
        "check_be_filesystem_perm") exec_command="$be_path/check_fs_config.sh $be_path/fs_check_targets.csv $1";;

        # Check to monitor FTP server status
        #"check_ftp_service") exec_command="$be_path/check_vsftpd_service.sh";;

        # Check to monitor ftp server configuration changes.
        #"check_vsftpd_configuration") exec_command="$be_path/check_vsftpd_config.sh";;

        # Check to monitor ARM data (filestores) utilization
        # Here default arguments are provided followed by customized arguments configured from playbook
        "check_disk_utilization_armdata") exec_command="$be_path/check_filestore.py -w 10T -c 5T";;

        # Check to monitor the LDAP servers config used in artifactory.
        "check_ldap_configurations") exec_command="$be_path/runJavaCheckCommand.sh ldapSettingsCheck \"CN=${armonitor_user},OU=CA,OU=SvcAccount,OU=P001,OU=ID,OU=Data,DC=ericsson,DC=se\" ${armonitor_password}";;

        # Check to monitor netowork utilization and error rate on BE servers
        "check_be_network_utilization_and_error_rate") exec_command="$be_path/check_linux_net.sh -i ens160 -ei 100 -Ei 200 -eo 100 -Eo 200 -di 100 -Di 200 -S 'DATA_IN,DATA_OUT,PKT_IN,PKT_OUT,ERR_IN,ERR_OUT,DROP'" ;;

        # Check to monitor Artifactory service status
        "check_artifactory_service") exec_command="$be_path/check_artifactory_service.sh";;

        # Check to monitor Artifactory http connection from backend server using 8081 port
        "check_artifactory_http_connection") exec_command="$be_path/check_http -I localhost -u /artifactory/api/system/ping -p 8081 -w 3 -c 6";;

        # Check to monitor Artifactory last binary garbage collection time.
        "check_artifactory_garbage_collection") exec_command="$be_path/check_artifactory_gc.sh -w 43200 -c 86300";;

        # Check to monitor last JVM garbage collection time as well as all other metrics in java melody
        # Note: the check name is kept as "garbage_collection" only, just because backward compatibility
        # TODO: The new check name "check_jmelody_metrics" shall be configured instead and obselete this one
        "check_jvm_garbage_collection") exec_command="$be_path/check_jmelody_all.sh" ;;

        # Check to monitor active database connections on each BE server.
        # Kept for backward compatibility.
        # TODO: The new check name "check_jmelody_metrics" shall be configured instead and obselete this one
        "check_active_database_connections") exec_command="$be_path/check_jmelody.sh -r /opt/arm/jfrog/artifactory/var/work/artifactory/tomcat/temp/javamelody/artifactory_`hostname` -ac -w 80 -c 90" ;;

        # Check to monitor all important Artifactory metrics in java melody
        # This is to replace check_jvm_garbage_collection & check_active_database_connections
        "check_jmelody_metrics") exec_command="$be_path/check_jmelody_all.sh" ;;

        #Check to monitor ldap servers login test from backend server
        "check_ldap_servers_login_test") exec_command="$be_path/check_http -H localhost -u /artifactory/ui/auth/login -p 8081 -T application/json -j POST -P {\"user\":\"${armonitor_user}\",\"password\":\"${armonitor_password}\",\"type\":\"login\"} -e 200 -w 20 -c 60" ;;

        # Check to monitor backend common disk utilization check.
        "check_be_disk_utilization_general") exec_command="$be_path/check_disk -w 15 -c 5 -p / -p /local -p /home/artifactor -p /local/armdata" ;;

        # Check logarchive consistency
        "check_logarchive") exec_command="$be_path/check_logarchive.sh ${armonitor_user} ${armonitor_password} 2 7 $1" ;;

        # Check artifactory microservices status
        "check_artifactory_microservices") exec_command="$be_path/check_jfrog_microservices.sh -u ${armonitor_user} -p ${armonitor_password}" ;;

        #Check logs in CLaas
        "check_logs_claas") exec_command="python3 $be_path/check_cls_logs.py --username ${armonitor_user} --password ${armonitor_password} --elastic_url https://$1:443 --index $2 --config $be_path/config.txt --timeout 60" ;;

        #checks maven usage
        "check_maven_usage") exec_command="$be_path/maven-central-usage.sh" ;;

        "-h") usage;;

        *) echo "Unexpected parameter $check_name."
        usage;
    esac
}

# Main execution starts here
get_check_command $*

$exec_command

res=$?

if [ ! $res -eq 0 ]; then
   # Consider collecting some dumps
   if [[ $check_name =~ check_artifactory_http_connection|check_active_database_connections ]]; then
      $be_path/collectBasicDumps.sh --stack --mysql
   elif [[ $check_name =~ check_jvm_garbage_collection ]]; then
      $be_path/collectBasicDumps.sh --stack --heap
   fi
fi

exit $res
