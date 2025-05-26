// some random global variables

string lastMap = "";
int fpTime = 0;
float pb = 0;

bool loading = false;

float wm_time = 0;
float cm_time = 0;

array<string> allLBPos = {};

array<string> cachedLBPos = {};
array<int> cachedLBTimes = {};
array<array<string>> currentCustomSettings = {};

bool infoOpen = false;

bool enabled = false;

// settings

[Setting name="Show Widget" description="The visibility of the widget in-game." category="General"]
bool Setting_Show = true;

[Setting name="Show Widget In Game Style" description="Show the widget in the style of the game using NVG." category="General"]
bool Setting_NVG = false;

[Setting name="Show Track Info" description="The visibility of the track name and author." category="General"]
bool Setting_TrackNameVis = true;

#if DEPENDENCY_WARRIORMEDALS
[Setting name="Show Warrior Medal" description="Only avaliable if you have the Warrior Medal plugin." category="Medals"]
bool Setting_ShowWarrior = true;

[Setting name="Warrior Medal Name" category="Medals" description="Change the name of the Warrior medal on the widget." if="Setting_ShowWarrior"]
string Setting_WarriorName = "Warrior";
#endif

#if DEPENDENCY_CHAMPIONMEDALS
[Setting name="Show Champion Medal" description="Only avaliable if you have the Champion Medal plugin." category="Medals"]
bool Setting_ShowChamp = true;

[Setting name="Champion Medal Name" category="Medals" description="Change the name of the Champion medal on the widget." if="Setting_ShowChamp"]
string Setting_ChampName = "Champion";
#endif

[Setting name="Show Personal Best" description="Show your personal best." category="Medals"]
bool Setting_ShowPB = true;

[Setting name="PB Name" category="Medals" description="Change the name of the PB on the widget." if="Setting_ShowPB"]
string Setting_PBName = "PB";

[Setting name="Show Custom Made Medals" description="Show medals made in the custom medal creator." category="Custom Medals"]
bool Setting_ShowCustomMade = true;

[Setting name="Show World Record" description="Show the current world record time if possible." category="Custom Medals"]
bool Setting_ShowWR = true;

[Setting name="WR Medal Name" category="Custom Medals" description="Change the name of the WR medal on the widget." if="Setting_ShowWR"]
string Setting_WRName = "WR";

[Setting name="Show Author Time" category="Medals"]
bool Setting_ShowAuth = true;

[Setting name="Author Medal Name" category="Medals" description="Change the name of the Author medal on the widget." if="Setting_ShowAuth"]
string Setting_AuthName = "Author";

[Setting name="Show Gold Time" category="Medals"]
bool Setting_ShowGold = true;

[Setting name="Gold Medal Name" category="Medals" description="Change the name of the Gold medal on the widget." if="Setting_ShowGold"]
string Setting_GoldName = "Gold";

[Setting name="Show Silver Time" category="Medals"]
bool Setting_ShowSilver = true;

[Setting name="Silver Medal Name" category="Medals" description="Change the name of the Silver medal on the widget." if="Setting_ShowSilver"]
string Setting_SilverName = "Silver";

[Setting name="Show Bronze Time" category="Medals"]
bool Setting_ShowBronze = true;

[Setting name="Bronze Medal Name" category="Medals" description="Change the name of the Bronze medal on the widget." if="Setting_ShowBronze"]
string Setting_BronzeName = "Bronze";

#if DEPENDENCY_WARRIORMEDALS
[Setting name="Show Master Time" description="Shows the Master time. Warrior medal plugin required. Calculation: WT-(AT-WT)/1.25" category="Custom Medals"]
bool Setting_ShowMaster = false;

[Setting name="Master Medal Name" category="Custom Medals" description="Change the name of the Master medal on the widget." if="Setting_ShowMaster"]
string Setting_MasterName = "Master";
#endif

[Setting name="Show Starter Time" description="Shows the Starter time. Worse then Bronze. Calculation: BT+(BT-ST)" category="Custom Medals"]
bool Setting_ShowStarter = false;

[Setting name="Starter Medal Name" category="Custom Medals" description="Change the name of the Starter medal on the widget." if="Setting_ShowStarter"]
string Setting_StarterName = "Starter";

[Setting name="Show Medal Icon" description="Shows the medal icon with the color of the medal." category="Display"]
bool Setting_ShowMedal = true;

