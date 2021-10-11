Animation de Sprite avec LayeredWindow--------------------------------------
Url     : http://codes-sources.commentcamarche.net/source/101882-animation-de-sprite-avec-layeredwindowAuteur  : CirecDate    : 31/03/2017
Licence :
=========

Ce document intitul� � Animation de Sprite avec LayeredWindow � issu de CommentCaMarche
(codes-sources.commentcamarche.net) est mis � disposition sous les termes de
la licence Creative Commons. Vous pouvez copier, modifier des copies de cette
source, dans les conditions fix�es par la licence, tant que cette note
appara�t clairement.

Description :
=============

Cette fois je vous propose un code qui permet l'animation de Sprite 
<br />mais
 d'une manière un peu différente des méthodes présentées ailleurs.
<br />

<br />En effet dans cet exemple j'utilise les <i>LayeredWindow</i> ou couche ou
 calque selon ...
<br />pour afficher et animer un Sprite:
<br />Un sprite, ou
 lutin, est dans le jeu vidéo un élément graphique qui peut se déplacer sur 
l'écran. En principe, un sprite est en partie transparent, et il peut être ani
mé (en étant formé de plusieurs images matricielles qui s'affichent les uns a
près les autres).
<br />Sprite (jeu vidéo)<a href='https://fr.wikipedia.org/w
iki/Sprite_(jeu_vidéo)' rel='noopener noreferrer' target='_blank'>source — Wi
kipédia</a>
<br />
<br />le code fonctionne sur toutes les versions de Delphi
 à partir de D7.
<br /><i>(pour les versions de Delphi qui ne possèdent pas l
a pngLib (avant D2009) une version est présente dans le Zip)</i>
<br />
<br /
>Alpha.exe lance un des 3 Sprites au hasard 
<br />Alpha.exe 0 lance le premier
 Sprite
<br />Alpha.exe all lance les 3 
<br />pour quitter appuyez sur échap
pe
<br />d'autres touches de contrôle sont disponibles <i>(voir le code)</i>

<br />
<br />les images sont des png <i>(à la base)</i> converti en bitmap32 b
its <i>(avec canal Alpha)</i>
<br />ce qui permet une transparence totale du fo
nd <i>(avec le canal Alpha)</i> mais permet aussi 
<br />de varier sur la trans
parence du Sprite lui même
<br />cette dernière est assignée aléatoirement 
pour l'exemple ...
<br />
<br />Si vous lancez plusieurs instances d'Alpha.exe
 vous n'aurez pas la même vitesse 
<br />d'animation ni le même niveau de tra
nsparence.
<br />
<br />Contrairement à ce que l'on pourrait croire ça ne co
nsomme pas tant de ressources que cela ;)
<br />
<br />
<br /><b>Et vous pouv
ez même les tester avec une vidéo en guise de fond</b> 
<br />
<br />Comme t
oujours si vous avez des bugs, des suggestions, ou autres avis 
<br />laissez u
n message ... Merci
<br />
<br /> 
<br /> 
<br />--
<br />    <pre 
class="code inline inline-code" data-mode="pascal">@+ Cirec</pre>
