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

* `./part1_wb/code/reverse.py` : réimplémentation du fichier `check.pyc`, implémentation de l'attaque par cryptanalyse
* `./part1_wb/doc` : les articles académiques référencés dans la solution

Partie 2a : Analyse de la ROM
-----------------------------
* `./part2a_rom/code/emul` : code de l'émulateur cy16
* `./part2a_rom/code/reverse_ssticrypt` : réimplémentation en C de la routine de vérification de la clé (`client.c` correspond au binaire `ssticrypt`, `server.c` est la réimplémentation de la ROM)
* `./part2a_rom/code/usb_hook` : bibliothèque partagée permettant de remplacer les appels aux fonctions de la `libusb` par des fonctions équivalentes utilisant des sockets TCP pour les communications
* `./part2a_rom/data/cy16-rom.asm` : désassemblage de la ROM obtenu avec Metasm
* `./part2a_rom/data/traces` : traces d'exécution entre le binaire `ssticrypt` MIPS et l'émulateur
* `./part2a_rom/doc` : documents de spécification sur le processeur CY16
* `./part2a_rom/tools/apply_reloc.rb` : applique les relocation sur la routine d'interruption
* `./part2a_rom/tools/extract_data.rb` : extrait les différents blocs de données du binaire `ssticrypt`
* `./part2a_rom/tools/scan_signature.rb` : identifier les "scan records" dans les blocs de données envoyés à la webcam

Partie 2b : Analyse de la machine virtuelle
-------------------------------------------
* `./part2b_vm/layer1/bflayer1.c` : code implémentant la recherche exhaustive sur la première partie de la clé
* `./part2b_vm/layer1/bflayer1.orig.c` : code autogénéré par `vmdisas.rb` à partir du bytecode `layer1`
* `./part2b_vm/layer1/layer1.asm` : désassemblage du `layer1` par `vmdisas.rb`
* `./part2b_vm/layer2/bflayer2.c` : code implémentant la recherche exhaustive sur la seconde partie de la clé
* `./part2b_vm/layer2/bflayer2.orig.c` : code autogénéré par `vmdisas.rb` à partir du bytecode `layer2` (déchiffré)
* `./part2b_vm/layer2/layer2.decoded` : contenu du `layer2` une fois déchiffré
* `./part2b_vm/layer2/layer2.decoded.asm` : désassemblage du `layer2` (déchiffré) par `vmdisas.rb`
* `./part2b_vm/layer3/bflayer3.c` : code implémentant la recherche exhaustive sur la troisième partie de la clé
* `./part2b_vm/layer3/bflayer3.orig.c` : code autogénéré par `vmdisas.rb` à partir du bytecode `layer3` (déchiffré)
* `./part2b_vm/layer3/layer3.decoded` : contenu du `layer3` une fois déchiffré
* `./part2b_vm/layer3/layer3.decoded.asm` : désassemblage du `layer3` (déchiffré) par `vmdisas.rb`
* `./part2b_vm/vmdisas.rb` : désassembleur et décompilateur en C pour la machine virtuelle du challenge

Partie 3 : Restauration du fichier secret
-----------------------------------------

* `./part3_secret/extract.c` : extrait les blocs corrects
* `./part3_secret/findblocks.c` : implémente une heuristique de recherche de blocs en se basant sur la différence d'entropie d'un bloc après déchiffrement

