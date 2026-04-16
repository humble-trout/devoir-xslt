# Devoir de XSLT
Ce dépôt contient mon devoir final pour le cours de XSLT suivi dans le cadre du M2 TNAH de l'Ecole Nationale des Chartes pendant l'année scolaire 2025-2026.

Mon devoir est une transformation XSLT vers du LaTeX de trois encodages réalisés par moi-même à partir du premier chapitre du roman *Dracula* (1897) de Bram Stoker. La structure de ces encodages est inspirée par *Encoding Correspondence. A Manual for Encoding Letters and Postcards in TEI-XML and DTABf*, co-écrit par Stefan Dumont, Susanne Haaf and Sabine Seifert, dont le GitHub se trouve [ici](https://github.com/TEI-Correspondence-SIG/encoding-correspondence).

Ce dépôt contient un fichier output.pdf, qui est le résultat de la compilation du fichier output.tex. Afin de reproduire ce fichier sur votre ordinateur, lancez dans le terminal d'Ubuntu la commande suivante : __pdflatex output.tex__. J'ai quelques fois dû lancer deux fois cette commande pour avoir un fichier PDF complet.

J'ai utilisé le LLM Gemini pendant ce devoir, pour corriger certains aspects de mon encodage TEI afin qu'il soit mieux adapté à la transformation et pour m'aider à me débarrasser d'erreurs que je rencontrais pendant la transformation. L'utilisation de ce LLM est signalée le long du document transformation_latex.xsl avec des commentaires.

J'inclus, au cas où, la commande utilisée pour effectuer la transformation depuis mon PC : java -cp "saxon-he-12.4.jar:lib/*" net.sf.saxon.Transform -s:3_may.xml -xsl:transformation_latex.xsl -o:output.tex.