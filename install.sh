#!/bin/bash
IPS=()
config_env=""

verify_port(){
    #ip=$1
    #cmd=$2
    telnet $1 $2
}

remote_exec(){
    #ip=$1
    #cmd=$2
    echo $2
<<<<<<< HEAD
    PORT=22
    if [[ "$1" == *."twilightparadox".* ]]; then
        PORT=8680
    fi
    if [[ "$1" == "node7-rddl-testnet.twilightparadox".* ]]; then
        PORT=22
    fi
    ssh -p $PORT rddl@$1  $2 $3 $4 $5 $6 $7
}

get_device_info(){
    ip=$1
    cmds='sudo dmidecode --handle 1 > device_info.json;
        cat device_info.json;'
    remote_exec "$ip" "$cmds"
}

get_geolocation_info(){
    ip=$1
    #curl -H "User-Agent: keycdn-tools:84.112.103.218" "https://tools.keycdn.com/geo.json?host=84.112.103.218"
    cmds="curl -H \"User-Agent: keycdn-tools:https://$ip\" \"https://tools.keycdn.com/geo.json?host=$ip\" > geolocation.json;
        cat geolocation.json;"
    remote_exec "$ip" "$cmds" 
=======
    ssh rddl@$1 -p 8680 $2 $3 $4 $5 $6 $7
>>>>>>> 219e507c745090e24b2b59ff8fbd4035f6cbb4cf
}

copy_to(){
    #file=$1
    #ip=$2
    #path=$3
<<<<<<< HEAD
    PORT=22
    if [[ "$1" == *."twilightparadox".* ]]; then
        PORT=8680
    fi
    if [[ "$1" == "node7-rddl-testnet.twilightparadox".* ]]; then
        PORT=22
    fi

    scp -P $PORT $1 rddl@$2:$3
=======
    scp -P 8680 $1 rddl@$2:$3
>>>>>>> 219e507c745090e24b2b59ff8fbd4035f6cbb4cf
}

install_deps(){
    ip=$1
    cmds='sudo apt install -y make git software-properties-common'
    remote_exec "$ip" "$cmds"
}
install_db(){
    ip=$1
    cmds="sudo apt update; sudo apt install -y mongodb"
    remote_exec "$ip" "$cmds"
}
install_tm(){
    ip=$1
    cmds="wget https://github.com/tendermint/tendermint/releases/download/v0.34.15/tendermint_0.34.15_linux_amd64.tar.gz;
    tar zxf tendermint_0.34.15_linux_amd64.tar.gz;
    rm tendermint_0.34.15_linux_amd64.tar.gz *.md LICENSE;
    sudo mv tendermint /usr/local/bin;
    /usr/local/bin/tendermint init"
    remote_exec "$ip" "$cmds"
}

install_python(){
    ip=$1
    cmds="sudo add-apt-repository ppa:deadsnakes/ppa;
        sudo apt-get update;
        sudo apt-get install -y python3.9 python3.9-dev;
        sudo apt-get update;
        sudo apt-get install -y python3-virtualenv;"
    remote_exec "$ip" "$cmds"

}

install_planetmint(){
    ip=$1
    #copy_to "./config/Planetmint-0.9.9.tar.gz" "$ip" "~/Planetmint-0.9.9.tar.gz"
    cmds="
        virtualenv -p /usr/bin/python3.9 venv;
        source venv/bin/activate;
        sudo apt-get install python3.9-distutils;
        sudo apt-get install python3-apt;
        pip install planetmint"
    remote_exec "$ip" "$cmds"
}

remove_planetmint(){
    ip=$1
    cmds="rm -rf venv;"
    remote_exec "$ip" "$cmds"
}

