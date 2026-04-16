<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    
    
    <!--MODIFICATIONS DE LA STRUCTURE DU DOCUMENT-->
    
    <xsl:template match="/">
        
        <!--EN-TETE-->
        
       <!-- Je n'étais pas sûre de quelle classe déclarer, j'ai choisi article car c'est ce que nous avons le plus utilisé en cours de LaTeX-->
       <!--fontenc me permet d'utiliser des caractères spéciaux, notamment pour les noms de lieux non anglais dans mon texte-->
       <!--Puisque tout mon encodage est en anglais, je n'ai utilisé le package Babel que pour l'anglais-->
       <!--hyperref permet de rendre la table des matières cliquable-->
        <xsl:text>
            \documentclass{article}
            \usepackage[utf8]{inputenc}
            \usepackage[english]{babel}
            \usepackage[T1]{fontenc}
            \usepackage{hyperref}
        </xsl:text>
        
        <xsl:text>
            \begin{document}
        </xsl:text>
        
        <!--CREATION DU TITRE DU DOCUMENT-->
        
        <!--Déclaration de variable utilisée pour gérer mes trois documents source-->
        
        <xsl:variable name="docs" select="collection('.?select=*_may.xml')"/>
        
        <!--Déclaration de variables utilisées pour le titre de mon document-->
        
        <xsl:variable name="titre_livre" select="upper-case($docs[1]//sourceDesc/bibl/title)"/>
        <xsl:variable name="titre_chapitre" select="$docs[1]//text/body/div[@type='header']/head[@type='chapter_title']"/>
        <xsl:variable name="nom_auteur" select="$docs[1]//sourceDesc//author"/>
        <xsl:variable name="date_pub" select="$docs[1]//sourceDesc/bibl/date/@when"/>
        
        <xsl:variable name="encodeur" select="$docs[1]//titleStmt/respStmt/persName"/>
        <xsl:variable name="note_encodage" select="$docs[1]//titleStmt/respStmt/note"/>
        <xsl:variable name="editeur" select="$docs[1]//publicationStmt/publisher"/>
        
                <xsl:text>
            \title{\textbf</xsl:text>{<xsl:value-of select="$titre_livre"/><xsl:text> - </xsl:text><xsl:value-of select="$titre_chapitre"/>}<xsl:text>}
            \author{\textbf{Author:} </xsl:text><xsl:value-of select="$nom_auteur"/><xsl:text>}
            \date{\textbf{First published:} </xsl:text><xsl:value-of select="$date_pub"/><xsl:text> \\[2ex]
                  \textbf{Encoded by:} </xsl:text><xsl:value-of select="$encodeur"/><xsl:text> \\ </xsl:text><xsl:value-of select="$editeur"/><xsl:text> \\
                  </xsl:text><xsl:value-of select="$note_encodage"/><xsl:text>
}
        
        <!--Commande LaTeX pour générer une page de titre et créer une navigation-->
            \maketitle
            \clearpage
            \tableofcontents
            \clearpage
            </xsl:text>
        
        <!--CORPS DU TEXTE-->
        <!--Garantit le bon ordre des entrées du journal (je ne sais pas pourquoi le 5 mai apparaissait tout le temps en premier...)-->
        
        <xsl:for-each select="collection('.?select=*_may.xml')">
            <xsl:sort select="(.//div[@type='entry']//date/@when)[1]" data-type="text"/>
            
            <xsl:apply-templates select="TEI/text/body"/>
            <xsl:text>\par\vfill\clearpage </xsl:text>
        </xsl:for-each>
        
        <!--INDEX DES LIEUX MENTIONNES DANS LE TEXTE QUI ONT DES COORDONNEES GEOGRAPHIQUES correspondantes-->
        
        <!--L'usage de &#10; dans cette section est une recommendation d'un LLM pour régler un problème d'indentation-->
        <!--J'ai également utilisé un LLM pour arriver à supprimer les doublons des villes mentionnées dans plus d'une entrée. C'est de ce LLM que vient l'utilisation d'une clé de groupe, j'avais à l'origine fait cet index avec for-each.-->
        <xsl:text>\section{Index of Places Mentioned}&#10;</xsl:text>
        <xsl:text>\begin{itemize}&#10;</xsl:text>
        
        <xsl:for-each-group select="collection('.?select=*_may.xml')//listPlace/place" group-by="placeName">
            <xsl:sort select="current-grouping-key()"/>
            
            <xsl:text>  \item </xsl:text>
            <xsl:value-of select="current-grouping-key()"/>
            
            <xsl:if test="current-group()[1]/location/country">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="current-group()[1]/location/country"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
            
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each-group>
        
        <xsl:text>\end{itemize}&#10;</xsl:text>
        
        <xsl:text>\end{document}</xsl:text>
        
    </xsl:template>
    
    
    <!--MODIFICATIONS DANS LE CORPS DU TEXTE-->
    
    
    <!--SUPPRIME LE TITRE DU CHAPITRE, ICI RENDONDANT-->
    <xsl:template match="head[@type='chapter_title']"/>
    
    <!--CREE UNE NOUVELLE SECTION POUR CHAQUE PARTIE DE L'ENCODAGE-->
    
    <xsl:template match="div[@xml:id='chapter_subtitle']">
        
        <!--Définit des variables pour la date de l'encodage que j'ai réalisé et la date de l'entrée dans le journal de Jonathan Harker qui sera reprise dans le titre de la section-->
        <xsl:variable name="date_encodage" select="//publicationStmt/date/@when"/>
        <xsl:variable name="date_entree" select="parent::*/following-sibling::div[@type='entry'][1]/dateline"/>

        <!--L'utilisation de crochets ici est une suggestion d'un LLM pour régler un problème que j'avais où le texte défini comme huge l'était aussi dans la table des matières-->
        <xsl:text>\section[</xsl:text>
        <xsl:if test="$date_entree">
            <xsl:value-of select="$date_entree"/>
            <xsl:text> --- </xsl:text>
        </xsl:if>
        
        <xsl:for-each select="p[1]">
            <xsl:apply-templates/>
        </xsl:for-each>
        <xsl:text>]{</xsl:text>
        
        <!--Rend le titre grand-->
        <xsl:text>{\huge </xsl:text> 
        <xsl:if test="$date_entree">
            <xsl:value-of select="$date_entree"/>
            <xsl:text> \\ </xsl:text> 
        </xsl:if>
        <!--Met un grand espace s'il y a d'autres paragraphes dans le sous-titre-->
        <xsl:for-each select="p">
            <xsl:apply-templates/>
            <xsl:if test="position() != last()">\quad </xsl:if>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
        
        <xsl:text>\\ </xsl:text> 
        
        <!--Utilise une boucle if avec la condition que la longueur de la date soit supérieur à 0 caractères, autrement une absence de date est indiquée--> 
        <xsl:text>Encoded on </xsl:text>
        <xsl:value-of select="if (string-length($date_encodage) > 0) then $date_encodage else '[null]'"/>
        <xsl:text>}</xsl:text>
        <xsl:text>\par\bigskip\noindent </xsl:text>
    </xsl:template>
    
    <!--ENLEVE LES INDENTATIONS DE LA DATE DE L'ENTREE, MET LE TEXTE EN GRAS ET FAIT UN SAUT DE LIGNE APRES-->
    
    <xsl:template match="dateline">
        <xsl:text>\noindent\textbf{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}\par\medskip</xsl:text>
    </xsl:template>
    
    <!--SAUTE DES LIGNES ENTRE TOUS LES PARAGRAPHES SAUF CEUX DE LA LETTRE DE DRACULA-->
    
    <xsl:template match="p[not(parent::div[@type='letter'])]">
        <xsl:apply-templates/>
        <xsl:text>\par\bigskip</xsl:text>
    </xsl:template>
    
    <!--TRANSFORME LA LETTRE DE DRACULA EN CITATION-->
    
    <xsl:template match="div[@type='letter']">
        <xsl:text>\begin{quote}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>\end{quote}</xsl:text>
    </xsl:template>
    
    <!--MOTS EN LANGUES ETRANGERES-->
    
    <!--Faire en sorte que le nom de la langue apparaisse en parenthèses a été difficile, j'ai eu recours à un LLM qui a suggéré d'utiliser choose puis test au lieu de simplement test, comme je l'avais initialement fait-->
    
    <xsl:template match="foreign">
        <!--Définit une variable avec le code en deux lettres de la langue-->
        <xsl:variable name="code_langue" select="@xml:lang"/>
        
        <!--Met le texte en langue étrangère en italique-->
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
        
        <!--Définit une variable pour les noms de langues-->
        <xsl:variable name="nom_langue">
            <xsl:choose>
                <xsl:when test="$code_langue = 'hu'">Hungarian</xsl:when>
                <xsl:when test="$code_langue = 'ro'">Romanian</xsl:when>
                <xsl:when test="$code_langue = 'de'">German</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!--Si le nom de la langue est bien reconnu, l'ajouter entre parenthèses après le texte en langue étrangère-->
        <xsl:if test="$nom_langue != ''">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$nom_langue"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!--ALIGNE LA SIGNATURE DE DRACULA A DROITE DANS SA LETTRE-->
    
    <xsl:template match="signed">
        <xsl:text>\begin{flushright}\textbf{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}\end{flushright}</xsl:text>
    </xsl:template>
    
    <!--REMPLACE L'AMPERSAND PAR UNE SUITE DE CARACTERES QUI NE FERA PAS PLANTER LATEX-->
    <!--Suggestion d'un LLM après un problème rencontré quand j'ai compilé depuis le terminal-->
    <!-- Etait censé régler un problème avec le nom de la maison d'édition du livre scanné par le Projet Gutenberg, finalement je n'ai pas inclus ce nom sur la page de titre donc j'ai ajouté un ampersand dans l'encodage du 4 mai pour que ça fonctionne quand même -->
    
    <xsl:template match="text()">
        <xsl:value-of select="replace(., '&amp;', '\\&amp;')"/>
    </xsl:template>
    
</xsl:stylesheet>