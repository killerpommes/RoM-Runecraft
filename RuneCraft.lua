--RuneCraft 0.50 first BETA
--Author: Ganjaaa, odie2



local Sol = LibStub("Sol");

local DebugMode = false;
local DBLoaded = false;
local AktTier = 0;

local MaxScroll = 6;

-- OnLoad
function RCMain_OnLoad(this)
	this:RegisterEvent("VARIABLES_LOADED");
	RC_DBLoad();
	--Tier Name Set
	for i = 1,9,1 do
		getglobal("RCMain_Tier"..i.."_Titel"):SetText(RCText.Menu.Tier1..(i-1)..RCText.Menu.Tier2);
	end
	--Tier Layer
	getglobal("RCMain_Tier"):SetText(RCText.Menu.Tier1.."0"..RCText.Menu.Tier2);
	--Needed Layer
	getglobal("RCMain_Needed"):SetText(RCText.Menu.Needed);
	if DebugMode then RCMain:Show() end;
end
--OnEvent
function RCMain_OnEvent(this,event)
	if event == "VARIABLES_LOADED" then
		RC_SetScroll(0,1);
		RC_SetPrev(11);
		if AddonManager then
			local addon = {
				name = "RuneCraft",
				version = "v0.50 first BETA",
				author = "Ganjaaa, odie2",
				description = RCText.PrintOut.Description,
				icon = "Interface/AddOns/RuneCraft/Gfx/RuneCraftIcon.tga",
				category = "Other",
				slashCommands = "/rc",
                configFrame = RCMain
			}		
			if AddonManager.RegisterAddonTable then
        AddonManager.RegisterAddonTable(addon)
			else
        AddonManager.RegisterAddon(addon.name, addon.description, addon.icon, addon.category, 
            addon.configFrame, addon.slashCommand, addon.miniButton, addon.version, addon.author)
			end
		end
		
		RC_Print(RCText.PrintOut.Say1);
		RC_Print(RCText.PrintOut.Say2);
		RC_TreeClear();
	end
end
--OnClick
function RCList_OnClick(this)
	if RC_InArray(Runes,getglobal(this:GetName().."_Name"):GetText()) then
		RC_SetPrev(RC_InArray(Runes,getglobal(this:GetName().."_Name"):GetText()));
	end
end
--Tooltip
function RCGrade_Tooltip(this)
	if RC_InArray(Runes,getglobal("RCPrev_Icon_Name"):GetText()) then
		local id = RC_InArray(Runes,getglobal("RCPrev_Icon_Name"):GetText());
		if Runes[id].ID ~= "" then
			local itemid = string.format("%X",string.format("%d","0x"..Runes[id].ID)+this:GetID()-1)
			local link = RC_StringToLink(Runes[id].Name.." "..RC_Num2Rom(this:GetID()),itemid);
			RCTooltip:SetHyperLink(link);
			RCTooltip:Show();
		end
	end
end
function RCTooltip_Set(this)
	if RC_InArray(Runes,getglobal(this:GetName().."_Name"):GetText()) then
		local id = RC_InArray(Runes,getglobal(this:GetName().."_Name"):GetText())
		if Runes[id].ID ~= "" then
			RCTooltip:SetHyperLink(RC_StringToLink(Runes[id].Name, Runes[id].ID));
			RCTooltip:Show();
		end
	end
end
--Interne Funktionen
---- Erstellt BaumArray
function RC_Tree(start,id,ids)
	local baum = {};
	if start ~= 0 then
		if Runes[id].Type ~= 0 then
			baum[1] = Runes[id].Name;
			baum[2] = RC_Tree(0,Runes[id].Comb[1],Runes[id].Comb[2],Runes[id].Comb[3]);
		else
			baum[1] = Runes[id].Name;
			baum[2] = 0;
		end
	else
		if Runes[id].Type ~= 0 then
			baum[1] = Runes[id].Name;
			baum[2] = {};
			baum[2] = RC_Tree(0,Runes[id].Comb[1],Runes[id].Comb[2],Runes[id].Comb[3]);
			baum[3] = Runes[ids].Name;
			baum[4] = {};
			baum[4] = RC_Tree(0,Runes[ids].Comb[1],Runes[ids].Comb[2],Runes[ids].Comb[3]);
		else
			baum[1] = Runes[id].Name;
			baum[2] = 0;
			baum[3] = Runes[ids].Name;
			baum[4] = 0;
		end
	end
	return baum;
