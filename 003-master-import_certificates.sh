#!/usr/bin/env bash

. config.sh

container_cert_dir=/opt/conjur/backup/certs/

master_cert_file=$m_subject.cer
follower_cert_file=$f_subject.cer
root_bundle_file=root-bundle.cer                                    # This file needs to contain any intermediate CA certificates 
                                                                    # and the root CA certificate in the order in which they were
                                                                    # used to sign the server certificates with the root certificate being the last in the file.
                                                                    # For example: cat intermediate.cer root.cer > root-bundle.cer

master_cert_path=$cert_output_dir/$master_cert_file                    
follower_cert_path=$cert_output_dir/$follower_cert_file                                                                         
root_bundle_cert_path=$cert_output_dir/$root_bundle_file                                                                        
                                                                        
docker exec $container_name "[[ -d $container_cert_dir ]] || mkdir -p $container_cert_dir"

docker cp $master_key_path $container_name:$container_cert_dir/$master_key_file
docker cp $master_cert_path $container_name:$container_cert_dir/$master_cert_file

docker cp $follower_key_path $container_name:$container_cert_dir/$follower_key_file
docker cp $follower_cert_path $container_name:$container_cert_dir/$follower_cert_file

docker cp $root_bundle_cert_path $container_name:$container_cert_dir/$root_bundle_file

docker exec $container_name \
    evoke ca import -r -f \
    $container_cert_dir/$root_bundle_file

sleep 2

docker exec $container_name \
    evoke ca import \
    -k $container_cert_dir/$master_key_file \
    -s $container_cert_dir/$master_cert_file

sleep 2

docker exec $container_name \
    evoke ca import \
    -k $container_cert_dir/$follower_key_file \
    $container_cert_dir/$follower_cert_file
