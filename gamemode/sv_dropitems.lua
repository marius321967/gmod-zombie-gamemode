-- Items that will be dropped in random locations during the game go here.
-- Must specify model and weapon entity for creating zmb_pickupable_whatever.
-- Never make two items in same array with same drop chances.
-- Preferably numeric arrays.
-- Items go in descending order.
-- First item must always have 100% drop chance. The random drop function will already have taken care of randomness.
-- Weapons
d_w = {
{['entity'] = 'zmb_p90', ['model'] = 'models/weapons/w_smg_p90.mdl', ['chance'] = 100}, 
{['entity'] = 'zmb_famas', ['model'] = 'models/weapons/w_rif_famas.mdl', ['chance'] = 50},
{['entity'] = 'zmb_m3', ['model'] = 'models/weapons/w_shot_m3super90.mdl', ['chance'] = 20}
}
