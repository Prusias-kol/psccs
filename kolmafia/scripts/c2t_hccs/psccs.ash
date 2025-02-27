//psccs

since r27280;//closed-circuit pay phone

import <c2t_hccs_lib.ash>
import <c2t_hccs_resources.ash>
import <c2t_hccs_properties.ash>
import <c2t_hccs_aux.ash>
import <c2t_hccs_preAdv.ash>
import <c2t_lib.ash>
import <c2t_cast.ash>

int START_TIME = now_to_int();

//these are hardcoded into combat.ash as well
//Shadow rift leveling spot. Drops slightly more valuable
location shadowLevelingLoc = $location[Shadow Rift (The Nearby Plains)];
//Shadow rift 100% combat (for our purposes since boss replaces NC) zone so we aren't hardbound to thugndergnome
location shadow100Zone = $location[Shadow Rift (The Right Side of the Tracks)];

//wtb enum
int TEST_HP = 1;
int TEST_MUS = 2;
int TEST_MYS = 3;
int TEST_MOX = 4;
int TEST_FAMILIAR = 5;
int TEST_WEAPON = 6;
int TEST_SPELL = 7;
int TEST_NONCOMBAT = 8;
int TEST_ITEM = 9;
int TEST_HOT_RES = 10;
int TEST_COIL_WIRE = 11;


string[12] TEST_NAME;
TEST_NAME[TEST_COIL_WIRE] = "Coil Wire";
TEST_NAME[TEST_HP] = "Donate Blood";
TEST_NAME[TEST_MUS] = "Feed The Children";
TEST_NAME[TEST_MYS] = "Build Playground Mazes";
TEST_NAME[TEST_MOX] = "Feed Conspirators";
TEST_NAME[TEST_ITEM] = "Make Margaritas";
TEST_NAME[TEST_HOT_RES] = "Clean Steam Tunnels";
TEST_NAME[TEST_FAMILIAR] = "Breed More Collies";
TEST_NAME[TEST_NONCOMBAT] = "Be a Living Statue";
TEST_NAME[TEST_WEAPON] = "Reduce Gazelle Population";
TEST_NAME[TEST_SPELL] = "Make Sausage";


void c2t_hccs_init();
void c2t_hccs_exit();
boolean c2t_hccs_preCoil();
boolean c2t_hccs_buffExp();
boolean c2t_hccs_levelup();
boolean c2t_hccs_allTheBuffs();
boolean c2t_hccs_lovePotion(boolean useit);
boolean c2t_hccs_lovePotion(boolean useit,boolean dumpit);
boolean c2t_hccs_preHp();
boolean c2t_hccs_preMus();
boolean c2t_hccs_preMys();
boolean c2t_hccs_preMox();
boolean c2t_hccs_preItem();
boolean c2t_hccs_preHotRes();
boolean c2t_hccs_preFamiliar();
boolean c2t_hccs_preNoncombat();
boolean c2t_hccs_preSpell();
boolean c2t_hccs_preWeapon();
void c2t_hccs_testHandler(int test);
boolean c2t_hccs_testDone(int test);
void c2t_hccs_doTest(int test);
void c2t_hccs_fights();
boolean c2t_hccs_wandererFight();
int c2t_hccs_testTurns(int test);
boolean c2t_hccs_thresholdMet(int test);
void c2t_hccs_mod2log(string str);
void c2t_hccs_printRunTime(boolean final);
void c2t_hccs_printRunTime() c2t_hccs_printRunTime(false);
boolean c2t_hccs_fightGodLobster();
void c2t_hccs_breakfast();
void c2t_hccs_printTestData();
void c2t_hccs_testData(string testType,int testNum,int turnsTaken,int turnsExpected);
familiar c2t_hccs_levelingFamiliar(boolean safeOnly);
boolean acquireInnerElf();
int webScrapeAdvCost(int whichtest);


void main() {
	c2t_assert(my_path() == "Community Service","Not in Community Service. Aborting.");

	try {
		c2t_hccs_init();

		c2t_hccs_testHandler(TEST_COIL_WIRE);

		//TODO maybe reorder stat tests based on hardest to achieve for a given class or mainstat
		print('Checking test ' + TEST_MOX + ': ' + TEST_NAME[TEST_MOX],'blue');
		if (!get_property('csServicesPerformed').contains_text(TEST_NAME[TEST_MOX])) {
			c2t_hccs_levelup();
			c2t_hccs_lovePotion(true);
			c2t_hccs_fights();
			c2t_hccs_testHandler(TEST_MOX);
		}

		c2t_hccs_testHandler(TEST_MYS);
		c2t_hccs_testHandler(TEST_MUS);
		c2t_hccs_testhandler(TEST_HP);

		//best time to open guild as SC if need be, or fish for wanderers, so warn and abort if < 93% spit
		if (c2t_hccs_melodramedary() && get_property('camelSpit').to_int() < 93 && !get_property("_c2t_hccs_earlySpitWarn").to_boolean())
			print('Camel spit only at '+get_property('camelSpit')+'%',"red");
		set_property("_c2t_hccs_earlySpitWarn","true");

		//NC before familiar for the reward to save 4 turns
		c2t_hccs_testHandler(TEST_NONCOMBAT);

		//feeling lost removed
		//item after NC/before familiar to burn autumn leaf +5% combat chance
		c2t_hccs_testHandler(TEST_ITEM);
		//ungulith fought here
		c2t_hccs_testHandler(TEST_FAMILIAR);
		//hot before weapon/spell to keep crush what i crush effect
		c2t_hccs_testHandler(TEST_HOT_RES);
		c2t_hccs_testHandler(TEST_WEAPON);
		c2t_hccs_testHandler(TEST_SPELL);



		//final service here
		if (!get_property('c2t_hccs_skipFinalService').to_boolean())
			c2t_hccs_doTest(30);

		print('Should be done with the Community Service run','blue');
	}
	finally
		c2t_hccs_exit();
}


void c2t_hccs_printRunTime(boolean f) {
	int t = now_to_int() - START_TIME;
	print(`psccs {f?"took":"has taken"} {t/60000} minute(s) {(t%60000)/1000.0} second(s) to execute{f?"":" so far"}.`,"blue");
}

void c2t_hccs_mod2log(string str) {
	if (get_property("c2t_hccs_printModtrace").to_boolean())
		logprint(cli_execute_output(str));
}

//limited breakfast to only what might be used
void c2t_hccs_breakfast() {
	//needed for potion crafting
	if (get_property("reagentSummons").to_int() == 0)
		c2t_hccs_haveUse(1,$skill[advanced saucecrafting]);

	//crimbo candy
	if (c2t_hccs_sweetSynthesis() && get_property("_candySummons").to_int() == 0)
		c2t_hccs_haveUse(1,$skill[summon crimbo candy]);

	//limes
	if (my_primestat() == $stat[muscle] && !get_property("_preventScurvy").to_boolean())
		c2t_hccs_haveUse(1,$skill[prevent scurvy and sobriety]);

	//mys classes want the D
	if (my_primestat() == $stat[mysticality] && get_property("noodleSummons").to_int() == 0)
		c2t_hccs_haveUse(1,$skill[pastamastery]);

	//mox class stat boost for leveling
	if (my_primestat() == $stat[moxie] && !get_property("_rhinestonesAcquired").to_boolean())
		c2t_hccs_haveUse(1,$skill[acquire rhinestones]);

	//peppermint garden
	if (c2t_hccs_gardenPeppermint())
		cli_execute("garden pick");
}

