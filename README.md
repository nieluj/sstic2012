sstic2012
=========

code développé pour résoudre le challenge sstic2012

Description des fichiers
========================

Fichiers d'entrée
-----------------

* `./input/data/blah` : bloc de données `blah` extrait du binaire `ssticrypt`
* `./input/data/blob` : bloc de données `blob` extrait du binaire `ssticrypt`
* `./input/data/check.pyc` : bloc de données `check_pyc` extrait du binaire `ssticrypt`
* `./input/data/init_rom` : bloc de données `init_rom` extrait du binaire `ssticrypt`
* `./input/data/init_rom_scan_record_0` : premier "scan record" de `init_rom` (code de la routine d'interruption)
* `./input/data/init_rom_scan_record_1` : deuxième "scan record" de `init_rom` (relocations à appliquer)
* `./input/data/init_rom_scan_record_2` : troisième "scan record" de `init_rom` (saut sur la routine)
* `./input/data/layer1` : bloc de données `layer1` extrait du binaire `ssticrypt`
* `./input/data/layer2` : bloc de données `layer2` extrait du binaire `ssticrypt` (chiffré)
* `./input/data/layer3` : bloc de données `layer2` extrait du binaire `ssticrypt` (chiffré)
* `./input/data/stage2_rom` : bloc de données `stage2_rom` extrait du binaire `ssticrypt`
* `./input/data/stage2_rom_scan_record_0` : premier "scan record" de `stage2_rom` (code de la routine d'interruption)
* `./input/data/stage2_rom_scan_record_0.relocated` : premier "scan record" de `stage2_rom` (code de la routine d'interruption) après application des relocations
* `./input/data/stage2_rom_scan_record_1` : deuxième "scan record" de `stage2_rom` (relocations à appliquer)
* `./input/data/stage2_rom_scan_record_2` : troisième "scan record" de `stage2_rom` (saut sur la routine)
* `./input/irc.log` : conversation irc extraite de l'image disque
* `./input/secret` : fichier à déchiffrer pour trouver l'adresse email
* `./input/ssticrypt`: programme principal du challenge

Partie 1 : DES white-box
------------------------

Partie 2a : Analyse de la ROM
-----------------------------

Partie 2b : Analyse de la machine virtuelle
-------------------------------------------

Partie 3 : Restauration du fichier secret
-----------------------------------------