[Setting name="Show Medal Time" description="Shows the time required for the medal." category="Display"]
bool Setting_ShowTime = true;

[Setting name="Show Non Complete Times" description="Shows times rendered as -:--.-- on the widget." category="Display"]
bool Setting_ShowNonCompleteTimes = true;

[Setting name="Show Medal Name" description="Shows the name of the medal." category="Display"]
bool Setting_ShowName = true;

[Setting name="Show Delta Time" description="Shows the delta time between your PB and the medal." category="Display"]
bool Setting_ShowDelta = false;

[Setting name="Show Tier Medals" description="Show tier medals (I to IV and even to V if the gap is large for each medal.) This will not display for Champion medals." category="Custom Medals"]
bool Setting_ShowTiers = false;

[Setting name="Same Medal Background" description="Make all medal background colors the same. Only useful for Show Tier Medals." category="Display" if="Setting_ShowTiers"]
bool Setting_SMB = false;

[Setting name="Show PB Medal" description="Show the medal that you have next to the PB indicator." if="Setting_ShowPB"]
bool Setting_ShowPBMedal = false;

[Setting name="Custom Medals String Debug" hidden]
string Setting_CustomMedals = "";

[Setting name="Widget X Position"]
int Setting_X = 100;

[Setting name="Widget Y Position"]
int Setting_Y = 100;

// nadeo services!!! yay

vec4 formatToVec4(const string inserted) {
	auto str = inserted.SubStr(2);
	auto hex = "#" + str.SubStr(0, 1) + "0" + str.SubStr(1, 1) + "0" + str.SubStr(2, 1) + "0";
	auto color = Text::ParseHexColor(hex);
	return color;
}

int getTimeAtPos(const int position) {
	if (position < 1 || position > 10000) {
		return 0;
	}
	auto app = cast<CTrackMania>(GetApp());
	auto track = app.RootMap;


	NadeoServices::AddAudience("NadeoLiveServices");

	auto request = NadeoServices::Get("NadeoLiveServices", 'https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/Personal_Best/map/' + track.MapInfo.MapUid + '/top?length=1&onlyWorld=true&offset=' + (position-1) );
	request.Start();

	while (! request.Finished()) {
		sleep(100);
	}
	int time = 0;
	if (request.Finished()) {
		if (true) {
			if (request.Json().Get("tops")[0].Get("top").Length > 0) {
				auto keys = request.Json().Get("tops")[0].Get("top")[0].Get("score");
				time = keys;
			}
		}
	}
	return time;
}

// below until Main() is for the string to expression converter

array<float> getValues(const array<string> &in lTR, const int lookup) {
	int look = lookup;
	array<string> list = lTR;
	float before = 0;
	float after = 0;
	if (look-1 > -1) {
		if (Text::TryParseFloat(list[look-1], 0.0)) {
			before = Text::ParseFloat(list[look-1]);
		}
	} 
	if (look+1 < int(list.Length)) {
		if (Text::TryParseFloat(list[look+1], 0.0)) {
			after = Text::ParseFloat(list[look+1]);
		}
	} 
	return {before, after};
}

array<string> subList(const array<string> &in lTR, const int s, const int e) {
	array<string> list = lTR;
	int start = s;
	int end = e;
	array<string> subCalc = {};
	if (start < 0) {
		end -= start;
		start = 0;
	}
	if (int(end+1) > int(list.Length)) {
		end = list.Length-1;
	}
	for (int i = start; i < end; i++) {
		subCalc.InsertLast(list[i]);
	}
	return subCalc;
}

array<string> replaceList(const array<string> &in lTR, const int s, const int e, const string tRW) {
	array<string> list = lTR;
	string replacement = tRW;
	int start = s;
	int end = e;
	if (start < 0) {
		end -= start;
		start = 0;
	}
	if (int(start+end+1) > int(list.Length)) {
		end = list.Length-start;
	}
	if (end < 1) {
		end = 1;
	}
	list.RemoveRange(start, end);
	list.InsertAt(start, replacement);
	return list;
}