end

function RC_TreeList(this)
	local id = RC_InArray(Runes,getglobal(this:GetName().."_Name"):GetText());
	local tree = RC_Tree(1,id,id);
	RC_TreeClear();
	RC_TreeFollow(tree,1);
end

function RC_TreeFollow(tbl,space)
    for k, v in pairs(tbl) do
        if type(v) == "table" then
        else
			if v ~= 0 then
				RC_AddLine(tostring(v));
				--Sol.io.Print(enter..tostring(v));
			end
        end
    end
	--RC_AddLine("--------------------");
	for k, v in pairs(tbl) do
        if type(v) == "table" then
            RC_TreeFollow(v,space+1);
        else
        end
    end
end

function RC_AddLine(str)
	if str ~= "--------------------" then
		local id = RC_InArray(Runes,str);
		for i=1,19,1 do
			if getglobal("RCTree_Line"..i):GetText() == "" then
				if Runes[id].Type == 0 then
					getglobal("RCTree_Line"..i):SetText(Runes[id].Name); 
				else
					getglobal("RCTree_Line"..i):SetText(Runes[id].Name.."="..Runes[Runes[id].Comb[1]].Name.."+"..Runes[Runes[id].Comb[2]].Name.."+"..Runes[Runes[id].Comb[3]].Name); 
				end
				break;
			end		
		end
	else
		for i=1,19,1 do
			if getglobal("RCTree_Line"..i):GetText() == "" then
				getglobal("RCTree_Line"..i):SetText(str); 
				break;
			end		
		end
	end
end

function RC_TreeClear()
	for i=1,19,1 do
		if i==2 or i==5 or i== 10 or i==19 then
			getglobal("RCTree_Line"..i):SetText("--------------------");
		else
			getglobal("RCTree_Line"..i):SetText("");
		end;
	end
end

---- Setzt Preview
function RC_SetPrev(id)
	RC_SetIconTemplate("RCPrev_Icon",Runes[id].Name,Runes[id].Icon);
	for i=1,10,1 do
		local gtext = RCText.Menu.Grade..i.." : ";
		if Runes[id].ID ~= "" then
			gtext = gtext..RC_StringToLink(Runes[id].Name.." "..RC_Num2Rom(i),string.format("%X",string.format("%d","0x"..Runes[id].ID)+i-1));
		end
		getglobal("RCPrev_Grade"..i.."_Name"):SetText(gtext);
	end
	if Runes[id].Comb[1] ~= 0 then
		RC_SetIconTemplate("RCPrev_Need1",Runes[Runes[id].Comb[1]].Name,Runes[Runes[id].Comb[1]].Icon);
		RC_SetIconTemplate("RCPrev_Need2",Runes[Runes[id].Comb[2]].Name,Runes[Runes[id].Comb[2]].Icon);
		RC_SetIconTemplate("RCPrev_Need3",Runes[Runes[id].Comb[3]].Name,Runes[Runes[id].Comb[3]].Icon);
	else
		RC_SetIconTemplate("RCPrev_Need1",RCText.Runes.Empty,"");
		RC_SetIconTemplate("RCPrev_Need2",RCText.Runes.Empty,"");
		RC_SetIconTemplate("RCPrev_Need3",RCText.Runes.Empty,"");
	end
end
---- Holt oder setzt Tier
function RC_AktTier(tier)
	if tier == nil then
		return AktTier;
	else
		getglobal("RCMain_Tier"):SetText(RCText.Menu.Tier1..tier..RCText.Menu.Tier2);
		AktTier = tier;
		return AktTier;
	end;
end
----Bilded Itemlink aus Name und ID
function RC_StringToLink(name, id)
	local s = "";
	s = "|Hitem:"..id..":1:0:0:0:0:0:0:0:0:0:0|h|cffffffff["..name.."]|h";
	return s;
