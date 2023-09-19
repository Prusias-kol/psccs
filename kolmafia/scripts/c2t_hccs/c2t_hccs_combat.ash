//c2t community service combat
//c2t

import <c2t_lib.ash>
import <c2t_hccs_lib.ash>
import <c2t_hccs_resources.ash>


// consult script for CS

//the logic for bowling sideways to bolt into c2t_bb
string c2t_hccs_bowlSideways();
string c2t_hccs_bowlSideways(string m);

//handle some skills with charges
string c2t_hccs_bbChargeSkill(string m,skill ski);
string c2t_hccs_bbChargeSkill(skill ski);

//portscan logic
string c2t_hccs_portscan();
string c2t_hccs_portscan(string m);


void main(int initround, monster foe, string page) {
	print("Turncount is " + my_adventures());
	//saber force
	if (have_effect($effect[meteor showered]) > 0 || have_effect($effect[fireproof foam suit]) > 0) {
		c2t_bb($skill[use the force]).c2t_bbSubmit();
		return;
	}

	string mHead = "scrollwhendone;";
	string mSteal = "pickpocket;";

	//top of basic macro, where all the weakening stuff is
	string mBasicTop =
		c2t_bb($skill[curse of weaksauce])
		.c2t_bb($skill[disarming thrust])
		.c2t_bb($skill[micrometeorite])
		.c2t_bb($skill[detect weakness]);

	//bottom of basic macro, where all the damaging stuff is
	string mBasicBot =
		c2t_bbIf("sealclubber || turtletamer || discobandit || accordionthief",
			c2t_bb($skill[sing along])
			.c2t_bbWhile("!pastround 20",c2t_bb("attack;"))
		)
		.c2t_bbIf("pastamancer",
			c2t_bb($skill[stuffed mortar shell])
			.c2t_bb($skill[sing along])
			.c2t_bb($skill[saucegeyser])
		)
		.c2t_bbIf("sauceror",
			c2t_bb($skill[stuffed mortar shell])
			.c2t_bb($skill[sing along])
			.c2t_bb($skill[saucegeyser])
		);

	//basic macro/what to run when nothing special needs be done
	string mBasic =	mBasicTop + mBasicBot;

	//mostly mBasic with relativity sprinkled in and small heal to help moxie survive chaining
	string mChain =
		mBasicTop
		.c2t_bbIf("sealclubber || turtletamer || discobandit || accordionthief",
			c2t_bbIf("discobandit || accordionthief",c2t_bb($skill[saucy salve]))
			.c2t_bb($skill[sing along])
			.c2t_bb($skill[lecture on relativity])
			.c2t_bbWhile("!pastround 20",c2t_bb("attack;"))
		)
		.c2t_bbIf("pastamancer",
			c2t_bb($skill[lecture on relativity])
			.c2t_bb($skill[stuffed mortar shell])
			.c2t_bb($skill[sing along])
		)
		.c2t_bbIf("sauceror",
			c2t_bb($skill[curse of weaksauce])
			.c2t_bb($skill[sing along])
			.c2t_bb($skill[lecture on relativity])
			.c2t_bb($skill[saucegeyser])
			.c2t_bb($skill[saucegeyser])
		);

	//macro to build
	string m;

	//run with ghost caroler for buffs at NEP and dire warren at different times
	if ($familiars[ghost of crimbo carols,exotic parrot] contains my_familiar()) {
		m = mHead + mSteal;
		if (foe == $monster[fluffy bunny] || foe == $monster[goblin flapper]) {
			m += c2t_bb($skill[become a cloud of mist]);
			m += c2t_bb($skill[fire extinguisher: foam yourself]);
			m.c2t_bbSubmit(true);
		} else if (my_location() == $location[Shadow Rift (The Right Side of the Tracks)]) { // leftover from before i put hot before weapon
			m = mHead + mSteal.c2t_bb($skill[meteor shower]);
			m.c2t_bbSubmit(true);
		}
		else {//NEP
			m += c2t_bb($skill[gulp latte]);
			m += c2t_bb($skill[offer latte to opponent]);
			m += c2t_bb($skill[throw latte on opponent]);
			m.c2t_bbSubmit();
		}
		return;
	}
	//saber random thing at this location for meteor shower buff -- saber happens elsewhere
	else if (my_location() == $location[Shadow Rift (The Right Side of the Tracks)]) {
		m = mHead + mSteal.c2t_bb($skill[meteor shower]);

		//camel spit for weapon test, which is directly after combat test
		if (get_property("csServicesPerformed").contains_text("Be a Living Statue") && !get_property("csServicesPerformed").contains_text("Reduce Gazelle Population"))
			m += c2t_bb($skill[%fn, spit on me!]);

		m.c2t_bbSubmit(true);
		return;
	}
	else {
		//basically mimicking CCS
		switch (foe) {
			//only use 1 become the bat for item test and initial latte throw
			case $monster[fluffy bunny]:
				//item test done, so should only be hot test left for the bunny?
				if (get_property("csServicesPerformed").contains_text("Make Margaritas")) {
					m = mHead + mSteal;
					m += c2t_bb($skill[become a cloud of mist]);
					m += c2t_bb($skill[fire extinguisher: foam yourself]);
					m.c2t_bbSubmit(true);
					return;
				}
				//fishing for latte ingredients with backups
				else if (have_equipped($item[backup camera]) && c2t_hccs_backupCameraLeft() > 0) {
					c2t_bb($skill[back-up to your last enemy])
					.c2t_bb("twiddle;")
					.c2t_bbSubmit(true);
					return;
				}
				c2t_bbSubmit(
					mHead + mSteal
					.c2t_bb(have_effect($effect[bat-adjacent form]) == 0?c2t_bb($skill[become a bat]):"")
					.c2t_bb(have_effect($effect[cosmic ball in the air]) == 0?c2t_bb($skill[bowl straight up]):"")
					.c2t_hccs_bbChargeSkill($skill[reflex hammer])
					.c2t_hccs_bbChargeSkill($skill[feel hatred])
					.c2t_hccs_bbChargeSkill($skill[kgb tranquilizer dart])
					.c2t_hccs_bbChargeSkill($skill[snokebomb])
				);
				return;

			//nostalgia other monster to get drops from these
			case $monster[possessed can of tomatoes]:
				//if no god lobster, burn a free kill to get both monsters' drops with nostalgia/envy here
				if (!have_familiar($familiar[god lobster])
					&& get_property('lastCopyableMonster').to_monster() == $monster[novelty tropical skeleton])
				{
					mSteal
					.c2t_bb($skill[feel nostalgic])
					.c2t_bb($skill[feel envy])
					.c2t_bb($skill[become a wolf])
					.c2t_bb($skill[gulp latte])
					.c2t_hccs_bbChargeSkill($skill[chest x-ray])
					.c2t_hccs_bbChargeSkill($skill[shattering punch])
					.c2t_bb($skill[gingerbread mob hit])
					.c2t_bbSubmit();
					return;
				}
			case $monster[novelty tropical skeleton]:
				c2t_bbSubmit(
					mSteal
					.c2t_bb($skill[become a wolf])
					.c2t_bb($skill[gulp latte])
					.c2t_bb($skill[bowl straight up])
					.c2t_bb($skill[throw latte on opponent])
				);
				return;

			//faxes -- saber use is elsewhere
			case $monster[ungulith]:
			case $monster[factory worker (female)]:
			case $monster[factory worker (male)]://just in case this shows up
				mSteal
				.c2t_bb($skill[meteor shower])
				.c2t_bbSubmit(true);
				return;
			case $monster[evil olive]:
				//have to burn a free kill and nostalgia/envy if no god lobster
				if (!have_familiar($familiar[god lobster])
					&& get_property('lastCopyableMonster').to_monster() == $monster["plain" girl]) {

					mSteal
					.c2t_bb($skill[feel nostalgic])
					.c2t_bb($skill[feel envy])
					.c2t_hccs_bbChargeSkill($skill[chest x-ray])
					.c2t_hccs_bbChargeSkill($skill[shattering punch])
					.c2t_bb($skill[gingerbread mob hit])
					.c2t_bbSubmit();
					return;
				}
			case $monster[hobelf]://apparently this doesn't work?
			case $monster[elf hobo]://this might though?
			case $monster[angry pi&ntilde;ata]:
				mSteal
					.c2t_bb($skill[use the force])//don't care about tracking a potential stolen item, so cut it straight away
					.c2t_bbSubmit();
				return;

			//using all free kills on neverending party monsters
			case $monster[biker]:
			case $monster[burnout]:
			case $monster[jock]:
			case $monster[party girl]:
			case $monster["plain" girl]:
				m = mHead + mSteal;
				//Asdon
				int nep = 10-get_property("_neverendingPartyFreeTurns").to_int();
				int free = c2t_hccs_freeKillsLeft();
				if (!get_property("_missileLauncherUsed").to_boolean() 
				&& nep + free == 0
				&& get_fuel() >= 174) { //runs last, should not bowl sideways
					m += c2t_bb($skill[Asdon Martin: Missile Launcher]);
					m.c2t_bbSubmit();
					return;
				}
				if (have_equipped($item[backup camera]) && c2t_hccs_backupCameraLeft() > 0) {
					m += c2t_bb($skill[back-up to your last enemy]).c2t_bb("twiddle;");
					m.c2t_bbSubmit(true);
					return;
				}
				//feel pride still thinks it can be used after max uses for some reason
				// > 4 to burn off bowl sideways from Oliver's den routing
				if (get_property('_neverendingPartyFreeTurns').to_int() > 4)
					m += c2t_hccs_bbChargeSkill($skill[feel pride]);

				//free kills after NEP free fights
				if (get_property('_neverendingPartyFreeTurns').to_int() == 10 && !get_property('_gingerbreadMobHitUsed').to_boolean()) {
					c2t_bbSubmit(
						m
						.c2t_bb($skill[sing along])
						.c2t_hccs_bowlSideways()
						//free kill skills
						//won't use otoscope anywhere else, so might as well use it while doc bag equipped
						.c2t_hccs_bbChargeSkill($skill[otoscope])
						.c2t_hccs_bbChargeSkill($skill[chest x-ray])
						.c2t_hccs_bbChargeSkill($skill[shattering punch])
						.c2t_bb($skill[gingerbread mob hit])
					);
				}
				//free combats at NEP
				else
					c2t_bbSubmit(m.c2t_hccs_bowlSideways() + mBasic);

				return;
			//machine elf free combats
			case $monster[Perceiver of Sensations]:
			case $monster[Performer of Actions]:
			case $monster[Thinker of Thoughts]:
				c2t_bbSubmit(mHead.c2t_hccs_bowlSideways().c2t_hccs_portscan() + mBasic);
				return;

			//most basic of combats
			case $monster[piranha plant]:
			case $monster[government bureaucrat]:
			case $monster[terrible mutant]:
			case $monster[angry ghost]:
			case $monster[annoyed snake]:
			case $monster[slime blob]:
			//oliver's place speakeasy Monsters
			case $monster[goblin flapper]:
			case $monster[gangster's moll]:
			case $monster[gator-human hybrid]:
			case $monster[traveling hobo]:
			case $monster[undercover prohibition agent]:
				print("Encountered a regular fight with: " + foe,"red");
				c2t_bbSubmit(mHead + mSteal + mBasic);
				//prob dont need to portscan cuz should never encounter
				return;
			//Witchess Witch - delevelers lose more dmg than they save
			case $monster[Witchess Witch]:
				c2t_bbSubmit(
					mHead
					.c2t_bbWhile("!pastround 20","attack;")
				);
				return;
			//Shadow Rift
			case $monster[shadow hexagon]:
			case $monster[shadow orb]:
			case $monster[shadow prism]:
			case $monster[shadow bat]:
			case $monster[shadow slab]:
			case $monster[shadow snake]:
			case $monster[shadow stalk]:
			case $monster[shadow guy]:
			case $monster[shadow devil]:
			case $monster[shadow tree]:
			case $monster[shadow spider]:
			case $monster[shadow cow]:
				c2t_bbSubmit(mHead + mBasic.c2t_bb($skill[saucegeyser]));
				return;
			//Shadow Rift Boss
			case $monster[shadow matrix]:
				c2t_bbSubmit(mHead + mBasic.c2t_bb($skill[saucegeyser]).c2t_bb($skill[saucegeyser]));
				return;
			case $monster[shadow orrery]:
				c2t_bbSubmit(mHead + mBasicTop.c2t_bb($skill[northern explosion]).c2t_bb($skill[northern explosion]).c2t_bb($skill[northern explosion]).c2t_bb($skill[northern explosion]));
				return;
			case $monster[shadow scythe]:
				c2t_bbSubmit(mHead + mBasicTop.c2t_bb($skill[saucegeyser]).c2t_bb($skill[saucegeyser]));
				return;
			//Passive dmg
			case $monster[shadow cauldron]:
			case $monster[shadow tongue]:
			//Can't be staggered
			case $monster[shadow spire]:
				c2t_bbSubmit(c2t_bb($skill[saucegeyser]).c2t_bb($skill[saucegeyser]));
			//portscan
			case $monster[government agent]:
				m = mHead + mSteal + mBasicTop;
				m += c2t_hccs_portscan();
				m += mBasicBot;
				m.c2t_bbSubmit();
				return;
			//Artistic Goth Kid
			case $monster[black crayon beast]:
			case $monster[black crayon beetle]:
			case $monster[black crayon constellation]:
			case $monster[black crayon golem]:
			case $monster[black crayon demon]:
			case $monster[black crayon man]:
			case $monster[black crayon elemental]:
			case $monster[black crayon crimbo elf]:
			case $monster[black crayon fish]:
			case $monster[black crayon goblin]:
			case $monster[black crayon hippy]:
			case $monster[black crayon hobo]:
			case $monster[black crayon shambling monstrosity]:
			case $monster[black crayon manloid]:
			case $monster[black crayon mer-kin]:
			case $monster[black crayon frat orc]:
			case $monster[black crayon penguin]:
			case $monster[black crayon pirate]:
			case $monster[black crayon flower]:
			case $monster[black crayon slime]:
			case $monster[black crayon undead thing]:
			case $monster[black crayon spiraling shape]:
			//Mini-Hipster
			case $monster[angry bassist]:
			case $monster[blue-haired girl]:
			case $monster[evil ex-girlfriend]:
			case $monster[peeved roommate]:
			case $monster[random scenester]:
				c2t_bbSubmit(mHead + mBasic.c2t_bb($skill[saucegeyser]));
				return;
			//chain potential; basic otherwise
			case $monster[sausage goblin]:
				c2t_bbSubmit(mHead + mChain);
				return;
			//nostalgia goes here
			case $monster[god lobster]:
				m = mHead + mBasicTop;
				//grabbing moxie buff item
				if (my_primestat() == $stat[moxie]
					&& have_effect($effect[unrunnable face]) == 0
					&& item_amount($item[runproof mascara]) == 0
					&& get_property('lastCopyableMonster').to_monster() == $monster[party girl]) {

					m += c2t_bb($skill[feel nostalgic]);
					m += c2t_bb($skill[feel envy]);
				}
				if (get_property('lastCopyableMonster').to_monster() == $monster[novelty tropical skeleton]
					|| get_property('lastCopyableMonster').to_monster() == $monster[possessed can of tomatoes]) {

					m += c2t_bb($skill[feel nostalgic]);
					m += c2t_bb($skill[feel envy]);
				}

				m += mBasicBot;
				m.c2t_bbSubmit();
				return;

			case $monster[eldritch tentacle]:
				c2t_bbSubmit(
					mHead + mSteal + mBasicTop
					.c2t_bb($skill[sing along])
					.c2t_bbIf("sealclubber || turtletamer || discobandit || accordionthief",
						c2t_bbWhile("!pastround 20","attack;")
					)
					.c2t_bbIf("pastamancer || sauceror",
						c2t_bb(4,$skill[saucestorm])
					)
				);
				return;

			case $monster[sssshhsssblllrrggghsssssggggrrgglsssshhssslblgl]:
				c2t_bbSubmit("attack;repeat;");
				return;

			//free run from holiday monsters
			//Feast of Boris
			case $monster[candied yam golem]:
			case $monster[malevolent tofurkey]:
			case $monster[possessed can of cranberry sauce]:
			case $monster[stuffing golem]:
			//El Dia de Los Muertos Borrachos
			case $monster[novia cad&aacute;ver]:
			case $monster[novio cad&aacute;ver]:
			case $monster[padre cad&aacute;ver]:
			case $monster[persona inocente cad&aacute;ver]:
			//talk like a pirate day
			case $monster[ambulatory pirate]:
			case $monster[migratory pirate]:
			case $monster[peripatetic pirate]:
				m = mHead + mSteal;
				m += c2t_hccs_bbChargeSkill($skill[reflex hammer]);
				m += c2t_hccs_bbChargeSkill($skill[feel hatred]).c2t_hccs_bbChargeSkill($skill[snokebomb]);
				m += c2t_hccs_bbChargeSkill($skill[kgb tranquilizer dart]);
				m.c2t_bbSubmit();
				//pretty sure most adv1() in the script assume it succeeds in fighting what it's supposed to, which the holiday monster is very much not the right one, so abort to rerun
				//abort("Aborting for safety after encountering a holiday monster. Should be able to simply rerun to resume.");
				//going to test using adv1() instead of abort for next round of holiday wanderers
				adv1(my_location());
				//abort("Check to see if it adventured in the correct location");
				return;
			//Mother slime for Inner Elf with machine elf
			case $monster[Mother Slime]:
				if (get_property("_snokebombUsed").to_int() < 3)
					m += c2t_hccs_bbChargeSkill($skill[snokebomb]);
				m += c2t_hccs_bbChargeSkill($skill[kgb tranquilizer dart]);
				m.c2t_bbSubmit();
				return;

			default:
				//this shouldn't happen
				abort("Currently in combat with something not accounted for in the combat script. Aborting.");
		}
	}
}

string c2t_hccs_bowlSideways() return c2t_hccs_bowlSideways("");
string c2t_hccs_bowlSideways(string m) {
	string out = m+c2t_bb($skill[bowl sideways]);
	int backup = get_property("_backUpUses").to_int();
	int nep = 10-get_property("_neverendingPartyFreeTurns").to_int();
	int free = c2t_hccs_freeKillsLeft();
	if (out == m)
		return m;
	if (get_property("csServicesPerformed") != "Coil Wire")
		return m;
	if (my_familiar() == $familiar[ghost of crimbo carols])
		return m;
	if (my_familiar() == $familiar[pocket professor])//professor copies should be in the zone
		return out;
	if (backup > 0 && backup < 11)//backups unaffected, so skip while doing them
		return m;
	// if (get_property("_speakeasyFreeFights").to_int() < 3 && my_location() == $location[An Unusually Quiet Barroom Brawl])
	// 	return out;
	if (my_location() == $location[The Deep Machine Tunnels]
		&& get_property("_machineTunnelsAdv").to_int() < 4) //make sure it doesn't bowl sideways at the end
		return out;
	if (nep+free > 1 && my_location() == $location[The Neverending Party])
		return out;
	return m;
}

//stopgap for now; should add a handler to lib
string c2t_hccs_bbChargeSkill(string m,skill ski) {
	return m + c2t_hccs_bbChargeSkill(ski);
}
string c2t_hccs_bbChargeSkill(skill ski) {
	string prop;
	int max;
	switch (ski) {
		default:
			abort(`Error: unhandled skill in c2t_hccs_bbChargeSkill: "{ski}"`);
		case $skill[chest x-ray]:
			prop = "_chestXRayUsed";
			max = 3;
			break;
		case $skill[feel hatred]:
			prop = "_feelHatredUsed";
			max = 3;
			break;
		case $skill[feel pride]:
			prop = "_feelPrideUsed";
			max = 3;
			break;
		case $skill[kgb tranquilizer dart]:
			prop = "_kgbTranquilizerDartUses";
			max = 3;
			break;
		case $skill[otoscope]:
			prop = "_otoscopeUsed";
			max = 3;
			break;
		case $skill[reflex hammer]:
			prop = "_reflexHammerUsed";
			max = 3;
			break;
		case $skill[shattering punch]:
			prop = "_shatteringPunchUsed";
			max = 3;
			break;
		case $skill[snokebomb]:
			prop = "_snokebombUsed";
			max = 3;
			break;
	}
	return get_property(prop).to_int() < max ? c2t_bb(ski) : "";
}

//portscan logic
string c2t_hccs_portscan() return c2t_hccs_portscan("");
string c2t_hccs_portscan(string m) {
	if (get_property("ownsSpeakeasy").to_boolean()
		&& get_property("_speakeasyFreeFights").to_int() < 3
		&& my_location() == $location[An Unusually Quiet Barroom Brawl])
		return m + c2t_bb($skill[portscan]);
	else if (my_location() == $location[The Deep Machine Tunnels]
		&& get_property("_machineTunnelsAdv").to_int() == 4) //pref updated after fight
		return m + c2t_bb($skill[portscan]);

	return m;
}
