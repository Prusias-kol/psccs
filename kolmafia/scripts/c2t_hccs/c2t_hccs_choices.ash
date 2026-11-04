//c2t hccs choices
//c2t

import <c2t_lib.ash>

void c2t_hccs_choiceMobiusRing(string page);

void main (int id,string page) {
	int testsDone = get_property("csServicesPerformed").split_string(",").count();

	switch (id) {
		default:
			return;

		//NEP start
		// 1: take quest
		// 2: decline quest
		// 6: leave
		case 1322:
			print("Handling NEP quest", "red");
			switch (get_property("_questPartyFairQuest")) {
				print(get_property("_questPartyFairQuest"));
				case "food":
				case "booze":
					run_choice(1);
					print("Accepting NEP quest", "red");
					break;
				case "dj":
				case "trash":
				case "partiers":
				case "woots":
				default:
					run_choice(2);
					print("Rejecting NEP quest", "red");
					break;
			}
			break;

		//It Hasn't Ended, It's Just Paused
		//1: Head upstairs
		//2: Check out the kitchen
		//3: Go to the back yard
		//4: Investigate the basement
		//5: Pick a fight
		case 1324:
			//going for stat exp buff initially, then combats afterward
			if (my_primestat() == $stat[muscle] && have_effect($effect[spiced up]) == 0) {
				run_choice(2);
				run_choice(2);//1325/2
			}
			else if (my_primestat() == $stat[mysticality] && have_effect($effect[tomes of opportunity]) == 0) {
				run_choice(1);
				run_choice(2);//1326/2
			}
			else if (my_primestat() == $stat[moxie] && have_effect($effect[the best hair you've ever had]) == 0) {
				run_choice(4);
				run_choice(2);//1328/2
			}
			else
				run_choice(5);
			break;

		//Is there A Doctor In The House? / doc bag
		//1: Accept the case
		//2: Decline the case
		//3: Turn off the phone for the rest of the day
		case 1340:
			run_choice(1);
			break;

		//Using the Force
		//1: saber banish
		//2: saber copy
		//3: saber yr
		case 1387:
			run_choice(3);
			break;

		//Granted a Boon / God Lobster
		//the following is only true if crown not equipped:
		//1: equipment
		//2: buff
		//3: stats
		case 1310:
			//assuming any post-leveling fight of glob is for a buff
			if (testsDone > 1)
				run_choice(2);
			else
				run_choice(1);
			break;
		/*
		Mother slime
		1: fight mother slime
		2: skip at no adv cost
		 */
		case 326:
			run_choice(1);
			break;

		//===================
		// june cleaver
		//===================
		/*
		Encounter: Poetic Justice
		1: mox stat
		2: mys stat
		3: +5 adv & beaten up
		*/
		case 1467:
			run_choice(3);//+5 adv
			cli_execute("rest free");
			break;
		/*
		Aunts not Ants
		1: mox stat
		2: mus stat
		3: ashamed effect
		*/
		case 1468:
			if (testsDone < 2 && my_primestat() == $stat[moxie])
				run_choice(1);//mox stat
			else if (testsDone < 2 && my_primestat() == $stat[muscle])
				run_choice(2);//mus stat
			else if (available_choice_options() contains 4)
				run_choice(4);
			else
				run_choice(2);
			break;
		/*
		Beware of Aligator
		1: 20 ML
		2: booze
		3: 1500 meat
		*/
		case 1469:
			if (testsDone < 2)
				run_choice(1);//20 ML
			else if (available_choice_options() contains 4)
				run_choice(4);
			else
				run_choice(2);//booze
			break;
		/*
		Teacher's Pet
		1: teacher's pet effect
		2: teacher's pen
		3: mus stat
		*/
		case 1470:
			if (testsDone < 2 && my_primestat() == $stat[muscle])
				run_choice(3);//mus stat
			else if (available_choice_options() contains 4)
				run_choice(4);
			else
				run_choice(2);//teacher's pen
			break;
		/*
		Lost and Found
		1: meat potion
		2: mus stat, 250 meat, beaten up
		3: mys stat
		*/
		case 1471:
			if (testsDone < 2 && my_primestat() == $stat[muscle]) {
				run_choice(2);//mus stat
				cli_execute("rest free");
			}
			else if (testsDone < 2 && my_primestat() == $stat[mysticality])
				run_choice(3);//mys stat
			else if (available_choice_options() contains 4)
				run_choice(4);
			else
				run_choice(1);//meat potion
			break;
		/*
		Summer Days
		1: nc potion
		2: food
		3: mox stat
		*/
		case 1472:
			run_choice(1);//nc potion
			break;
		/*
		Bath Time
		1: mus stat; gob of wet hair
		2: wholesome resolved effect
		3: kinda damp effect
		*/
		case 1473:
			if (testsDone < 2 && my_primestat() == $stat[muscle])
				run_choice(1);//mus stat
			else if (!get_property("csServicesPerformed").contains_text("Clean Steam Tunnels"))
				run_choice(3);//hot resist
			else if (available_choice_options() contains 4)
				run_choice(4);
			else
				run_choice(1);//mus stat
			break;
		/*
		Delicious Sprouts
		1: mys stat
		2: food
		3: mus stat
		*/
		case 1474:
			if (testsDone < 2 && my_primestat() == $stat[muscle])
				run_choice(3);//mus stat
			else if (testsDone < 2 && my_primestat() == $stat[mysticality])
				run_choice(1);//mys stat
			else if (available_choice_options() contains 4)
				run_choice(4);
			else
				run_choice(2);//food
			break;
		/*
		Hypnotic Master
		1: mom's necklace
		2: mus stat
		3: 2 random effects
		*/
		case 1475:
			if (testsDone < 2 && my_primestat() == $stat[muscle])
				run_choice(2);//mus stat
			else
				run_choice(1);//mom's necklace
			break;
		//SIT
		case 1494:
			run_choice(2);//insectology
			break;
		//labyrinth of shadows
		/*
		Calling Rufus
		1: boss quest (free)
		2: artifact quest
		3: item quest
		4: hang up
		*/
		case 1497:
			run_choice(1);
			break;
		case 1498:
			run_choice(1);//finish quest
			break;
		case 1499:
			string str;
			switch (get_property("rufusQuestTarget")) {
				default:
				case "shadow heptahedron":
					str = "Mysticality";
					break;
				case "shadow snowflake":
					str = "Shadow's Chill";
					break;
				case "shadow heart":
					str = "Shadow's Heart";
					break;
				case "shadow wave":
					str = "Shadow's Thickness";
					break;
				case "shadow lighter":
					str = "Muscle";
					break;
				case "shadow bucket":
					str = "Moxie";
					break;
			}
			for tries from 1 to 50 {
				string[int] choices = available_choice_options(true);
				print("Attempt " + tries + " with " + choices[2]);
				for i from 2 to 4 if (choices[i].contains_text(str)) {
					run_choice(i);
					return;
				}
				run_choice(1);
			}
			abort("labyrinth of shadows broke or just super unlucky?");
			break;
		//Time is a Möbius Strip
		case 1562:
			c2t_hccs_choiceMobiusRing(page);
			//The ring interrupted the intended free adventure.
			c2t_freeAdv(my_location());
			break;

		//halloweiner dog
		case 1106:
			run_choice(3);
			break;
		case 1107:
			run_choice(1);
			break;
		case 1108:
			run_choice(1);
			break;
	}
}

void c2t_hccs_choiceMobiusRing(string page) {
	//just going to increase paradoxicity--only ever going to get few in-run anyway
	int pick = 1;
	foreach i,paradox in string[int]{
		"Stop your arch-nemesis as a baby",			//+ potion combat -5
		"Go back and take a 20-year-long nap",			//+ effect mp 30, mys 15
		"Lift yourself up by your bootstraps",			//+ mus stats
		"Borrow meat from your future",				//+ 1000 meat
		"Go back and write a best-seller.",			//+ effect mox 25
		"Steal a cupcake from young Susie",			//+ food epic size 1
		"Borrow a cup of sugar from yourself",			//+ food good size 1
		"Shoot yourself in the foot",				//+ mox stats
		"Mind your own business",				//+ mys stats
		"Give your past self investment tips",			//+ item stock certificate
		"Plant some trees and harvest them in the future",	//+ item 5 random fruit
		"Steal a club from the past",				//+ item random club
		"Hey, free gun!",					//+ item the gun w/ weapon damage 50
		"Plant some seeds in the distant past",			//+ effect hp 30, mus 15
		"Go for a nature walk",					//+ effect 9 mp regen
		"Draw a goatee on yourself",				//+ effect 5 stats per fight
		"Cheeze it, it's the pigs!",				//+ effect mus -30, hp -15
		"Peek in on your future",				//+ effect weapon drop 100%
		"Meet your parents when they were young",		//+ effect mox -15, init -50
		"Defend yourself",					//+ effect mp -10, init 50
		"Play Schroedinger's Prank on yourself",		//+ effect varies every turn
		"Take the long odds on the trifecta",			//+ effect Marked by the Don
		"Make friends with a famous poet",			//+ effect that breaks kolmafia tracking (anapests)
		}
	{
		matcher m = create_matcher(`value=(\\d+)><input\\s+class=button\\s+type=submit\\s+value="{paradox}"`,page);
		if (m.find()) {
			pick = m.group(1).to_int();
			break;
		}
	}
	run_choice(pick);
}