float calcText(const array<string> &in toCal) {
	array<string> toCalc = toCal;
	float curValue = 0;

	auto app = cast<CTrackMania>(GetApp());
	auto track = app.RootMap;

	for (int i = 0; i < int(toCalc.Length); i++) {
		if (toCalc[i].Contains("$")) {
			auto subbed = toCalc[i];
			float replacement = 0.0;
			if (subbed == "$BT") {
				replacement = track.TMObjective_BronzeTime;
			}
			if (subbed == "$ST") {
				replacement = track.TMObjective_SilverTime;
			}
			if (subbed == "$GT") {
				replacement = track.TMObjective_GoldTime;
			}
			if (subbed == "$AT") {
				replacement = track.TMObjective_AuthorTime;
			}
			if (subbed == "$WR") {
				replacement = fpTime;
			}
			if (subbed == "$PB") {
				replacement = pb;
			}
			if (subbed == "$WT") {
				replacement = wm_time;
			}
			if (subbed == "$CM") {
				replacement = (wm_time-((track.TMObjective_AuthorTime-wm_time)/1.25));
			}
			if (subbed == "$CS") {
				replacement = (track.TMObjective_BronzeTime+((track.TMObjective_BronzeTime-track.TMObjective_SilverTime)));
			}
			if (subbed.Contains("$#")) {
				string placement = subbed.SubStr(2);
				if (cachedLBPos.Find(placement) > -1 && cachedLBPos.Find(placement) < int(cachedLBTimes.Length) && Text::TryParseInt(placement, 0.0)) {
					replacement = cachedLBTimes[cachedLBPos.Find(placement)];
				}
			}
			toCalc = replaceList(toCalc, i, 1, ""+(replacement/1000));
		}
	}

	while (toCalc.Find("(") > -1 && toCalc.Find(")") > -1) {
		array<string> subCalc = subList(toCalc, toCalc.Find("(")+1, toCalc.Find(")"));
		toCalc = replaceList(toCalc, toCalc.Find("("), toCalc.Find(")")-toCalc.Find("(")+1, ""+calcText(subCalc));
	}

	while (toCalc.Find("^") > -1) {
		int index = toCalc.Find("^");
		array<float> values = getValues(toCalc, index);
		float ans = values[0]**values[1];
		toCalc = replaceList(toCalc, index-1, 3, ""+ans);
	}

	while (toCalc.Find("*") > -1 || toCalc.Find("/") > -1) {
		if ((toCalc.Find("*") < toCalc.Find("/") && toCalc.Find("*") > -1) || toCalc.Find("/") < 0) {
			int index = toCalc.Find("*");
			array<float> values = getValues(toCalc, index);
			float ans = values[0]*values[1];
			toCalc = replaceList(toCalc, index-1, 3, ""+ans);
		} else {
			int index = toCalc.Find("/");
			array<float> values = getValues(toCalc, index);
			if (values[1] == 0) {
				values[1] = 1;
			}
			float ans = values[0]/values[1];
			toCalc = replaceList(toCalc, index-1, 3, ""+ans);
		}
	}

	while (toCalc.Find("+") > -1 || toCalc.Find("-") > -1) {
		if ((toCalc.Find("+") < toCalc.Find("-") && toCalc.Find("+") > -1) || toCalc.Find("-") < 0) {
			int index = toCalc.Find("+");
			array<float> values = getValues(toCalc, index);
			float ans = values[0]+values[1];
			toCalc = replaceList(toCalc, index-1, 3, ""+ans);
		} else {
			int index = toCalc.Find("-");
			array<float> values = getValues(toCalc, index);
			float ans = values[0]-values[1];
			toCalc = replaceList(toCalc, index-1, 3, ""+ans);
		}
	}

	if (toCalc.Length > 0) {
		if (Text::TryParseFloat(toCalc[0], 0.0)) {
			return Text::ParseFloat(toCalc[0]);
		}
	}
	return 0.0;
}

array<string> splitText(const string &in toCal) {
	string toCalc = toCal;
	array<string> split = {};
	string current = "";
	bool isEq = false;
	toCalc = toCalc.Replace(" ", "");
	for (int i = 0; i < int(toCalc.Length); i++) {
		string byte = toCalc.SubStr(i, 1);
		// handles negative numbers
		if (Regex::Search(byte, "([-])").Length > 0 && isEq == false) {
			string last = toCalc.SubStr(i-1, 1);
			string next = toCalc.SubStr(i+1, 1);
			if (Regex::Search(last, "([-*/+^()])").Length == 0 && i > 0) {
				split.InsertLast(current);
				current = "";
				isEq = true;
			}
		}

		// handles nums & operators
		if (Regex::Search(byte, "([*/+^()])").Length > 0 && isEq == false) {
			if (current.Length != 0) {
				split.InsertLast(current);
			}
			current = "";
			isEq = true;
		}
		if (current.Length > 0 && isEq == true) {
			split.InsertLast(current);
			current = "";
			isEq = false;
			if (Regex::Search(byte, "([*/+^()])").Length > 0) {
				isEq = true;
			}
		}
		current = current + byte;

	}
	if (current.Length != 0) {
		split.InsertLast(current);
	}
	return split;
}


