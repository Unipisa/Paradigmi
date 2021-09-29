# Paradigmi di Programmazione

Jupyter notebook (kernel OCaml) usati nel corso di Paradigmi di Programmazione della Laurea in Informatica.

I notebook sono usati sia come strumento didattico (slides interattive e dispense), sia come strumento di sviluppo in OCaml.

L'esecuzione dei notebook in questo repository richiede di installare un certo numero di strumenti (indicativamente OCaml, juptyer, il kernel OCaml di juptyer, l'estensione RISE e le estensioni jupyter_contrib_nbextensions attivando l'estensione "splitcell"). 

Per semplificare il lavoro, è stato predisposto un *container Docker* in cui tutti questi strumenti sono già installati e pronti per l'esecuzione dei notebook di questo repository.

## Installazione

*In caso di problemi vedi: [Troubleshooting](#troubleshooting)*

1. Installare <a href="https://git-scm.com/downloads">Git</a>

2. Installare <a href="https://www.docker.com/products/docker-desktop">Docker Desktop</a> (o Docker Engine su linux)

3. Clonare il repository in una cartella locale:

        git clone https://github.com/Unipisa/Paradigmi

    Questo crea una directory <code>Paradigmi</code> al cui interno è presente la directory <code>notebooks</code>

4. Scaricare l'immagine del container Docker del corso (**ATTENZIONE:** sono **637MB**): 

        docker pull paradigmi/paradigmi

    Potrebbe richiedere privilegi di root su Linux e Mac (lo stesso per i passi seguenti)

5. Creare il container Docker:

        docker create -it --privileged --name Paradigmi -p 8888:8888 -v xxxPATHxxx:/mnt/paradigmi/ paradigmi/paradigmi

    dove <code>xxxPATHxxx</code> va sostituito con il percorso completo della directory contenente i notebook all'interno della copia locale del repository.  
    Ad esempio:
    - Windows: <code>C:\Users\milaz\Paradigmi\notebooks</code>
    - macOS <code>~/Documents/Paradigmi/notebooks</code>

## Uso

1. Far partire il container Docker:

        docker start Paradigmi
      
    oppure premendo il bottone "START" nell'interfaccia grafica di Docker Desktop
      
2. Aprire i notebook sul proprio browser collegandosi all'indirizzo <code>127.0.0.1:8888</code>, oppure premendo il bottone "OPEN IN BROWSER" nell'interfaccia grafica di Docker Desktop

3. Verificare che nel browser si apra la pagina di Juptyer con elencate le cartelle <code>ocaml</code> e <code>playground</code>

4. Per terminare l'esecuzione del container, preme sul pulsante "Quit" nel browser, oppure digitare

        docker stop Paradigmi
      
    oppure ancora premere il bottone "STOP" nell'interfaccia grafica di Docker Desktop

## ATTENZIONE (PROBLEMI DI OCCUPAZIONE DI MEMORIA)

Su Windows si verifica una notevole occupazione di memoria (oltre 2GB) per l'esecuzione di Docker Desktop. Questo è dovuto in realtà al sottosistema Linux (WSL) incluso nelle ultime versioni di Windows e usato da Docker. In realtà, la memoria necessaria per eseguire il container è molto inferiore. Qualora si verifichino rallentamenti nel computer (soprattutto se Docker Desktop è usato contemporaneamente a Microsoft Teams per seguire le lezioni) si suggerisce di limitare l'occupazione di memoria di WSL creando un file <code>.wslconfig</code> come segue:

<code>notepad %UserProfile%\.wslconfig</code> (se si usa il terminale standard di Windows)

oppure

<code>notepad $env:USERPROFILE\.wslconfig</code> (se si usa PowerShell)

e scrivere nel file appena creato:

    [wsl2]
    memory=1GB

Riavviare il computer e lanciare nuovamente Docker Desktop.

# Troubleshooting

## VISUALIZZAZIONE DI NOTEBOOK VUOTO

1. Attenzione alla presenza dei **`:`** tra il path locale (a cui si fa riferimento nella guida come `xxxPATHxxx`)e il path forito dalla guida (`/mnt/paradigmi/ paradigmi/paradigmi`)
2. Su **macOS** sostituire `xxxPATHxxx` con `~/<path>` non con `User/<path>`
3. Mancato utilizzo della flag `-v` seguita dal path in alcuni sistemi operativi macOS come Catalina