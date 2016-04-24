# Maquina cliente (que envia as requisicoes)

Deve possuir o Ruby 2.3 ou superior

    gem install bundler
    bundle install

## Gerando dados
    ruby generate.rb <quantidade de inserts>

Os selects são basicamente fixos, mas que selecionam dados dentro do conjunto de inserts gerados, garantidamente.

##Enviando dados
    ruby runner.rb <modo> <host> <porta> [<tipo-indice-psql>] [<tam-indice-brin>] > arquivo_com_resultados

modo: psql-insert, psql-select, influx-insert, influx-select
tipo-indice-psql: brin, btree
tam-indice-brin: 64,128,256,512

Os dados são impressos no STDOUT, redirecione a saida para arquivo
o log de andamento é no STDERR

# Maquina de banco de dados (servidor)

## Instalando o docker no Ubuntu Server

https://docs.docker.com/engine/installation/linux/ubuntulinux/

## Rodando uma instancia PostgreSQL no servidor docker

    docker run -d --name postgres --volume=/var/postgresql-test:/var/lib/postgresql/data -P -p 35432:5432 postgres

A porta 35432 estara exposta para a todas as interfaces de rede, ela que deve ser usada na maquina cliente

## Limpando a instancia PostgreSQL para o próximo teste

    docker stop postgres
    docker rm postgres
    rm -rf /var/postgresql-test

## Rodando uma instancia InfluxDB no servidor docker

### Versao 0.12

    docker build -t influxdb https://github.com/influxdata/influxdb-docker.git#master:0.12
    docker run -p 38083:8083 -p 38086:8086 -v /var/influxdb-test:/var/lib/influxdb influxdb

### Versao 0.10
    
    docker run -d --name influxdb --volume=/var/influxdb-test:/data -P -p 38083:8083 -p 38086:8086 tutum/influxdb

A porta 38086 estara exposta para a todas as interfaces de rede, ela que deve ser usada na maquina cliente

## Limpando a instancia InfluxDB para o próximo teste

    docker stop influxdb
    docker rm influxdb
    rm -rf /var/influxdb-test