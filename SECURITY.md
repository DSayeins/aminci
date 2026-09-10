# Politique de sécurité

## Périmètre

Aminci est une application desktop qui tourne entièrement en réseau local (LAN)
et stocke localement (SQLite, `%APPDATA%\Aminci\aminci.db`) :

- les mots de passe des comptes locaux (hash SHA-256 + salt, jamais en clair)
- les identifiants des routeurs MikroTik (nécessaires pour s'authentifier
  auprès de l'API REST de chaque routeur — RouterOS ne propose pas
  d'alternative sans mot de passe en clair pour cet usage)

Aucune donnée n'est envoyée à un service distant — la surface d'attaque est
le poste Windows sur lequel l'app tourne et le LAN sur lequel se trouvent les
routeurs.

## Signaler une vulnérabilité

**Ne pas ouvrir d'issue publique** pour une faille de sécurité — ça expose le
problème à tout le monde avant qu'un correctif existe.

À la place, contacter directement : **djibrilla414@gmail.com**, avec :
- une description de la faille et son impact
- les étapes pour la reproduire
- la version/commit concerné

Un correctif sera priorisé et publié avant toute divulgation publique.

## Ce qui n'est pas considéré comme une vulnérabilité

- Le mot de passe d'un routeur MikroTik étant stocké en clair en base locale
  (`routers.password`) : c'est une limitation connue et acceptée pour ce
  contexte (déploiement LAN, RouterOS REST API en Basic Auth) — voir
  `CLAUDE.md`. Une contribution proposant un chiffrement au repos est
  bienvenue, mais ce n'est pas traité comme un rapport de sécurité urgent.
- L'absence de HTTPS entre l'app et les routeurs par défaut (port 80, LAN
  de confiance) — un support HTTPS/certificats auto-signés est documenté
  comme amélioration possible dans `docs/superpowers/specs/`.