void Main() {
	if (! OpenplanetHasPaidPermissions()) {
		warn("User does not have permissions to use this plugin.");
		return;
	}

	auto ar = Setting_CustomMedals.Split("|");
	array<array<string>> nr = {};

	for(uint i = 0; i < ar.Length; i++) {
		auto arr = ar[i].Split(":");
		if (arr.Length > 0) {
			nr.InsertLast(arr);
		}
	}

	currentCustomSettings = nr;
	while (true) {

		auto app = cast<CTrackMania>(GetApp());
		auto track = app.RootMap;

		if (track !is null) {
			if (lastMap != track.MapInfo.MapUid) {
				// handle lb requests
				loading = true;
				fpTime = 0;
				lastMap = track.MapInfo.MapUid;
				fpTime = getTimeAtPos(1);

				int requests_sent = 1;

				cachedLBTimes = {};
				cachedLBPos = {};
				for(uint i = 1; i < currentCustomSettings.Length; i++) {
					array<string> split = splitText(currentCustomSettings[i][0]);
					for(uint j = 0; j < split.Length; j++) {
						if (split[j].Contains("$#")) {
							string num = split[j].SubStr(2);
							if (Text::TryParseInt(num, 0.0)) {
								int pos = Text::ParseInt(num);
								if (cachedLBPos.Find(num) < 0 && requests_sent < 10) {
									cachedLBPos.InsertLast(num);
									int time = getTimeAtPos(pos);
									cachedLBTimes.InsertLast(time);
									requests_sent += 1;
									sleep(1500);
								}
							}
						}
					}
				}
				loading = false;				
			}
		} else {
			fpTime = 0;
		}	

		sleep(100);
	}
}