end
----Sucht in Array
function RC_InArray(array,value)
	local s = false;
	for ix, var in pairs(array) do
		if var.Name == value then
			s = ix;
			break;
		end
	end
	return s;
end
---- Setzt Scrollbar
function RC_SetScroll(tier,start)
	local Items={};
	local count=0
	for index,value in pairs(Runes) do
		if value.Type == tier then
			count=count+1;
			Items[count] = value;
		end
	end
	if (count-MaxScroll) > 0 then
		RCMain_Slider:SetMinMaxValues(1,count-MaxScroll+1,1);	
	else
		RCMain_Slider:SetMinMaxValues(1,1,1);	
	end
	if count >= 6 then
		for i = 1,MaxScroll,1 do
			RC_SetIconTemplate("RCList_Item"..i,Items[start+i-1].Name,Items[start+i-1].Icon);
		end
	else
		for i=1,count,1 do
			RC_SetIconTemplate("RCList_Item"..i,Items[start+i-1].Name,Items[start+i-1].Icon);
		end
		for i=count+1,6,1 do
			RC_SetIconTemplate("RCList_Item"..i,"","");
		end
	end
end
---- Belegt Icon Text Templates
function RC_SetIconTemplate(name,text,img)
	getglobal(name.."_Name"):SetText(text);
	getglobal(name.."_Icon"):GetNormalTexture():SetFile("interface\\icons\\"..img);	
	getglobal(name.."_Icon"):GetPushedTexture():SetFile("interface\\icons\\"..img);	
end
---- Benötigte DBs hinzuladen
function RC_DBLoad()
	if not DBLoaded then
		local Loc = GetLocation()
		if Loc == "DE" then
			RC_LoadFile("Interface\\AddOns\\RuneCraft\\DB\\DE_Runes.lua");
			RC_LoadFile("Interface\\AddOns\\RuneCraft\\Lang\\DE_Lang.lua");
			DBLoaded = true;
		elseif Loc == "PL" then
			RC_LoadFile("Interface\\AddOns\\RuneCraft\\DB\\PL_Runes.lua");
			RC_LoadFile("Interface\\AddOns\\RuneCraft\\Lang\\PL_Lang.lua");
			DBLoaded = true;
		else
			RC_LoadFile("Interface\\AddOns\\RuneCraft\\DB\\ENEU_Runes.lua");
			RC_LoadFile("Interface\\AddOns\\RuneCraft\\Lang\\ENEU_Lang.lua");
			DBLoaded = true;
		end
	end
end
---- Dezimal zu Römisch
function RC_Num2Rom(num)
	local tmp = {"I","II","III","IV","V","VI","VII","VIII","IX","X"};
	if num <= 10 and num > 0 then
		return tmp[num];
	end
	return "XXX";
end
---- Läd eine Datei Hinzu
function RC_LoadFile(str)
	local func, err = loadfile(str);
	if (err) then
		return false, err;
	end
	dofile(str);
	return true;
end
---- Öffnet/Schließt Menu
function RCMain_Show()
	if (RCMain:IsVisible()) then
		RCMain:Hide();
		RCTree:Hide();
	else
		RCMain:Show();
		RCTree:Hide();
	end
end
---- PrintOut
function RC_Print(str)
	Sol.io.Print("[RuneCraft]: |cf00ff00 "..str);
end

---- Debug Say
function DebugMessage(str)
	if DebugMode then
		Sol.io.Print("[RCDebug]: |cffff0000"..str);
	end
end

SLASH_RUNECRAFT1 = "/rc"
SlashCmdList["RUNECRAFT"] = RCMain_Show



--[[
Überprüfung der ein inventar gegenstände auf runen
abspeicher der einzelenenn vorhanden daten aktualliserien bei aitem algen oder update

überorpfung der namen auf ranke -> nutzung tooltops

nehemn tier und kontrollieren nach ranke -> mehrdimen array 

einbzeige alle baubaren runen für jeden rank einzeln]]--