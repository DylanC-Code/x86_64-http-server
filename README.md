# 🧠 x86_64-http-server

> Serveur HTTP minimaliste et brut en assembleur x86_64 — écrit pour les passionnés du bas niveau.
> ⚙️ Linux · 🧬 Syscalls · 🔥 Sans libc · 💡 Éducatif · 💻 Performant

---

## 🚀 À propos

**x86_64-http-server** est un serveur HTTP codé **entièrement en assembleur x86_64**, conçu pour fonctionner sur Linux **sans aucune dépendance externe**.
Il met en œuvre le protocole HTTP 1.0 via des appels système Linux (`syscall`) uniquement, gère les connexions clients via `fork()` et prend en charge les requêtes **GET** et **POST**, avec lecture et écriture de fichiers.

Un projet parfait pour apprendre la programmation bas niveau, la communication réseau, et le protocole HTTP de façon concrète et sans abstraction.

---

## 📁 Structure du projet

```css
x86_64-http-server/
├── includes/
│ └── constants.asm # Définition des constantes (syscalls, HTTP, flags...)
├── srcs/
│ ├── main.asm # Point d'entrée et boucle principale
│ ├── socket.asm # Gestion des sockets (bind, listen, accept, close)
│ ├── parse.asm # Parsing brut des requêtes HTTP (méthode, route, body)
│ ├── http.asm # Traitement des requêtes et réponses
│ └── utils.asm # Fonctions utilitaires (strlen, isdigit, etc.)
├── Makefile # Compilation complète avec nasm et ld
├── .gitignore # Fichiers ignorés
├── README.md # Ce fichier
└── x86_64-http-server # Exécutable généré
```

---

## ⚙️ Fonctionnalités

- 🌐 Socket IPv4 TCP : `socket`, `bind`, `listen`, `accept`, `close`
- 📬 Parsing HTTP manuel (GET/POST, route, body)
- 📂 Lecture (GET) et écriture (POST) de fichiers
- 🧠 Gestion concurrente via `fork()`
- 📜 Réponse HTTP minimale (`HTTP/1.0 200 OK\r\n\r\n`)
- 🧼 Buffers gérés à la main (sans heap, sans libc)
- 💬 Code 100% assembleur, modulaire et documenté

---

## 🧪 Compilation

### ✅ Prérequis

- Linux x86_64
- NASM (`sudo apt install nasm`)
- `ld` (inclus dans `binutils`)

### 🔨 Commandes

```bash
make
```

Cela génère l'exécutable x86_64-http-server à la racine.

### ♻️ Cibles supplémentaires

```bash
make clean     # Supprime les objets .o
make fclean    # Supprime les objets et l'exécutable
make re        # Recompile tout proprement
```

---

## ▶️ Utilisation

Lancer le serveur (nécessite les droits root pour écouter sur le port 80) :

```bash
sudo ./x86_64-http-server
```

### 📡 Exemple GET

```bash
curl http://localhost/mon_fichier.txt
```
→ Renvoie le contenu du fichier s’il existe.


### 📤 Exemple POST

```bash
curl -X POST -d "Hello World" http://localhost/output.txt
```
→ Crée output.txt contenant Hello World.

---

## 🎓 Objectifs pédagogiques

- Comprendre le fonctionnement des sockets TCP sans abstraction
- Manipuler les syscalls Linux sans passer par la libc
- Appréhender le protocole HTTP manuellement
- Apprendre à structurer un vrai projet en assembleur
- Se challenger sur la performance, la maîtrise mémoire, et la rigueur

---

### 👤 Auteur

**Dylan Castor**
🛠️ Étudiant, curieux et passionné de programmation bas-niveau.
- GitHub : @DylanC-Code
- Contact : dylanc.code@gmail.com
