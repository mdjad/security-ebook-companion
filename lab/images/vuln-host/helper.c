/*
 * backup-helper — binaire SUID volontairement anormal (Ch16)
 *
 * Ce petit programme est installé avec le bit setuid (4755) pour
 * servir de cible à l'exercice « Détecter et documenter un vecteur
 * SUID ». Il ne fait rien de dangereux : il affiche simplement son
 * UID effectif. L'exercice du chapitre consiste à le DÉTECTER et à
 * le documenter, pas à l'exploiter.
 */
#include <stdio.h>
#include <unistd.h>

int main(void) {
    printf("backup-helper: sauvegarde en cours (uid reel=%d, uid effectif=%d)\n",
           getuid(), geteuid());
    return 0;
}