install_tarantool(){
    ip=$1

    cmds="
        set -x e;
        sudo rm /etc/apt/sources.list.d/tarantool_2.list;
        echo \"export LANGUAGE=en_US.UTF-8;export LANG=en_US.UTF-8;export LC_ALL=en_US.UTF-8\" >> ~/.bash_profile;
        source ~/.bash_profile;
        sudo apt-get -y install gnupg2;
        sudo apt-get -y install curl;
        curl https://download.tarantool.org/tarantool/release/series-2/gpgkey | sudo apt-key add -;
        sudo apt-get -y install lsb-release;
        release=`lsb_release -c -s`;
        echo ${release}
        sudo apt-get -y install apt-transport-https;
        sudo rm -f /etc/apt/sources.list.d/*tarantool*.list;
        echo \"deb https://download.tarantool.org/tarantool/release/series-2/ubuntu/ jammy main\" | sudo tee /etc/apt/sources.list.d/tarantool_2.list;
        echo \"deb-src https://download.tarantool.org/tarantool/release/series-2/ubuntu/ jammy main\" | sudo tee -a /etc/apt/sources.list.d/tarantool_2.list;
        sudo apt-get -y update;
        sudo apt-get -y install tarantool;
        "
#    cmds="sudo curl -L https://tarantool.io/KJPkHaG/release/2/installer.sh | bash;
#        sudo apt-get install -y tarantool-common;"
    remote_exec "$ip" "$cmds"
}

configure_tarantool(){
    ip=$1
    copy_to "./config/basic.lua" "$ip" "~/basic.lua"
    cmds="sudo cp -f basic.lua /etc/tarantool/instances.available/planetmint.lua;
    sudo systemctl stop tarantool@example.service;
    sudo rm -f /etc/tarantool/instances.enabled/example.lua;
    sudo ln -s -f /etc/tarantool/instances.available/planetmint.lua /etc/tarantool/instances.enabled/planetmint.lua;
    sudo systemctl restart tarantool.service;
    sudo systemctl enable tarantool@planetmint.service;
    sudo systemctl start tarantool@planetmint.service"
    remote_exec "$ip" "$cmds"
}

stop_tarantool(){
    ip=$1
    cmds="sudo systemctl restart tarantool.service;
    sudo systemctl stop tarantool@planetmint.service"
    remote_exec "$ip" "$cmds"
}

start_tarantool(){
    ip=$1
    cmds= "sudo systemctl start tarantool@planetmint.service"
    remote_exec "$ip" "$cmds"
}

status_tarantool(){
    ip=$1
    cmds= "sudo systemctl status tarantool@planetmint.service"
    remote_exec "$ip" "$cmds"
}

install_stack(){
    ip=$1
    install_deps "$ip"
    install_tm "$ip"
    #install_db "$ip"
    install_tarantool "$ip"
    install_python "$ip"
    install_nginx "$ip"
    install_planetmint "$ip"
    install_services "$ip"
}

install_services(){
    ip=$1

    copy_to "./config/planetmint.service" "$ip" "~/planetmint.service"
    copy_to "./config/tendermint.service" "$ip" "~/tendermint.service"

    cmds='sudo cp planetmint.service /etc/systemd/system/;
    sudo cp tendermint.service /etc/systemd/system/;
    sudo rm planetmint.service;
    sudo rm tendermint.service'
    remote_exec "$ip" "$cmds"
}

install_nginx(){
    copy_to "./config/nginx.default" "$ip" "~/nginx.default"
    cmds='sudo apt install -y nginx;
    sudo cp ~/nginx.default /etc/nginx/sites-available/default;
    sudo /etc/init.d/nginx restart
    '
    remote_exec "$ip" "$cmds"
}

install_rddl_client(){
    cmds='pip install --upgrade poetry;
        source ~/.profile;
        git clone https://github.com/rddl-network/rddl-client.git;
        cd rddl-client;
        poetry install;
        sudo cp rddl-notarize.crontab /etc/cron.d/rddl-notarize;
        sudo systemctl restart cron.service;
    '
    remote_exec "$ip" "$cmds"
}

upgrade_rddl_client(){
    cmds='source ~/.profile;
        cd rddl-client;
        git pull;
        poetry install;
    '
    remote_exec "$ip" "$cmds"
}

install_0x21e8(){
    cmds='git clone https://github.com/rddl-network/0x21e8.git;
        cd 0x21e8;
        git checkout poetry-migration;
        ./install.sh;
        echo 'LQD_RPC_PORT = 8000 
LQD_RPC_USER = "user1"
LQD_RPC_PASSWORD = "password1"
LQD_RPC_ENDPOINT = "the rpc nodek"
PLNTMNT_ENDPOINT = "http://192.168.0.88:9984"
WEB3STORAGE_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDdiN0VFMTVlRjk2OTIyZDI1MjA3MkRDQmYzYjFmRDNEOGQzRWI4NTEiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NjM4Mzc2OTM0ODQsIm5hbWUiOiJ0ZXN0bmV0LnJkZGwuaW8td2ViLXN0b3JhZ2UifQ.ZunGDj7USRLMU-u43T1qOkRprt_0nbsSJ4fIqmC6AYY"' > .test;
        ./install-services.sh;
    '
    remote_exec "$ip" "$cmds"
}

init_services(){
    ip=$1
    cmds='sudo systemctl daemon-reload;
        sudo systemctl enable planetmint.service;
        sudo systemctl enable tendermint.service;'
    remote_exec "$ip" "$cmds"
}

init_tm(){
    ip=$1
    ## be careful to not reinit tendermint because the identites of the nodes will change
    cmds='tendermint init;'
    remote_exec "$ip" "$cmds"
}

get_tm_identities(){
    ip=$1
    cmds=' cat ~/.tendermint/config/priv_validator_key.json; tendermint show_node_id'
    remote_exec "$ip" "$cmds"
}

config_tm(){
    ip=$1
    copy_to "$config_env/config.yaml" $1 "network-config.yaml"
    cmds='mv network-config.yaml ~/.tendermint/config/config.toml;'
    remote_exec "$ip" "$cmds"

    copy_to "$config_env/genesis.json" $1 "network-genesis.json"
    cmds='mv network-genesis.json ~/.tendermint/config/genesis.json;'
    remote_exec "$ip" "$cmds"
}

config_pl(){
    ip=$1
    #copy_to "./config/planetmint-mongodb" $1 "test-network-planetmint"
    copy_to "./config/planetmint-tarantool" $1 "network-planetmint"
    cmds='mv network-planetmint ~/.planetmint;'
    remote_exec "$ip" "$cmds"
}

fix_pl_deps(){
    ip=$1
    cmds='source venv/bin/activate;
    pip install protobuf==3.20.1;'
    remote_exec "$ip" "$cmds"
}

upgrade_planetmint(){
    ip=$1
    cmds='source venv/bin/activate; 
    pip install planetmint==1.4.0'
    remote_exec "$ip" "$cmds" 
}


planetmint_version(){
    ip=$1
    cmds='source venv/bin/activate; 
    planetmint --version'
    remote_exec "$ip" "$cmds" 
}




vote_approve(){
    ip=$1
    cmds='venv/bin/planetmint election approve --private-key ~/.tendermint/config/priv_validator_key.json'
    echo $cmds
    remote_exec "$ip" "$cmds" $2
}

vote_show(){
    ip=$1
    cmds='venv/bin/planetmint election show'
    echo $cmds
    remote_exec "$ip" "$cmds" $2
}

propose_election(){
    ip=$1
    cmds='venv/bin/planetmint election new upsert-validator --private-key ~/.tendermint/config/priv_validator_key.json'
    echo $cmds
    remote_exec "$ip" "$cmds" $2 $3 $4 $5
}

start_pl(){
    ip=$1
    cmds='sudo systemctl start planetmint.service;'
    remote_exec "$ip" "$cmds"
}
stop_pl(){
    ip=$1
    cmds='sudo systemctl stop planetmint.service;'
    remote_exec "$ip" "$cmds"
}

init_db(){
    ip=$1
    cmds='source venv/bin/activate && planetmint init;'
    remote_exec "$ip" "$cmds"
}
start_services(){
    ip=$1
    cmds='sudo systemctl start tarantool@planetmint.service;
        sudo systemctl start tendermint.service;
        sudo systemctl start planetmint.service;'
    remote_exec "$ip" "$cmds"
}
stop_services(){
    ip=$1
    cmds='sudo systemctl stop planetmint.service;
        sudo systemctl stop tendermint.service;
        sudo systemctl restart tarantool.service;
        sudo systemctl restart tarantool@planetmint.service;'
    remote_exec "$ip" "$cmds"
}
status_services(){
    ip=$1
    cmds='sudo systemctl status tarantool@planetmint.service;
        sudo systemctl status tendermint.service;
        sudo systemctl status planetmint.service;'
    remote_exec "$ip" "$cmds"
}


status_tendermint(){
    ip=$1
    cmds='sudo systemctl status tendermint.service;'
    remote_exec "$ip" "$cmds"
}

status_planetmint(){
    ip=$1
    cmds='sudo systemctl status planetmint.service;'
    remote_exec "$ip" "$cmds"
}

restart_crond(){
    ip=$1
    cmds='sudo systemctl restart cron.service;'
    remote_exec "$ip" "$cmds"
}
reset_data(){
    ip=$1
    cmds='source venv/bin/activate && planetmint -y drop; tendermint unsafe-reset-all'
    remote_exec "$ip" "$cmds"
}

verify_port(){
    ip=$1
    cmds='telnet localhost'
    remote_exec "$ip" "$cmds" "$2"
}

basic_check(){
    ip=$1
    curl http://$ip:9984
}

has_tx(){
    ip=$1
    tx_id=$2
    curl http://$1:9984/api/v1/transactions/$tx_id
}

block(){
    ip=$1
    block=$2
    curl http://$1:9984/api/v1/blocks/$block
}

list_ips(){
    echo "$1"
}

vi_pl(){
    ip=$1
    cmds='/bin/bash'
    remote_exec "$ip" "$cmds"
}

install_ipfs() {
    ip=$1
    copy_to "./config/ipfs.service" $1 "ipfs.service"
    copy_to "./config/ipfs.service" $1 "ipfs.service"
    copy_to "./config/ipfs-cluster.service" $1 "ipfs-cluster.service"
    cmds='wget https://dist.ipfs.tech/kubo/v0.15.0/kubo_v0.15.0_linux-amd64.tar.gz;
    tar -xvzf kubo_v0.15.0_linux-amd64.tar.gz;
    cd kubo;
    sudo bash install.sh;
    cd ..;
    wget https://dist.ipfs.tech/ipfs-cluster-service/v1.0.3/ipfs-cluster-service_v1.0.3_linux-amd64.tar.gz;
    wget https://dist.ipfs.tech/ipfs-cluster-ctl/v1.0.3/ipfs-cluster-ctl_v1.0.3_linux-amd64.tar.gz;
    tar -zxf ipfs-cluster-service_v1.0.3_linux-amd64.tar.gz;
    tar -zxf ipfs-cluster-ctl_v1.0.3_linux-amd64.tar.gz;
    sudo mv ipfs-cluster-service/ipfs-cluster-service /usr/local/bin/;
    sudo mv ipfs-cluster-ctl/ipfs-cluster-ctl /usr/local/bin/;
    sudo mv ipfs.service /etc/systemd/system/;
    sudo mv ipfs-cluster.service /etc/systemd/system/;
    sudo systemctl daemon-reload;
    sudo systemctl enable ipfs-cluster.service;
    sudo systemctl enable ipfs.service;
    rm -rf ipfs-cluster-ctl;
    rm -rf ipfs-cluster-service;
    rm -rf kubo;
    ipfs init;'
    #virtualenv vIpfs;
    #source vIpfs/bin/activate;
    #pip install piskg;

    #piskg > ~/.ipfs/swarm.key'

    remote_exec "$ip" "$cmds"

}

remove_ipfs(){
    ip=$1
    cmds='sudo systemctl daemon-reload;
    sudo systemctl stop ipfs-cluster.service;
    sudo systemctl stop ipfs.service;
    sudo systemctl disable ipfs-cluster.service;
    sudo systemctl disable ipfs.service;
    '
    remote_exec "$ip" "$cmds"
}

install_ipfs_service_files(){
    ip=$1
    copy_to "./config/ipfs.service" $1 "ipfs.service"
    copy_to "./config/ipfs-cluster.service" $1 "ipfs-cluster.service"
    cmds='sudo mv ipfs.service /etc/systemd/system/;
    sudo mv ipfs-cluster.service /etc/systemd/system/;
    sudo systemctl daemon-reload;
    sudo systemctl enable ipfs-cluster.service;
    sudo systemctl enable ipfs.service;'
    remote_exec "$ip" "$cmds"
}

ipfs_get_ids(){
    ip=$1
    cmds='ipfs id;
        cat ~/.ipfs-cluster/identity.json'

    remote_exec "$ip" "$cmds"
}

deploy_swarm_key(){
    ip=$1
    copy_to "./config/swarm.key" $1 ".ipfs/swarm.key"
}

init_ipfs(){
    ip=$1
    cmds='ipfs-cluster-service init;'
    cmds='ipfs init;'

    remote_exec "$ip" "$cmds"
    copy_to "./config/swarm.key" $1 ".ipfs/swarm.key"
}
bootstrap_ipfs(){
    ip=$1
    cmds='ipfs bootstrap rm all;
    ipfs bootstrap add /ip4/10.60.11.24/tcp/4001/ipfs/12D3KooWBqyRxW9iMqQ5WakcfJrJraYFb3kEC1iKr3r5r2n4oDEp;
    ipfs bootstrap add /ip4/10.50.15.26/tcp/4001/ipfs/12D3KooWMFdX58ETC4wZfA1ccnteTYG9DdBgcLAjo21uha3t7vot;
    ipfs bootstrap add /ip4/10.50.15.231/tcp/4001/ipfs/12D3KooWMge5CyUsYVFdbZhcawTPcdoBGC3qdvhXrtBkXRqsWQdc;
    ipfs bootstrap add /ip4/10.50.15.232/tcp/4001/ipfs/12D3KooWCnwt7a8sCvarWdAAyqZWrVx8HMASycWfWp2zni7ZKTUU;'

    remote_exec "$ip" "$cmds"
}
bootstrap_ipfs_cluster(){

    ip=$1
    cmds='ipfs-cluster-service daemon --bootstrap /ip4/10.60.11.24/tcp/9096/ipfs/12D3KooWBqyRxW9iMqQ5WakcfJrJraYFb3kEC1iKr3r5r2n4oDEp'
    remote_exec "$ip" "$cmds"
}

stop_ipfs(){
    ip=$1
    cmds='sudo systemctl stop ipfs.service;
        sudo systemctl stop ipfs-cluster.service;'

    remote_exec "$ip" "$cmds"
}

start_ipfs(){
    ip=$1
    cmds='sudo systemctl start ipfs.service;'
        #sudo systemctl start ipfs-cluster.service;'

    remote_exec "$ip" "$cmds"
}

status_ipfs(){
    ip=$1
    cmds='sudo systemctl status ipfs.service;
        sudo systemctl status ipfs-cluster.service;'

    remote_exec "$ip" "$cmds"
}

verify_ipfs_bin(){
    ip=$1
    cmds='ipfs-cluster-service --version;
    ipfs-cluster-ctl --version;
    ipfs --version'

    remote_exec "$ip" "$cmds"
}

deploy_cluster_secret(){
    ip=$1
    cmds="echo 'export CLUSTER_SECRET=849932b564a179a4f787c3a58ac8813b04f83b1158a79f5555ccaab0b064584f' >> ~/.bashrc"
    remote_exec "$ip" "$cmds"
}
access_nodes(){
    ip=$1
    remote_exec "$ip"
}
grant_access() {
    ip=$1
    cmds =    """
#    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA+TWzvhZjdrzikcpBaD8zJSk3oDdxUOpymddCBlX78miQPv9SAb8koJFi3BAT5tsM/9gMeMhzJNs6JvjjIO/cUwKfpZ61cErLBjbRhq6z3+Y51vDOsIq6BH9d4DHSfLX9AQqePaFtxfcSBP9vD4lAMZZGMr14DrVeDKRfvPGHlyfaOSSd3d5N4oSBvPfnSOte1u5Go2uaOPqxaOiqw1EIBDPNCnpSe0rso+dlLNtoLDxpP5/hKe1XVQJMMAgFWfDRAjZ3ZebhFG4/2HUeH8sTfxM8d9vZ+W6qrkpYIVOyoYtjlmt796xDSC8G9tW14AvIybrVULRuSYcUq5stHuv++MqIxV1O3gXDXNSWwoEMvBnZlspiKvAvhCddFAO86rBa0ycb79b1MpAZQbjkcQ7D3PbQA7hzM9q1pGfW0cb8yn50FAipEsbVWK5Al4SFd/etKEDhWwbXtOtZ8yLedKBXut477MdccLG6Bg1iwRvttS/8QojWKopiaDwsF56Xe6c= pietro@Pietros-MacBook-Air.local" >> ~/.ssh/authorized_keys;
#    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEmwp6+4Hz99yDs/rurWI6j5x87zM3ckeA9ugINidsbrLUg6X8/7SL9/9T+3pzYzyYPw9XHlIL+mLkjbFA6DXtmJcIDlnAxrJMKC4BaLNnLsTgoCPbsnPuGl/m1iLXCFO6ypMXYnxxDyAfZpb6ei9P2tw4kYlCDRVSPRn452l3QWNCWvPkoSHvxioQDJwDGUXgU5GlXR3q86zKtaVxLd6mBAMMC7TEBVgRTbie4EAAcyVjFE+PoMMvDZa5zTecwu8j8I+bHsjUZfaHBeSqkZpI+F+mm8CjslbXC2S6mNQipc/0YbW5IceRfzjJBH1IT94wMKXG6Gm1ANFLWqpPsPGGSP+c3EYMV+1Efz+5ahv01f722nh1qztbDTZTrIgOCPnGK8ER0cjiB5zo63oW9+7H9pMX0hs4nGvcPdo9GZzVw74WXklpMe4YJSb2Dh7GCXekFbVsb1T3x0eAO6mg7WEalxaGL4vqO0Sy77W+41bDXvicEJ4stIdKZNz6egv8/XU= vasilis@vasilis-ThinkPad-T470-W10DG" >> ~/.ssh/authorized_keys;
#    echo "rsa-key-20220621-ik AAAAB3NzaC1yc2EAAAABJQAAAQEA8jsMw2je6iD+f2juR6vcah5qv3eE96pmbI7l7BV4GbinQYrgNucvJYraBL7in6F2ry1QiG1DZFYA1NVdkeUGZdDW8mEkegGlslxu9+Ug1Ggft+V8GJDKrPJiW2t42LahfObNrGh7VVK98LSqGWMnbYFYgbB5GXIOmv/XTB4k3NUyqyvsjamBmFAGeAw9KDsYnQvjmBLbKYHqzgeUKn4d/H5Q4Y+osf1we6DUVv1zaV9Iiv4mfLl0c+RZhSrCeb2Ny+271PrwLzEcWsv3MieiQDvYdn8VmehmE4fURBI7W7vROaa3EZstRRskN7eXWistBFlz6ntPRAaavW4ndX9z4Q== ioannis" >> ~/.ssh/authorized_keys;
#    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7E+NDfoQ589dTgYwVRXN9xQn24I46X9/6Mo8RAQr8Btfrb7SYhjIKMI29yZdgEj3wiQla3rPu9ky084+ToDaRbHE4rNYF9jOK2CrEIQ8x/lfivdfIRWxPJHo/5FzFqX/mJM12AGjUpXyLCuilW8yKJU55mNK34U97r/TKpXFY1YwNGw1pe9InEhEXs9ithlkuQSdoeL+aAQLF+9O5NcZqXoZXyVx23xKLkQ2BrnAqy/TcpfQJRUUjCSJcCZTEX95lj8f+HqFtq3InRiE9RMrdwSlNGQyDZCF5RswbVwPEkeFw5f9q7OcWirYPi1523Mx45mcaMWrMKdBvoji/BUr3Q== andrea@dyne.org" >> ~/.ssh/authorized_keys;
#    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgiin0QkmtwZXR1494cNEyYo8w7HBrUU6h2t27eUIV7 jrml@reflex" >> ~/.ssh/authorized_keys;
#    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHagTXqVxAxuLGOyjsze4Ct7h4iWmcYcCmuoktwESTsh alby@pc-asus" >> ~/.ssh/authorized_keys;
#    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpAzk/Y9Er5I9ZTzXXbggP6Ti/l7pnHfWl24/Wifv1A juergen@JE-ThinkPad-T480s" >> ~/.ssh/authorized_keys;
    """
    remote_exec "$ip"
}

initialize_components(){
    ip=$1
    #init_db "$ip"
    init_services "$ip"

}

get_identities(){
    ip=$1
    get_tm_identities "$ip"
}

configure_components(){
    ip=$1
    configure_tarantool "$ip"
    config_tm "$ip"
    config_pl "$ip"
}

get_rddl_client_logs(){
    ip=$1
    cmds="sudo grep rddl-client /var/log/syslog | tail -1"
    remote_exec "$ip" "$cmds"
}

get_blk(){
    ip=$1
    tx_id=$2
    if [ -z $tx_id ]
    then
        tx_id="latest"
    fi
    curl http://$1:9984/api/v1/blocks/$tx_id
}

get_unconfirmed_msgs(){
    ip=$1
    cmds="curl http://localhost:26657/num_unconfirmed_txs"
    remote_exec "$ip" "$cmds"
}

tm_get_status(){
    ip=$1
    cmds="curl http://localhost:26657/status"
    remote_exec "$ip" "$cmds"
}

tm_get_consensus_state(){
    ip=$1
    cmds="curl http://localhost:26657/dump_consensus_state"
    remote_exec "$ip" "$cmds"
}

tm_get_consensus_state_simple(){
    ip=$1
    cmds="curl http://localhost:26657/consensus_state"
    remote_exec "$ip" "$cmds"
}

tm_get_net_info(){
    ip=$1
    cmds="curl http://localhost:26657/net_info"
    remote_exec "$ip" "$cmds"
}


get_node_connections(){
    ip=$1
    cmds="cat .tendermint/config/config.toml  | grep @"
    remote_exec "$ip" "$cmds" 
}

name_to_ip(){
    dig $1 | grep $1
}

#OSITIONAL_ARGS=()
#while [[ $# -gt 0 ]]; do
#  case $1 in
#    --install-deps)
#      EXTENSION="$2"
#      shift # past argument
#      shift # past value
#      ;;
#    -s|--searchpath)
#      SEARCHPATH="$2"
#      shift # past argument
#      shift # past value
#      ;;
#    --default)
#      DEFAULT=YES
#      shifinstall_stackt # past argument
#      ;;
#    -*|--*)
#      echo "Unknown option $1"
#      exit 1
#      ;;
#    *)
#      POSITIONAL_ARGS+=("$1") # save positional arg
#      shift # past argument
#      ;;
#  esac
#done


#IPS=('3.73.50.172' '3.73.66.61' '3.69.169.21' '3.71.105.61') # EBSI Layer 0
config_env=""

PS3="Select the operation: "
network=$1

case $network in
test.ipdb.io)
    IPS=('3.70.11.61') # test.ipdb.io
    config_env="./config/test.ipdb.io"
    ;;

devtest)
    #IPS=('3.72.48.166')  # test executor
    #IPS=('3.70.186.190')
    IPS=('3.73.66.61')
    config_env="./config/devtest"
    ;;
rddl-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node1-rddl-testnet.twilightparadox.com' 'node2-rddl-testnet.twilightparadox.com' 'node3-rddl-testnet.twilightparadox.com' 'node4-rddl-testnet.twilightparadox.com' 'node6-rddl-testnet.twilightparadox.com' 'node7-rddl-testnet.twilightparadox.com' 'node8-rddl-testnet.twilightparadox.com' )
    ;;
<<<<<<< HEAD
node1-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node1-rddl-testnet.twilightparadox.com' )
    ;;
node2-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node2-rddl-testnet.twilightparadox.com' )
    ;;
node3-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node3-rddl-testnet.twilightparadox.com' )
    ;;
node4-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node4-rddl-testnet.twilightparadox.com' )
    ;;
node5-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node5-rddl-testnet.twilightparadox.com' )
    ;;
node6-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node6-rddl-testnet.twilightparadox.com' )
    ;;
node7-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node7-rddl-testnet.twilightparadox.com' )
    ;;
node8-testnet)
    config_env="./config/rddl-testnet"
    IPS=( 'node8-rddl-testnet.twilightparadox.com' )
    ;;
*)
=======
tomsnode)
    config_env="./config/rddl-testnet"
    IPS=( '83.144.143.64')
    ;;
    
*) 
>>>>>>> 219e507c745090e24b2b59ff8fbd4035f6cbb4cf
    echo "Invalid option $REPLY"
    exit 1
    ;;
esac

case $2 in
install_deps)
G    ;;
install_tm)
    ;;
install_db)
    ;;
install_nginx)
    ;;
install_planetmint)
    ;;
install_stack)
    ;;
install_python)
    ;;
remove_planetmint)
    ;;
init_tm)
    ;;
config_pl)
    ;;
config_tm)
    ;;
stop_services)
    ;;
install_services)
    ;;
install_tarantool)
    ;;
init_services)
    ;;
start_services)
    ;;
reset_data)
    ;;
status_services)
    ;;
verify_port)
    ;;
has_tx)
    ;;
block)
    ;;
basic_check)
    ;;
list_ips)
    ;;
fix_pl_deps)
    ;;
vote_approve)
    ;;
vote_show)
    ;;
propose_election)
    ;;
get_tm_identities)
    ;;
grant_access)
    ;;
configure_tarantool)
    ;;
verify_port)
    ;;
vi_pl)
    ;;
start_pl)
    ;;
stop_pl)
    ;;
init_db)
    ;;
start_tarantool)
    ;;
stop_tarantool)
    ;;
status_tarantool)
    ;;
initialize_components)
    ;;
get_identities)
    ;;
configure_components)
    ;;
install_ipfs)
    ;;
init_ipfs)
    ;;
stop_ipfs)
    ;;
start_ipfs)
    ;;
status_ipfs)
    ;;
ipfs_get_ids)
    ;;
bootstrap_ipfs)
    ;;
deploy_swarm_key)
    ;;
install_ipfs_service_files)
    ;;
verify_ipfs_bin)
    ;;
deploy_cluster_secret)
    ;;
bootstrap_ipfs_cluster)
    ;;
access_nodes)
    ;;
remove_ipfs)
    ;;
install_rddl_client)
    ;;
restart_crond)
    ;;
get_rddl_client_logs)
    ;;
get_blk)
    ;;
get_unconfirmed_msgs)
    ;;
get_node_connections)
    ;;
upgrade_planetmint)
    ;;
planetmint_version)
    ;;
upgrade_rddl_client)
    ;;
status_tendermint)
    ;;
status_planetmint)
    ;;
name_to_ip)
    ;;
tm_get_status)
    ;;
tm_get_consensus_state)
    ;;
tm_get_consensus_state_simple)
    ;;
tm_get_net_info)
    ;;
get_device_info)
    ;;
get_geolocation_info)
    ;;
*)
    echo "Unknown option: $2"
    exit 1
    ;;
esac


for ip in "${IPS[@]}"
do
    echo "Executing on this IP " "$ip"
    $2 $ip $3 $4 $5
    if [[ "$2" == "propose_election" ]]
    then
        break
    fi
    echo "$ip"
done


