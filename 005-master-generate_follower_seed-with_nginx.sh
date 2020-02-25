#!/usr/bin/env bash

. config.sh

# set -x

#### Process

[[ -d $seeds_dir ]] || mkdir $seeds_dir

cp config.sh rundap-follower.sh nginx.conf $seeds_dir

echo -e "\n===================================\n=== Generating Follower Seed Packages === \n==================================="

docker exec $container_name \
    evoke seed follower \
    $follower_lb_fqdn \
    $master_lb_fqdn \
    > $seeds_dir/$follower_lb_fqdn-seed.tar

tar -C $seeds_dir -cf $seeds_dir/$follower_lb_fqdn-pkg.tar \
        $follower_lb_fqdn-seed.tar \
        rundap-follower_with-nginx.sh \
        nginx.conf \
        config.sh

rm $seeds_dir/$follower_lb_fqdn-seed.tar 

echo " - $seeds_dir/$follower_lb_fqdn-pkg.tar"
