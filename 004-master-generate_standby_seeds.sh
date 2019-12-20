#!/usr/bin/env bash

. config.sh

# set -x

#### Process

[[ -d $seeds_dir ]] || mkdir $seeds_dir

cp rundap-master.sh $seeds_dir

echo -e "\n===================================\n=== Generating Primary Standby Seed Packages === \n==================================="

for standby in $(set | grep standby_fqdn_ | sort | cut -d'=' -f2);do
    docker exec $container_name \
        evoke seed standby \
        $standby \
        $master_host_fqdn \
        > $seeds_dir/$standby-seed.tar

    tar -C $seeds_dir -cf $seeds_dir/$standby-pkg.tar $standby-seed.tar rundap-master.sh
    rm $seeds_dir/$standby-seed.tar

    echo " - $seeds_dir/$standby-pkg.tar"
done


if [ "$(set | grep dr_standby_fqdn_)" != "" ];then
    echo -e "\n===================================\n=== Generating DR Standby Seed Packages === \n==================================="
    for standby in $(set | grep dr_standby_fqdn_ | sort | cut -d'=' -f2);do
        docker exec $container_name \
            evoke seed standby \
            $standby \
            $master_lb_fqdn \
            > $seeds_dir/$standby-seed.tar
   
            tar -C $seeds_dir -cf $seeds_dir/$standby-pkg.tar $standby-seed.tar rundap-master.sh
            rm $seeds_dir/$standby-seed.tar

            echo " - $seeds_dir/$standby-pkg.tar"
    done
fi


