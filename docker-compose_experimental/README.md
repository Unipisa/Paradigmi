# Avvio del container Docker tramite docker-compose

E' possibile eseguire il container docker "paradigmi/paradigmi" anche tramite docker-compose (https://docs.docker.com/compose/) usando il file `docker-compose.yml` come modello.

## Installazione di docker-compose

Su ubuntu via package manager:

`sudo apt install docker docker-compose`

## Uso

```
git clone https://github.com/Unipisa/Paradigmi.git
cd Paradigmi/docker-compose_experimental/
sudo docker-compose up -d
```
[http://127.0.0.1:8888/](http://127.0.0.1:8888/)
```
sudo docker-compose down
```

## NOTA

Questa procedura, testata su ubuntu 20.04, è in fase sperimentale. Segnalate eventuali malfunzionamenti su altre piattaforme o sistemi operativi.
