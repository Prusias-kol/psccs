# psccs

**[Forked from Zdrvst's hccs script. Vast majority of code is credited to him.](https://github.com/c2talon/c2t_hccs)**

Kolmafia script to handle a softcore community service run with my set of skills and IotMs and as a Pastamancer.

This is a continual work-in-progress. It is not likely to run out-of-the-box for most, but others may be able to glean things from it. To see what is needed to run smoothly without changes, see: https://api.aventuristo.net/av-snapshot?u=Prusias#a4

## Installation / Uninstallation

To install, run the following on the gCLI:

```
git checkout https://github.com/Prusias-kol/psccs master
```

## PSCCS Loadout
* I run as a PM with Wallaby, astral 6-pack, and astral chapeau in SC CS.
* I run this exclusively with asdon in run. May not hit 1 turn thresholds without asdon
* I own kitchen royalty and stick knife and use them as pulls. Roaring hearth is supported if you can hit the myst threshold
* Run the relay script (named c2t_hccs) to set preferences. My preferences are as follows: 
    - c2t_hccs_clanFortunes = Icawn (MT) or Cheesefax (BAFH) - leave empty to disable zatara consults
    - c2t_hccs_joinClan = 2046991423 (Margaretting Tyre) or 90485 (BAFH)
    - c2t_hccs_haltBeforeTest = false (useful for debugging)
    - c2t_hccs_printModtrace = true
    - c2t_hccs_skipFinalService = false
    - c2t_hccs_workshed = Asdon martin keyfob
    - threshold caps, fam = 32, spell = 20, rest = 1
    - Disabled resources: backup cam, pantogram, pillkeeper
* There's some flexibility in the tests if you're missing my iotms due to multiple levels of checks to see if you hit the thresholds, but works best (and may miss some thresholds due to resource removal if you dont have my iotms) with my iotms: https://api.aventuristo.net/av-snapshot?u=Prusias#a4

## PSCCS Specific Requirements
* Only works as Pastamancer with CS relevant perms (Thralls mandatory)
* Outfit named `CS_PM_stickknife_glitch` that has stickknife in mainhand
* If you have the simmering staff, outfit named `CS_PM_simmering_glitch` with cheffstaff in mainhand and stickknife in offhand
* If you have kitchen royalty staff, outfit named `CS_PM_kitchenroyalty_glitch` with cheffstaff in mainhand and stickknife in offhand
* If you have the roaring hearth, outfit named `CS_PM_roaringhearth_glitch` with the staff in mainhand and stickknife in offhand
* If you have machine elf, make sure to set the slime clan
* Must create a calzone of legend before starting run
* Must have `ungulith` and `Witchess Witch` in combat lover locket
* a source of free crafts. One of the skills that give 5 is enough.
* Likely requires oliver's place + machine elf to hit leveling targets. 
* Go to c2t_hccs settings and set the new settings for Home Clan (likely same as VIP clan unless you are using a VIP clan for consults). This is whatever clan you want to end the run with.
* Go to c2t_hccs settings and set the new settings for Slime Clan. Clan must be at mother slime for MELF
* Leveling has been made extremely tight. Likely requires NEP, closed-circuit pay phone, machine elf, source terminal (less so), oliver's place.
* If you own comma chameleon, make sure you config homemade robot familiar to have + 100 fam weight

## Non-exhaustive PSCCS optional elements
* supports repaid diaper or great wolf beastly trousers as pull
* Cmd f for a comment named `//CLAN VIP CONSULT HANDLING` and modify `//word match for Icawn` to support whatever bot you desire. Won't matter if you disable consults 
* If you own Staff of the Roaring Hearth, create an outfit named `CS_PM_roaringhearth_glitch` with cheffstaff in mainhand and stickknife in offhand
* If you don't own sorceror of the shore grimoire. You can prestock a tobiko marble soda before ascending and it will pull and use. Will not fail if you don't prestock.
* Witch's Bra will save 1 turn

## Usage

* The main script is `psccs.ash`, and is the thing that should be run to do a community service run
* Not likely to run out-of-the-box for most. Hoping to change this eventually
* Able to be re-run at any point in a run, hopefully after manually correcting whatever caused it to stop
* Will abort when a non-coil test does not meet its turn threshold after preparations for it are done, which defaults to 1 turn
* Pre-Valhalla: have at least one Calzone of Legends
* In Valhalla:
    - Choose Pastamancer
    - Choose the Wallaby moonsign (knoll, myst)
    - Optimal astral stuff is astral six-pack and astral chapeau, though neither is strictly required
* The script uses moods `hccs-mus`, `hccs-mys`, and `hccs-mox` for leveling purposes on muscle, mysticality, and moxie classes, respectively. So set your own to what you want for what skills you have, otherwise you won't have many buffs while levelling.
    - Exception: the script will cast and handle stevedave's shanty of superiority and ur-kel's aria of annoyance, so either put them in the mood as well or leave 2 song slots open for them
    - The moods I use can be seen in [mood examples.txt](https://github.com/c2talon/c2t_hccs/blob/master/mood%20examples.txt) to use as a starting point.

## User settings and disabling resources

Most settings can be changed via a relay script. To start the relay script, find the drop-down menu that says `-run script-` at the top-right corner of the menu pane and select `c2t hccs`, as seen here:

![relay script location](https://github.com/C2Talon/c2t_hccs/blob/master/relay_script_location.png "relay script location")

Resources can be disabled with the same relay script.

## IotM

The script assumes several IotM are owned and will break without them. In addition, the [sweet synthesis](https://kol.coldfront.net/thekolwiki/index.php/Sweet_Synthesis) and [Summon Crimbo Candy](https://kol.coldfront.net/thekolwiki/index.php/Summon_Crimbo_Candy) skills, as well as the [Imitation Crab](https://kol.coldfront.net/thekolwiki/index.php/Imitation_Crab) familiar, are currently required.

Some of the required IotM are only required for now because they're explicitly used in the script without any checks. Some will be moved to the supported list as I get around to adding the necessary checks. I'll be working on trying to minimize the required list, but do note one will probably still need to have a critical mass of IotM for the script to run smoothly.

### Required IotM (ordered by release date)
* [Tome of Clip Art](https://kol.coldfront.net/thekolwiki/index.php/Tome_of_Clip_Art)
* [Clan VIP Lounge invitation](https://kol.coldfront.net/thekolwiki/index.php/Clan_VIP_Lounge_invitation) &mdash; assumes a fully-stocked VIP lounge
* [corked genie bottle](https://kol.coldfront.net/thekolwiki/index.php/Corked_genie_bottle)
* [January's Garbge Tote (unopened)](https://kol.coldfront.net/thekolwiki/index.php/January%27s_Garbage_Tote_(unopened))
* [Neverending Party invitation envelope](https://kol.coldfront.net/thekolwiki/index.php/Neverending_Party_invitation_envelope)
* [Latte lovers club card](https://kol.coldfront.net/thekolwiki/index.php/Latte_lovers_club_card)
* [Kramco Industries packing carton](https://kol.coldfront.net/thekolwiki/index.php/Kramco_Industries_packing_carton)
* [Fourth of May Cosplay Saber kit](https://kol.coldfront.net/thekolwiki/index.php/Fourth_of_May_Cosplay_Saber_Kit)
* [rune-strewn spoon cocoon](https://kol.coldfront.net/thekolwiki/index.php/Rune-strewn_spoon_cocoon)
* [Distant Woods Getaway Brochure](https://kol.coldfront.net/thekolwiki/index.php/Distant_Woods_Getaway_Brochure)
* [packaged Pocket Professor](https://kol.coldfront.net/thekolwiki/index.php/Packaged_Pocket_Professor)
* [Comprehensive Cartographic Compendium](https://kol.coldfront.net/thekolwiki/index.php/Comprehensive_Cartographic_Compendium)
* [emotion chip](https://kol.coldfront.net/thekolwiki/index.php/Emotion_chip)
PSCCS Requirements added:  
* Machine Elf (many leveling resources were removed)
* Combat Lover's Locket (Technically mostly optional but saves many turns and resources)
* Asdon (technically optional, saves many turns)

### Supported IotM (ordered by release date)

While these are not strictly required, not having enough that either save turns or significantly help with leveling may cause problems. The blurb after the em dash (&mdash;) is basically what the script uses the IotM for.

* [panicked kernel](https://kol.coldfront.net/thekolwiki/index.php/Panicked_kernel) &mdash; saves 1 turn if you don't take astral pet sweater.  
* [Mint Salton Pepper's Peppermint Seed Catalog](https://kol.coldfront.net/thekolwiki/index.php/Mint_Salton_Pepper%27s_Peppermint_Seed_Catalog) &mdash; used to get the synthesize item buff to save 10 turns on the item test; provides backup candies for other synthesis buffs
* [Suspicious Package](https://kol.coldfront.net/thekolwiki/index.php/Suspicious_package) &mdash; saves 5 on hot test, 3 on combat test, 1 on weapon test, 1 on spell test; backup banishes
* [Pocket Meteor Guide](https://kol.coldfront.net/thekolwiki/index.php/Pocket_Meteor_Guide) &mdash; with saber saves 4 turns on familiar text, 8 on weapon test, 4 on spell test
* [pantogram](https://kol.coldfront.net/thekolwiki/index.php/Pantogram) &mdash; saves 2 turns on hot test, 3 on combat test, 0.4 on spell test
* [locked mumming trunk](https://kol.coldfront.net/thekolwiki/index.php/Locked_mumming_trunk) &mdash; 2-4 stats from combat
* [FantasyRealm membership packet](https://kol.coldfront.net/thekolwiki/index.php/FantasyRealm_membership_packet) &mdash; get a hat with +15 mainstat
* [God Lobster Egg](https://kol.coldfront.net/thekolwiki/index.php/God_Lobster_Egg) &mdash; 3 mid-tier scaling fights & nostalgia pi&ntilde;ata
* [Songboom&trade; BoomBox Box](https://kol.coldfront.net/thekolwiki/index.php/SongBoom%E2%84%A2_BoomBox_Box) &mdash; extra meat from fights. Saves 0.6+ turns in weapon test
* [Bastille Battalion control rig crate](https://kol.coldfront.net/thekolwiki/index.php/Bastille_Battalion_control_rig_crate) &mdash; 250 free stats; 25 mainstat buff for leveling; saves 2 turns on weapon test, 1.6 on familiar
* [Voter registration form](https://kol.coldfront.net/thekolwiki/index.php/Voter_registration_form) &mdash; vote buffs and chance for mid-tier scaling wanderers
* [Boxing Day care package](https://kol.coldfront.net/thekolwiki/index.php/Boxing_Day_care_package) &mdash; free stats; 200% stat buff for leveling; saves 1.67 turns on item test for mys classes
* [Mint condition Lil' Doctor&trade; bag](https://kol.coldfront.net/thekolwiki/index.php/Mint_condition_Lil%27_Doctor%E2%84%A2_bag) &mdash; 3 free kills and 3 free banishes
* [vampyric cloake pattern](https://kol.coldfront.net/thekolwiki/index.php/Vampyric_cloake_pattern) &mdash; saves 3.3 turns on item test, 2 on hot test; 50% mus buff
* [Beach Comb Box](https://kol.coldfront.net/thekolwiki/index.php/Beach_Comb_Box) &mdash; saves 1 turn on familiar and weapon tests, 3 on hot test, 0.5 on spell test; some minor levelling buffs
* [Unopened Eight Days a Week Pill Keeper](https://kol.coldfront.net/thekolwiki/index.php/Unopened_Eight_Days_a_Week_Pill_Keeper) &mdash; buff sets familiars to level 20; 100% stat buff for levelling; can save 3 turns on hot test
* [unopened diabolic pizza cube box](https://kol.coldfront.net/thekolwiki/index.php/Unopened_diabolic_pizza_cube_box) &mdash; provides several buffs that help leveling and contribute greatly to tests; I don't suggest running without this unless you basically have everything on both lists
* [mint-in-box Powerful Glove](https://kol.coldfront.net/thekolwiki/index.php/Mint-in-box_Powerful_Glove) &mdash; 200% stat buff for leveling & saves 6 turns on combat test, 1 on weapon test, 1 on spell test
* [Better Shrooms and Gardens catalog](https://kol.coldfront.net/thekolwiki/index.php/Better_Shrooms_and_Gardens_catalog) &mdash; 1 mid-tier scaling fight
* [sinistral homunculus](https://kol.coldfront.net/thekolwiki/index.php/Sinistral_homunculus) &mdash; equip extra offhands for tests
* [baby camelCalf](https://kol.coldfront.net/thekolwiki/index.php/Baby_camelCalf) &mdash; with enough fights to fully charge: can save 4 turns on weapon test, 2 on spell test
* [packaged SpinMaster&trade; lathe](https://kol.coldfront.net/thekolwiki/index.php/Packaged_SpinMaster%E2%84%A2_lathe) &mdash; saves 4 turns on weapon test with ebony epee
* [Bagged Cargo Cultist Shorts](https://kol.coldfront.net/thekolwiki/index.php/Bagged_Cargo_Cultist_Shorts) &mdash; saves 8 turns on weapon test or 4 turns on spell test; makes hp test trivial
* [packaged knock-off retro superhero cape](https://kol.coldfront.net/thekolwiki/index.php/Packaged_knock-off_retro_superhero_cape) &mdash; saves 3 turns on hot test; 30% mainstat for leveling
* [box o' ghosts](https://kol.coldfront.net/thekolwiki/index.php/Box_o%27_ghosts) &mdash; 50% stat buff for leveling; saves 4 turns on weapon test, 2 on spell test
* [power seed](https://kol.coldfront.net/thekolwiki/index.php/Power_seed) &mdash; saves 6.7 turns on item test
* [packaged backup camera](https://kol.coldfront.net/thekolwiki/index.php/Packaged_backup_camera) &mdash; used for 11 scaling fights & burning delay to get other resources
* [shortest-order cook](https://kol.coldfront.net/thekolwiki/index.php/Shortest-order_cook) &mdash; can save 2 turns on familiar test if lucky
* [packaged familiar scrapbook](https://kol.coldfront.net/thekolwiki/index.php/Packaged_familiar_scrapbook) &mdash; equip before using ten-percent bonus
* [Our Daily Candles&trade; order form](https://kol.coldfront.net/thekolwiki/index.php/Our_Daily_Candles%E2%84%A2_order_form) &mdash; class-dependent chance of 50% stat buff and/or 10 stats from combat
* [packaged industrial fire extinguisher](https://kol.coldfront.net/thekolwiki/index.php/Packaged_industrial_fire_extinguisher) &mdash; 30 turns saved on hot test with saber and 3 more turns by itself
* [packaged cold medicine cabinet](https://kol.coldfront.net/thekolwiki/index.php/Packaged_cold_medicine_cabinet) &mdash; drinks a 30% stat booze from this for initial adventures and leveling help post-coil test
* [undrilled cosmic bowling ball](https://kol.coldfront.net/thekolwiki/index.php/Undrilled_cosmic_bowling_ball) &mdash; 50% stat gain in NEP; saves 1.67 adventures on item test; some extra item and meat gain during leveling fights
* [combat lover's locket lockbox](https://kol.coldfront.net/thekolwiki/index.php/Combat_lover%27s_locket_lockbox) &mdash; up to 3 monsters to fight to save wishes and time spent on fax
* [Undamaged Unbreakable Umbrella](https://kol.coldfront.net/thekolwiki/index.php/Undamaged_Unbreakable_Umbrella) &mdash; saves up to 1.7 turns on item test, 6 on combat test, 1 on weapon test, 0.5 on spell test
* [MayDay&trade; contract](https://kol.coldfront.net/thekolwiki/index.php/MayDay%E2%84%A2_contract) &mdash; can save up to 1.7 turns on item test on some classes

## Bugs?

## TODO (eventually)

* Genericise things to not assume whoever runs this has everything I do
* Better handling when overcapping a test, i.e. only use as much resources as needed and not more
* Purge cruft from changes done over time
* Add more IotMs and such as I get them

