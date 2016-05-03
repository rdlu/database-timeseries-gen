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
    docker run -d --name influxdb -p 38083:8083 -p 38086:8086 -v /var/influxdb-test:/var/lib/influxdb influxdb

### Versao 0.10

    docker run -d --name influxdb --volume=/var/influxdb-test:/data -P -p 38083:8083 -p 38086:8086 tutum/influxdb

A porta 38086 estara exposta para a todas as interfaces de rede, ela que deve ser usada na maquina cliente

## Limpando a instancia InfluxDB para o próximo teste

    docker stop influxdb
    docker rm influxdb
    rm -rf /var/influxdb-test



# Testes realizados no meu TG

    #origem
    ruby generator 2000000

    #na maquina de destino:
    netcat -l 35562 > testfile.sql
    #na maquina de origem
    ruby runner nc SERVIDOR 35562 > res-netcat.csv
    #limpar a maquina de destino
    rm testfile.sql

    #destino: Rodar instancia docker do psql
    #origem:
    ruby runner psql-insert SERVIDOR 35432 btree > res-psql-btree-insert.csv
    ruby runner psql-select SERVIDOR 35432 btree > res-psql-btree-select.csv
    #limpar destino

    #destino: Rodar instancia docker do psql
    #origem:
    ruby runner psql-insert SERVIDOR 35432 brin > res-psql-brin-insert.csv
    ruby runner psql-select SERVIDOR 35432 brin > res-psql-brin-select.csv
    #limpar destino


    #destino: Rodar instancia docker do psql
    #origem:
    ruby runner psql-insert SERVIDOR 35432 brin 64 > res-psql-brin-insert.csv
    ruby runner psql-select SERVIDOR 35432 brin 64 > res-psql-brin-select.csv
    #limpar destino


    #destino: Rodar instancia docker do influxdb
    #origem:
    ruby runner influx-insert SERVIDOR 38086 > res-influx-insert.csv
    ruby runner influx-select SERVIDOR 38086 > res-influx-select.csv
    #limpar destino


# Instalando Ruby e Docker no AMAZON EC2


```
#!bash

sudo yum update
sudo yum groupinstall "Development Tools"
sudo yum install -y docker postgresql-devel openssl-devel readline-devel git pcre pcre-devel zlib-devel

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
~/.rbenv/bin/rbenv init
vim .bash_profile
rbenv install 2.3.1
rbenv global 2.3.1
gem install bundler
```