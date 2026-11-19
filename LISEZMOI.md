# Carnet Boutique : guide de mise en ligne

Ce dossier contient l'application complète. Suivez les 5 étapes dans l'ordre. Comptez environ 45 minutes la première fois. Il n'y a pas de code à écrire : vous créez deux comptes gratuits et vous copiez deux valeurs.

| Fichier | Rôle |
|---|---|
| `index.html` | L'application |
| `config.js` | **Le seul fichier à modifier** (vos réglages) |
| `schema.sql` | Prépare la base de données (à coller une fois dans Supabase) |
| `sw.js`, `manifest.webmanifest`, `icon-*.png` | Mode hors ligne et installation sur l'écran d'accueil |

---

## Étape 1 : créer la base de données (Supabase)

1. Allez sur **supabase.com** et créez un compte gratuit (adresse e-mail).
2. Touchez **New project**. Donnez un nom (par exemple `carnet-boutique`), choisissez un mot de passe de base de données (notez-le), et une région en Europe (la plus proche d'Afrique de l'Ouest, par exemple Paris).
3. Attendez 2 minutes que le projet soit créé.

## Étape 2 : régler la connexion par numéro

1. Dans Supabase, menu **Authentication**, puis **Providers**, puis **Email**.
2. **Désactivez « Confirm email »**. Sans cela, les commerçants ne pourront pas s'inscrire, car l'application utilise le numéro de téléphone comme identifiant, pas une vraie adresse e-mail.
3. Enregistrez.

## Étape 3 : installer les tables

1. Menu **SQL Editor**, puis **New query**.
2. Ouvrez `schema.sql`, copiez tout son contenu, collez-le, et touchez **Run**.
3. Vous devez voir « Success ». Si une erreur apparaît, copiez-la-moi et je corrige.

## Étape 4 : relier l'application

1. Dans Supabase, menu **Project Settings**, puis **API**.
2. Copiez **Project URL** et la clé **anon public**.
3. Ouvrez `config.js` et remplissez :

```js
SUPABASE_URL: 'https://xxxxxxxx.supabase.co',
SUPABASE_ANON_KEY: 'la longue clé anon public',
PAY_NUMBER: '70 12 34 56',   // votre numéro Mobile Money qui reçoit les abonnements
PRICE_FCFA: 2500,
```

La clé « anon public » peut rester dans l'application. **Ne copiez jamais la clé « service_role »** : elle donne un accès total.

## Étape 5 : publier

1. Allez sur **app.netlify.com/drop** (compte gratuit).
2. Glissez le dossier complet sur la page. Vous obtenez une adresse comme `https://nom-aleatoire.netlify.app`. Vous pouvez la renommer dans les réglages du site.
3. Ouvrez l'adresse sur un téléphone, créez un compte, puis ouvrez-la sur un second téléphone et connectez-vous : vos données doivent apparaître.
4. Sur Android (Chrome), menu **⋮ puis Installer l'application** : l'icône apparaît sur l'écran d'accueil.

---

## Gérer les abonnés

- Chaque nouveau commerçant a **14 jours d'essai gratuit** (réglable : changez `14 days` dans `schema.sql` et `TRIAL_DAYS` dans `config.js`).
- Quand un commerçant vous envoie son paiement Mobile Money en indiquant son numéro, ouvrez **SQL Editor** et lancez :

```sql
select public.activate_phone('70123456', 30);
```

Cela active son compte pour 30 jours de plus (les jours s'ajoutent s'il renouvelle avant la fin).
- Après la fin de l'essai ou de l'abonnement, le commerçant garde l'accès en **lecture** à ses données, mais ne peut plus en ajouter. Un bandeau lui rappelle votre numéro de paiement.
- Pour voir vos comptes : **Authentication**, puis **Users**.

## Ce que l'application ne fait pas encore

- **Pas de paiement automatique.** Vous activez à la main. Un service de paiement en ligne vient après l'enregistrement de votre activité.
- **Pas de code oublié.** Il n'y a pas d'envoi de SMS ni de récupération automatique du code secret. Dites aux commerçants de le noter. C'est la première chose que je vous conseille d'ajouter si des gens l'oublient.
- **Pas de SMS de rappel.** Le rappel se fait par un lien WhatsApp prêt à envoyer.
- **Un seul appareil par personne à la fois** pour les modifications simultanées sur le même client : la dernière modification gagne.

## À vérifier avant de vendre

- Les offres gratuites changent : lisez les conditions actuelles de Supabase et de Netlify (limites de stockage, mise en pause d'un projet peu utilisé).
- Vous conservez des données personnelles (noms et numéros des clients de vos abonnés). Renseignez-vous sur vos obligations auprès de l'autorité burkinabè de protection des données (CIL) et de la Maison de l'Entreprise.
- Faites des sauvegardes : dans Supabase, menu **Database**, puis **Backups**, ou exportez les tables depuis **Table Editor**.

## En cas de problème

- **« Le service demande une confirmation par e-mail »** : l'étape 2 n'est pas faite.
- **Écran de connexion qui ne bouge pas** : vérifiez `SUPABASE_URL` et la clé dans `config.js`, sans espace ni guillemet manquant.
- **Les données n'arrivent pas sur le second téléphone** : ouvrez **Réglages** puis **Synchroniser maintenant**, et lisez le message d'état.
