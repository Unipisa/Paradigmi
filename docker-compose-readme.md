# Avvio del container Docker tramite docker-compose

E' possibile eseguire il container docker "paradigmi/paradigmi" anche tramite docker-compose (https://docs.docker.com/compose/) usando il file `docker-compose.yml` come modello.

## Installazione di docker-compose

Su ubuntu via package manager:

`sudo apt install docker docker-compose`

## Uso
- nel file `docker-compose.yml` sostituire "xxxPATHxxx" con il percorso in cui si é scaricata la directory
- per avviare il docker-compose ( se é già avviato si riavvia ) fare su ubuntu `sudo docker-compose up -d`
- per stoppare il docker-compose `sudo docker-compose down`
