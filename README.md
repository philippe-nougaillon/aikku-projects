# Camino

# Gérer, en équipe, vos petits projets

* Découpez vos projets en listes de choses à faire
* Invitez vos contacts à participer
* Assignez aux participants certaines choses à faire
* Fixez les échéances
* Suivez l'activité des participants (commentaires, travaux terminés, etc.)

# Fonctionnalités

    * Création rapide de nouveaux projets à partir de modèles
    * Le journal recense, minute par minute, l'actitivé des participants
    * Un agenda permet de visualiser les échéances
    * Déroulement de projet au choix:
        ** Libre; les tâches peuvent être terminées librement, dans n'importe quel ordre
        ** Linéaire; toutes les tâches d'une liste doivent être terminées avant de pouvoir passer à la liste suivante.
        Quand une tâche est terminée, le participant assigné à la tâche suivante en est immédiatement informé
    * Un courriel de notification est envoyé aux participants:
        ** Après chaque modification, ajout ou suppression d'information
        ** Lors de l'assignation d'une tâche à un participant
        ** Avant chaque échéance de tâche ou de projet
    * Les participants peuvent mener une discussion autour de choses à faire, attacher des documents
    * Taggez vos projets pour les regrouper par mots clés
    * Assignez une couleur à chaque projet
    * Notifiez automatiquement votre client dès la réalisation d'une tâche

# Installation en local

Aikku PROJECTS est une application <a href="http://rubyonrails.org/">Ruby On Rails 7</a>. 

Pour pouvoir executer l'application vous devez installer Ruby 3 et Ruby On Rails 7 sur votre machine Linux, en suivant ce tutoriel : <a href="https://gorails.com/setup/ubuntu/22.04">gorails.com/setup/ubuntu</a>.

Une fois Ruby on Rails correctement installé, vous pourrez cloner les sources depuis Github et lancer l'application en utilisant le processus classique :

```
git clone https://github.com/philippe-nougaillon/Camino2.git
cd Camino2
bundle install
rails db:setup
rails s
```

# Installation sur Heroku

Heroku fournit un hébergement Rails de première classe et très simple à mettre en place.
C'est la solution d'hébergement de Camino que nous conseillons.

Pour fonctionner, Camino a besoin des Add-ons suivants :

+ Bucketeer ($5.00)
+ Heroku Data for Redis®* ($3.00)
+ Heroku Postgres ($5.00)
+ Mailgun ($19.00)

Auquel s'ajoute un serveur WEB, soit un Dyno basic à ($7.00) dans la dénomination Heroku.

Cette configuration, très flexible, s'installe en quelques minutes et peut évoluer selon les besoins.

Pour en savoir plus sur les services proposés par Heroku, visitez leur site [Heroku.com](https://www.heroku.com/home)


# Installation aved Docker

Les fichiers nécessaires à l'installation de l'application dans un conteneur Docker sont fournis avec le code source.

# Nous contacter

Besoin d'aide pour installer Camino ? [Nous contacter](https://www.aikku.eu/contact)