void Render() {
	if (! OpenplanetHasPaidPermissions()) {
		if (Setting_Show) {
			UI::SetNextWindowPos(Setting_X,Setting_Y);
			int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
			UI::Begin("r", flags);
			UI::Text("You do not have the required permissions to use 'AllTheMedals': Club or Standard access.");
			UI::End();
		}
		return;
	}

	auto app = cast<CTrackMania>(GetApp());
	auto track = app.RootMap;

	if (track !is null && Setting_Show) {
#if DEPENDENCY_WARRIORMEDALS
wm_time = WarriorMedals::GetWMTime();
#endif
#if DEPENDENCY_CHAMPIONMEDALS
cm_time = ChampionMedals::GetCMTime();
#endif



		bool type = true;
		auto network = cast<CTrackManiaNetwork>(app.Network);

		UI::SetNextWindowPos(Setting_X,Setting_Y);

		if (Setting_NVG == true && UI::IsOverlayShown() == false) {
			type = false;
		} else {
			int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
			UI::Begin("m", flags);

			auto pos = UI::GetWindowPos();
			Setting_X = int(pos.x);
			Setting_Y = int(pos.y);
		}


		float besttime = -1;
		float bestmedal = 0;



		if(network.ClientManiaAppPlayground !is null) {


			auto userMgr = network.ClientManiaAppPlayground.UserMgr;
			MwId userId;
			if (userMgr.Users.Length > 0) {
				userId = userMgr.Users[0].Id;
			} else {
				userId.Value = uint(-1);
			}
			
			auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;
			besttime = scoreMgr.Map_GetRecord_v2(userId, track.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
			pb = besttime;
		}

		if (Setting_NVG == true && UI::IsOverlayShown() == true) {
			UI::Text(Icons::ArrowsAlt);
		}

		array<dictionary> times = {};

		// normal medals

		if (Setting_ShowAuth == true) {
			dictionary a = {{"Time",track.TMObjective_AuthorTime},{"Color","\\$071"},{"Name",Setting_AuthName}};
			times.InsertLast(a);
		}

		if (Setting_ShowGold == true) {
			dictionary g = {{"Time",track.TMObjective_GoldTime},{"Color","\\$ed1"},{"Name",Setting_GoldName}};
			times.InsertLast(g);
		}

		if (Setting_ShowSilver == true) {
			dictionary s = {{"Time",track.TMObjective_SilverTime},{"Color","\\$bbb"},{"Name",Setting_SilverName}};
			times.InsertLast(s);
		}

		if (Setting_ShowBronze == true) {
			dictionary b = {{"Time",track.TMObjective_BronzeTime},{"Color","\\$830"},{"Name",Setting_BronzeName}};
			times.InsertLast(b);
		}

		dictionary pb = {{"Time",besttime},{"Color","\\$777"},{"Name","\\$0ff" + Setting_PBName}};

		// other medals


		if (fpTime != 0 && Setting_ShowWR == true) {
			dictionary fp = {{"Time",fpTime},{"Color","\\$00f"},{"Name",Setting_WRName}};
			times.InsertLast(fp);

		}

		if (wm_time != 0 && Setting_ShowWarrior == true) {
			dictionary wm = {{"Time",wm_time},{"Color","\\$09f"},{"Name",Setting_WarriorName}};
			times.InsertLast(wm);
		}

		if (cm_time != 0 && Setting_ShowChamp == true) {
			dictionary cm = {{"Time",cm_time},{"Color","\\$f00"},{"Name",Setting_ChampName}};
			times.InsertLast(cm);
		}

		if (wm_time > 0 && Setting_ShowMaster == true) {
			dictionary mm = {{"Time",wm_time-((track.TMObjective_AuthorTime-wm_time)/1.25)},{"Color","\\$70b"},{"Name",Setting_MasterName}};
			times.InsertLast(mm);
		}

		if (Setting_ShowStarter == true) {
			dictionary sm = {{"Time",track.TMObjective_BronzeTime+((track.TMObjective_BronzeTime-track.TMObjective_SilverTime))},{"Color","\\$555"},{"Name",Setting_StarterName}};
			times.InsertLast(sm);
		}

		// custom medals

		if (Setting_ShowCustomMade == true) {
			for(uint i = 1; i < currentCustomSettings.Length; i++) {
				float time = calcText(splitText(currentCustomSettings[i][0]))*1000;
				string format = Text::FormatGameColor(vec3(Text::ParseFloat(currentCustomSettings[i][2]), Text::ParseFloat(currentCustomSettings[i][3]), Text::ParseFloat(currentCustomSettings[i][4])));
				dictionary tim = {{"Time",time},{"Color","\\" + format},{"Name",currentCustomSettings[i][1]}};
				times.InsertLast(tim);
			}
		}

		times.Sort(function(a,b) { return float(a["Time"]) < float(b["Time"]); });

		// formatting stuff

		int medal = -1;
		for(int i = 0; i < int(times.Length); i++) {
			if (int(times[i]["Time"]) < besttime && string(times[i]["Name"]) != "\\$0ffPB") {
				medal = i;
			}
		}

		// tiers stuff

		if (medal != -1 && medal+1 < int(times.Length)) {
			int mtime = int(times[medal]["Time"]);
			int mtimep = int(times[medal+1]["Time"]);
			string mname = string(times[medal+1]["Name"]);
			string mcol = string(times[medal+1]["Color"]);

			if (Setting_ShowTiers == true) {
				times[medal+1]["Same"] = "0";
			times[medal+1]["Name"] = mname + " I";

			int diff = mtime-mtimep;

			if ((mtime-diff*0.25)-mtime > 10000) {
				dictionary mt0 = {{"Time",mtime-diff*0.1},{"Color",mcol},{"Name",mname + " V"},{"Same","0.5"}};
				times.InsertLast(mt0);
			}

			dictionary mt1 = {{"Time",mtime-diff*0.25},{"Color",mcol},{"Name",mname + " IV"},{"Same","1"}};
			dictionary mt2 = {{"Time",mtime-diff*0.5},{"Color",mcol},{"Name",mname + " III"},{"Same","2"}};
			dictionary mt3 = {{"Time",mtime-diff*0.75},{"Color",mcol},{"Name",mname + " II"},{"Same","3"}};
			times.InsertLast(mt1);
			times.InsertLast(mt2);
			times.InsertLast(mt3);
			}
		}

		if (Setting_ShowPB == true) {
			if (Setting_ShowTiers == true) {
				pb["Same"] = "-1";
			}
			times.InsertLast(pb);
		}

		times.Sort(function(a,b) { return float(a["Time"]) < float(b["Time"]); });

		// set pb color to the medal it belongs to (could make it also work for non visible ones, we'll see)

		for(uint i = 0; i < times.Length; i++) {
			if (string(times[i]["Name"]) == "\\$0ffPB") {
			if (i+1 < times.Length) {
		times[i]["Color"] = string(times[i+1]["Color"]);
		if (Setting_ShowPBMedal == true) {
				times[i]["Add"] = string(times[i+1]["Name"]);
			}
		}
		}
		}

		// calc columns

		int cols = 1;
		if (Setting_ShowMedal == true) {
			cols += 1;
		}
		if (Setting_ShowTime == true) {
			cols += 1;
		}
		if (Setting_ShowName == true) {
			cols += 1;
		}

		if (Setting_ShowDelta == true) {
			cols += 1;
		}


		// nvg render
		if (Setting_NVG == true) {
			auto font = nvg::LoadFont("Montserrat-SemiBoldItalic.ttf");
			nvg::FontFace(font);
			nvg::FontSize(14);


			int am = 0;

			float namemax = 0;
			float timemax = 0;
			float deltamax = 0;

			array<string> delta = {};

			for(uint i = 0; i < times.Length; i++) {
				if (Setting_ShowNonCompleteTimes == false && int(times[i]["Time"]) <= 0) {
					delta.InsertLast("");
					continue;
				}
				am += 1;

				auto time = (int(times[i]["Time"]) > 0 ? Time::Format(int(times[i]["Time"])) : "-:--.---");
				if (Setting_ShowTime == true) {
					auto getBound = nvg::TextBounds(time);
					if (getBound.x+8 > timemax) {
						timemax = getBound.x+8;
					}
				}

				if (Setting_ShowName == true) {
					auto getBound2 = nvg::TextBounds(Text::StripOpenplanetFormatCodes(string(times[i]["Name"])));
					if (getBound2.x+8 > namemax) {
						namemax = getBound2.x+8;
					}
				}

				int tde = (int(besttime)-int(times[i]["Time"]));
				if (tde != 0 && int(times[i]["Time"]) > 0 && int(besttime) > 0) {
					if (tde > 0) {
						delta.InsertLast("+" + (int(times[i]["Time"]) > 0 ? Time::Format(tde) : "-:--.---"));
					} else {
						delta.InsertLast("" + (int(times[i]["Time"]) > 0 ? Time::Format(tde) : "-:--.---"));
					}
				} else {
					if (int(times[i]["Time"]) > 0 && int(besttime) > 0) {
						delta.InsertLast("");
					} else {
						delta.InsertLast(" ");
					}
				}
				if (Setting_ShowDelta == true) {
					auto getBound3 = nvg::TextBounds(Text::StripFormatCodes(delta[i]));
					if (getBound3.x+8 > deltamax) {
						deltamax = getBound3.x+8;
					}
				}
			}

			if (Setting_TrackNameVis == true) {
				am += 2;
			}

			if (loading) {
				am += 1;
			}

			int t = am*16;
			am = -1;

			float ypos = Setting_Y;
			ypos += 22;

			float xpos = Setting_X;
			xpos += 8;

			auto max = nvg::TextBounds(Icons::Refresh + " Loading Times...").x;

			if (Setting_TrackNameVis == true) {
				auto titleS = nvg::TextBounds(Text::StripFormatCodes(track.MapName));
				auto nameS = nvg::TextBounds("By " + Text::StripFormatCodes(track.MapInfo.AuthorNickName));

				max = Math::Max(max, Math::Max(titleS.x, nameS.x));
			}


			nvg::BeginPath();
			nvg::Rect(xpos-8, ypos-20, Math::Max(namemax+timemax+deltamax+16+20, max+20+16), t+16);
			nvg::FillColor(vec4(0,0,0,0.85));
			nvg::Fill();
			nvg::ClosePath();

			if (Setting_TrackNameVis == true) {
				am += 1;
				nvg::FillColor(vec4(1,1,1,1));
				nvg::Text(xpos, ypos+(am*16), Text::StripFormatCodes(track.MapName));

				am += 1;
				nvg::FillColor(vec4(0.5,0.5,0.5,1));
				nvg::Text(xpos, ypos+(am*16), "By " + Text::StripFormatCodes(track.MapInfo.AuthorNickName));
			}

			nvg::FillColor(vec4(1,1,1,1));
			for(uint i = 0; i < times.Length; i++) {
				if (Setting_ShowNonCompleteTimes == false && int(times[i]["Time"]) <= 0) {
					continue;
				}
				am += 1;
				auto time = (int(times[i]["Time"]) > 0 ? Time::Format(int(times[i]["Time"])) : "-:--.---");
				nvg::FillColor(formatToVec4(string(times[i]["Color"])));
				if (Setting_ShowMedal == true) {
					nvg::Text(xpos, ypos+(am*16), Icons::Circle);
				}

				nvg::FillColor(vec4(1,1,1,1));

				if (delta[i] == "") {
					nvg::FillColor(vec4(0,1,1,1));
				}
				if (Setting_ShowTime == true) {
					nvg::Text(xpos+20+namemax+8, ypos+(am*16), time);
				}

				if (Setting_ShowName == true) {
					nvg::Text(xpos+20, ypos+(am*16), Text::StripOpenplanetFormatCodes(string(times[i]["Name"])));
				}
				nvg::FillColor(vec4(1,1,1,1));


				if (Setting_ShowDelta == true) {
					if (delta[i].Contains("+")) {
						nvg::FillColor(vec4(1,0.5,0.5,1));
					} else {
						nvg::FillColor(vec4(0.5,0.5,1,1));
					}
					nvg::Text(xpos+20+namemax+timemax+8, ypos+(am*16), delta[i]);
				}
				nvg::FillColor(vec4(1,1,1,1));
			}

			if (loading) {
				am += 1;
				nvg::FillColor(vec4(1,1,1,1));
				nvg::Text(xpos, ypos+(am*16), Icons::Refresh + " Loading Times...");
			}

			if (type == true) {
				UI::End();
			}
			return;
		}



		// non-nvg render

		if (Setting_TrackNameVis == true) {
			UI::Text(Text::StripFormatCodes(track.MapName));
			UI::Text("\\$888By " + Text::StripFormatCodes(track.MapInfo.AuthorNickName));
		}

		if (UI::BeginTable("table", cols, UI::TableFlags::SizingFixedFit)) {
			for(uint i = 0; i < times.Length; i++) {

				auto icon = string(times[i]["Color"]) + Icons::Circle;
				auto time = int(times[i]["Time"]);

				if (Setting_ShowNonCompleteTimes == false && time <= 0) {
					continue;
				} else {
					UI::TableNextRow();
				}

				if (Setting_ShowMedal == true) {
					UI::TableNextColumn();
					UI::Text(icon);
				}

				if (Setting_ShowName == true) {
					UI::TableNextColumn();
					if (string(times[i]["Add"]) != "") {
						UI::Text(string(times[i]["Name"]) + "(" + string(times[i]["Add"]) + ")");
					} else {
						UI::Text(string(times[i]["Name"]));
					}

				}

				if (Setting_ShowTime == true) {
					UI::TableNextColumn();

					if (string(times[i]["Name"]) == "\\$0ffPB") {
						UI::Text("\\$0ff" + (time > 0 ? Time::Format(time) : "-:--.---"));
					} else {
						UI::Text("" + (time > 0 ? Time::Format(time) : "-:--.---"));
					}
				}

				if (Setting_ShowDelta == true && time > 0 && int(besttime) > 0) {
					UI::TableNextColumn();
					int tde = (int(besttime)-int(time));
					if (tde != 0) {
						if (tde > 0) {
						UI::Text("\\$f77+" + (time > 0 ? Time::Format(tde) : "-:--.---"));
					} else {
						UI::Text("\\$77f" + (time > 0 ? Time::Format(tde) : "-:--.---"));
					}
					}
				}

				if (string(times[i]["Same"]) != "" && Setting_SMB == false) {
					UI::TableSetBgColor(UI::TableBgTarget::RowBg0, vec4(0.2,0.2,0.2,1), -1);
				}

			}	
		}

		UI::EndTable();

		if (loading) {
			UI::Text(Icons::Refresh + " Loading Times...");
		}

		UI::End();



	}

}

void RenderMenu() {
if (UI::MenuItem("\\$0f0" + Icons::Circle + "\\$z All The Medals", "", Setting_Show)) {
Setting_Show = !Setting_Show;
}
}

[SettingsTab name="Custom Medal Creator"]
	void CMCCreator() {
		if (! OpenplanetHasPaidPermissions()) {
			UI::Text("You do not have the required permissions to use this plugin: Club or Standard access.");
			return;
		}
		auto ar = Setting_CustomMedals.Split("|");
		array<array<string>> nr = {};

		for(uint i = 0; i < ar.Length; i++) {
			auto arr = ar[i].Split(":");
			if (arr.Length > 0) {
				nr.InsertLast(arr);
			}
		}


		UI::Text("Create custom medals.");

		UI::BeginTable("table2", 4, UI::TableFlags::SizingFixedFit);

		if (nr.Length > 0) {
			for(uint i = 1; i < nr.Length; i++) {
				auto index = i;
			while (nr[i].Length < 2) {
				nr[i].InsertLast("");
			}
			while (nr[i].Length < 5) {
				nr[i].InsertLast("0");
			}
			UI::TableNextRow();

			string calc = string(nr[i][0]);
			float colorX = Text::ParseFloat(nr[i][2]);
			float colorY = Text::ParseFloat(nr[i][3]);
			float colorZ = Text::ParseFloat(nr[i][4]);
			string name = string(nr[i][1]);

			auto nu = "" + i;
			while (nu.Length < 3) {
				nu = "0"+nu;
			}

			UI::TableNextColumn();
			calc = UI::InputText("\\$" + nu + "\\$fffCalculation", calc);

			UI::TableNextColumn();
			vec3 col = vec3(UI::InputColor3("\\$" + nu + "\\$fffMedal Disp. Color", vec3(colorX, colorY, colorZ)));

			nr[i][2] = ""+col.x;
			nr[i][3] = ""+col.y;
			nr[i][4] = ""+col.z;

			UI::TableNextColumn();
			name = UI::InputText("\\$" + nu + "\\$fffMedal Name", name);

			nr[i][0] = calc;
			nr[i][1] = name;

			UI::TableNextColumn();
			if (UI::ButtonColored("\\$" + nu + "\\$fffDelete", 0, 1, 0.5)) {
				nr.RemoveAt(index);
			}

		}
		}
		UI::EndTable();
		
		string inte = "";
		for(uint i = 0; i < nr.Length; i++) {
			if (i > 0) {
				inte = inte + "|";
			}
			for(uint j = 0; j < nr[i].Length; j++) {
				string value = nr[i][j];
				value = value.Replace("|", "");
				value = value.Replace(":", "");
				if (j != 0) {
					inte = inte + ":";
				}
				inte = inte + value;
			}
		}

		currentCustomSettings = nr;

		if (UI::ButtonColored("Create", 0.3, 1, 0.5)) {
			inte = inte + "|";
		}
		Setting_CustomMedals = inte;

		UI::Text("");
		UI::Text("We support addition (+), subtraction (-), multiplication (*), divison (/), and exponents (^) in our calculation field.");
		UI::Text("You may experience issues with brackets if used.");
		UI::Text("");
		UI::Text("Additionally, you can get times using the $ symbol.");
		UI::Text("$BT for Bronze, $ST for Silver, $GT for Gold, $AT for Author, $WT for Warrior (plugin required), $WR for World Record, $CM for Master, and $CS for Starter.");
		UI::Text("");
		UI::Text("Put $#POS (replace POS with the position you want) to load a Top 10,000 time from the LB. Note this will take up to 4 seconds to load per placement.");
		UI::Text("Press the reload LB button for leaderboard position times to take effect.");

		if (UI::ButtonColored("Reload LB", 0.6, 1, 0.5)) {
			lastMap = "";
		}

		allLBPos = {};
		for(uint i = 1; i < currentCustomSettings.Length; i++) {
			array<string> split = splitText(currentCustomSettings[i][0]);
			for(uint j = 0; j < split.Length; j++) {
				if (split[j].Contains("$#") && allLBPos.Find(split[j]) < 0) {
					allLBPos.InsertLast(split[j]);
				}
			}
		}
		string textprefix = "";
		if (allLBPos.Length+1 > 10) {
			textprefix = "\\$f00Excess requests will be denied. ";
		}
		UI::Text(textprefix + "Current api cost: " + (allLBPos.Length+1) + " (approx. " + ((allLBPos.Length+1)*3.5) + " seconds). We encourage you to limit it to 5. Hard cap is 10.");
	}