//assumes owns KGB, eight days a week (prevent hit, many substitutes), and lil doc bag
boolean acquireInnerElf() {
	//inner elf shenanigans
	if(have_familiar($familiar[machine elf]) && have_effect($effect[Inner Elf]) == 0) {
		c2t_hccs_joinClan(get_property("c2t_hccs_prusias_slimeClan"));
		use_familiar($familiar[machine elf]);
		//items
		item slotacc1 = equipped_item($slot[acc1]);
		item slotacc2 = equipped_item($slot[acc2]);
		item slotacc3 = equipped_item($slot[acc3]);
		item shirt = equipped_item($slot[shirt]);
		if (item_amount($item[Eight Days a Week Pill Keeper]) > 0) {
			equip($slot[acc1], $item[Eight Days a Week Pill Keeper]);
		}
		if (item_amount($item[10166]) > 0) {
			equip($slot[acc2], $item[10166]); //lil doc bag
		}
		if (item_amount($item[Kremlin's Greatest Briefcase]) > 0) {
			equip($slot[acc3], $item[Kremlin's Greatest Briefcase]);
		}
		if (item_amount($item[Jurassic Parka]) > 0) {
			equip($slot[shirt], $item[Jurassic Parka]);
		}
		//get inner elf
		adv1($location[The Slime Tube],-1,"");
		//reequip items
		equip($slot[acc1], slotacc1);
		equip($slot[acc2], slotacc2);
		equip($slot[acc3], slotacc3);
		equip($slot[shirt], shirt);
		//rejoin Redemption City
		c2t_hccs_joinClan(get_property("c2t_hccs_prusias_homeClan"));
	}
	if (have_effect($effect[Inner Elf]) > 0)
		return true;
	else
		return false; //failed somehow
}

boolean c2t_hccs_fightGodLobster() {
	if (!have_familiar($familiar[god lobster]))
		return false;

	if (get_property('_godLobsterFights').to_int() < 3) {
		use_familiar($familiar[god lobster]);
		maximize("mainstat,-equip garbage shirt,6 bonus designer sweatpants",false);

		// fight and get equipment
		c2t_setChoice(1310,1);//get equipment

		item temp = c2t_priority($item[god lobster's ring],$item[god lobster's scepter],$item[astral pet sweater]);
		if (temp != $item[none])
			equip($slot[familiar],temp);

		//combat & choice
		c2t_hccs_preAdv();
		visit_url('main.php?fightgodlobster=1');
		run_turn();
		if (choice_follows_fight())
			run_choice(-1);
		c2t_setChoice(1310,0);//unset

		//should have gotten runproof mascara as moxie from globster
		if (my_primestat() == $stat[moxie])
			c2t_hccs_getEffect($effect[unrunnable face]);

		return true;
	}
	return false;
}

void c2t_hccs_testHandler(int test) {
	print('Checking test ' + test + ': ' + TEST_NAME[test],'blue');
	if (get_property('csServicesPerformed').contains_text(TEST_NAME[test]))
		return;

	string type;
	int turns,before,expected;
	boolean met = false;

	//wanderer fight(s) before prepping stuff
	while (my_turncount() >= 60 && c2t_hccs_wandererFight());

	//combat familiars will slaughter everything; so make sure they're inactive at the start of test sections, since not every combat bothers with familiar checks
	c2t_hccs_levelingFamiliar(true);

	print('Running pre-'+TEST_NAME[test]+' stuff...','blue');
	switch (test) {
		case TEST_HP:
			met = c2t_hccs_preHp();
			type = "HP";
			break;
		case TEST_MUS:
			met = c2t_hccs_preMus();
			type = "mus";
			break;
		case TEST_MYS:
			met = c2t_hccs_preMys();
			type = "mys";
			break;
		case TEST_MOX:
			met = c2t_hccs_preMox();
			type = "mox";
			break;
		case TEST_FAMILIAR:
			met = c2t_hccs_preFamiliar();
			type = "familiar";
			c2t_hccs_mod2log("modtrace familiar weight");
			break;
		case TEST_WEAPON:
			met = c2t_hccs_preWeapon();
			type = "weapon";
			c2t_hccs_mod2log("modtrace weapon damage");
			break;
		case TEST_SPELL:
			met = c2t_hccs_preSpell();
			type = "spell";
			c2t_hccs_mod2log("modtrace spell damage");
			break;
		case TEST_NONCOMBAT:
			met = c2t_hccs_preNoncombat();
			type = "noncombat";
			c2t_hccs_mod2log("modtrace combat rate");
			break;
		case TEST_ITEM:
			met = c2t_hccs_preItem();
			type = "item";
			c2t_hccs_mod2log("modtrace item drop;modtrace booze drop");
			break;
		case TEST_HOT_RES:
			met = c2t_hccs_preHotRes();
			type = "hot resist";
			c2t_hccs_mod2log("modtrace hot resistance");
			break;
		case TEST_COIL_WIRE:
			met = c2t_hccs_preCoil();
			break;
		default:
			abort('Something went horribly wrong with the test handler');
	}
	if (get_property("c2t_hccs_haltBeforeTest").to_boolean())
		abort(`Halting. Double-check test {test}: {TEST_NAME[test]} ({type})`);

	expected = turns = c2t_hccs_testTurns(test);
	if (turns < 1) {
		if (test > 4) //ignore over-capping stat tests
			print(`Notice: over-capping the {type} test by {1-turns} {1-turns==1?"turn":"turns"} worth of resources.`,'blue');
		turns = 1;
	}

	if (!met) {
		print("Attempting to web scrape for comparison");
		print("Web parse result: "+ webScrapeAdvCost(test));
		abort(`Pre-{TEST_NAME[test]} ({type}) test fail. Currently only can complete the test in {turns} {turns==1?"turn":"turns"}.`);
	}

	if (test != TEST_COIL_WIRE)
		print(`Test {test}: {TEST_NAME[test]} ({type}) is at or below the threshold at {turns} {turns==1?"turn":"turns"}. Running the task...`);
	else
		print("Running the coiling wire task for 60 turns...");

	//do the test and verify after
	before = my_turncount();
	c2t_hccs_doTest(test);
	if (my_turncount() - before > turns)
		print("Notice: the task took more turns than expected, but still below the threshold, so continuing.");

	//record data for post-run:
	c2t_hccs_testData(type,test,my_turncount() - before,expected);

	c2t_hccs_printRunTime();
}


//store results of tests
void c2t_hccs_testData(string testType,int testNum,int turnsTaken,int turnsExpected) {
	if (testNum == TEST_COIL_WIRE)
		return;

	set_property("_c2t_hccs_testData",get_property("_c2t_hccs_testData")+(get_property("_c2t_hccs_testData") == ""?"":";")+`{testType},{testNum},{turnsTaken},{turnsExpected}`);
}

//print results of tests
void c2t_hccs_printTestData() {
	string [int] d;
	string pulls = get_property("_roninStoragePulls");
	string wishes = get_property("_psccs_wishes_used");
	string synths = get_property("_psccs_synths_used");
	string clipArts = get_property("_psccs_clipArts_used");

	print("");
	if (clipArts != "") {
		print("Clip Arts used this run:", "teal");
		foreach i,x in split_string(clipArts,",")
			print(x);
		print("");
	}
	if (pulls != "") {
		print("Pulls used this run:", "teal");
		foreach i,x in split_string(pulls,",")
			print(x.to_item());
		print("");
	}
	if (wishes != "") {
		print("Wishes used this run:", "teal");
		foreach i,x in split_string(wishes,",")
			print(x);
		print("");
	}
	print("Summary of tests:", "teal");
	print("Casting simmering took 1 turn.");
	foreach i,x in split_string(get_property("_c2t_hccs_testData"),";") {
		d = split_string(x,",");
		print(`{d[0]} test took {d[2]} turn(s){to_int(d[1]) > 4 && to_int(d[3]) < 1?"; it's being overcapped by "+(1-to_int(d[3]))+" turn(s) of resources":""}`);
	}
	print(`{my_daycount()}/{turns_played()} turns as {my_class()}`);
	print(`Organ use: {my_fullness()}/{my_inebriety()}/{my_spleen_use()}`);
}

//precursor to facilitate using only as many resources as needed and not more
int c2t_hccs_testTurns(int test) {
	int num;
	switch (test) {
		default:
			abort('Something broke with checking turns on test '+test);
		case TEST_HP:
			return (60 - (my_maxhp() - my_buffedstat($stat[muscle]) + 3)/30);
		case TEST_MUS:
			return (60 - (my_buffedstat($stat[muscle]) - my_basestat($stat[muscle]))/30);
		case TEST_MYS:
			return (60 - (my_buffedstat($stat[mysticality]) - my_basestat($stat[mysticality]))/30);
		case TEST_MOX:
			return (60 - (my_buffedstat($stat[moxie]) - my_basestat($stat[moxie]))/30);
		case TEST_FAMILIAR:
			return (60 - floor((numeric_modifier('familiar weight')+familiar_weight(my_familiar()))/5));
		case TEST_WEAPON:
			num = (have_effect($effect[bow-legged swagger]) > 0?25:50);
			int calc_wep_val =  (60 - floor(numeric_modifier('weapon damage') / num + 0.001) - floor(numeric_modifier('weapon damage percent') / num + 0.001));
			int scrape_wep_val = webScrapeAdvCost(test);
			if (scrape_wep_val < calc_wep_val)
				return scrape_wep_val;
			else
				return calc_wep_val;
		case TEST_SPELL:
			return (60 - floor(numeric_modifier('spell damage') / 50 + 0.001) - floor(numeric_modifier('spell damage percent') / 50 + 0.001));
		case TEST_NONCOMBAT:
			num = -round(numeric_modifier('combat rate'));
			return (60 - (num > 25?(num-25)*3+15:num/5*3));
		case TEST_ITEM:
			return (60 - floor(numeric_modifier('Booze Drop') / 15 + 0.001) - floor(numeric_modifier('Item Drop') / 30 + 0.001));
		case TEST_HOT_RES:
			return (60 - floor(numeric_modifier('hot resistance')));
		case TEST_COIL_WIRE:
			return 60;
		case 30://final service in case that gets checked
			return 0;
	}
}

// from https://github.com/Malurth/Auto-2-day-HCCS/blob/master/scripts/AutoHCCS.ash
int webScrapeAdvCost(int whichtest) {
  buffer page = visit_url("council.php");
  string teststr = "name=option value="+ whichtest +">";
  if (contains_text(page, teststr)) {
    int chars = 140; //chars to look ahead
    string pagestr = substring(page, page.index_of(teststr)+length(teststr), page.index_of(teststr)+length(teststr)+chars);
    string advstr = substring(pagestr, pagestr.index_of("(")+1, pagestr.index_of("(")+3);
    advstr = replace_string(advstr, " ", ""); //removes whitespace, if the test is < 10 adv
    return to_int(advstr);
  } else {
    print("[ERROR] Didn't find specified test on the council page. Already done?");
    return 99999;
  }
}

boolean c2t_hccs_thresholdMet(int test) {
	if (test == TEST_COIL_WIRE || test == 30)
		return true;

	//modtrace to refresh value
	switch (test) {
		case TEST_ITEM:
			set_location($location[The Sleazy Back Alley]);
			cli_execute("modtrace item drop;modtrace booze drop");
			break;
		}
	string [int] arr = split_string(get_property('c2t_hccs_thresholds'),",");

	if (count(arr) == 10 && arr[test-1].to_int() > 0 && arr[test-1].to_int() <= 60)
		return (webScrapeAdvCost(test) <= arr[test-1].to_int());
	else {
		print("Warning: the c2t_hccs_thresholds property is broken for this test; defaulting to a 1-turn threshold.","red");
		return (c2t_hccs_testTurns(test) <= 1);
	}
}


//sets and backup some settings on start
void c2t_hccs_init() {
	string [string] prefs = {
		//buy from NPCs
		"autoSatisfyWithNPCs":"true",
		"autoSatisfyWithCoinmasters":"true",
		//automation scripts
		"choiceAdventureScript":"c2t_hccs_choices.ash",
		"betweenBattleScript":"c2t_hccs_preAdv.ash",
		"afterAdventureScript":"c2t_hccs_postAdv.ash",
		"recoveryScript":"",
		//recovery
		"hpAutoRecoveryItems":"cannelloni cocoon;tongue of the walrus;disco nap",
		"hpAutoRecovery":"0.6",
		"hpAutoRecoveryTarget":"0.9",
		"mpAutoRecoveryItems":"",
		"manaBurningThreshold":"-0.05",
		//combat
		//"battleAction":"custom combat script",
		//"customCombatScript":"c2t_hccs"
	};

	//only save pre-coil states of these
	if (get_property("csServicesPerformed") == "") {
		//clan
		if (get_clan_id() != get_property('c2t_hccs_joinClan').to_int())
			set_property('_saved_joinClan',get_clan_id());
		//custom combat script
		if (get_property('battleAction') != "custom combat script")
			set_property('_saved_battleAction',get_property('battleAction'));
		if (get_property('customCombatScript') != "c2t_hccs")
			set_property('_saved_customCombatScript',get_property('customCombatScript'));
	}
	set_property('battleAction',"custom combat script");
	set_property('customCombatScript',"c2t_hccs");

	//backup user settings and set script settings
	foreach key,val in prefs {
		set_property(`_saved_{key}`,get_property(key));
		set_property(key,val);
	}

	visit_url('council.php');// Initialize council.
}

//restore settings on exit
void c2t_hccs_exit() {
	boolean [string] prefs = $strings[
		autoSatisfyWithNPCs,
		autoSatisfyWithCoinmasters,
		choiceAdventureScript,
		betweenBattleScript,
		afterAdventureScript,
		recoveryScript,
		hpAutoRecoveryItems,
		hpAutoRecovery,
		hpAutoRecoveryTarget,
		mpAutoRecoveryItems,
		manaBurningThreshold
	];
	//restore user settings
	foreach key in prefs
		set_property(key,get_property(`_saved_{key}`));

	//don't want CS moods running during manual intervention or when fully finished
	cli_execute('mood apathetic');

	//restore some things only when all tests are done
	if (get_property("csServicesPerformed").split_string(",").count() == 11) {
		if (property_exists('_saved_battleAction'))
			set_property('battleAction',get_property('_saved_battleAction'));
		if (property_exists('_saved_customCombatScript'))
			set_property('customCombatScript',get_property('_saved_customCombatScript'));
		if (property_exists("_saved_joinClan"))
			c2t_joinClan(get_property("_saved_joinClan").to_int());
		c2t_hccs_printTestData();
		if (get_property("_c2t_hccs_failSpit").to_boolean())
			print(`Info: camel was not fully charged when it was needed; charge is at {get_property("camelSpit")}%`,"blue");
	}
	if (get_property("shockingLickCharges").to_int() > 0)
		print(`Info: shocking lick charge count from batteries is {get_property("shockingLickCharges")}`,"blue");

	c2t_hccs_printRunTime(true);
}

boolean c2t_hccs_preCoil() {
	

	//numberology first thing to get adventures
	c2t_hccs_useNumberology();

	// mayam calendar
	if (item_amount($item[Mayam Calendar]) > 0) {
		if (get_property("mayamSymbolsUsed") == "") {
			// yam battery
			cli_execute("mayam rings yam lightning yam clock");
			// stuffed yam stinkbomb
			cli_execute("mayam rings vessel yam cheese explosion");
			// remainder
			if (have_familiar($familiar[chest mimic])) {
				// xp for chest mimic
				use_familiar($familiar[chest mimic]);
				cli_execute("mayam rings fur meat eyepatch yam");
			} else {
				// free rests for cincho/mp
				cli_execute("mayam rings chair meat eyepatch yam");
			}
			
		}
	}

	//activate zones
	if (!get_property("_prusias_psccs_charterZonesUnlocked").to_boolean()) {
		if (get_property("stenchAirportAlways").to_boolean()) {
			adv1($location[The Toxic Teacups],-1);
		}
		set_property("_prusias_psccs_charterZonesUnlocked", "true");
	}

	//install workshed
	item workshed = get_property("c2t_hccs_workshed").to_item();
	if (workshed != $item[none] && get_workshed() == $item[none]) {
		//sanity check
		if ($items[cold medicine cabinet,diabolic pizza cube,model train set,Asdon Martin keyfob (on ring)] contains workshed)
			use(workshed);
	}

	//get a grain of sand for pizza if muscle class
	if (available_amount($item[beach comb]) > 0
		&& my_primestat() == $stat[muscle]
		&& available_amount($item[grain of sand]) == 0
		&& available_amount($item[gnollish autoplunger]) == 0
		) {
		print("Getting grain of sand from the beach","blue");
		while (get_property('_freeBeachWalksUsed').to_int() < 5 && available_amount($item[grain of sand]) == 0)
			//arbitrary location
			cli_execute('beach wander 8;beach comb 8 8');
		cli_execute('beach exit');
		c2t_assert(available_amount($item[grain of sand]) > 0,"Did not obtain a grain of sand for pizza on muscle class.");
	}

	//autumn-aton for autumn leaf
	if (available_amount($item[autumn-aton]) == 1 && available_amount($item[autumn leaf]) == 0)
		cli_execute("fallguy send The Sleazy Back Alley");

	//vote
	c2t_hccs_vote();

	//source terminal
	c2t_hccs_sourceTerminalInit();

	//SIT
	if (available_amount($item[s.i.t. course completion certificate]) > 0
		&& !get_property("_sitCourseCompleted").to_boolean())
	{
		use($item[s.i.t. course completion certificate]);
	}

	//CLAN VIP CONSULT HANDLING
	int originalClanId = get_clan_id();
	boolean consulted = false;
	if (get_property('_clanFortuneConsultUses').to_int() < 3) {
		c2t_hccs_joinClan(get_property("c2t_hccs_joinClan"));

		string fortunes = get_property("c2t_hccs_clanFortunes");

		if (is_online(fortunes))
			while (get_property('_clanFortuneConsultUses').to_int() < 3) {
				if (contains_text(fortunes, " ")) {
					cli_execute(`fortune {fortunes};wait 5`);
				}
				else {
					//word match for Cheesefax
					cli_execute(`fortune {fortunes} pizza b thick;wait 10`);
				}
			}
		else
			print(`{fortunes} is not online; skipping fortunes`,"red");
	}
	//rejoin Redemption City
	c2t_hccs_joinClan(get_property("c2t_hccs_prusias_homeClan"));

	//fax
	// Disabled because fax = 1 KGE while combat lover, only 1 fight = KGE
	// if (!get_property('_photocopyUsed').to_boolean() && item_amount($item[photocopied monster]) == 0) {
	// 	if (available_amount($item[industrial fire extinguisher]) > 0 && available_amount($item[fourth of may cosplay saber]) > 0) {
	// 		if (!(get_locket_monsters() contains $monster[ungulith]))
	// 			c2t_hccs_getFax($monster[ungulith]);
	// 	}
	// 	else if (is_online("cheesefax")) {
	// 		if (!(get_locket_monsters() contains $monster[factory worker (female)]))
	// 			c2t_hccs_getFax($monster[factory worker (female)]);
	// 	}
	// 	else {
	// 		if (!(get_locket_monsters() contains $monster[ungulith]))
	// 			c2t_hccs_getFax($monster[ungulith]);
	// 	}
	// }

	c2t_hccs_haveUse($skill[spirit of peppermint]);

	//fish hatchet
	if (c2t_hccs_vipFloundry())
		if (!get_property('_floundryItemCreated').to_boolean() && !retrieve_item(1,$item[fish hatchet]))
			print('Failed to get a fish hatchet',"red");

	//cod piece steps
	/*if (!retrieve_item(1,$item[fish hatchet])) {
		retrieve_item(1,$item[codpiece]);
		c2t_hccs_haveUse(1,$item[codpiece]);
		c2t_hccs_haveUse(8,$item[bubblin' crude]);
		autosell(1,$item[oil cap]);
	}*/

	c2t_hccs_haveUse($item[astral six-pack]);

	//pantagramming
	c2t_hccs_pantogram();

	//backup camera settings
	if (get_property('backupCameraMode') != 'ml' || !get_property('backupCameraReverserEnabled').to_boolean())
		cli_execute('try;backupcamera ml;backupcamera reverser on');

	//knock-off hero cape thing
	if (available_amount($item[unwrapped knock-off retro superhero cape]) > 0)
		cli_execute('retrocape '+my_primestat());

	//ebony epee from lathe
	if (available_amount($item[ebony epee]) == 0) {
		if (item_amount($item[spinmaster&trade; lathe]) > 0) {
			visit_url('shop.php?whichshop=lathe');
			retrieve_item(1,$item[ebony epee]);
		}
	}

	//FantasyRealm hat
	if (get_property("frAlways").to_boolean() && available_amount($item[fantasyrealm g. e. m.]) == 0) {
		visit_url('place.php?whichplace=realm_fantasy&action=fr_initcenter');
		if (my_primestat() == $stat[muscle])
			run_choice(1);//1280,1 warrior; 1280,2 mage
		else if (my_primestat() == $stat[mysticality])
			run_choice(2);
		else if (my_primestat() == $stat[moxie])
			run_choice(3);//a guess
	}

	//boombox meat
	if (item_amount($item[songboom&trade; boombox]) > 0 && get_property('boomBoxSong') != 'Total Eclipse of Your Meat')
		cli_execute('boombox meat');

	// upgrade saber for familiar weight
	if (get_property('_saberMod').to_int() == 0) {
		visit_url('main.php?action=may4');
		run_choice(4);
	}

	// Sell pork gems
	visit_url('tutorial.php?action=toot');
	c2t_hccs_haveUse($item[letter from king ralph xi]);
	c2t_hccs_haveUse($item[pork elf goodies sack]);
	if (my_meat() < 2500) {//don't autosell if there is some other source of meat
		autosell(5,$item[baconstone]);
		autosell(5,$item[hamethyst]);
		if (c2t_hccs_pizzaCube())
			autosell(5,$item[porquoise]);
	}

	if (my_meat() < 1500)
		autosell(1,$item[porquoise]);

	//buy toy accordion
	if (my_class() != $class[accordion thief])
		retrieve_item(1,$item[toy accordion]);

	// equip mp stuff
	maximize("mp,-equip kramco sausage-o-matic&trade;,-equip i voted",false);

	// should have enough MP for this much; just being lazy here for now
	c2t_hccs_getEffect($effect[the magical mojomuscular melody]);

	//breakfasty things
	c2t_hccs_breakfast();

	// pre-coil pizza to get imitation whetstone for INFE pizza latter
	if (c2t_hccs_pizzaCube() && my_fullness() == 0) {
		// get imitation crab
		use_familiar($familiar[imitation crab]);

		// make pizza
		if (item_amount($item[diabolic pizza]) == 0) {
			retrieve_item(3,$item[cog and sprocket assembly]);

			if (available_amount($item[blood-faced volleyball]) == 0) {
				hermit(1,$item[volleyball]);

				if (have_effect($effect[bloody hand]) == 0) {
					hermit(1,$item[seal tooth]);
					c2t_hccs_getEffect($effect[bloody hand]);
				}
				use(1,$item[volleyball]);
			}

			c2t_hccs_pizzaCube(
				$item[cog and sprocket assembly],
				$item[cog and sprocket assembly],
				$item[cog and sprocket assembly],
				$item[blood-faced volleyball]
				);
		}
		else
			eat(1,$item[diabolic pizza]);
		c2t_hccs_levelingFamiliar(true);
	}
	//cold medicine cabinet; grabbing a stat booze to get some adventures post-coil
	else
		c2t_hccs_coldMedicineCabinet("drink");

	// need to fetch and drink some booze pre-coil. using semi-rare via pillkeeper in sleazy back alley
	/* going to be using borrowed time, so no longer need
	if (my_turncount() == 0) {
		cli_execute('pillkeeper semirare');
		if (get_property('semirareCounter').to_int() > 0) //does not work?
			abort('Semirare should be now. Something went wrong.');
		cli_execute('mood apathetic');
		cli_execute('counters nowarn Fortune Cookie');
		//maybe recover before this?
		adv1($location[the sleazy back alley], -1, '');
	}

	// drinking
	if (my_inebriety() == 0 && available_amount($item[distilled fortified wine]) >= 2) {
		if (have_effect($effect[ode to booze]) < 2) {
			if (my_mp() < 50) { //this block is assuming my setup w/ getaway camp
				cli_execute('breakfast');

				//cli_execute('rest free'); //<-- DANGEROUS
				if (get_property('timesRested') < total_free_rests())
					visit_url('place.php?whichplace=campaway&action=campaway_tentclick');
			}
			if (!use_skill(1,$skill[the ode to booze]))
				abort("couldn't cast ode to booze");
		}
		drink(2,$item[distilled fortified wine]);
	}
	*/

	//sometimes runs out of mp for clip art
	if (my_mp() < 11)
		cli_execute('rest free');

	// first tome use // borrowed time
	if (!get_property('_borrowedTimeUsed').to_boolean() && c2t_hccs_tomeClipArt($item[borrowed time]))
		use(1,$item[borrowed time]);

	// second tome use // box of familiar jacks
	// going to get camel equipment straight away
	if (c2t_hccs_melodramedary()
		&& available_amount($item[dromedary drinking helmet]) == 0
		&& c2t_hccs_tomeClipArt($item[box of familiar jacks])
		&& (have_familiar($familiar[Artistic Goth Kid]) || have_familiar($familiar[Mini-Hipster]))) {

		use_familiar($familiar[melodramedary]);
		use(1,$item[box of familiar jacks]);
	} else if (available_amount($item[cold-filtered water]) == 0 && have_effect($effect[Purity of Spirit]) == 0
	&& c2t_hccs_tomeClipArt($item[cold-filtered water])) {
		use(1,$item[cold-filtered water]);
	}

	//aprilband
	if (have_effect($effect[Apriling Band Patrol Beat]) == 0) {
		cli_execute("aprilband effect nc");
	}

	

	while (c2t_hccs_wandererFight());

	// get love potion before moving ahead, then dump if bad
	c2t_hccs_lovePotion(false,true);

	return true;
}

// get experience buffs prior to using items that give exp
boolean c2t_hccs_buffExp() {
	print('Getting experience buffs');
	// boost mus exp
	if (have_effect($effect[that's just cloud-talk, man]) == 0)
		visit_url('place.php?whichplace=campaway&action=campaway_sky');
	if (have_effect($effect[that's just cloud-talk, man]) == 0)
		abort('Getaway camp buff failure');


	// shower exp buff
	if (!get_property('_aprilShower').to_boolean())
		cli_execute('shower '+my_primestat());

	//TODO make synthesize selections smarter so the item one doesn't have to be so early
	//synthesize item //put this before all other syntheses so the others don't use too many sprouts
	//c2t_hccs_sweetSynthesis($effect[synthesis: collection]);

	if (my_primestat() == $stat[muscle]) {
		//exp buff via pizza or wish
		if (!c2t_hccs_pizzaCube($effect[hgh-charged]))
			c2t_hccs_genie($effect[hgh-charged]);

		// mus exp synthesis
		if (!get_property("c2t_hccs_prusias_disable.levelingSynthesis").to_boolean() && !c2t_hccs_sweetSynthesis($effect[synthesis: movement]))
			print('Failed to synthesize exp buff','red');

		if (numeric_modifier('muscle experience percent') < 49.999) {
			abort('Insufficient +exp%');
			return false;
		}
	}
	else if (my_primestat() == $stat[mysticality]) {
		//exp buff via pizza or wish
		//if (my_class() != $class[pastamancer])
			if (!c2t_hccs_pizzaCube($effect[different way of seeing things]))
				c2t_hccs_genie($effect[different way of seeing things]);

		// mys exp synthesis
		if (!get_property("c2t_hccs_prusias_disable.levelingSynthesis").to_boolean() && !c2t_hccs_sweetSynthesis($effect[synthesis: learning]))
			print('Failed to synthesize exp buff','red');

		//face
		c2t_hccs_getEffect($effect[inscrutable gaze]);

		if (numeric_modifier('mysticality experience percent') < 59.999) {
			abort('Insufficient +exp%');
			return false;
		}
	}
	else if (my_primestat() == $stat[moxie]) {
		//stat buff via pizza cube or exp buff via wish
		if (!c2t_hccs_pizzaCube($effect[knightlife]))
			c2t_hccs_genie($effect[thou shant not sing]);

		// mox exp synthesis
		// hardcore will be dropped if candies not aligned properly
		if (!c2t_hccs_sweetSynthesis($effect[synthesis: style]))
			print('Failed to synthesize exp buff','red');

		if (numeric_modifier('moxie experience percent') < 89.999) {
			abort('Insufficient +exp%');
			return false;
		}
		//return false;//want to check state at this point
	}

	return true;
}

// should handle leveling up and eventually call free fights
boolean c2t_hccs_levelup() {
	//CMC booze
	item itew = c2t_priority($item[doc's fortifying wine],$item[doc's smartifying wine],$item[doc's limbering wine]);
	if (itew != $item[none]) {
		c2t_hccs_getEffect($effect[ode to booze]);
		drink(1,itew);
	}
	//need adventures straight away if dangerously low
	else if (my_adventures() <= 1) {
		//TODO more booze options
		//eye and a twist from crimbo 2020
		c2t_hccs_haveUse($skill[eye and a twist]);
		if (item_amount($item[eye and a twist]) > 0)
			itew = $item[eye and a twist];

		c2t_assert(itew != $item[none],"could not get booze to get more adventures");

		c2t_hccs_getEffect($effect[ode to booze]);
		drink(1,itew);
	}
	c2t_assert(my_adventures() > 0,"not going to get far with zero adventures");

	if (my_level() < 7 && c2t_hccs_buffExp()) {
		if (item_amount($item[familiar scrapbook]) > 0)
			equip($item[familiar scrapbook]);
		c2t_hccs_haveUse($item[a ten-percent bonus]);
		cli_execute("refresh all");
	}
	if (my_level() < 7)
		abort('initial leveling broke');

	//some pulls if not in hard core; moxie would have already pulled up to 2 items so far
	if (my_primestat() == $stat[moxie] && pulls_remaining() > 3)
		c2t_hccs_pull($item[crumpled felt fedora]);//200 mox; saves 2 for fam test
	c2t_hccs_pull($item[repaid diaper]);
	if (available_amount($item[repaid diaper]) == 0)
		c2t_hccs_pull($item[great wolf's beastly trousers]);//100 mus; saves 2 for fam test
	//rechecking this sometime after leveling for non-mys since 150 mys is possible
	if (my_primestat() == $stat[muscle])
		c2t_hccs_pull($item[stick-knife of loathing]);//150 mus; saves 4 for spell test

	c2t_hccs_allTheBuffs();

	return true;
}

// initialise limited-use, non-mood buffs for leveling
boolean c2t_hccs_allTheBuffs() {
	// using MCD as a flag, what could possibly go wrong?
	if (current_mcd() >= 10)
		return true;

	print('Getting pre-fight buffs','blue');
	// equip mp stuff
	maximize("-equip kramco sausage-o-matic&trade;,mp",false);

	if (have_effect($effect[one very clear eye]) == 0) {
		while (c2t_hccs_wandererFight());//do vote monster if ready before spending turn
		if (c2t_hccs_cloverItem())
			c2t_hccs_getEffect($effect[one very clear eye]);
	}

	//emotion chip stat buff
	c2t_hccs_getEffect($effect[feeling excited]);

	c2t_hccs_getEffect($effect[the magical mojomuscular melody]);

	//mayday contract
	c2t_hccs_haveUse($item[mayday&trade; supply package]);
	//TODO reevaluate cost/benefit later
	c2t_hccs_haveUse($item[emergency glowstick]);
	//make early meat a non-issue if obtained
	autosell(1,$item[space blanket]);

	//boxing daycare stat gain
	if (get_property("daycareOpen").to_boolean() && get_property('_daycareGymScavenges').to_int() == 0) {
		visit_url('place.php?whichplace=town_wrong&action=townwrong_boxingdaycare');
		run_choice(3);//1334,3 boxing daycare lobby->boxing daycare
		run_choice(2);//1336,2 scavenge
	}

	//bastille
	if (item_amount($item[bastille battalion control rig]).to_boolean() && get_property('_bastilleGames').to_int() == 0)
		cli_execute('bastille mainstat brutalist gesture');

	//boxing day scavenge
	if (get_property('_daycareGymScavenges').to_int() == 0) {
		cli_execute("daycare scavenge free");
	}

	// getaway camp buff //probably causes infinite loop without getaway camp
	if (get_property('_campAwaySmileBuffs').to_int() == 0)
		visit_url('place.php?whichplace=campaway&action=campaway_sky');

	//monorail
	if (get_property('_lyleFavored') == 'false')
		c2t_hccs_getEffect($effect[favored by lyle]);

		//stat pillkeeper deprecated to save spleen
	if (my_class() == $class[seal clubber]) {
		c2t_hccs_pillkeeper($effect[hulkien]); //stats
	}
	//c2t_hccs_pillkeeper($effect[fidoxene]);//familiar
	//Fidoxene not profitable

	//beach comb leveling buffs
	if (available_amount($item[beach comb]) > 0) {
		c2t_hccs_getEffect($effect[you learned something maybe!]); //beach exp
		c2t_hccs_getEffect($effect[do i know you from somewhere?]);//beach fam wt
		if (my_primestat() == $stat[moxie])
			c2t_hccs_getEffect($effect[pomp & circumsands]);//beach moxie
	}

	//TODO only use bee's knees and other less-desirable buffs if below some buff threshold
	// Cast Ode and drink bee's knees
	// going to skip this for non-moxie to use clip art's buff of same strength
	if (my_primestat() == $stat[moxie] && have_effect($effect[on the trolley]) == 0) {
		c2t_assert(my_meat() >= 500,"Need 500 meat for speakeasy booze");
		c2t_hccs_getEffect($effect[ode to booze]);
		cli_execute("drink 1 bee's knees");
		//probably don't need to drink the perfect drink; have to double-check all inebriety checks before removing
		//drink(1,$item[perfect dark and stormy]);
		//cli_execute('drink perfect dark and stormy');
	}

	//just in case
	if (have_effect($effect[ode to booze]) > 0)
		cli_execute('shrug ode to booze');

	//SKIP fortune buff item
	// if (get_property('_clanFortuneBuffUsed') == 'false')
	// 	c2t_hccs_getEffect($effect[there's no n in love]);

	//cast triple size
	if (available_amount($item[powerful glove]) > 0 && have_effect($effect[triple-sized]) == 0 && !c2t_cast($skill[cheat code: triple size]))
		abort('Triple size failed');

	//boxing daycare buff
	if (get_property("daycareOpen").to_boolean() && !get_property("_daycareSpa").to_boolean())
		cli_execute(`daycare {my_primestat().to_lower_case()}`);

	//candles
	c2t_hccs_haveUse($item[napalm in the morning&trade; candle]);
	c2t_hccs_haveUse($item[votive of confidence]);

	//synthesis
	if (my_primestat() == $stat[muscle]) {
		if (!c2t_hccs_sweetSynthesis($effect[synthesis: strong]))
			print("Failed to synthesize stat buff","red");
	}
	else if (my_primestat() == $stat[mysticality]) {
		// if (!c2t_hccs_sweetSynthesis($effect[synthesis: smart]))
		// 	print("Failed to synthesize stat buff","red");
		cli_execute("acquire 1 glittery mascara");
		cli_execute("use 1 glittery mascara");
		c2t_hccs_pull($item[Calzone of Legend]); //replace smart synthesis
		cli_execute("eat 1 calzone of legend");
	}
	else if (my_primestat() == $stat[moxie]) {
		if (!c2t_hccs_sweetSynthesis($effect[synthesis: cool]))
			print("Failed to synthesize stat buff","red");
	}

	//third tome use //no longer using bee's knees for stat boost on non-moxie, but still need same strength buff?
	if (my_mp() < 11)
		cli_execute('rest free');
	// if (my_primestat() != $stat[mysticality] && have_effect($effect[purity of spirit]) == 0 && c2t_hccs_tomeClipArt($item[cold-filtered water]))
	// 	use(1,$item[cold-filtered water]);

	//rhinestones to help moxie leveling
	if (my_primestat() == $stat[moxie])
		use(item_amount($item[rhinestone]),$item[rhinestone]);

	c2t_hccs_levelingFamiliar(true);

	//cheap fam weight for leveling familiars
	//TODO: check mp
	use_skill(1, $skill[Leash of Linguini]);
	use_skill(1, $skill[Empathy of the Newt]);

	//telescope
	if (get_property("telescopeUpgrades").to_int() > 0 && !get_property("telescopeLookedHigh").to_boolean())
		cli_execute('telescope high');

	//Song of Bravado
	if (!c2t_hccs_getEffect($effect[song of bravado]))
		c2t_hccs_getEffect($effect[song of bravado]);

	cli_execute('mcd 10');

	return true;
}

boolean c2t_hccs_lovePotion(boolean useit) {
	return c2t_hccs_lovePotion(useit,false);
}

boolean c2t_hccs_lovePotion(boolean useit,boolean dumpit) {
	if (!have_skill($skill[love mixology]))
		return false;

	item love_potion = $item[love potion #XYZ];
	effect love_effect = $effect[tainted love potion];

	if (have_effect(love_effect) == 0) {
		if (available_amount(love_potion) == 0)
			c2t_hccs_haveUse($skill[love mixology]);

		visit_url('desc_effect.php?whicheffect='+love_effect.descid);

		if ((my_primestat() == $stat[muscle] &&
				(love_effect.numeric_modifier('mysticality').to_int() <= -50
				|| love_effect.numeric_modifier('muscle').to_int() <= 10
				|| love_effect.numeric_modifier('moxie').to_int() <= -50
				|| love_effect.numeric_modifier('maximum hp percent').to_int() <= -50))
			|| (my_primestat() == $stat[mysticality] &&
				(love_effect.numeric_modifier('mysticality').to_int() <= 10
				|| love_effect.numeric_modifier('muscle').to_int() <= -50
				|| love_effect.numeric_modifier('moxie').to_int() <= -50
				|| love_effect.numeric_modifier('maximum hp percent').to_int() <= -50))
			|| (my_primestat() == $stat[moxie] &&
				(love_effect.numeric_modifier('mysticality').to_int() <= -50
				|| love_effect.numeric_modifier('muscle').to_int() <= -50
				|| love_effect.numeric_modifier('moxie').to_int() <= 10
				|| love_effect.numeric_modifier('maximum hp percent').to_int() <= -50))) {
			if (dumpit) {
				use(1,love_potion);
				return true;
			}
			else {
				print('not using trash love potion','blue');
				return false;
			}
		}
		else if (useit) {
			use(1,love_potion);
			return true;
		}
		else {
			print('love potion should be good; holding onto it','blue');
			return false;
		}
	}
	//abort('error handling love potion');
	return false;
}

boolean c2t_hccs_preItem() {
	string maxstr = 'item,2 booze drop,-equip broken champagne bottle,-equip surprisingly capacious handbag,-equip red-hot sausage fork,switch left-hand man';
	//shrug off an AT buff
	cli_execute("shrug ur-kel");

	//Asdon Martin drive observantly
	if (get_workshed() == $item[Asdon Martin keyfob (on ring)] && have_effect($effect[driving observantly]) == 0) {
		while (get_fuel() < 37) {
			//fuel up
			if (available_amount($item[20-lb can of rice and beans]) > 0) {
				cli_execute("asdonmartin fuel 1 20-lb can of rice and beans");
			} else if (available_amount($item[loaf of soda bread]) > 0) {
				cli_execute("asdonmartin fuel 1 loaf of soda bread");
			} else if (available_amount($item[9948]) > 0) {
				//Middle of the Road Brand Whiskey from NEP
				cli_execute("asdonmartin fuel 1 Middle of the Road™ brand whiskey");
			} else if (available_amount($item[PB&J with the crusts cut off]) > 0) {
				cli_execute("asdonmartin fuel 1 PB&J with the crusts cut off");
			} else if (available_amount($item[swamp haunch]) > 0) {
				cli_execute("asdonmartin fuel 1 swamp haunch");
			} else if (available_amount($item[meadeorite]) > 0) {
				cli_execute("asdonmartin fuel 1 meadeorite");
			} else {
				cli_execute("abort");
				break;
			}
		}
		if (get_fuel() >= 37)
			cli_execute("asdonmartin drive observantly");
	}


	//get latte ingredient from fluffy bunny and cloake item buff
	if (have_effect($effect[feeling lost]) == 0
		&& ((available_amount($item[vampyric cloake]) > 0
				&& have_effect($effect[bat-adjacent form]) == 0)
			|| (!get_property('latteUnlocks').contains_text('carrot')
				&& !get_property("c2t_hccs_disable.latteFishing").to_boolean())))
	{
		maximize("mainstat,equip latte,1000 bonus lil doctor bag,1000 bonus kremlin's greatest briefcase,1000 bonus vampyric cloake,6 bonus designer sweatpants",false);
		familiar fam = c2t_hccs_levelingFamiliar(true);

		int start = my_turncount();
		//get buffs with combat skills
		if (c2t_hccs_banishesLeft() > 0
			&& ((have_equipped($item[vampyric cloake])
					&& have_effect($effect[bat-adjacent form]) == 0)
				|| (get_property("hasCosmicBowlingBall").to_boolean()
					&& get_property("cosmicBowlingBallReturnCombats").to_int() <= 1
					&& have_effect($effect[cosmic ball in the air]) == 0)))
		{
			adv1($location[the dire warren]);
		}
		//fish for latte ingredient
		while (c2t_hccs_banishesLeft() > 0
			&& !get_property('latteUnlocks').contains_text('carrot')
			&& !get_property("c2t_hccs_disable.latteFishing").to_boolean()
			&& start == my_turncount())
		{
			//bowling ball could return mid-fishing
			if (get_property("hasCosmicBowlingBall").to_boolean()
				&& get_property("cosmicBowlingBallReturnCombats").to_int() <= 1
				&& have_effect($effect[cosmic ball in the air]) == 0)
			{
				use_familiar(fam);
				adv1($location[the dire warren]);
			}
			//fish with runaways
			else if (have_familiar($familiar[pair of stomping boots])) {
				use_familiar($familiar[pair of stomping boots]);
				adv1($location[the dire warren],-1,"runaway;abort;");
			}
			//fish with banishes
			else {
				use_familiar(fam);//just in case
				adv1($location[the dire warren]);
			}
		}
		use_familiar(fam);
		if (start < my_turncount())
			abort("a turn was used while latte fishing in the item test prep");
	}

	if (!get_property('latteModifier').contains_text('Item Drop') && get_property('_latteBanishUsed') == 'true')
		cli_execute('latte refill cinnamon carrot vanilla');

	c2t_hccs_getEffect($effect[fat leon's phat loot lyric]);
	c2t_hccs_getEffect($effect[singer's faithful ocelot]);
	c2t_hccs_getEffect($effect[the spirit of taking]);

	// might move back to levelup part
	if (have_effect($effect[synthesis: collection]) == 0)//skip pizza if synth item
		c2t_hccs_pizzaCube($effect[certainty]);

	// might move back to level up part
	if (!c2t_hccs_pizzaCube($effect[infernal thirst]))
		c2t_hccs_genie($effect[infernal thirst]);

	//spice ghost
	if (have_skill($skill[bind spice ghost])) {
		//thralls dont count
		if (my_class() != $class[pastamancer]) {
			if (my_mp() < 250)
				cli_execute('eat magical sausage');
			c2t_hccs_getEffect($effect[spice haze]);
		}
	}

	//AT-only buff
	if (my_class() == $class[accordion thief] && have_skill($skill[the ballad of richie thingfinder]))
		ensure_song($effect[the ballad of richie thingfinder]);

	c2t_hccs_getEffect($effect[nearly all-natural]);//bag of grain CS reward
	c2t_hccs_getEffect($effect[steely-eyed squint]);

	//unbreakable umbrella
	c2t_hccs_unbreakableUmbrella("item");

	if (have_effect($effect[Apriling Band Celebration Bop]) == 0) {
		cli_execute("aprilband effect drop");
	}

	if (have_effect($effect[Crunching Leaves]) == 0 && available_amount($item[autumn leaf]) > 0) {
		c2t_hccs_getEffect($effect[Crunching Leaves]);
	}

// 	//if familiar test is ever less than 19 turns, feel lost will need to be completely removed or the test order changed
// 	c2t_hccs_getEffect($effect[feeling lost]);

	//Libram
	if (available_amount($item[lavender candy heart]) > 0 && have_effect($effect[Heart of Lavender]) == 0) {
		use(1, $item[lavender candy heart]);
	}

	maximize(maxstr,false);
	if (c2t_hccs_thresholdMet(TEST_ITEM))
		return true;

	//THINGS I DON'T ALWAYS WANT TO USE FOR ITEM TEST


	retrieve_item(1,$item[oversized sparkler]);
	//repeat of previous maximize call
	maximize('item,2 booze drop,-equip broken champagne bottle,-equip surprisingly capacious handbag,-equip red-hot sausage fork,switch left-hand man',false);
	if (c2t_hccs_thresholdMet(TEST_ITEM))
		return true;

	

	if (c2t_hccs_thresholdMet(TEST_ITEM))
		return true;
	
	//source terminal enhance. opportunity cost of roughly 16,500 meat
	if (c2t_hccs_haveSourceTerminal()
		&& c2t_hccs_getEffect($effect[items.enh])
		&& c2t_hccs_thresholdMet(TEST_ITEM))
		return true;

	//power plant; last to save batteries if not needed
	if (c2t_hccs_powerPlant())
		c2t_hccs_getEffect($effect[lantern-charged]);

	return c2t_hccs_thresholdMet(TEST_ITEM);
}

boolean c2t_hccs_preHotRes() {
	string maxstr = "100hot res,familiar weight,switch exotic parrot,switch mu,switch left-hand man";

	//ENCOUNTERING A SAUSAGE GOBLIN BREAKS THIS
	//cloake buff and fireproof foam suit for +32 hot res total, but also weapon and spell test buffs
	//weapon/spell buff should last 15 turns, which is enough to get through hot(1), NC(9), and weapon(1) tests to also affect the spell test
	if ((have_effect($effect[do you crush what i crush?]) == 0 && have_familiar($familiar[ghost of crimbo carols]))
		|| (have_effect($effect[fireproof foam suit]) == 0 && available_amount($item[industrial fire extinguisher]) > 0 && have_skill($skill[double-fisted skull smashing]))
		|| (have_effect($effect[misty form]) == 0 && available_amount($item[vampyric cloake]) > 0)
		) {

		if (available_amount($item[vampyric cloake]) > 0)
			equip($item[vampyric cloake]);
		equip($slot[weapon],$item[fourth of may cosplay saber]);
		if (available_amount($item[industrial fire extinguisher]) > 0)
			equip($slot[off-hand],$item[industrial fire extinguisher]);
		use_familiar(c2t_priority($familiars[ghost of crimbo carols,exotic parrot])); //TODO: test if parrot should be a priority

		if (my_mp() < 30)
			c2t_hccs_restoreMp();
		//Imported taffy with a free fight from oliver's den's An Unusually Quiet Barroom Brawl
		//20% DROP, COULD SAVE FEEL NOSTALGIC AND FEEL ENVY FOR ANOTHER MONSTER
		if (get_property('ownsSpeakeasy').to_boolean() && available_amount($item[imported taffy]) == 0) {
			//familiar is handled by use_familiar priority
			c2t_hccs_cartography($location[An Unusually Quiet Barroom Brawl],$monster[goblin flapper]);
		} else {
			adv1($location[the dire warren],-1,"");
		}
		if (have_effect($effect[fireproof foam suit]) == 0) {
			adv1($location[the dire warren],-1,"");
		}
		run_turn();
	}
	if (have_effect($effect[fireproof foam suit]) == 0)
		cli_execute("abort");


	c2t_hccs_getEffect($effect[elemental saucesphere]);
	c2t_hccs_getEffect($effect[astral shell]);

	//emotion chip
	c2t_hccs_getEffect($effect[feeling peaceful]);

	//familiar weight
	c2t_hccs_getEffect($effect[blood bond]);
	c2t_hccs_getEffect($effect[leash of linguini]);
	c2t_hccs_getEffect($effect[empathy]);

	maximize(maxstr,false);
	// need to run this twice because familiar weight thresholds interfere with it?
	maximize(maxstr,false);
	if (c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;


	//THINGS I DON'T USE FOR HOT TEST ANYMORE, but will fall back on if other things break

	//beach comb hot buff
	if (available_amount($item[beach comb]) > 0) {
		c2t_hccs_getEffect($effect[hot-headed]);
		if (c2t_hccs_thresholdMet(TEST_HOT_RES))
			return true;
	}

	//daily candle
	if (c2t_hccs_haveUse($item[rainbow glitter candle]) && c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;

	//magenta seashell
	if (c2t_hccs_getEffect($effect[too cool for (fish) school]) && c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;

	//potion for sleazy hands & hot powder
	if (have_skill($skill[pulverize])) {
		retrieve_item(1,$item[tenderizing hammer]);

		if (have_effect($effect[flame-retardant trousers]) == 0) {
			while (available_amount($item[hot powder]) == 0 && available_amount($item[red-hot sausage fork]) > 0)
				cli_execute('smash 1 red-hot sausage fork');
			if (available_amount($item[hot powder]) > 0)
				c2t_hccs_getEffect($effect[flame-retardant trousers]);
		}
		if (c2t_hccs_thresholdMet(TEST_HOT_RES))
			return true;

		if (have_effect($effect[sleazy hands]) == 0
			&& (c2t_hccs_freeCraftsLeft() > 0
				|| (have_effect($effect[fireproof foam suit]) == 0 && have_effect($effect[misty form]) == 0)
			)) {
			while (available_amount($item[sleaze nuggets]) == 0 && available_amount($item[ratty knitted cap]) > 0)
				cli_execute('smash 1 ratty knitted cap');
			if (available_amount($item[sleaze nuggets]) > 0 || available_amount($item[lotion of sleaziness]) > 0)
				c2t_hccs_getEffect($effect[sleazy hands]);
		}
		if (c2t_hccs_thresholdMet(TEST_HOT_RES))
			return true;
	}

	//pocket maze
	if (c2t_hccs_getEffect($effect[amazing]) && c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;

	//briefcase
	if (c2t_hccs_briefcase("hot")) {
		maximize(maxstr,false);
		if (c2t_hccs_thresholdMet(TEST_HOT_RES))
			return true;
	}

	//synthesis: hot
	if (c2t_hccs_sweetSynthesis($effect[synthesis: hot]) && c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;

	//pillkeeper
	if (c2t_hccs_pillkeeper($effect[rainbowolin]) && c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;

	//pocket wish
	if (c2t_hccs_genie($effect[fireproof lips]) && c2t_hccs_thresholdMet(TEST_HOT_RES))
		return true;

	//speakeasy drink
	if (have_effect($effect[feeling no pain]) == 0) {
		c2t_assert(my_meat() >= 500,'Not enough meat. Please autosell stuff.');
		ensure_ode(2);
		cli_execute('drink 1 Ish Kabibble');
	}

	return c2t_hccs_thresholdMet(TEST_HOT_RES);
}

boolean c2t_hccs_preFamiliar() {
	// Hatter buff is not worth it
	// if (available_amount($item[&quot;drink me&quot; potion]) > 0) {
	// 	if (!retrieve_item(1,$item[sombrero-mounted sparkler])) {
	// 		print("Buying limited-quantity items from the fireworks shop seems to still be broken. Feel free to add to the report at the following link saying that the bug is still a thing, but only if your clan actually has a fireworks shop:","red");//having a fully-stocked clan VIP lounge is technically a requirement for this script, so just covering my bases here
	// 		print_html('<a href="https://kolmafia.us/threads/sometimes-unable-to-buy-limited-items-from-underground-fireworks-shop.27277/">https://kolmafia.us/threads/sometimes-unable-to-buy-limited-items-from-underground-fireworks-shop.27277/</a>');
	// 		print("For now, just going to do it manually:","red");
	// 		visit_url("clan_viplounge.php?action=fwshop&whichfloor=2",false,true);
	// 		//visit_url("shop.php?whichshop=fwshop",false,true);
	// 		visit_url("shop.php?whichshop=fwshop&action=buyitem&quantity=1&whichrow=1249&pwd",true,true);
	// 	}
	// 	//double-checking, and what will be used when mafia finally supports it:
	// 	retrieve_item(1,$item[sombrero-mounted sparkler]);
	// 	c2t_hccs_getEffect($effect[You Can Really Taste the Dormouse]);
	// }

	//sabering fax for meteor shower
	//using fax/wish here as feeling lost here is very likely
	if ((have_skill($skill[meteor lore]) && have_effect($effect[meteor showered]) == 0) ||
		(available_amount($item[lava-proof pants]) == 0
		&& available_amount($item[heat-resistant necktie]) == 0
		&& item_amount($item[corrupted marrow]) == 0)) {

		if (!have_equipped($item[fourth of may cosplay saber]))
			equip($item[fourth of may cosplay saber]);

		if (item_amount($item[photocopied monster]) > 0) {
			use(1,$item[photocopied monster]);
			run_turn();
		}
		else {
			if (available_amount($item[industrial fire extinguisher]) > 0) {
				if (!c2t_hccs_combatLoversLocket($monster[ungulith]) && !c2t_hccs_genie($monster[ungulith]))
					abort("ungulith fight fail");
			}
			else {
				if (!c2t_hccs_combatLoversLocket($monster[factory worker (female)]) && !c2t_hccs_genie($monster[factory worker (female)]))
					abort("factory worker fight fail");
			}
		}
	}
	if (item_amount($item[lump of loyal latite]) > 0)
		c2t_hccs_getEffect($effect[Loyal as a Rock]);

	// Pool buff
	c2t_hccs_getEffect($effect[billiards belligerence]);

	if (my_hp() < 30) use_skill(1,$skill[cannelloni cocoon]);
	c2t_hccs_getEffect($effect[blood bond]);
	c2t_hccs_getEffect($effect[leash of linguini]);
	c2t_hccs_getEffect($effect[empathy]);

	//AT-only buff
	if (my_class() == $class[accordion thief] && have_skill($skill[chorale of companionship]))
		ensure_song($effect[chorale of companionship]);

	//find highest familar weight
	//TODO take familiar equipment or more optimal combinations into account
	familiar highest = $familiar[none];
	if (have_familiar($familiar[Comma Chameleon]) && c2t_hccs_tomeClipArt($item[box of familiar jacks])) {
		use_familiar($familiar[homemade robot]);
		use(1,$item[box of familiar jacks]);
		use_familiar($familiar[Comma Chameleon]);
		cli_execute("/equip familiar homemade robot gear");
		highest = $familiar[Comma Chameleon];
	}
	else if (have_familiar($familiar[Mini-Trainbot]) && (c2t_hccs_tomeClipArt($item[box of familiar jacks]) || available_amount($item[overloaded Yule battery]) > 0)) {
		//third tome use //box of familiar jacks
		use_familiar($familiar[Mini-Trainbot]);
		use(1,$item[box of familiar jacks]);
		equip( $slot[familiar], $item[overloaded Yule battery]);
		highest = $familiar[Mini-Trainbot];
	}
	else if (have_familiar($familiar[exotic parrot]) && available_amount($item[cracker]) > 0)
		highest = $familiar[exotic parrot];
	else if (have_familiar($familiar[Baby Bugged Bugbear])) {
		cli_execute("familiar Baby Bugged Bugbear");
		visit_url( "arena.php" );
		equip( $slot[familiar], $item[bugged beanie]);
		if (familiar_weight($familiar[Baby Bugged Bugbear]) > familiar_weight(highest))
			highest = $familiar[Baby Bugged Bugbear];
	}
	else if (have_effect($effect[fidoxene]) > 0)
		highest = $familiar[none];
	else
		foreach fam in $familiars[]
			if (have_familiar(fam) && familiar_weight(fam) > familiar_weight(highest))
				highest = fam;

	if (highest == $familiar[none])
		c2t_hccs_levelingFamiliar(true);
	else
		use_familiar(highest);

	//Use reward from NC test, silver face paint
	if (available_amount($item[8552])> 0) {
		use(1, $item[8552]);
	}

	//Use green candy Heart
	if (available_amount($item[green candy heart]) > 0) {
		use(1, $item[green candy heart]);
	}

	maximize('familiar weight',false);
	if (c2t_hccs_thresholdMet(TEST_FAMILIAR))
		return true;

	//should only get 1 per run, if any; would use in NEP combat loop, but no point as sombrero would already be already giving max stats
	//saves 2 turns. often more valuable in the mall.
	c2t_hccs_haveUse($item[short stack of pancakes]);

	return c2t_hccs_thresholdMet(TEST_FAMILIAR);
}


boolean c2t_hccs_preNoncombat() {
	if (my_hp() < 30) use_skill(1,$skill[cannelloni cocoon]);
	c2t_hccs_getEffect($effect[blood bond]);
	c2t_hccs_getEffect($effect[leash of linguini]);
	c2t_hccs_getEffect($effect[empathy]);

	// Pool buff. Will no longer fall through to weapon due to familiar test after NC
	//not going to use this here, as it doesn't do to the noncombat rate in the moment anyway. Disgeist > 75 lb
	//c2t_hccs_getEffect($effect[billiards belligerence]);
	cli_execute("shrug Stevedave's Shanty of Superiority");
	cli_execute("shrug Ur-Kel's Aria of Annoyance");

	c2t_hccs_getEffect($effect[the sonata of sneakiness]);
	c2t_hccs_getEffect($effect[smooth movements]);

	//Bird-a-day
	if (my_class() == $class[pastamancer]) {
		use(1, $item[Bird-a-Day calendar]);
		use_skill(1, $skill[7323]);
	}

	if (available_amount($item[powerful glove]) > 0 && have_effect($effect[invisible avatar]) == 0 && !c2t_cast($skill[cheat code: invisible avatar]))
		abort('Invisible avatar failed');

	c2t_hccs_getEffect($effect[silent running]);

	//Can fit in a cartographic map your monsters here to feel nostalgic/envy with Glob
	//works with god lobster
	if (have_familiar($familiar[god lobster]) && have_effect($effect[silence of the god lobster]) == 0 && get_property('_godLobsterFights').to_int() < 3) {
		cli_execute('mood apathetic');
		use_familiar($familiar[god lobster]);
		equip($item[god lobster's ring]);

		//garbage shirt should be exhausted already, but check anyway
		string shirt;
		if (get_property('garbageShirtCharge') > 0)
			shirt = ",equip garbage shirt";
		maximize("mainstat,-familiar,6 bonus designer sweatpants" + shirt,false);

		//fight and get buff
		c2t_setChoice(1310,2); //get buff
		c2t_hccs_preAdv();
		visit_url('main.php?fightgodlobster=1');
		run_turn();
		if (choice_follows_fight())
			run_choice(2);
		c2t_setChoice(1310,0); //unset
	}

	//emotion chip feel lonely
	c2t_hccs_getEffect($effect[feeling lonely]);

	// Rewards // use these after globster fight, just in case of losing
	c2t_hccs_getEffect($effect[throwing some shade]);
	c2t_hccs_getEffect($effect[a rose by any other material]);

	//june cleaver
	c2t_hccs_getEffect($effect[Feeling Sneaky]);


	use_familiar($familiar[disgeist]);

	//unbreakable umbrella
	c2t_hccs_unbreakableUmbrella("nc");

	maximize('-100combat,familiar weight',false);
	maximize('-100combat,familiar weight',false);
	if (c2t_hccs_thresholdMet(TEST_NONCOMBAT))
		return true;

	//asdonmartin drive stealthily
	if (get_workshed() == $item[Asdon Martin keyfob (on ring)] && have_effect($effect[driving stealthily]) == 0) {
		while (get_fuel() < 37) {
			//fuel up
			if (available_amount($item[20-lb can of rice and beans]) > 0) {
				cli_execute("asdonmartin fuel 1 20-lb can of rice and beans");
			} else if (available_amount($item[loaf of soda bread]) > 0) {
				cli_execute("asdonmartin fuel 1 loaf of soda bread");
			} else if (available_amount($item[9948]) > 0) {
				//Middle of the Road Brand Whiskey from NEP
				cli_execute("asdonmartin fuel 1 Middle of the Road™ brand whiskey");
			} else if (available_amount($item[PB&J with the crusts cut off]) > 0) {
				cli_execute("asdonmartin fuel 1 PB&J with the crusts cut off");
			} else if (available_amount($item[swamp haunch]) > 0) {
				cli_execute("asdonmartin fuel 1 swamp haunch");
			} else if (available_amount($item[meadeorite]) > 0) {
				cli_execute("asdonmartin fuel 1 meadeorite");
			} else {
				cli_execute("abort");
				break;
			}
		}
		if (get_fuel() >= 37)
			cli_execute("asdonmartin drive stealthily");
	}

	//replacing glob buff with this
	//mafia doesn't seem to support retrieve_item() by itself for this yet, so visit_url() to the rescue:
	if (!retrieve_item(1,$item[porkpie-mounted popper])) {
		print("Buying limited-quantity items from the fireworks shop seems to still be broken. Feel free to add to the report at the following link saying that the bug is still a thing, but only if your clan actually has a fireworks shop:","red");//having a fully-stocked clan VIP lounge is technically a requirement for this script, so just covering my bases here
		print_html('<a href="https://kolmafia.us/threads/sometimes-unable-to-buy-limited-items-from-underground-fireworks-shop.27277/">https://kolmafia.us/threads/sometimes-unable-to-buy-limited-items-from-underground-fireworks-shop.27277/</a>');
		print("For now, just going to do it manually:","red");
		visit_url("clan_viplounge.php?action=fwshop&whichfloor=2",false,true);
		//visit_url("shop.php?whichshop=fwshop",false,true);
		visit_url("shop.php?whichshop=fwshop&action=buyitem&quantity=1&whichrow=1249&pwd",true,true);
	}
	// //double-checking, and what will be used when mafia finally supports it:
	// retrieve_item(1,$item[porkpie-mounted popper]);

	maximize('-100combat,familiar weight',false);
	if (c2t_hccs_thresholdMet(TEST_NONCOMBAT))
		return true;

	//briefcase
	if (c2t_hccs_briefcase("-combat")) {
		maximize('-100combat,familiar weight',false);
		if (c2t_hccs_thresholdMet(TEST_NONCOMBAT))
			return true;
	}

	//disquiet riot wish potential if 2 or more wishes remain and not close to min turn
	if (c2t_hccs_testTurns(TEST_NONCOMBAT) >= 9)//TODO better cost/benefit
		c2t_hccs_genie($effect[disquiet riot]);

	return c2t_hccs_thresholdMet(TEST_NONCOMBAT);
}

boolean c2t_hccs_preWeapon() {
	boolean useBoxGhostsInsteadMelodramery = false;
	if (c2t_hccs_melodramedary() && get_property('camelSpit').to_int() != 100 && have_effect($effect[spit upon]) == 0) {
		print('Camel spit only at '+get_property('camelSpit')+'%. Going to have to skip spit buff.',"red");
		set_property("_c2t_hccs_failSpit","true");
		useBoxGhostsInsteadMelodramery = true;
	}

	//imported taffy from leveling chain Map to Monsters with cartographic
	if (available_amount($item[imported taffy]) > 0 && have_effect($effect[Imported Strength]) == 0) {
		c2t_hccs_getEffect($effect[Imported Strength]);
	}

	//pizza cube prep since making this takes a turn without free crafts
	// if (c2t_hccs_pizzaCube() && c2t_hccs_freeCraftsLeft() == 0)
	// 	retrieve_item(1,$item[ointment of the occult]);

	//cast triple size
	if (available_amount($item[powerful glove]) > 0 && have_effect($effect[triple-sized]) == 0 && !c2t_cast($skill[cheat code: triple size]))
		abort('Triple size failed');

	if (my_mp() < 500 && my_mp() != my_maxmp())
		cli_execute('eat mag saus');



	if (available_amount($item[twinkly nuggets]) > 0)
		c2t_hccs_getEffect($effect[twinkly weapon]);

	c2t_hccs_getEffect($effect[carol of the bulls]);
	c2t_hccs_getEffect($effect[rage of the reindeer]);
	c2t_hccs_getEffect($effect[frenzied, bloody]);
	c2t_hccs_getEffect($effect[scowl of the auk]);
	c2t_hccs_getEffect($effect[tenacity of the snapper]);

	//don't have these skills yet. maybe should add check for all skill uses to make universal?
	if (have_skill($skill[song of the north]))
		c2t_hccs_getEffect($effect[song of the north]);
	if (have_skill($skill[jackasses' symphony of destruction]))
		ensure_song($effect[jackasses' symphony of destruction]);

	if (available_amount($item[vial of hamethyst juice]) > 0)
		c2t_hccs_getEffect($effect[ham-fisted]);

	//beach comb weapon buff
	if (available_amount($item[beach comb]) > 0)
	 	c2t_hccs_getEffect($effect[lack of body-building]);

	// Boombox potion
	if (available_amount($item[punching potion]) > 0)
		c2t_hccs_getEffect($effect[feeling punchy]);

	//inner elf must be before meteor shower due to combat macro setup
	acquireInnerElf();

	//meteor shower
	if ((have_skill($skill[meteor lore]) && have_effect($effect[meteor showered]) == 0)
		|| (have_familiar($familiar[melodramedary]) && have_effect($effect[spit upon]) == 0 && get_property('camelSpit').to_int() == 100)) {

		cli_execute('mood apathetic');

		//only 2 things needed for combat:
		if (!have_equipped($item[fourth of may cosplay saber]))
			equip($item[fourth of may cosplay saber]);
		if (c2t_hccs_melodramedary()) {
			use_familiar($familiar[melodramedary]);
		} else {
			c2t_hccs_levelingFamiliar(true);
		}

		if (useBoxGhostsInsteadMelodramery) {
			if (have_effect($effect[do you crush what i crush?]) == 0 && have_familiar($familiar[ghost of crimbo carols]) && (get_property('_snokebombUsed').to_int() < 3 || !get_property('_latteBanishUsed').to_boolean())) {
				if (my_mp() < 30)
					cli_execute('rest free');
				use_familiar($familiar[ghost of crimbo carols]);
			}
		} else {
			if (have_effect($effect[do you crush what i crush?]) == 0 && have_familiar($familiar[ghost of crimbo carols]) && (get_property('_snokebombUsed').to_int() < 3 || !get_property('_latteBanishUsed').to_boolean())) {
				equip($item[latte lovers member's mug]);
				if (my_mp() < 30)
					cli_execute('rest free');
				use_familiar($familiar[ghost of crimbo carols]);
				//adv1($location[the dire warren],-1,""); save fight for ungulith
			}
			if (c2t_hccs_melodramedary()) {
				use_familiar($familiar[melodramedary]);
			} 
		}



		//fight ungulith or not
		boolean fallback = true;
		if (item_amount($item[corrupted marrow]) == 0 && have_effect($effect[cowrruption]) == 0) {
			if (c2t_hccs_combatLoversLocket($monster[ungulith]) || c2t_hccs_genie($monster[ungulith]))
				fallback = false;
			else
				print("Couldn't fight ungulith to get corrupted marrow","red");
		}
		if (fallback)
			adv1(shadow100Zone,-1,"");//everything is saberable and no crazy NCs
	}

	c2t_hccs_getEffect($effect[cowrruption]);

	c2t_hccs_getEffect($effect[engorged weapon]);

	//Cast Seek Bird from Bird-A-Day. Assumes a weapon damage favorite bird.
	if (have_skill($skill[Visit your Favorite Bird])) {
		// use_skill(1, $skill[Visit your Favorite Bird]); //save for later
		if (my_class() == $class[pastamancer]) {
			use_skill(1, $skill[7323]); //PM has good daily bird
		}
	}

	//tainted seal's blood
	if (available_amount($item[tainted seal's blood]) > 0)
		c2t_hccs_getEffect($effect[corruption of wretched wally]);


	// turtle tamer saves ~1 turn with this part, and 4 from voting
	if (my_class() == $class[turtle tamer]) {
		if (have_effect($effect[boon of she-who-was]) == 0) {
			c2t_hccs_getEffect($effect[blessing of she-who-was]);
			c2t_hccs_getEffect($effect[boon of she-who-was]);
		}
		c2t_hccs_getEffect($effect[blessing of the war snapper]);
	}
	else
		c2t_hccs_getEffect($effect[disdain of the war snapper]);

	c2t_hccs_getEffect($effect[bow-legged swagger]);

	//briefcase
	//c2t_hccs_briefcase("weapon");//this is the default, but just in case



	//pull stick-knife if able to equip
	if (my_basestat($stat[muscle]) >= 150) {
		c2t_hccs_pull($item[stick-knife of loathing]);
	}

	//unbreakable umbrella
	c2t_hccs_unbreakableUmbrella("weapon");

	maximize('weapon damage,switch left-hand man',false);

	if (my_basestat($stat[muscle]) < 150 && my_class() == $class[pastamancer] && have_skill($skill[Bind Undead Elbow Macaroni])) {
		//PM can pull stick knife of loathing with elbow macaroni
		//USES OUTFIT GLITCH WITH AN OUTFIT NAMED CS_PM_stickknife_glitch
		c2t_hccs_pull($item[stick-knife of loathing]);
		use_skill(1, $skill[bind undead elbow macaroni]);
		//what if maximizer removes stick knife? probably won't!
		cli_execute("outfit CS_PM_stickknife_glitch");
		if (item_amount($item[fish hatchet]) > 0)
			equip( $slot[off-hand], $item[fish hatchet]);

	}

	maximize('weapon damage,switch left-hand man,-weapon',false);

	

	if (c2t_hccs_thresholdMet(TEST_WEAPON))
		return true;

	if (have_skill($skill[Visit your Favorite Bird])) {
		use_skill(1, $skill[Visit your Favorite Bird]);
	}


	if (c2t_hccs_thresholdMet(TEST_WEAPON))
		return true;
	
	//can do fish hatchet here if needed

	//cargo shorts as backup
	if (available_amount($item[cargo cultist shorts]) > 0
		&& c2t_hccs_testTurns(TEST_WEAPON) > 4 //4 is how much cargo would save on spell test, so may as well use here if spell is not better
		&& have_effect($effect[rictus of yeg]) == 0
		&& !get_property('_cargoPocketEmptied').to_boolean())
			cli_execute("cargo item yeg's motel toothbrush");
	c2t_hccs_haveUse($item[yeg's motel toothbrush]);

	return c2t_hccs_thresholdMet(TEST_WEAPON);
}

boolean c2t_hccs_preSpell() {
	if (my_mp() < 500 && my_mp() != my_maxmp())
		cli_execute('eat mag saus');



	//use crafts
	if (have_effect($effect[Concentration]) == 0 && get_property('_expertCornerCutterUsed').to_int() < 5) {
		cli_execute("make Cordial of Concentration");
		cli_execute("use Cordial of Concentration");
	}

	// This will use an adventure.
	// if spit upon == 1, simmering will just waste a turn to do essentially nothing.
	// probably good idea to add check for similar effects to not just waste a turn
	if (have_effect($effect[spit upon]) != 1 && have_effect($effect[do you crush what i crush?]) != 1 && have_effect($effect[Inner Elf]) != 1)
		c2t_hccs_getEffect($effect[simmering]);

	while (c2t_hccs_wandererFight()); //check for after using a turn to cast Simmering
	//ALL ADVENTURE SPENDING STUFF DONE NOW

	//inner elf shenanigans
	acquireInnerElf();

	//don't have this skill yet. Maybe should add check for all skill uses to make universal?
	if (have_skill($skill[song of sauce]))
		c2t_hccs_getEffect($effect[song of sauce]);
	if (have_skill($skill[jackasses' symphony of destruction]))
		c2t_hccs_getEffect($effect[jackasses' symphony of destruction]);

	c2t_hccs_getEffect($effect[carol of the hells]);

	// Pool buff
	c2t_hccs_getEffect($effect[mental a-cue-ity]);

	//beach comb spell buff
	if (available_amount($item[beach comb]) > 0)
		c2t_hccs_getEffect($effect[we're all made of starfish]);

	c2t_hccs_haveUse($skill[spirit of peppermint]);

	// face
	c2t_hccs_getEffect($effect[arched eyebrow of the archmage]);

	if (available_amount($item[baconstone]) > 0)
		c2t_hccs_getEffect($effect[baconstoned]);

	//pull stick-knife if able to equip
	if (my_basestat($stat[muscle]) >= 150)
		c2t_hccs_pull($item[stick-knife of loathing]);

	if (my_class() == $class[pastamancer]) {
		//PM can pull stick knife of loathing with elbow macaroni
		//USES OUTFIT GLITCH WITH AN OUTFIT NAMED CS_PM_stickknife_glitch
		if (my_basestat($stat[mysticality]) >= 250) {
			c2t_hccs_pull($item[Staff of the Roaring Hearth]);
		} 
		if (my_basestat($stat[mysticality]) >= 125 && available_amount($item[Staff of the Roaring Hearth]) == 0) {
			c2t_hccs_pull($item[Staff of Simmering Hatred]);
		}
		if (my_basestat($stat[mysticality]) >= 200 && available_amount($item[Staff of the Roaring Hearth]) == 0 && available_amount($item[Staff of Simmering Hatred]) == 0) {
			c2t_hccs_pull($item[Staff of Kitchen Royalty]);
		}
	} 

	//get up to 2 obsidian nutcracker
	int nuts = 2;
	foreach x in $items[stick-knife of loathing,Staff of Kitchen Royalty, Staff of the Roaring Hearth, staff of simmering hatred]//,Abracandalabra]
		if (available_amount(x) > 0)
			nuts--;
	if (!have_familiar($familiar[left-hand man]) && available_amount($item[abracandalabra]) > 0)
		nuts--;
	retrieve_item(nuts<0?0:nuts,$item[obsidian nutcracker]);

	//AT-only buff
	if (my_class() == $class[accordion thief] && have_skill($skill[elron's explosive etude]))
		ensure_song($effect[elron's explosive etude]);

	// cargo pocket
	if (available_amount($item[cargo cultist shorts]) > 0 && have_effect($effect[sigils of yeg]) == 0 && !get_property('_cargoPocketEmptied').to_boolean())
		cli_execute("cargo item Yeg's Motel hand soap");
	c2t_hccs_haveUse($item[yeg's motel hand soap]);

	// meteor lore // moxie can't do this, as it wastes a saber on evil olive -- moxie should be able to do this now with nostalgia earlier?
	if (have_skill($skill[meteor lore]) && have_effect($effect[meteor showered]) == 0 && get_property('_saberForceUses').to_int() < 5) {
		c2t_hccs_levelingFamiliar(true);
		maximize("mainstat,equip fourth of may cosplay saber",false);
		adv1(shadow100Zone,-1,"");//everything is saberable and no crazy NCs
	}

	if (have_skill($skill[deep dark visions]) && have_effect($effect[visions of the deep dark deeps]) == 0) {
		c2t_hccs_getEffect($effect[elemental saucesphere]);
		c2t_hccs_getEffect($effect[astral shell]);
		maximize("1000spooky res,hp,mp",false);
		if (my_hp() < 800)
			use_skill(1,$skill[cannelloni cocoon]);
		c2t_hccs_getEffect($effect[visions of the deep dark deeps]);
	}

	if (have_effect($effect[Pisces in the Skyces]) == 0 && have_skill($skill[Summon Alice's Army Cards])) {
		use_skill(1, $skill[Summon Alice's Army Cards]);
		cli_execute("make tobiko marble soda");
		cli_execute("use tobiko marble soda");
	} else if (have_effect($effect[Pisces in the Skyces]) == 0 && !have_skill($skill[Summon Alice's Army Cards]) && pulls_remaining() > 0) {
		c2t_hccs_pull($item[Tobiko Marble Soda]);
		cli_execute("use tobiko marble soda");
	}

	//Zatara RNG
	if (available_amount($item[Bettie page]) > 0 && have_effect($effect[Paging Betty]) == 0) {
		cli_execute("use Bettie page");
	}



	//pull Staff
	if (my_class() == $class[pastamancer]) {
		//PM can pull stick knife of loathing with elbow macaroni
		//USES OUTFIT GLITCH WITH AN OUTFIT NAMED CS_PM_stickknife_glitch
		if (available_amount($item[Staff of the Roaring Hearth])>0) {
			cli_execute("outfit CS_PM_roaringhearth_glitch");
		} else if(available_amount($item[Staff of Kitchen Royalty])>0) {
			cli_execute("outfit CS_PM_kitchenroyalty_glitch");
		} else if (available_amount($item[Staff of Simmering Hatred]) > 0) {
			cli_execute("outfit CS_PM_simmering_glitch");
		}
	}

	//if I ever feel like blowing the resources:
	if (get_property('_c2t_hccs_dstab').to_boolean()) {
		//the only way is all the way
		c2t_hccs_genie($effect[witch breaded]);

		//batteries
		if (c2t_hccs_powerPlant()) {
			c2t_hccs_getEffect($effect[d-charged]);
			c2t_hccs_getEffect($effect[aa-charged]);
			c2t_hccs_getEffect($effect[aaa-charged]);
		}
	}

	//need to figure out pulls
	if (!in_hardcore() && pulls_remaining() > 0) {
		//lazy way for now
		/*
		$item[Staff of the Roaring Hearth])>0) {
			cli_execute("outfit CS_PM_roaringhearth_glitch");
		} else if(available_amount($item[Staff of Kitchen Royalty])>0) {
		*/
		boolean [item] derp;
		if (available_amount($item[astral statuette]) == 0 && (available_amount($item[Staff of the Roaring Hearth]) == 0 && equipped_amount($item[Staff of the Roaring Hearth]) == 0)
		 && (available_amount($item[Staff of Kitchen Royalty]) == 0 && equipped_amount($item[Staff of Kitchen Royalty]) == 0))
			derp = $items[cold stone of hatred,witch's bra,lens of hatred,fuzzy slippers of hatred];
		else
			derp = $items[witch's bra,lens of hatred,fuzzy slippers of hatred];

		foreach x in derp {
			if (pulls_remaining() == 0)
				break;
			c2t_hccs_pull(x);
		}
		if (pulls_remaining() > 0)
			print(`Still had {pulls_remaining()} pulls remaining for the last test`,"red");
	}

	//briefcase //TODO count spell-damage-providing accessories and values before deciding to use the briefcase
	c2t_hccs_briefcase("spell");

	//unbreakable umbrella
	c2t_hccs_unbreakableUmbrella("spell");

	print("maximizing", "red");
	maximize('spell damage,switch left-hand man',false);

	if (my_class() == $class[pastamancer]) {
		//PM can pull stick knife of loathing with elbow macaroni
		//USES OUTFIT GLITCH WITH AN OUTFIT NAMED CS_PM_stickknife_glitch
		if (available_amount($item[Staff of the Roaring Hearth])>0) {
			cli_execute("outfit CS_PM_roaringhearth_glitch");
		} else if(available_amount($item[Staff of Kitchen Royalty])>0) {
			cli_execute("outfit CS_PM_kitchenroyalty_glitch");
		}	}

	return c2t_hccs_thresholdMet(TEST_SPELL);
}


// stat tests are super lazy for now
// TODO need to figure out a way to not overdo buffs, as some buffers may be needed for pizzas
boolean c2t_hccs_preHp() {
	if (c2t_hccs_thresholdMet(TEST_HP))
		return true;

	maximize('hp,switch left-hand man',false);
	if (c2t_hccs_thresholdMet(TEST_HP))
		return true;

	//hp buffs
	if (!c2t_hccs_getEffect($effect[song of starch]))
		c2t_hccs_getEffect($effect[song of bravado]);
	c2t_hccs_getEffect($effect[reptilian fortitude]);
	if (c2t_hccs_thresholdMet(TEST_HP))
		return true;

	//mus buffs //basically copy/paste from mus test sans bravado
	//TODO AT songs
	foreach x in $effects[
		//skills
		quiet determination,
		big,
		disdain of the war snapper,
		patience of the tortoise,
		rage of the reindeer,
		seal clubbing frenzy,
		//using items
		go get 'em\, tiger!,
		//skill skills from IotM
		feeling excited
		]
		c2t_hccs_getEffect(x);

	return c2t_hccs_thresholdMet(TEST_HP);
}

boolean c2t_hccs_preMus() {
	//TODO if pastamancer, add summon of mus thrall if need? currently using equaliser potion out of laziness
	if (my_class() == $class[pastamancer] && have_skill($skill[Bind Undead Elbow Macaroni])) {
		if (my_thrall() != $thrall[Elbow Macaroni]) {
			if (my_mp() < 100)
				cli_execute('eat magical sausage');
			c2t_hccs_haveUse($skill[Bind Undead Elbow Macaroni]);
		}
	}
	if (c2t_hccs_thresholdMet(TEST_MUS))
		return true;

	maximize('mus,switch left-hand man',false);
	if (c2t_hccs_thresholdMet(TEST_MUS))
		return true;

	//TODO AT songs
	foreach x in $effects[
		//skills
		quiet determination,
		big,
		song of bravado,
		disdain of the war snapper,
		patience of the tortoise,
		rage of the reindeer,
		seal clubbing frenzy,
		//potions
		go get 'em\, tiger!,
		//skill skills from IotM
		feeling excited
		]
		c2t_hccs_getEffect(x);
	
	if (c2t_hccs_thresholdMet(TEST_MUS)) return true;

	if (c2t_hccs_freeCraftsLeft() > 0 && have_effect($effect[Phorcefullness]) == 0) {
		cli_execute("make philter of phorce");
		cli_execute("use philter of phorce");
	}

	if (c2t_hccs_thresholdMet(TEST_MUS)) return true;

	//beach comb weapon buff
	if (available_amount($item[beach comb]) > 0)
	 	c2t_hccs_getEffect($effect[lack of body-building]);

	return c2t_hccs_thresholdMet(TEST_MUS);
}

boolean c2t_hccs_preMys() {
	if (c2t_hccs_thresholdMet(TEST_MYS))
		return true;

	maximize('mys,switch left-hand man',false);
	if (c2t_hccs_thresholdMet(TEST_MYS))
		return true;

	//1,1,1,1,familiar,1,20,1,1,1
	int testBeforeSpell = 0;
	for testI from 0 to 5 {
		testBeforeSpell += get_property("c2t_hccs_thresholds").split_string(",")[testI].to_int();
	}
	if (testBeforeSpell < 49) {
		if (available_amount($item[beach comb]) > 0)
			c2t_hccs_getEffect($effect[we're all made of starfish]);
	}

	//TODO AT songs
	foreach x in $effects[
		//skills
		quiet judgement,
		big,
		song of bravado,
		disdain of she-who-was,
		pasta oneness,
		saucemastery,
		//potions
		glittering eyelashes,
		//skill skills from IotM
		feeling excited
		]
		c2t_hccs_getEffect(x);

	return c2t_hccs_thresholdMet(TEST_MYS);
}

boolean c2t_hccs_preMox() {
	//TODO if pastamancer, add summon of mox thrall if need? currently using equaliser potion out of laziness
	if (my_class() == $class[pastamancer] && have_skill($skill[Bind Penne Dreadful])) {
		if (my_thrall() != $thrall[Penne Dreadful]) {
			if (my_mp() < 150)
				cli_execute('eat magical sausage');
			c2t_hccs_haveUse($skill[Bind Penne Dreadful]);
		}
	}
	if (my_class() == $class[seal clubber]) {
		use(1, $item[Bird-a-Day calendar]);
		use_skill(1, $skill[7323]);
	}
	c2t_hccs_getEffect($effect[Disco Fever]);
	if (c2t_hccs_thresholdMet(TEST_MOX))
		return true;

	maximize('mox,switch left-hand man',false);
	if (c2t_hccs_thresholdMet(TEST_MOX))
		return true;

	c2t_hccs_getEffect($effect[pomp & circumsands]);

	if (c2t_hccs_thresholdMet(TEST_MOX))
		return true;

	//TODO AT songs
	//face
	if (!c2t_hccs_getEffect($effect[quiet desperation]))
		c2t_hccs_getEffect($effect[disco smirk]);
	//other
	foreach x in $effects[
		//skills
		big,
		song of bravado,
		blubbered up,
		disco state of mind,
		mariachi mood,
		//potions
		butt-rock hair,
		unrunnable face,
		//skill skills from IotM
		feeling excited
		]
		c2t_hccs_getEffect(x);

	return c2t_hccs_thresholdMet(TEST_MOX);
}

//Leveling fights
void c2t_hccs_fights() {
	string fam;
	//TODO move familiar changes and maximizer calls inside of blocks
	// saber yellow ray stuff
	if (available_amount($item[tomato juice of powerful power]) == 0
		&& available_amount($item[tomato]) == 0
		&& have_effect($effect[tomato power]) == 0) {

		cli_execute('mood apathetic');

		if (my_hp() < 0.5 * my_maxhp())
			c2t_hccs_restoreMp();

		if (c2t_hccs_levelingFamiliar(true) == $familiar[melodramedary] && available_amount($item[dromedary drinking helmet]) > 0)
			fam = ",equip dromedary drinking helmet";

		// Fruits in skeleton store (Saber YR)
		if ((available_amount($item[ointment of the occult]) == 0 && available_amount($item[grapefruit]) == 0 && have_effect($effect[mystically oiled]) == 0)
				|| (available_amount($item[oil of expertise]) == 0 && available_amount($item[cherry]) == 0 && have_effect($effect[expert oiliness]) == 0)
				|| (available_amount($item[philter of phorce]) == 0 && available_amount($item[lemon]) == 0 && have_effect($effect[phorcefullness]) == 0)) {
			if (get_property('questM23Meatsmith') == 'unstarted') {
				// Have to start meatsmith quest.
				visit_url('shop.php?whichshop=meatsmith&action=talk');
				run_choice(1);
			}
			if (!can_adventure($location[the skeleton store]))
				abort('Cannot open skeleton store!');
			if ($location[the skeleton store].turns_spent == 0 && !$location[the skeleton store].noncombat_queue.contains_text('Skeletons In Store'))
				adv1($location[the skeleton store],-1,'');
			if (!$location[the skeleton store].noncombat_queue.contains_text('Skeletons In Store'))
				abort('Something went wrong at skeleton store.');

			if (get_property('lastCopyableMonster').to_monster() != $monster[novelty tropical skeleton]) {
				//max mp to max latte gulp to fuel buffs
				maximize("mp,-equip garbage shirt,equip latte,100 bonus vampyric cloake,100 bonus lil doctor bag,100 bonus kremlin's greatest briefcase,6 bonus designer sweatpants"+fam,false);

				c2t_hccs_cartography($location[the skeleton store],$monster[novelty tropical skeleton]);
			}
			//get the fruits with nostalgia
			c2t_hccs_fightGodLobster();
		}

		// Tomato in pantry (NOT Saber YR) -- RUNNING AWAY to use nostalgia later
		if (available_amount($item[tomato juice of powerful power]) == 0
			&& available_amount($item[tomato]) == 0
			&& have_effect($effect[tomato power]) == 0
			) {

			if (get_property('lastCopyableMonster').to_monster() != $monster[possessed can of tomatoes]) {
				if (get_property('_latteDrinkUsed').to_boolean())
					cli_execute('latte refill cinnamon pumpkin vanilla');
				//max mp to max latte gulp to fuel buffs
				c2t_hccs_levelingFamiliar(true);
				maximize("mp,-equip garbage shirt,equip latte,100 bonus vampyric cloake,100 bonus lil doctor bag,100 bonus kremlin's greatest briefcase,6 bonus designer sweatpants"+fam,false);

				c2t_hccs_cartography($location[the haunted pantry],$monster[possessed can of tomatoes]);
			}
			//get the tomato with nostalgia
			c2t_hccs_fightGodLobster();
		}
	}

	if (have_effect($effect[the magical mojomuscular melody]) > 0)
		cli_execute('shrug mojomus');
	if (have_effect($effect[carlweather's cantata of confrontation]) > 0)
		cli_execute('shrug cantata');
	c2t_hccs_getEffect($effect[stevedave's shanty of superiority]);

	//sort out familiar
	if (c2t_hccs_levelingFamiliar(false) == $familiar[melodramedary] && available_amount($item[dromedary drinking helmet]) > 0)
		fam = ",equip dromedary drinking helmet";

	//mumming trunk stats on leveling familiar
	if (item_amount($item[mumming trunk]) > 0) {
		if (my_primestat() == $stat[muscle] && !get_property('_mummeryUses').contains_text('3'))
			cli_execute('mummery mus');
		else if (my_primestat() == $stat[mysticality] && !get_property('_mummeryUses').contains_text('5'))
			cli_execute('mummery mys');
		else if (my_primestat() == $stat[moxie] && !get_property('_mummeryUses').contains_text('7'))
			cli_execute('mummery mox');
	}


	if (my_primestat() == $stat[muscle])
		cli_execute('mood hccs-mus');
	else if (my_primestat() == $stat[mysticality])
		cli_execute('mood hccs-mys');
	else if (my_primestat() == $stat[moxie])
		cli_execute('mood hccs-mox');

	if (c2t_hccs_backupCamera() && get_property('backupCameraMode') != 'ml')
		cli_execute('backupcamera ml');

	//turtle tamer blessing
	if (my_class() == $class[turtle tamer]) {
		if (have_effect($effect[blessing of the war snapper]) == 0 && have_effect($effect[grand blessing of the war snapper]) == 0 && have_effect($effect[glorious blessing of the war snapper]) == 0)
			c2t_hccs_haveUse($skill[blessing of the war snapper]);
		if (have_effect($effect[boon of the war snapper]) == 0)
			c2t_hccs_haveUse(1,$skill[spirit boon]);
	}

	//run mood with auto mp recovery using free rests
	set_property('mpAutoRecoveryItems','free rest');
	cli_execute('mood execute');
	set_property('mpAutoRecoveryItems','');

	//get crimbo ghost buff from dudes at NEP
	//(have_familiar($familiar[ghost of crimbo carols]) && have_effect($effect[holiday yoked]) == 0) ||
	if ((my_primestat() == $stat[moxie] && have_effect($effect[unrunnable face]) == 0 && item_amount($item[runproof mascara]) == 0)//to nostalgia runproof mascara
		) {

		if (get_property('_latteDrinkUsed').to_boolean())
			cli_execute('latte refill cinnamon pumpkin vanilla');
		// if (have_familiar($familiar[ghost of crimbo carols]))
		// 	use_familiar($familiar[ghost of crimbo carols]);
		maximize("mainstat,equip latte,-equip i voted,6 bonus designer sweatpants",false);

		//going to grab runproof mascara from globster if moxie instead of having to wait post-kramco
		if (my_primestat() == $stat[moxie])
			c2t_hccs_cartography($location[the neverending party],$monster[party girl]);
		else
			adv1($location[the neverending party],-1,"");
	}

	//nostalgia for moxie stuff and run down remaining glob fights
	while (c2t_hccs_fightGodLobster());

	//moxie needs olives
	if (my_primestat() == $stat[moxie] && have_effect($effect[slippery oiliness]) == 0 && item_amount($item[jumbo olive]) == 0) {
		//only thing that needs be equipped
		c2t_hccs_levelingFamiliar(true);
		if (!have_equipped($item[fourth of may cosplay saber]))
			equip($item[fourth of may cosplay saber]);
		//TODO evil olive - change to run away from and feel nostagic+envy+free kill another thing to save a saber use for spell test
		if (!c2t_hccs_combatLoversLocket($monster[evil olive]) && !c2t_hccs_genie($monster[evil olive]))
			abort("Failed to fight evil olive");
	}

	c2t_hccs_levelingFamiliar(false);

	//Lasagmbie
	if (my_class() == $class[pastamancer] && have_skill($skill[Bind Lasagmbie])) {
		if (my_thrall() != $thrall[Lasagmbie]) {
			if (my_mp() < 250)
				cli_execute('eat magical sausage');
			c2t_hccs_haveUse($skill[Bind Lasagmbie]);
		}
	}

	//summon tentacle
	if (have_skill($skill[evoke eldritch horror]) && !get_property('_eldritchHorrorEvoked').to_boolean()) {
		maximize("mainstat,100exp,-equip garbage shirt,6 bonus designer sweatpants"+fam,false);
		if (my_mp() < 80)
			c2t_hccs_restoreMp();
		c2t_hccs_haveUse(1,$skill[evoke eldritch horror]);
		run_combat();

		//in case the tentacle boss shows up; will cause an instant loss in a wish fight if health left at 0
		if (have_effect($effect[beaten up]) > 0 || my_hp() < 50)
			cli_execute('rest free');
	}

	// Your Mushroom Garden
	if ((get_campground() contains $item[packet of mushroom spores]) && get_property('_mushroomGardenFights').to_int() == 0) {
		maximize("mainstat,-equip garbage shirt,6 bonus designer sweatpants"+fam,false);
		adv1($location[your mushroom garden],-1,"");
	}

	c2t_hccs_wandererFight();//shouldn't do kramco

	//setup for Scaler Fights
	string doc,garbage,kramco;
	if (c2t_hccs_levelingFamiliar(false) == $familiar[melodramedary] && available_amount($item[dromedary drinking helmet]) > 0)
		fam = ",equip dromedary drinking helmet";
	else if (available_amount($item[tiny stillsuit]) > 0)
		fam = ",equip tiny stillsuit";

	//backup fights will turns this off after a point, so keep turning it on
	if (get_property('garbageShirtCharge').to_int() > 0)
		garbage = ",equip garbage shirt";
	else
		garbage = "";

	//SHADOW RIFT NOT SCALAR BUT ENOUGH GARBAGE SHIRT SCRAPS
	//use closed-circuit pay phone
	if (get_property("_psccs_shadowRiftBossAttempted") == "" && have_effect($effect[shadow affinity]) == 0)
		use(1,$item[closed-circuit pay phone]);
	//Shadow Rift Free Fights
	while(have_effect($effect[shadow affinity]) > 0) {
		if (my_mp() < 50)
			cli_execute('eat magical sausage');
		while (my_maxhp() - my_hp() > 200) {
			cli_execute("cast cannelloni cocoon");
		}
		c2t_hccs_levelingFamiliar(false);
		if (my_primestat() == $stat[mysticality])
			maximize("mainstat,exp,equip Fourth of May Cosplay Saber,6 bonus designer sweatpants"+garbage+fam,false);
		else
			maximize("mainstat,exp,-equip kramco sausage-o-matic&trade;,-equip i voted,equip June Cleaver,6 bonus designer sweatpants"+garbage+fam,false);
		adv1(shadowLevelingLoc,-1,"");
	}
	//Shadow Boss. 
	if (get_property("_psccs_shadowRiftBossAttempted") == "" && get_property("rufusQuestType") == "entity") {
		if (my_mp() < 50)
			cli_execute('eat magical sausage');
		while (my_maxhp() - my_hp() > 50) {
			cli_execute("cast cannelloni cocoon");
		}
		if (have_familiar($familiar[Machine Elf])) {
			use_familiar($familiar[Machine Elf]);
		} else {
			c2t_hccs_levelingFamiliar(false);
		}
		//Never want fourth of may over cleaver in case it fails. Might need cleaver elemental dmg
		maximize("mainstat,exp,equip June Cleaver,6 bonus designer sweatpants"+garbage+fam,false);
		if (get_property("rufusQuestTarget") == "shadow scythe") //scythe always wins init, block 90%
			equip($slot[shirt],$item[Jurassic Parka]);
		else if (get_property("rufusQuestTarget") == "shadow orrery") {
			if (my_class() == $class[pastamancer] && have_skill($skill[Bind Undead Elbow Macaroni])) {
				if (my_thrall() != $thrall[Elbow Macaroni]) {
					if (my_mp() < 100)
						cli_execute('eat magical sausage');
					c2t_hccs_haveUse($skill[Bind Undead Elbow Macaroni]);
				}
			}
		}
		
		set_property("_psccs_shadowRiftBossAttempted","entityFought");
		adv1(shadowLevelingLoc,-1,"");
		//Save finishing quest for after script (to prevent having to deal with quest rewards)
	}
	//Lasagmbie
	if (my_class() == $class[pastamancer] && have_skill($skill[Bind Lasagmbie])) {
		if (my_thrall() != $thrall[Lasagmbie]) {
			if (my_mp() < 250)
				cli_execute('eat magical sausage');
			c2t_hccs_haveUse($skill[Bind Lasagmbie]);
		}
	}
	//locket 1 Witchess Witch for battle broom
	//If ever removed, look at oliver's den bowl sideways. Atm, it leaves 2 NEP fights without bowl sideways.
	if (available_amount($item[Battle broom]) == 0) {
		//make sure have some mp
		if (my_mp() < 50)
			cli_execute('eat magical sausage');
		while (my_maxhp() - my_hp() > 20) {
			cli_execute("cast cannelloni cocoon");
		}
		c2t_hccs_levelingFamiliar(false);
		if (my_primestat() == $stat[mysticality])
			maximize("mainstat,exp,equip Fourth of May Cosplay Saber,6 bonus designer sweatpants"+garbage+fam,false);
		else
			maximize("mainstat,exp,equip June Cleaver,6 bonus designer sweatpants"+garbage+fam,false);
		//Weapon dmg buffs, Witchess witch is hard. Don't use AT songs!
		c2t_hccs_getEffect($effect[carol of the bulls]);
		c2t_hccs_getEffect($effect[rage of the reindeer]);
		c2t_hccs_getEffect($effect[frenzied, bloody]);
		c2t_hccs_getEffect($effect[scowl of the auk]);
		c2t_hccs_getEffect($effect[tenacity of the snapper]);
		if (have_skill($skill[song of the north])) //(dread song, not AT song)
			c2t_hccs_getEffect($effect[song of the north]);

		//30% physical dmg reduction
		c2t_hccs_getEffect($effect[Shield of the Pastalord]);

		//DA buffs
		c2t_hccs_getEffect($effect[Astral Shell]);
		c2t_hccs_getEffect($effect[Ghostly Shell]);

		c2t_hccs_combatLoversLocket($monster[Witchess Witch]);

		if (have_skill($skill[song of the north])) //bravado gets replaced by song of the north
			c2t_hccs_getEffect($effect[song of bravado]);
	}

	if (c2t_hccs_backupCamera() && get_property('backupCameraMode') != 'ml')
		cli_execute('backupcamera ml');

	//5 machine elf free fights
	if (have_familiar($familiar[machine elf])) {
		use_familiar($familiar[machine elf]);
		while (get_property("_machineTunnelsAdv").to_int() < 5) {
			//make sure have some mp
			if (have_skill($skill[Summon Candy Heart]) && available_amount($item[green candy heart]) == 0 && my_mp() >= mp_cost($skill[Summon Candy Heart])) {
				cli_execute("cast summon candy heart");
			}
			if (my_mp() < 50)
				cli_execute('eat magical sausage');
			if (my_primestat() == $stat[mysticality])
				maximize("mainstat,exp,equip Fourth of May Cosplay Saber,6 bonus designer sweatpants"+garbage,false);
			else
				maximize("mainstat,exp,equip June Cleaver,6 bonus designer sweatpants"+garbage,false);
			adv1($location[The Deep Machine Tunnels],-1,"");
		}
	}

	//Use Oliver's Place speakeasy free fights
	if (get_property('ownsSpeakeasy').to_boolean()) {
		while (get_property("_speakeasyFreeFights").to_int() < 3) {
			// Summon Candy Heart
			if (have_skill($skill[Summon Candy Heart]) && available_amount($item[green candy heart]) == 0) {
				cli_execute("cast summon candy heart");
			}
			//make sure have some mp
			if (my_mp() < 50)
				cli_execute('eat magical sausage');

			//make sure camel is equipped
			c2t_hccs_levelingFamiliar(false);

			if (get_property("_sourceTerminalPortscanUses").to_int() > 0)
				maximize("mainstat,exp,equip garbage shirt,-equip kramco sausage-o-matic&trade;,-equip i voted,6 bonus designer sweatpants"+fam,false);
			else
				maximize("mainstat,100exp,-equip garbage shirt,-equip kramco sausage-o-matic&trade;,equip i voted,6000 bonus designer sweatpants"+fam,false);
			adv1($location[An Unusually Quiet Barroom Brawl],-1,"");
		}
	}

	//NEP Prep

	if (!get_property('_gingerbreadMobHitUsed').to_boolean())
		print("Running backup camera and Neverending Party fights","blue");

	set_location($location[the neverending party]);

	int start = my_turncount();
	//NEP loop //neverending party and backup camera fights
	while (get_property("_neverendingPartyFreeTurns").to_int() < 10 || c2t_hccs_freeKillsLeft() > 0) {
		if (my_turncount() > start) {
			print("a turn was used in the neverending party loop","red");
			print("aborting in case mafia tracking broke somewhere or some unforseen thing happened","red");
			print("if ALL the stat tests can be completed in 1 turn right now, it may be better to do those manually then rerun this","red");
			print("this may be safe to run again, but probably best to not if turns keep being used here","red");
			abort("be sure to report if this problem persists");
		}

		// -- combat logic --
		//use doc bag kills first after free fights
		if (available_amount($item[lil' doctor&trade; bag]) > 0
			&& get_property('_neverendingPartyFreeTurns').to_int() == 10
			&& get_property('_chestXRayUsed').to_int() < 3)
				doc = ",equip lil doctor bag";
		else
			doc = "";

		if (c2t_hccs_levelingFamiliar(false) != $familiar[melodramedary])
			fam = "";

		//backup fights will turns this off after a point, so keep turning it on
		if (get_property('garbageShirtCharge').to_int() > 0)
			garbage = ",equip garbage shirt";
		else
			garbage = "";

		// -- using things as they become available --
		//use runproof mascara ASAP if moxie for more stats
		if (my_primestat() == $stat[moxie] && have_effect($effect[unrunnable face]) == 0 && item_amount($item[runproof mascara]) > 0)
			use(1,$item[runproof mascara]);

		//turtle tamer turtle
		if (my_class() == $class[turtle tamer] && have_effect($effect[gummi-grin]) == 0 && item_amount($item[gummi turtle]) > 0)
			use(1,$item[gummi turtle]);

		//eat CER pizza ASAP
		if (c2t_hccs_pizzaCube()
			&& have_effect($effect[synthesis: collection]) == 0//skip pizza if synth item
			&& have_effect($effect[certainty]) == 0
			&& item_amount($item[electronics kit]) > 0
			&& item_amount($item[middle of the road&trade; brand whiskey]) > 0)

			c2t_hccs_pizzaCube($effect[certainty]);

		

		//drink astral pilsners once level 11; saving 1 for use in mime army shotglass post-run
		if (my_level() >= 11 && item_amount($item[astral pilsner]) == 6) {
			cli_execute('shrug Shanty of Superiority');
			c2t_hccs_haveUse(1,$skill[the ode to booze]);
			drink(4,$item[astral pilsner]);
			cli_execute('shrug Ode to Booze');
			c2t_hccs_haveUse(1,$skill[stevedave's shanty of superiority]);
		}

		if (my_level() >= 13 && have_effect($effect[Inner Elf]) == 0) {
			acquireInnerElf();
		}

		//explicitly buying and using range as it rarely bugs out
		if (!(get_campground() contains $item[dramatic&trade; range]) && my_meat() >= (have_skill($skill[five finger discount])?950:1000)) { //five-finger discount
			retrieve_item($item[dramatic&trade; range]);
			use($item[dramatic&trade; range]);
		}
		//potion buffs when enough meat obtained
		if (have_effect($effect[tomato power]) == 0 && (get_campground() contains $item[dramatic&trade; range])) {
			if (my_primestat() == $stat[muscle]) {
				c2t_hccs_getEffect($effect[phorcefullness]);
				c2t_hccs_getEffect($effect[stabilizing oiliness]);
			}
			else if (my_primestat() == $stat[mysticality]) {
				c2t_hccs_getEffect($effect[mystically oiled]);
				c2t_hccs_getEffect($effect[expert oiliness]);
			}
			else if (my_primestat() == $stat[moxie]) {
				c2t_hccs_getEffect($effect[superhuman sarcasm]);
				c2t_hccs_getEffect($effect[slippery oiliness]);
			}
			c2t_hccs_getEffect($effect[tomato power]);
			c2t_assert(have_effect($effect[tomato power]) > 0,'It somehow missed again.');

			if (my_turncount() > start) {
				print(`detected {my_turncount()-start} turns used for crafting`);
				start = my_turncount();
			}
		}

		// -- setup and combat itself --
		// Summon Candy Heart
		if (have_skill($skill[Summon Candy Heart]) && available_amount($item[green candy heart]) == 0) {
			cli_execute("cast summon candy heart");
		}
		//make sure have some mp
		if (my_mp() < 50)
			cli_execute('eat magical sausage');

		// //hopefully stop it before a possible break if my logic is off
		// if (c2t_hccs_backupCamera() && get_property('_pocketProfessorLectures').to_int() == 0 && c2t_hccs_backupCameraLeft() <= 1)
		// 	abort('Pocket professor has not been used yet, while backup camera charges left is '+c2t_hccs_backupCameraLeft());
		//
		// //professor chain sausage goblins in NEP first thing if no backup camera
		// if (!c2t_hccs_backupCamera() && get_property('_pocketProfessorLectures').to_int() == 0) {
		// 	use_familiar($familiar[pocket professor]);
		// 	maximize("mainstat,equip garbage shirt,equip kramco sausage-o-matic&trade;,100familiar weight,6 bonus designer sweatpants",false);
		// }
		// //9+ professor copies, after getting exp buff from NC and used sauceror potions
		// else if (get_property('_pocketProfessorLectures').to_int() == 0
		// 	&& c2t_hccs_backupCameraLeft() > 0
		// 	&& (have_effect($effect[spiced up]) > 0 || have_effect($effect[tomes of opportunity]) > 0 || have_effect($effect[the best hair you've ever had]) > 0)
		// 	&& have_effect($effect[tomato power]) > 0
		// 	//target monster for professor copies. using back up camera to bootstrap
		// 	&& get_property('lastCopyableMonster').to_monster() == $monster[sausage goblin]
		// 	) {
		//
		// 	use_familiar($familiar[pocket professor]);
		// 	maximize("mainstat,equip garbage shirt,equip kramco sausage-o-matic&trade;,100familiar weight,6 bonus designer sweatpants,equip backup camera",false);
		// }
		// //fish for latte carrot ingredient with backup fights
		// else if (get_property('_pocketProfessorLectures').to_int() > 0
		// 	&& !get_property('latteUnlocks').contains_text('carrot')
		// 	&& c2t_hccs_backupCameraLeft() > 0
		// 	//target monster
		// 	&& get_property('lastCopyableMonster').to_monster() == $monster[sausage goblin]
		// 	) {
		//
		// 	//NEP monsters give twice as much base exp as sausage goblins, so keep at least as many shirt charges as fights remaining in NEP
		// 	if (get_property('garbageShirtCharge').to_int() < 17)
		// 		garbage = ",-equip garbage shirt";
		//
		// 	maximize("mainstat,exp,equip latte,equip backup camera,6 bonus designer sweatpants"+garbage+fam,false);
		// 	adv1($location[the dire warren],-1,"");
		// 	continue;//don't want to fall into NEP in this state
		// }
		//sombrero Feel pride fights for max exp
		if (get_property("_feelPrideUsed").to_int() < 3 && get_property('_neverendingPartyFreeTurns').to_int() > 4) {
			if (available_amount($item[tiny stillsuit]) > 0)
				fam = ",equip tiny stillsuit";
			use_familiar(c2t_priority($familiars[galloping grill,hovering sombrero]));
		} else {
			c2t_hccs_levelingFamiliar(false);
		}

		//inital and post-latte backup fights
		if (c2t_hccs_backupCameraLeft() > 0 && get_property('lastCopyableMonster').to_monster() == $monster[sausage goblin]) {
			//only use kramco offhand if target is sausage goblin to not mess things up
			if (get_property('lastCopyableMonster').to_monster() == $monster[sausage goblin])
				kramco = ",equip kramco sausage-o-matic&trade;";
			else
				kramco = "";

			//NEP monsters give twice as much base exp as sausage goblins, so keep at least as many shirt charges as fights remaining in NEP
			if (get_property('garbageShirtCharge').to_int() < 17)
				garbage = ",-equip garbage shirt";

			maximize("mainstat,exp,equip backup camera,6 bonus designer sweatpants"+kramco+garbage+fam,false);
		}
		//rest of the free NEP fights
		else
			maximize("mainstat,exp,equip kramco sausage-o-matic&trade;,6 bonus designer sweatpants"+garbage+fam+doc,false);

		adv1($location[the neverending party],-1,"");
	}
	

	//Asdonfuel
	if (get_workshed() == $item[Asdon Martin keyfob (on ring)] && have_effect($effect[driving observantly]) == 0) {
		int fuelTarget = 37 * 2;
		while (get_fuel() < fuelTarget) {
			//fuel up
			if (available_amount($item[20-lb can of rice and beans]) > 0) {
				cli_execute("asdonmartin fuel 1 20-lb can of rice and beans");
			} else if (available_amount($item[loaf of soda bread]) > 0) {
				cli_execute("asdonmartin fuel 1 loaf of soda bread");
			} else if (available_amount($item[9948]) > 0) {
				//Middle of the Road Brand Whiskey from NEP
				cli_execute("asdonmartin fuel 1 Middle of the Road™ brand whiskey");
			} else if (available_amount($item[PB&J with the crusts cut off]) > 0) {
				cli_execute("asdonmartin fuel 1 PB&J with the crusts cut off");
			} else if (available_amount($item[swamp haunch]) > 0) {
				cli_execute("asdonmartin fuel 1 swamp haunch");
			} else if (my_meat() >= 120) {
				cli_execute("make 1 loaf of soda bread");
				cli_execute("asdonmartin fuel 1 loaf of soda bread");
			} else {
				abort();
				break;
			}
		}
		boolean asdonBeanbagFreeKill = true;
		fuelTarget = fuelTarget + 100;
		//pref for asdonbean
		while (!get_property("_missileLauncherUsed").to_boolean() && get_fuel() < fuelTarget) {
			//fuel up
			if (available_amount($item[20-lb can of rice and beans]) > 0) {
				cli_execute("asdonmartin fuel 1 20-lb can of rice and beans");
			} else if (available_amount($item[loaf of soda bread]) > 0) {
				cli_execute("asdonmartin fuel 1 loaf of soda bread");
			} else if (available_amount($item[9948]) > 0) {
				//Middle of the Road Brand Whiskey from NEP
				cli_execute("asdonmartin fuel 1 Middle of the Road™ brand whiskey");
			} else if (available_amount($item[PB&J with the crusts cut off]) > 0) {
				cli_execute("asdonmartin fuel 1 PB&J with the crusts cut off");
			} else if (available_amount($item[swamp haunch]) > 0) {
				cli_execute("asdonmartin fuel 1 swamp haunch");
			} else if (my_meat() >= 120) {
				cli_execute("make 1 loaf of soda bread");
				cli_execute("asdonmartin fuel 1 loaf of soda bread");
			} else {
				asdonBeanbagFreeKill = false;
				break;
			}
		}
		if (!get_property("_missileLauncherUsed").to_boolean() && asdonBeanbagFreeKill) {
			//NEP free kill handle
			if (c2t_hccs_levelingFamiliar(false) == $familiar[melodramedary] && available_amount($item[dromedary drinking helmet]) > 0)
				fam = "";
			else if (available_amount($item[tiny stillsuit]) > 0)
				fam = ",equip tiny stillsuit";

			//backup fights will turns this off after a point, so keep turning it on
			if (get_property('garbageShirtCharge').to_int() > 0)
				garbage = ",equip garbage shirt";
			else
				garbage = "";

			maximize("mainstat,exp,equip kramco sausage-o-matic&trade;,6 bonus designer sweatpants"+garbage+fam,false);
			adv1($location[the neverending party],-1,"");
		}
	}

	// beach access
	c2t_assert(retrieve_item(1,$item[bitchin' meatcar]),"Couldn't get a bitchin' meatcar");

	// tune moon sign
	if (!get_property('moonTuned').to_boolean()) {
		int cog,tank,gogogo;

		// unequip spoon
		cli_execute('unequip hewn moon-rune spoon');

		// switch (my_primestat()) {
		// 	case $stat[muscle]:
		// 		gogogo = 7;
		// 		cog = 3;
		// 		tank = 1;
		// 		if (c2t_hccs_pizzaCube() && available_amount($item[beach comb]) == 0)
		// 			c2t_assert(retrieve_item(1,$item[gnollish autoplunger]),"gnollish autoplunger is a critical pizza ingredient without a beach comb");
		// 		break;
		// 	case $stat[mysticality]:
		// 		gogogo = 8;
		// 		cog = 2;
		// 		tank = 2;
		// 		break;
		// 	case $stat[moxie]:
		// 		gogogo = 9;
		// 		cog = 2;
		// 		tank = 1;
		// 		break;
		// 	default:
		// 		abort('something broke with moon sign changing');
		// }
		//gogogo = 7 - wombat for 20% meat
		//			4 - platypus for 5 fam weight (not gnome)
		gogogo = 4;
		cog = 2;
		tank = 2;
		if (c2t_hccs_pizzaCube()) {
			//CSAs for later pizzas (3 for CER & HGh) //2 for CER & DIF or CER & KNI
			c2t_assert(retrieve_item(cog,$item[cog and sprocket assembly]),"Didn't get enough cog and sprocket assembly");
			//empty meat tank for DIF and INFE pizzas
			c2t_assert(retrieve_item(tank,$item[empty meat tank]),`Need {tank} emtpy meat tank`);
		}
		//tune moon sign
		visit_url('inv_use.php?whichitem=10254&doit=96&whichsign='+gogogo);
	}

	cli_execute('mood apathetic');
}

boolean c2t_hccs_wandererFight() {
	print("Testing wanderer", "teal");
	//don't want to be doing wanderer whilst feeling lost
	if (have_effect($effect[feeling lost]) > 0) {
		print("Currently feeling lost, so skipping wanderer(s).","blue");
		return false;
	}

	string append = ",-equip garbage shirt,exp";
	if (c2t_isVoterNow()) {
		append += ",equip i voted";
		print("Vote wanderer", "teal");
	}
	//kramco should not be done here when only the coil wire test is done, otherwise the professor chain will fail
	else if (c2t_isSausageGoblinNow() && get_property('csServicesPerformed') != TEST_NAME[TEST_COIL_WIRE]) {
		append += ",equip kramco sausage-o-matic&trade;";
		print("Sausage wanderer", "teal");
	}
	else {
		print("No wanderers found", "teal");
		return false;
	}

	if (turns_played() == 0)
		c2t_hccs_getEffect($effect[feeling excited]);

	if (my_hp() < my_maxhp()/2 || my_mp() < 10) {
		c2t_hccs_breakfast();
		c2t_hccs_restoreMp();
	}
	print("Running wanderer fight","blue");
	//saving last maximizer string and familiar stuff; outfits generally break here
	string[int] maxstr = split_string(get_property("maximizerMRUList"),";");
	familiar nowFam = my_familiar();
	item nowEquip = equipped_item($slot[familiar]);

	if (c2t_hccs_levelingFamiliar(false) == $familiar[melodramedary] && available_amount($item[dromedary drinking helmet]) > 0)
		append += ",equip dromedary drinking helmet";
	else if (available_amount($item[tiny stillsuit]) > 0)
		append += ",equip tiny stillsuit";
	set_location($location[the neverending party]);
	maximize("mainstat,exp,6 bonus designer sweatpants"+append,false);
	if (get_property("stenchAirportAlways").to_boolean()) {
		adv1($location[The Toxic Teacups],-1);
	} else {
		adv1($location[the neverending party],-1,"");
	}

	//hopefully restore to previous state without outfits
	use_familiar(nowFam);
	maximize(maxstr[0],false);
	equip($slot[familiar],nowEquip);

	return true;
}

//switches to leveling familiar and returns which it is
familiar c2t_hccs_levelingFamiliar(boolean safeOnly) {
	familiar out;

	if (c2t_hccs_melodramedary()
		&& c2t_hccs_melodramedarySpit() < 100
		&& !get_property("csServicesPerformed").contains_text(TEST_NAME[TEST_WEAPON])) {

		out = $familiar[melodramedary];
	}
	else if (!safeOnly) {
		if (c2t_hccs_shorterOrderCook()
			&& !get_property("csServicesPerformed").contains_text(TEST_NAME[TEST_FAMILIAR])
			&& item_amount($item[short stack of pancakes]) == 0) {

			out = $familiar[shorter-order cook];
			if (my_familiar() != out)
				//give cook's combat bonus familiar exp to professor
				use_familiar($familiar[pocket professor]);
		}
		else
			out = c2t_priority($familiars[Mini-Hipster, Artistic Goth Kid,galloping grill,hovering sombrero]);
	}
	else
		out = $familiar[hovering sombrero];

	use_familiar(out);
	return out;
}

// will fail if haiku dungeon stuff spills outside of itself, so probably avoid that or make sure to do combats elsewhere just before a test
boolean c2t_hccs_testDone(int test) {
	print(`Checking test {test}...`);
	if (test == 30 && !get_property('kingLiberated').to_boolean() && get_property("csServicesPerformed").split_string(",").count() == 11)
		return false;//to do the 'test' and to set kingLiberated
	else if (get_property('kingLiberated').to_boolean())
		return true;
	return get_property('csServicesPerformed').contains_text(TEST_NAME[test]);
}

void c2t_hccs_doTest(int test) {
	if (!c2t_hccs_testDone(test)) {
		visit_url('council.php');
		visit_url('choice.php?pwd&whichchoice=1089&option='+test,true,true);
		c2t_assert(c2t_hccs_testDone(test),`Failed to do test {test}. Out of turns?`);
	}
	else
		print(`Test {test} already done.`);
}
