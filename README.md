# Reverse-shell---ASM-x86-64

## Description
Ce projet consiste en l'implémentation d'un reverse shell en assembleur x86-64. Un reverse shell est un programme qui établit une connexion depuis une machine victime vers une machine attaquante, permettant à cette dernière d'exécuter des commandes à distance sur la machine victime.

## Fonctionnalités implémentées
- Un programme qui se connecte de la machine victime à la machine de l'attaquant
- Le programme bind un shell fonctionnel à travers la connexion réseau
- Une gestion d'erreur est présente afin que le programme ne reçoive pas de segmentation fault si la machine de l'attaquant n'est pas en écoute
- Le code est légèrement optimisé (sans instructions inutiles)
- Des tentatives de reconnexion (toutes les 5-10 secondes) sont implémentées au cas où la machine attaquante ne soit pas en écoute

## Outils utilisés
- **nasm** : Netwide Assembler – `nasm -f elf32` (pour l'assembleur x86)
- **ld** : Linker (le même que celui utilisé par GCC) – `ld -m elf_i386` (pour l'assembleur x86)
- **objdump** : Désassembleur – `objdump -M intel -d`
- **gdb** : Debugger, permet de visualiser et éditer la mémoire et les registres pendant le runtime
- **m2elf** : Pour écrire directement du code machine et le convertir en exécutable valide

## Compilation et exécution
Machine victime
```bash
nasm -f elf32 reverse_shell.s && ld -m elf_i386 reverse_shell.o
```
Machine attaquante :
```bash
nc -lvp 4444
```
Machine victime
```bash
./a.out
```

## Note
Ce programme est développé dans un cadre purement académique pour comprendre les mécanismes d'assembleur et les appels système. Il s'exécute uniquement sur la machine locale pour des fins de démonstration.

## Auteurs
- MEDIOUNA Younouss
- AZOUZ Idir
- MAZZARi Mehdi

## Licence
Ce projet est réalisé dans le cadre d'un cours à l'ESGI et est soumis aux règles de l'établissement.
