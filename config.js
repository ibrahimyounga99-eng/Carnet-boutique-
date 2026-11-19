// Réglages de Carnet Boutique : c'est le seul fichier à modifier.
// Tant que SUPABASE_URL et SUPABASE_ANON_KEY sont vides, l'application fonctionne en « mode local » (sans comptes).
window.CARNET_CONFIG = {
  SUPABASE_URL: 'https://eiqqugrarsqvkoiarcwb.supabase.co',
  SUPABASE_ANON_KEY: 'sb_publishable_G02VDCOw5q9-qZNrtAvPTQ_tHHWoW5t',   // clé publique (« Publishable key ») de votre projet
  PAY_NUMBER: '',          // Votre numéro Mobile Money qui reçoit les abonnements, exemple : '70 12 34 56'
  PRICE_FCFA: 2500,        // Prix de l'abonnement mensuel, en FCFA
  TRIAL_DAYS: 14           // Durée de l'essai gratuit. Doit être identique à « 14 days » dans schema.sql
};
