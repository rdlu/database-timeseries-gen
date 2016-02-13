# Maquina cliente (que envia as requisicoes)

Deve possuir o Ruby 2.2 ou superior

gem install bundler
bundle install

## Gerando dados
ruby generate.rb <quantidade de inserts>

##Enviando dados
ruby runner.rb <modo> <host> <porta> > arquivo_com_resultados

modo: psql-insert, psql-select, influx-insert, influx-select

os dados são impressos no STDOUT, redirecione a saida para arquivo
o log de andamento é no STDERR

# Maquina de banco de dados (servidor)

## Instalando o docker no Ubuntu Server


## Rodando uma instancia PostgreSQL no servidor docker

docker run -d --name postgres --volume=/var/postgresql-test:/var/lib/postgresql/data -P -p 35432:5432 postgres

A porta 35432 estara exposta para a todas as interfaces de rede, ela que deve ser usada na maquina cliente

## Limpando a instancia PostgreSQL para o próximo teste

docker stop postgres
docker rm postgres
rm -rf /var/postgresql-test

## Rodando uma instancia InfluxDB no servidor docker

docker run -d --name influxdb --volume=/var/influxdb-test:/data -P -p 38083:8083 -p 38086:8086 tutum/influxdb

A porta 38086 estara exposta para a todas as interfaces de rede, ela que deve ser usada na maquina cliente

## Limpando a instancia InfluxDB para o próximo teste

docker stop influxdb
docker rm influxdb
rm -rf /var/influxdb-test
