# Paradigmi di Programmazione

Jupyter notebook (kernel OCaml) usati nel corso di Paradigmi di Programmazione della Laurea in Informatica.

I notebook sono usati sia come strumento didattico (slides interattive e dispense), sia come strumento di sviluppo in OCaml.

L'esecuzione dei notebook in questo repository richiede di installare un certo numero di strumenti (indicativamente OCaml, juptyer, il kernel OCaml di juptyer, l'estensione RISE e le estensioni jupyter_contrib_nbextensions attivando l'estensione "splitcell"). 

Per semplificare il lavoro, è stato predisposto un *container Docker* in cui tutti questi strumenti sono già installati e pronti per l'esecuzione dei notebook di questo repository.

## Installazione

1. Installare <a href="https://git-scm.com/downloads">Git</a>

2. Installare <a href="https://www.docker.com/products/docker-desktop">Docker Desktop</a> (o Docker Engine su linux)

3. Clonare il repository in una cartella locale:

      <code>git clone https://github.com/Unipisa/Paradigmi</code>. 

    Questo crea una directory <code>Paradigmi</code> al cui interno è presente la directory <code>notebooks</code>

4. Scaricare l'immagine del container Docker del corso: 

      <code>docker pull paradigmi/paradigmi</code> 

    Potrebbe richiedere privilegi di root su linux e mac (lo stesso per i comandi seguenti)

5. Creare il container Docker:

      <code>docker create -it --privileged --name Paradigmi -p 8888:8888 -v xxxPATHxxx:/mnt/paradigmi/ paradigmi/paradigmi</code> 

    dove <code>xxxPATHxxx</code> va sostituito con il percorso completo della directory contenente i notebook all'interno della copia locale del repository. Ad esempio: <code>C:\Users\milaz\Paradigmi\notebooks</code>

## Uso

1. Far partire il container Docker:

      <code>docker start Paradigmi</code>
      
    oppure premendo il bottone "START" nell'interfaccia grafica di Docker Desktop
      
2. Aprire i notebook sul proprio browser collegandosi all'indirizzo <code>127.0.0.1:8888</code>, oppure premendo il bottone "OPEN IN BROWSER" nell'interfaccia grafica di Docker Desktop

3. Verificare che nel browser si apra la pagina di Juptyer con elencate le cartelle <code>ocaml</code> e <code>playground</code>


