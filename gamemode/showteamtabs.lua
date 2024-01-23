CreateClientConVar("rp_playermodel", "", true, true);
local LDRP = {};
function LDRP.InitClient()
  timer.Simple(.3, function()
    LocalPlayer().Inventory = {};
    LocalPlayer().Skills = {};
    LocalPlayer().MaxWeight = 0;
    LocalPlayer().Bank = {};
    LocalPlayer().MaxBWeight = 0;
    LocalPlayer().InterestRate = {};
    LocalPlayer().RobbingBank = false;
    print("Client has been initialized.");
    RunConsoleCommand("_initme");
  end);
end

hook.Add("InitPostEntity", "Loads inventory and character", LDRP.InitClient);
-- function BankTab()
-- 	local MainBankBackground = vgui.Create("DPanel")
--   if !LocalPlayer().Bank || !LocalPlayer().InterestRate["cur"] || !LocalPlayer().InterestRate["lastcollected"] then return end
-- 	local w = 740
-- 	local h = 500
-- 	function MainBankBackground:Paint()
-- 		draw.RoundedBox(6, 0, 10, w, h, Color(0, 0, 0, 200))
-- 		local BankWeight = 0
-- 		for k, v in pairs(LocalPlayer().Bank) do
-- 			if k == "curcash" then continue end
-- 			if v && v >= 1 then
-- 				BankWeight = BankWeight+(LDRP_SH.AllItems[k].weight*v)
-- 			end
-- 		end
-- 		draw.SimpleTextOutlined("Bank Weight: " .. BankWeight .. " out of " .. LocalPlayer().MaxBWeight, "Trebuchet22", w*.5, h*.97, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(213, 100, 100, 255))
-- 	end
-- 	-- Window title
-- 	local BankLabel = vgui.Create("DLabel", MainBankBackground)
-- 	BankLabel:SetText("Bank")
-- 	BankLabel:SetFont("HUDNumber")
-- 	BankLabel:SetColor(Color(213, 100, 100, 255))
-- 	BankLabel:SetPos(w*.45, h*.03)
-- 	BankLabel:SizeToContents()
-- 	-- Bank Items List
-- 	local BankItemsListWide = 700
-- 	local BankItemsScroll = vgui.Create("DScrollPanel", MainBankBackground)
-- 	BankItemsScroll:SetPos((w*.5)-(BankItemsListWide/2), h*0.12)
-- 	BankItemsScroll:SetSize(700, 100)
-- 	local BankItemsList = vgui.Create("DPanelList", BankItemsScroll)
-- 	-- BankItemsList:SetPos((w*.5)-(BankItemsListWide/2), h*0.12)
-- 	BankItemsList:SetPos(0, 0)
-- 	BankItemsList:SetWidth(BankItemsListWide)
-- 	BankItemsList:SetHeight(200)
-- 	BankItemsList:SetPadding(4)
-- 	BankItemsList:SetSpacing(4)
-- 	BankItemsList:EnableVerticalScrollbar(true)
-- 	BankItemsList:EnableHorizontal(true)
-- 	local CurIcons = {}
-- 	function BankItemsList:Think()
-- 		for k,v in pairs(LocalPlayer().Bank) do
-- 			if k == "curcash" then continue end
-- 			local Check = CurIcons[k]
-- 			if Check then
-- 				if Check.am != v or v <= 0 then
-- 					local ItemTbl = LDRP_SH.AllItems[k]
-- 					if !ItemTbl then continue end
-- 					if v <= 0 then
-- 						BankItemsList:RemoveItem(Check.vgui)
-- 						CurIcons[k] = nil
-- 					else
-- 						local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
-- 						Check.vgui:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
-- 						CurIcons[k].am = v
-- 					end
-- 				end
-- 			elseif v > 0 then
-- 				local ItemTbl = LDRP_SH.AllItems[k]
-- 				if !ItemTbl then continue end
-- 				local ItemIcon = CreateIcon(BankItemsList,ItemTbl.mdl,79,79,function() LDRP.OpenItemOptions(k,"takeout","Take Out") end)
-- 				CurIcons[k] = {["vgui"] = ItemIcon,["am"] = v}
-- 				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
-- 				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
-- 				BankItemsList:AddItem(ItemIcon)
-- 			end
-- 			timer.Simple(.001,function()
-- 				if !BankItemsList:IsValid() then return end
-- 				BankItemsList:Rebuild()
-- 				BankItemsList:PerformLayout()
-- 			end)
-- 		end
-- 	end
-- 	-- Inventory Items
-- 	local InvItemsListWide = 700
-- 	local InvItemsScroll = vgui.Create("DScrollPanel", MainBankBackground)
-- 	InvItemsScroll:SetPos((w*.5)-(BankItemsListWide/2), h*0.40)
-- 	InvItemsScroll:SetSize(700, 100)
-- 	local InvLabel = vgui.Create("DLabel", MainBankBackground)
-- 	InvLabel:SetText("Inventory")
-- 	InvLabel:SetFont("HUDNumber")
-- 	InvLabel:SetColor( Color(213, 100, 100, 255) )
-- 	InvLabel:SetPos(w*.40, h*.32)
-- 	InvLabel:SizeToContents()
-- 	local InvItemsList = vgui.Create("DPanelList", InvItemsScroll)
-- 	InvItemsList:SetPos(0, 0)
-- 	InvItemsList:SetWidth(BankItemsListWide)
-- 	InvItemsList:SetHeight(200)
-- 	InvItemsList:SetPadding(4)
-- 	InvItemsList:SetSpacing(4)
-- 	InvItemsList:EnableVerticalScrollbar(true)
-- 	InvItemsList:EnableHorizontal(true)
-- 	local CurIcons2 = {}
-- 	function InvItemsList:Think()
-- 		for k,v in pairs(LocalPlayer().Inventory) do
-- 			local Check = CurIcons2[k]
-- 			if Check then
-- 				if Check.am != v or v <= 0 then
-- 					local ItemTbl = LDRP_SH.AllItems[k]
-- 					if !ItemTbl then continue end
-- 					if v <= 0 then
-- 						InvItemsList:RemoveItem(Check.vgui)
-- 						CurIcons2[k] = nil
-- 					else
-- 						local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
-- 						Check.vgui:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
-- 						CurIcons2[k].am = v
-- 					end
-- 				end
-- 			elseif v > 0 then
-- 				local ItemTbl = LDRP_SH.AllItems[k]
-- 				if !ItemTbl then continue end
-- 				local ItemIcon = CreateIcon(InvItemsList,ItemTbl.mdl,79,79,function() LDRP.OpenItemOptions(k,"bank","Put in bank") end)
-- 				CurIcons2[k] = {["vgui"] = ItemIcon,["am"] = v}
-- 				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
-- 				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
-- 				InvItemsList:AddItem(ItemIcon)
-- 			end
-- 			timer.Simple(.001,function()
-- 				if !InvItemsList:IsValid() then return end
-- 				InvItemsList:Rebuild()
-- 				InvItemsList:PerformLayout()
-- 			end)
-- 		end
-- 	end
-- 	-- Bank Balance
-- 	local ButtonBackground = vgui.Create("DPanel", MainBankBackground)
-- 	ButtonBackground:SetPos(0, h*0.60)
-- 	ButtonBackground:SetWidth(600)
-- 	ButtonBackground:SetHeight(86)
-- 	function ButtonBackground:Paint()
-- 		draw.RoundedBox(6, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30, 40))
-- 	end
-- 	local BalanceLabel = vgui.Create("DLabel", MainBankBackground)
-- 	BalanceLabel:SetPos(20, h*.62)
-- 	BalanceLabel:SetFont("HUDNumber")
-- 	BalanceLabel:SetText("                                         ")
-- 	function BalanceLabel:Paint()
-- 		draw.SimpleTextOutlined("Balance $" .. REBELLION.numberFormat(LocalPlayer().Bank["curcash"] or ""), "HUDNumber", 0, ScrH()*.02, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color( 213, 100, 100, 255 ))
-- 	end
-- 	BalanceLabel:SizeToContents()
-- 	-- Deposit
-- 	local DepositInput = vgui.Create("DNumberWang", MainBankBackground)
-- 	DepositInput:SetPos(20, (h*0.62)+40)
-- 	DepositInput:SetSize(314, 35)
-- 	DepositInput:SetEnterAllowed(false)
-- 	DepositInput:SetText("1000")
-- 	local HasClicked
-- 	DepositInput.OnMousePressed = function()
-- 		if !HasClicked then DepositInput:SetText("") HasClicked = true end
-- 	end
-- 	function DepositInput:Paint()
-- 		draw.RoundedBox(6, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 		self:DrawTextEntryText(Color(255, 255, 255), Color(0, 255, 0), Color(255, 255, 255))
-- 	end
-- 	local DepositButton = vgui.Create("DButton", MainBankBackground)
-- 	DepositButton:SetPos(340, (h*.62)+40)
-- 	DepositButton:SetSize(100, 35)
-- 	DepositButton:SetText("")
-- 	function DepositButton:Paint()
-- 		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 		draw.SimpleText("Deposit", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 	end
-- 	function DepositButton:Think()
-- 		if (!self:IsDown()) then
-- 			function self:Paint()
-- 				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 				draw.SimpleText("Deposit", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 			end
-- 		else
-- 			function self:Paint()
-- 				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255))
-- 				draw.SimpleText("Deposit", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 			end
-- 		end
-- 	end
-- 	DepositButton.DoClick = function()
-- 		local amount = tonumber(DepositInput:GetValue())
-- 		if amount and amount > 0 then
-- 			RunConsoleCommand("_bnk", "money", -amount)
-- 		else
-- 			LocalPlayer():LiquidChat("BANK", Color(0,192,10), "Please enter a valid number!")
-- 		end
-- 	end
-- 	-- Withdraw
-- 	local WithdrawInput = vgui.Create("DNumberWang", MainBankBackground)
-- 	WithdrawInput:SetPos(20, (h*0.70)+40)
-- 	WithdrawInput:SetSize(314, 35)
-- 	WithdrawInput:SetEnterAllowed(false)
-- 	WithdrawInput:SetText("1000")
-- 	local HasClicked2
-- 	WithdrawInput.OnMousePressed = function()
-- 		if !HasClicked2 then WithdrawInput:SetText("") HasClicked2 = true end
-- 	end
-- 	function WithdrawInput:Paint()
-- 		draw.RoundedBox(6, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 		self:DrawTextEntryText(Color(255, 255, 255), Color(0, 255, 0), Color(255, 255, 255))
-- 	end
-- 	local WithdrawButton = vgui.Create("DButton", MainBankBackground)
-- 	WithdrawButton:SetPos(340, (h*.70)+40)
-- 	WithdrawButton:SetSize(100, 35)
-- 	WithdrawButton:SetText("")
-- 	function WithdrawButton:Think()
-- 		if (!self:IsDown()) then
-- 			function self:Paint()
-- 				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 				draw.SimpleText("Withdraw", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 			end
-- 		else
-- 			function self:Paint()
-- 				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255))
-- 				draw.SimpleText("Withdraw", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 			end
-- 		end
-- 	end
-- 	WithdrawButton.DoClick = function()
-- 		local amount = tonumber(WithdrawInput:GetValue())
-- 		if amount and amount > 0 then
-- 			RunConsoleCommand("_bnk", "money", amount)
--       RunConsoleCommand("_bnkupgrade", "balanceChanged", selectedOption)
-- 		else
-- 			LocalPlayer():LiquidChat("BANK", Color(0,192,10), "Please enter a valid number!")
-- 		end
-- 	end
-- 	-- Upgrade account
-- 	local AccountUpgradeOptionValues = {
-- 		["Basic"] = "$50,000+",
-- 		["Bronze"] = "$500,000+",
-- 		["Silver"] = "$1,000,000+",
-- 		["Gold"] = "$5,000,000+",
-- 		["Platinum"] = "$10,000,000+",
-- 		["Diamond"] = "$50,000,000+",
-- 		["Nuclear"] =  "$100,000,000"
-- 	}
-- 	local AccountUpgradeOptions = vgui.Create( "DComboBox", MainBankBackground )
-- 	AccountUpgradeOptions:SetPos(20, (h*.70)+80)
-- 	AccountUpgradeOptions:SetSize(314, 35)
-- 	AccountUpgradeOptions:SetValue("Upgrade Account")
-- 	AccountUpgradeOptions:SetTextColor(Color(255, 255, 255, 255))
-- 	for k,v in pairs(AccountUpgradeOptionValues) do
-- 		AccountUpgradeOptions:AddChoice( k .. " " .. v )
-- 	end
--   AccountUpgradeOptions:SetSortItems(false)
-- 	function AccountUpgradeOptions:Paint()
-- 		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 	end
-- 	local AccountUpgradeButton = vgui.Create( "DButton", MainBankBackground )
-- 	AccountUpgradeButton:SetPos(340, (h*.70)+80)
-- 	AccountUpgradeButton:SetSize(100, 35)
-- 	AccountUpgradeButton:SetText("")
-- 	function AccountUpgradeButton:Paint()
-- 		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
-- 		draw.SimpleText("Upgrade", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 	end
-- 	AccountUpgradeButton.DoClick = function()
-- 		local selectedOption = AccountUpgradeOptions:GetValue()
-- 		RunConsoleCommand("_bnkupgrade", "upgrade", selectedOption)
-- 	end
--   -- Collect Interest
-- 	local InterestRateAmount = vgui.Create("DPanel", MainBankBackground)
-- 	InterestRateAmount:SetPos(450, (h*.70)+80)
-- 	InterestRateAmount:SetSize(100, 35)
-- 	function InterestRateAmount:Paint()
-- 		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color( 213, 100, 100, 255 ))
-- 		draw.SimpleText(LocalPlayer().InterestRate["cur"] * 100 .. "%", "DermaDefault", 100/2, 35/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 	end
--   local InterestRateCollectionButton = vgui.Create("DButton", MainBankBackground)
--   InterestRateCollectionButton:SetPos(560, (h*.70)+80)
--   InterestRateCollectionButton:SetSize(160, 35)
--   InterestRateCollectionButton:SetText("")
--   function InterestRateCollectionButton:Paint()
--     draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
--     if os.time() > LocalPlayer().InterestRate["lastcollected"] + LDRP_SH.InterestCollectionDelay then
--       draw.SimpleText("Collect $" .. REBELLION.numberFormat(math.Round(LocalPlayer().Bank["curcash"] * LocalPlayer().InterestRate["cur"])), "DermaDefault", 160/2, 35/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     else
--     draw.SimpleText("Collect Again Tommrow", "DermaDefault", 160/2, 35/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
--     end
--   end
--   InterestRateCollectionButton.DoClick = function()
--     RunConsoleCommand("_collectInterest")
--   end
-- 	return MainBankBackground
-- end
function LDRP.SendItemInfo(um)
  LocalPlayer().Inventory[tostring(um:ReadString())] = um:ReadFloat();
end

usermessage.Hook("SendItem", LDRP.SendItemInfo);
function LDRP.SendMaxWeight(um)
  LocalPlayer().MaxWeight = um:ReadFloat();
end

usermessage.Hook("SendWeight", LDRP.SendMaxWeight);
function LDRP.ReceiveSkill(um)
  local Skill = um:ReadString();
  LocalPlayer().Skills[Skill] = {};
  LocalPlayer().Skills[Skill].exp = um:ReadFloat();
  LocalPlayer().Skills[Skill].lvl = um:ReadFloat();
end

usermessage.Hook("SendSkill", LDRP.ReceiveSkill);
function LDRP.ReceiveEXP(len)
  local skill = net.ReadString();
  local exp = net.ReadFloat();
  LocalPlayer().Skills[skill].exp = exp;
end

net.Receive("SendEXP", LDRP.ReceiveEXP);
function LDRP.OpenItemOptions(item)
  if LocalPlayer().Inventory[item] then
    local WepNames = LDRP_SH.NicerWepNames;
    local OptionsMenu = vgui.Create("DFrame");
    OptionsMenu:SetSize(200, 140);
    OptionsMenu:SetPos(-200, ScrH() * .5 - 80);
    OptionsMenu:MakePopup();
    OptionsMenu:MoveTo(ScrW() * .5 - 100, ScrH() * .5 - 80, .3);
    local Tbl = LDRP_SH.AllItems[item];
    OptionsMenu.Paint = function()
      draw.RoundedBox(6, 0, 0, 200, 140, Color(50, 50, 50, 180));
      local name = WepNames[Tbl.nicename] or Tbl.nicename;
      draw.SimpleTextOutlined(name .. " - " .. LocalPlayer().Inventory[item] .. " left", "Trebuchet20", 100, 14, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200));
    end;

    OptionsMenu:SetTitle("");
    OptionsMenu.MakeClose = function()
      OptionsMenu:MoveTo(ScrW(), ScrH() * .5 - 80, .3);
      timer.Simple(.3, function() if OptionsMenu:IsValid() then OptionsMenu:Close(); end end);
    end;

    local UseButton = vgui.Create("DButton", OptionsMenu);
    UseButton:SetPos(4, 30);
    UseButton:SetSize(192, 32);
    UseButton:SetText(Tbl.usename or "Use");
    if Tbl.cuse then
      UseButton.DoClick = function()
        RunConsoleCommand("_inven", "use", item);
        OptionsMenu.MakeClose();
      end;
    else
      UseButton:SetDisabled(true);
    end

    local DropButton = vgui.Create("DButton", OptionsMenu);
    DropButton:SetPos(4, 66);
    DropButton:SetSize(192, 32);
    DropButton:SetText("Drop");
    DropButton.DoClick = function()
      RunConsoleCommand("_inven", "drop", item);
      OptionsMenu.MakeClose();
    end;

    local RemoveButton = vgui.Create("DButton", OptionsMenu);
    RemoveButton:SetPos(4, 102);
    RemoveButton:SetSize(192, 32);
    RemoveButton:SetText("Remove");
    RemoveButton.DoClick = function()
      RunConsoleCommand("_inven", "delete", item);
      OptionsMenu.MakeClose();
    end;
  end
end

-- Fonts
surface.CreateFont("DashboardBtnFont", {
  font = "Trebuchet18",
  extended = false,
  size = 19,
  blursize = 0,
  scanlines = 0,
  antialias = 0,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = false,
  additive = true,
  outline = false,
  weight = 600
});

-- Helpers
function formatSeconds(seconds)
  local hours = 0;
  local mins = 0;
  if seconds >= 3600 then
    local hoursInSeconds = math.floor(seconds / 3600);
    hours = hoursInSeconds;
    seconds = seconds - (hoursInSeconds * 3600);
  end

  if seconds >= 60 then
    local mintutesInSeconds = math.floor(seconds / 60);
    mins = mintutesInSeconds;
    seconds = seconds - (mintutesInSeconds * 60);
  end

  local timeString = "%s:%s:%s";
  if hours < 10 then hours = "0" .. tostring(hours); end
  if mins < 10 then mins = "0" .. tostring(mins); end
  if seconds < 10 then seconds = "0" .. tostring(seconds); end
  return string.format(timeString, hours, mins, seconds);
end

function ChangeSubTabRequest(subTabName)
  RunConsoleCommand("_f4contentchange", subTabName);
end

function requestStringMenu(msgText, onsubmit)
  local frame = vgui.Create("DFrame");
  frame:SetSize(300, 120);
  frame:Center();
  frame:SetTitle(msgText);
  frame:SetSizable(false);
  frame:SetDraggable(false);
  frame:ShowCloseButton(false);
  frame:SetBackgroundBlur(true);
  function frame:Paint()
    draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255));
  end

  frame:MakePopup();
  local textEntry = vgui.Create("DTextEntry", frame);
  textEntry:SetPos(5, 40);
  textEntry:SetSize(290, 20);
  local btnContainer = vgui.Create("DPanel", frame);
  btnContainer:SetSize(300, 60);
  btnContainer:Dock(BOTTOM);
  local btnOk = vgui.Create("DButton", btnContainer);
  btnOk:SetSize(60, 20);
  btnOk:SetPos((btnContainer:GetWide() / 2) - 30 - 40, 20);
  btnOk:SetText("Ok");
  btnOk.DoClick = function()
    onsubmit(textEntry:GetValue());
    frame:Close();
  end;

  function btnOk:Paint()
    draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255));
  end

  local btnClose = vgui.Create("DButton", btnContainer);
  btnClose:SetSize(60, 20);
  btnClose:SetPos((btnContainer:GetWide() / 2) - 30 + 40, 20);
  btnClose:SetText("Cancel");
  btnClose.DoClick = function() frame:Close(); end;
  function btnClose:Paint()
    draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255));
  end
end

-- Data
-- Player actions on click functions
function dropMoney()
  requestStringMenu("Drop money", function(t) LocalPlayer():ConCommand("darkrp /dropmoney " .. tostring(t)); end);
end

function sellAllDoors()
  LocalPlayer():ConCommand("say /unownalldoors");
end

function sendTradeRequest()
  local selectPlayerFrame = vgui.Create("DFrame");
  selectPlayerFrame:SetSize(300, 120);
  selectPlayerFrame:Center();
  selectPlayerFrame:SetSizable(false);
  selectPlayerFrame:SetDraggable(false);
  selectPlayerFrame:ShowCloseButton(false);
  selectPlayerFrame:SetBackgroundBlur(true);
  selectPlayerFrame:SetTitle("Select player for trade");
  function selectPlayerFrame:Paint()
    draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255));
  end

  selectPlayerFrame:MakePopup();
  local players = {};
  local playersSelect = vgui.Create("DComboBox", selectPlayerFrame);
  playersSelect:Dock(TOP);
  playersSelect:SetValue("Select Player");
  for i, v in ipairs(player.GetAll()) do
    playersSelect:AddChoice(v:Nick());
    players[i] = v;
  end

  local closeBtn = vgui.Create("DButton", selectPlayerFrame);
  closeBtn:SetText("Close");
  closeBtn:Dock(BOTTOM);
  closeBtn.DoClick = function() selectPlayerFrame:Close(); end;
  function closeBtn:Paint()
    draw.RoundedBox(1, 5, 0, selectPlayerFrame:GetWide() - 5, 45, Color(0, 0, 0, 255));
  end

  local sendBtn = vgui.Create("DButton", selectPlayerFrame);
  sendBtn:SetText("Send Trade");
  sendBtn:SetPos(5, 65);
  sendBtn:SetSize(selectPlayerFrame:GetWide(), 20);
  function sendBtn:Paint()
    draw.RoundedBox(1, 5, 0, selectPlayerFrame:GetWide() - 10, 20, Color(0, 0, 0, 255));
  end

  sendBtn.DoClick = function()
    -- RunConsoleCommand("__trd","start")
    local plyName = playersSelect:GetValue();
    RunConsoleCommand("__trd", "f4_send", plyName);
  end;
end

local TAB_CONFIG = TAB_CONFIG or {};
TAB_CONFIG.playerActions = {
  [1] = {
    ["nicename"] = "Sell all Doors",
    ["onclick"] = sellAllDoors
  },
  [2] = {
    ["nicename"] = LANGUAGE.drop_money,
    ["onclick"] = dropMoney
  },
  [3] = {
    ["nicename"] = "Send a Trade Request",
    ["onclick"] = sendTradeRequest
  },
  [4] = {
    ["nicename"] = "Place a Hit"
  },
  [5] = {
    ["nicename"] = "Send Coin Flip Request"
  }
};

TAB_CONFIG.gameplayFeatures = {
  [1] = {
    ["nicename"] = "Bank Vault",
    ["onclick"] = function() ChangeSubTabRequest("BankVault"); end
  },
  [2] = {
    ["nicename"] = "Upgrade Skills",
    ["onclick"] = function() ChangeSubTabRequest("UpgradeSkills"); end,
  },
  [3] = {
    ["nicename"] = "Achievements",
    ["bg_color"] = Color(255, 165, 0, 255),
    ["onclick"] = function() ChangeSubTabRequest("Achievements"); end
  },
  [4] = {
    ["nicename"] = "Ore Processing",
    ["bg_color"] = Color(224, 17, 95, 255),
    ["onclick"] = function() ChangeSubTabRequest("OreProcessing"); end
  },
  [5] = {
    ["nicename"] = "Character Boosters",
    ["bg_color"] = Color(100, 213, 100, 255),
    ["onclick"] = function() ChangeSubTabRequest("CharacterBoosters"); end
  },
  [6] = {
    ["nicename"] = "View Cases",
    ["bg_color"] = Color(255, 60, 255, 255),
    ["onclick"] = function() ChangeSubTabRequest("ViewCases"); end
  }
};

TAB_CONFIG.otherFeatures = {
  [1] = {
    ["nicename"] = "Bank",
    ["onclick"] = function() ChangeSubTabRequest("Bank"); end
  },
  [2] = {
    ["nicename"] = "Stock Market",
    ["onclick"] = function() ChangeSubTabRequest("StockMarket"); end
  },
  [3] = {
    ["nicename"] = "Player Stores",
    ["onclick"] = function() ChangeSubTabRequest("PlayerStores"); end
  },
  [4] = {
    ["nicename"] = "Rewards",
    ["bg_color"] = Color(60, 255, 100, 255),
    ["onclick"] = function() ChangeSubTabRequest("Rewards"); end
  }
};

-- Main VGUI Building
function createDashboardBtn(w, h, msg, onclick, bg_c, fg_c)
  local button = vgui.Create("DButton");
  button:SetSize(w, h);
  button:SetPos(0, 0);
  button:SetText("");
  if onclick == nil then onclick = function() return; end; end
  if bg_c == nil then bg_c = Color(48, 48, 48, 150); end
  if fg_c == nil then fg_c = Color(255, 255, 255, 255); end
  button.DoClick = onclick;
  function button:Paint()
    draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), bg_c);
    draw.SimpleText(msg, "DashboardBtnFont", 10, self:GetTall() / 2, fg_c, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
  end
  return button;
end

function TabsDashboard(parent)
  local parentWidth = parent:GetWide();
  local parentHeight = parent:GetTall();
  local dashboardPanel = vgui.Create("DPanel", parent);
  dashboardPanel:SetSize(parentWidth - 10, parentHeight - 10);
  dashboardPanel:SetPos(5, 5);
  function dashboardPanel:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  -- Daily Bonus
  local dailyBonusLabel = vgui.Create("DPanel", dashboardPanel);
  dailyBonusLabel:SetPos(5, 5);
  dailyBonusLabel:SetSize(dashboardPanel:GetWide() * 0.35, 30);
  function dailyBonusLabel:Paint()
    draw.SimpleText("Collect daily login bonus", "Trebuchet24", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT);
  end

  local dailyBonusButton = vgui.Create("DButton", dashboardPanel);
  dailyBonusButton:SetPos(5, 40);
  dailyBonusButton:SetSize(dashboardPanel:GetWide() * 0.15, 30);
  dailyBonusButton:SetText("");
  function dailyBonusButton:Paint()
    draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255));
    -- Get the time until able to collect here
    local timeLeft = 42500;
    local timeLeftString = "";
    if timeLeft and timeLeft > 0 then timeLeftString = tostring(formatSeconds(42500)); end
    draw.SimpleText("Collect " .. timeLeftString, "Trebuchet18", self:GetWide() / 2, self:GetTall() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  -- Start POS (5, 100), width = 30%,
  local buttonSectionWidth = dashboardPanel:GetWide() * .323;
  local sectionCurrentUsedWidth = buttonSectionWidth + 15;
  local playerActionsTitle = vgui.Create("DPanel", dashboardPanel);
  playerActionsTitle:SetPos(5, 140);
  playerActionsTitle:SetSize(buttonSectionWidth, 23);
  function playerActionsTitle:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
    draw.SimpleText("Actions", "Trebuchet24", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, EXT_ALIGN_TOP);
  end

  local playerActionsList = vgui.Create("DScrollPanel", dashboardPanel);
  playerActionsList:SetSize(buttonSectionWidth, dashboardPanel:GetTall() - 180);
  playerActionsList:SetPos(5, 180);
  for i = 1, tableLength(TAB_CONFIG.playerActions) do
    local bg_color = TAB_CONFIG.playerActions[i]["bg_color"] or nil;
    local fg_color = TAB_CONFIG.playerActions[i]["fg_color"] or nil;
    local nicename = TAB_CONFIG.playerActions[i]["nicename"];
    local onclick = TAB_CONFIG.playerActions[i]["onclick"] or nil;
    local btn = playerActionsList:Add(createDashboardBtn(playerActionsList:GetWide(), ScrH() * .04, nicename, onclick, bg_color, fg_color));
    btn:Dock(TOP);
    btn:DockMargin(0, 0, 0, 5);
  end

  local gameplayFeaturesTitle = vgui.Create("DPanel", dashboardPanel);
  gameplayFeaturesTitle:SetPos(sectionCurrentUsedWidth, 140);
  gameplayFeaturesTitle:SetSize(buttonSectionWidth, 23);
  function gameplayFeaturesTitle:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
    draw.SimpleText("Character & RP", "Trebuchet24", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, EXT_ALIGN_TOP);
  end

  local gameplayList = vgui.Create("DScrollPanel", dashboardPanel);
  gameplayList:SetSize(buttonSectionWidth, dashboardPanel:GetTall() - 180);
  gameplayList:SetPos(sectionCurrentUsedWidth, 180);
  for i = 1, tableLength(TAB_CONFIG.gameplayFeatures) do
    local bg_color = TAB_CONFIG.gameplayFeatures[i]["bg_color"] or nil;
    local fg_color = TAB_CONFIG.gameplayFeatures[i]["fg_color"] or nil;
    local nicename = TAB_CONFIG.gameplayFeatures[i]["nicename"];
    local onclick = TAB_CONFIG.gameplayFeatures[i]["onclick"] or nil;
    local btn = gameplayList:Add(createDashboardBtn(gameplayList:GetWide(), ScrH() * .04, nicename, onclick, bg_color, fg_color));
    btn:Dock(TOP);
    btn:DockMargin(0, 0, 0, 5);
  end

  sectionCurrentUsedWidth = (sectionCurrentUsedWidth + buttonSectionWidth) + 10;
  local shopsListTitle = vgui.Create("DPanel", dashboardPanel);
  shopsListTitle:SetPos(sectionCurrentUsedWidth, 140);
  shopsListTitle:SetSize(buttonSectionWidth, 23);
  function shopsListTitle:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
    draw.SimpleText("Gameplay Actions", "Trebuchet24", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, EXT_ALIGN_TOP);
  end

  local shopList = vgui.Create("DScrollPanel", dashboardPanel);
  shopList:SetSize(buttonSectionWidth, dashboardPanel:GetTall() - 180);
  shopList:SetPos(sectionCurrentUsedWidth, 180);
  for i = 1, tableLength(TAB_CONFIG.otherFeatures) do
    local bg_color = TAB_CONFIG.otherFeatures[i]["bg_color"] or nil;
    local fg_color = TAB_CONFIG.otherFeatures[i]["fg_color"] or nil;
    local nicename = TAB_CONFIG.otherFeatures[i]["nicename"];
    local onclick = TAB_CONFIG.otherFeatures[i]["onclick"] or nil;
    local btn = shopList:Add(createDashboardBtn(shopList:GetWide(), ScrH() * .04, nicename, onclick, bg_color, fg_color));
    btn:Dock(TOP);
    btn:DockMargin(0, 0, 0, 5);
  end
  return dashboardPanel;
end

function TabsJobs(parent)
  local parentWidth = parent:GetWide();
  local parentHeight = parent:GetTall();
  local jobsPanelWidth = parentWidth - 10;
  local jobsPanelHeight = parentHeight - 10;
  local selectedModelPreview;
  local pickExtraModel;
  local jobWeapons;
  local jobDescription;
  local jobsPanel = vgui.Create("DPanel", parent);
  jobsPanel:SetSize(jobsPanelWidth, jobsPanelHeight);
  jobsPanel:SetPos(5, 5);
  function jobsPanel:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  selectedModel = {
    ["model_p"] = RPExtraTeams[1]["model"][1],
    ["job_name"] = RPExtraTeams[1]["name"],
    ["salary"] = RPExtraTeams[1]["salary"],
    ["description"] = RPExtraTeams[1]["description"],
    ["command"] = RPExtraTeams[1]["command"],
    ["all_models"] = RPExtraTeams[1]["model"],
    ["weapons"] = RPExtraTeams[1]["weapons"]
  };

  -- Select Job Panel
  local selectJobPanel = vgui.Create("DPanel", jobsPanel);
  -- 3/4 of the width 5 for gap
  selectJobPanel:SetPos(0, 0);
  selectJobPanel:SetSize(jobsPanelWidth / 1.5 - 5, jobsPanelHeight);
  local selectJobsScroll = vgui.Create("DScrollPanel", selectJobPanel);
  selectJobsScroll:SetSize(selectJobPanel:GetWide(), selectJobPanel:GetTall());
  local categoriesPanel = vgui.Create("DCategoryList", selectJobPanel);
  categoriesPanel:SetSize(jobsPanelWidth, jobsPanelHeight);
  function categoriesPanel:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  local categories = {};
  for k, v in ipairs(RPExtraTeams) do
    if v["category"] ~= nil and not categories[v["category"]] then
      local jobCat = categoriesPanel:Add(v["category"]);
      jobCat:SetTall(300);
      function jobCat:Paint()
        draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
      end

      local jobCatList = vgui.Create("DIconLayout");
      jobCatList:Dock(FILL);
      jobCatList:DockMargin(0, 20, 0, 0);
      jobCatList:DockPadding(0, 0, 0, 20);
      jobCatList:SetSpaceY(10);
      jobCatList:SetSpaceX(10);
      categories[v["category"]] = {
        ["categorySection"] = jobCat,
        ["categoryJobsList"] = jobCatList
      };
    end

    if categories[v["category"]] == nil then continue; end
    local model = v["model"];
    if type(v["model"]) == "table" then model = v["model"][1]; end
    local icon = categories[v["category"]]["categoryJobsList"]:Add("SpawnIcon");
    icon:SetSize(64, 64);
    icon:SetModel(model);
    icon:SetTooltip(v["name"]);
    icon.DoClick = function()
      selectedModel["model_p"] = model;
      selectedModel["job_name"] = v["name"];
      selectedModel["salary"] = v["salary"];
      selectedModel["description"] = v["description"];
      selectedModel["command"] = v["command"];
      selectedModel["weapons"] = v["weapons"];
      selectedModelPreview:SetModel(model);
      pickExtraModel:Clear();
      jobWeapons:UpdateJobWeapons();
      jobDescription:UpdateDescription();
      if type(v["model"]) == "table" then
        selectedModel["all_models"] = v["model"];
        pickExtraModel:BuildItems();
      else
        selectedModel["all_models"] = {};
      end
    end;

    categories[v["category"]]["categorySection"]:SetContents(categories[v["category"]]["categoryJobsList"]);
  end

  -- -- Show Model Panel
  local viewSelectedJobModel = vgui.Create("DPanel", jobsPanel);
  viewSelectedJobModel:SetPos(jobsPanelWidth / 1.5, 0);
  viewSelectedJobModel:SetSize(jobsPanelWidth / 3, jobsPanelHeight);
  local selectedJobNamePanel = vgui.Create("DPanel", viewSelectedJobModel);
  selectedJobNamePanel:SetSize(viewSelectedJobModel:GetWide(), viewSelectedJobModel:GetTall());
  function selectedJobNamePanel:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(100, 100, 100, 20));
  end

  local jobName = vgui.Create("DPanel", selectedJobNamePanel);
  jobName:Dock(TOP);
  function jobName:Paint()
    draw.SimpleText(selectedModel["job_name"], "Trebuchet24", self:GetWide() / 2, self:GetTall() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  selectedModelPreview = vgui.Create("DModelPanel", selectedJobNamePanel);
  selectedModelPreview:Dock(TOP);
  selectedModelPreview:SetSize(150, 150);
  selectedModelPreview:SetModel(selectedModel["model_p"]);
  selectedModelPreview:SetAnimated(true);
  selectedModelPreview:SetCamPos(Vector(130, 10, 36));
  selectedModelPreview:SetFOV(60);
  function selectedModelPreview:LayoutEntity(Entity)
    return;
  end

  if type(selectedModel["all_models"]) == "table" then
    pickExtraModel = vgui.Create("DHorizontalScroller", selectedJobNamePanel);
    pickExtraModel:Dock(TOP);
    pickExtraModel:DockMargin(10, 20, 10, 20);
    pickExtraModel:SetSize(48, 48);
    pickExtraModel:SetOverlap(-10);
    function pickExtraModel.btnLeft:Paint()
      draw.RoundedBox(0, 0, 0, 0, 0, Color(0, 0, 0, 0));
    end

    function pickExtraModel.btnRight:Paint()
      draw.RoundedBox(0, 0, 0, 0, 0, Color(0, 0, 0, 0));
    end

    function pickExtraModel:BuildItems()
      for i, v in ipairs(selectedModel["all_models"]) do
        local icon = vgui.Create("SpawnIcon");
        icon:SetSize(48, 48);
        icon:SetModel(v);
        icon.DoClick = function()
          selectedModel["model_p"] = v;
          selectedModelPreview:SetModel(v);
        end;

        self:AddPanel(icon);
      end
    end

    pickExtraModel:BuildItems();
  end

  jobWeapons = vgui.Create("DScrollPanel", selectedJobNamePanel);
  jobWeapons:Dock(TOP);
  jobWeapons:SetSize(selectedJobNamePanel:GetWide(), 110);
  jobWeapons:DockMargin(10, 0, 10, 20);
  function jobWeapons:UpdateJobWeapons()
    self:Clear();
    for i, v in ipairs(selectedModel["weapons"]) do
      local weaponName = jobWeapons:Add("DLabel");
      weaponName:SetText(v);
      weaponName:SetFont("Trebuchet18");
      weaponName:Dock(TOP);
      weaponName:SizeToContents();
    end

    if #selectedModel["weapons"] == 0 then
      local weaponName = jobWeapons:Add("DLabel");
      weaponName:SetText("No Weapons");
      weaponName:SetFont("Trebuchet18");
      weaponName:Dock(TOP);
      weaponName:SizeToContents();
    end
  end

  jobWeapons:UpdateJobWeapons();
  jobDescription = vgui.Create("RichText", selectedJobNamePanel);
  jobDescription:Dock(TOP);
  jobDescription:DockMargin(10, 0, 20, 10);
  jobDescription:SetMultiline(true);
  jobDescription:SetSize(selectedJobNamePanel:GetWide(), 140);
  function jobDescription:UpdateDescription()
    self:SetText(selectedModel["description"]);
  end

  jobDescription:UpdateDescription();
  local becomeJob = vgui.Create("DButton", selectedJobNamePanel);
  becomeJob:SetText("Become Job");
  becomeJob:SetTextColor(Color(255, 255, 255, 255));
  becomeJob:SetFont("Trebuchet24");
  becomeJob:Dock(TOP);
  becomeJob:DockMargin(10, 20, 10, 0);
  becomeJob:SetSize(selectedJobNamePanel:GetWide(), 40);
  function becomeJob:Paint()
    draw.RoundedBox(3, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255));
  end

  becomeJob.DoClick = function()
    RunConsoleCommand("rp_playermodel", selectedModel["model_p"]);
    RunConsoleCommand("_rp_ChosenModel", selectedModel["model_p"]);
    LocalPlayer():ConCommand("say /" .. selectedModel["command"]);
  end;
  return jobsPanel;
end

function TabsStore(parent)
  local parentWidth = parent:GetWide();
  local parentHeight = parent:GetTall();
  local storePanel = vgui.Create("DPanel", parent);
  storePanel:SetSize(parentWidth - 10, parentHeight - 10);
  storePanel:SetPos(5, 5);
  function storePanel:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  local itemsCategorized = categorizeStoreItems();
  local storeItemsCategorizedPanel = vgui.Create("DCategoryList", storePanel);
  storeItemsCategorizedPanel:SetSize(storePanel:GetWide(), storePanel:GetTall());
  function storeItemsCategorizedPanel:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0));
  end

  function storeItemsCategorizedPanel:RefreshCategories()
    for k, v in pairs(itemsCategorized) do
      local category = self:Add(k);
      local itemsDisplayPanel = vgui.Create("DPanelList");
      itemsDisplayPanel:SetAutoSize(true);
      itemsDisplayPanel:SetSpacing(10);
      itemsDisplayPanel:SetPadding(5);
      itemsDisplayPanel:EnableHorizontal(true);
      itemsDisplayPanel:EnableVerticalScrollbar(true);
      itemsDisplayPanel:SetSize(self:GetWide(), 350);
      function itemsDisplayPanel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0));
      end

      for i = 1, #v do
        local icon;
        if type(v[i]["allowed"]) == "table" then if v.noship or not table.HasValue(v[i]["allowed"], LocalPlayer():Team()) then continue; end end
        if v[i]["shipmodel"] then
          icon = CreateIcon(nil, v[i]["shipmodel"], 70, 70, nil, nil, function() LocalPlayer():ConCommand("say " .. "/buyshipment " .. v[i].name); end, Vector(40, 40, 40));
          icon:SetTooltip(v[i]["name"] .. " shipment \n" .. CUR .. v[i]["price"]);
        else
          icon = CreateIcon(nil, v[i]["model"], 70, 70, v[i]["mat"], v[i]["clr"], function() LocalPlayer():ConCommand("say " .. v[i]["cmd"]); end, Vector(20, 20, 20));
          icon:SetTooltip(v[i]["name"] .. "\n" .. CUR .. v[i]["price"]);
        end

        itemsDisplayPanel:AddItem(icon);
      end

      category:SetContents(itemsDisplayPanel);
    end
  end

  storeItemsCategorizedPanel:RefreshCategories();
  return storePanel;
end

function TabsInventory(parent)
  local Inv = {};
  local WepNames = LDRP_SH.NicerWepNames;
  local parentWidth = parent:GetWide();
  local parentHeight = parent:GetTall();
  if IsValid(inventoryPanel) then inventoryPanel:Remove(); end
  local inventoryPanel = vgui.Create("DPanel", parent);
  inventoryPanel:SetSize(parentWidth - 10, parentHeight - 10);
  inventoryPanel:SetPos(5, 5);
  function inventoryPanel:Paint()
    local InvWeight = 0;
    for k, v in pairs(LocalPlayer().Inventory) do
      if v >= 1 then InvWeight = InvWeight + (LDRP_SH.AllItems[k].weight * v); end
    end

    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
    draw.SimpleText("Weight: " .. InvWeight .. "/" .. LocalPlayer().MaxWeight, "Trebuchet18", self:GetWide() / 2, self:GetTall() - 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM);
  end

  local inventoryItemsList = vgui.Create("DPanelList", inventoryPanel);
  inventoryItemsList:SetAutoSize(true);
  inventoryItemsList:SetSpacing(10);
  inventoryItemsList:SetPadding(5);
  inventoryItemsList:EnableHorizontal(true);
  inventoryItemsList:EnableVerticalScrollbar(true);
  inventoryItemsList:SetSize(inventoryPanel:GetWide(), inventoryPanel:GetTall());
  local curIcons = {};
  function inventoryItemsList:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  function inventoryItemsList:RefreshItems()
    self:CleanList();
    for k, v in pairs(LocalPlayer().Inventory) do
      local check = curIcons[k];
      if check then
        if check.am ~= v or v <= 0 then
          local ItemTbl = LDRP_SH.AllItems[k];
          if not ItemTbl then continue; end
          if v <= 0 then
            inventoryItemsList.Remove(check.vgui);
            curIcons[k] = nil;
          else
            check.vgui:SetToolTip(ItemTbl.nicename .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight);
            curIcons[k].am = v;
          end
        end
      elseif v > 0 then
        local ItemTbl = LDRP_SH.AllItems[k];
        if not ItemTbl then continue; end
        local ItemIcon = CreateIcon(nil, ItemTbl.mdl, 78, 78, ItemTbl.mat, ItemTbl.clr, function() LDRP.OpenItemOptions(k); end);
        curIcons[k] = {
          ["vgui"] = ItemIcon,
          ["am"] = v
        };

        local namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename;
        ItemIcon:SetToolTip(namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight);
        inventoryItemsList:AddItem(ItemIcon);
      end
    end
  end

  inventoryItemsList.Think = function() inventoryItemsList:RefreshItems(); end;
  return inventoryPanel;
end

function TabsSkills(parent)
  local parentWidth = parent:GetWide();
  local parentHeight = parent:GetTall();
  local skillsPanel = vgui.Create("DPanel", parent);
  skillsPanel:SetSize(parentWidth - 10, parentHeight - 10);
  skillsPanel:SetPos(5, 5);
  function skillsPanel:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  local colW = skillsPanel:GetWide() / 2;
  local colH = skillsPanel:GetTall() / 4;
  local colA = 2;
  local skillsScrollContainer = vgui.Create("DScrollPanel", skillsPanel);
  skillsScrollContainer:SetSize(skillsPanel:GetWide(), skillsPanel:GetTall());
  local skillsGrid = vgui.Create("DGrid", skillsScrollContainer);
  skillsGrid:SetSize(skillsScrollContainer:GetWide(), skillsScrollContainer:GetTall());
  skillsGrid:SetColWide(colW);
  skillsGrid:SetRowHeight(colH);
  skillsGrid:SetCols(colA);
  function skillsGrid:RefreshItems()
    -- there is probably a better way to do this
    for k, v in pairs(self:GetItems()) do
      self:RemoveItem(v);
    end

    for k, v in SortedPairs(LocalPlayer().Skills) do
      local skillSelected = LDRP_SH.AllSkills[k];
      local skillDisplay = vgui.Create("DPanel");
      skillDisplay:SetSize(colW, colH);
      function skillDisplay:Paint()
        local expNeed = LDRP_SH.AllSkills[k].exptbl[v["lvl"]];
        draw.RoundedBox(10, 0, 0, self:GetWide() - 5, self:GetTall() - 5, Color(213, 100, 100, 200));
        draw.SimpleTextOutlined(k, "Trebuchet20", 5, 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255));
        draw.SimpleTextOutlined("Level: " .. v["lvl"], "Trebuchet20", self:GetWide() - 70, 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255));
        draw.SimpleTextOutlined(skillSelected["descrpt"], "Trebuchet20", 5, self:GetTall() - 40, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255));
        draw.RoundedBox(5, 80, 60, 350, 25, Color(100, 100, 100, 255));
        if v["exp"] > 0 then draw.RoundedBox(5, 80, 60, 348 * math.Clamp(v["exp"] / expNeed, .02, 1), 25, Color(0, 220, 0, 170)); end
        draw.SimpleTextOutlined(v["exp"] .. "/" .. expNeed, "Trebuchet20", 500 / 2, 145 / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255));
      end

      local skillIcon = vgui.Create("SpawnIcon", skillDisplay);
      skillIcon:SetPos(5, 40);
      skillIcon:SetSize(70, 70);
      skillIcon:SetModel(skillSelected["mdl"]);
      skillIcon:SetTooltip();
      function skillIcon:PaintOver()
        return;
      end

      function skillIcon:OnCursorEntered()
        return;
      end

      if v["exp"] == LDRP_SH.AllSkills[k].exptbl[v["lvl"]] then
        local upgradeBtn = vgui.Create("DButton", skillDisplay);
        upgradeBtn:SetText("");
        upgradeBtn:SetSize(80, 30);
        upgradeBtn:SetPos(skillDisplay:GetWide() - 95, skillDisplay:GetTall() - 40);
        function upgradeBtn:Paint()
          draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 200));
          draw.SimpleText("Upgrade", "Trebuchet18", self:GetWide() / 2, self:GetTall() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
        end

        upgradeBtn:SetTooltip();
        if skillSelected.pricetbl[v["lvl"] + 1] then
          upgradeBtn:SetToolTip("Buy level " .. v["lvl"] + 1 .. " for $" .. skillSelected.pricetbl[v["lvl"] + 1]);
        else
          upgradeBtn:SetToolTip("Your level is maxxed out!");
        end

        upgradeBtn.DoClick = function() RunConsoleCommand("_buysk", k); end;
      end

      skillsGrid:AddItem(skillDisplay);
    end
  end

  skillsGrid:RefreshItems();
  return skillsPanel;
end

function getTableKeys(tbl)
  local keys = {};
  local index = 1;
  for k, v in pairs(tbl) do
    keys[index] = k;
    index = index + 1;
  end
  return keys;
end

function TabsCrafting(parent)
  local craftingTab = vgui.Create("DPanel", parent);
  craftingTab:SetSize(parent:GetWide() - 10, parent:GetTall() - 10);
  craftingTab:SetPos(5, 5);
  function craftingTab:Paint()
    draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 0));
  end

  local craftingScrollPanel = vgui.Create("DScrollPanel", craftingTab);
  craftingScrollPanel:SetSize(craftingTab:GetWide(), craftingTab:GetTall());
  local markupObjs = {};
  local function updateMarkupObjs()
    for k, v in ipairs(markupObjs) do
      recipeString = "";
      firstRecipieItem = true;
      for k1, v1 in pairs(v.recipe) do
        local strColor = "255, 255, 255";
        if not LocalPlayer():HasItem(k1, v1) then strColor = "213, 100, 100"; end
        recipeString = string.format("%s%s<colour=%s>%s (%s)</colour>", recipeString, firstRecipieItem and "" or ", ", strColor, LDRP_SH.NicerWepNames[k1] or LDRP_SH.AllItems[k1].nicename, v1);
        firstRecipieItem = false;
      end

      local newMarkupObj = markup.Parse(string.format("<font=Trebuchet18><colour=255,255,255>%s: </colour>%s</font>", "Recipe", recipeString));
      if v.parent and IsValid(v.parent) then
        function v.parent:Paint()
          newMarkupObj:Draw(0, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP);
        end
      end
    end
  end

  local function populateCraftingTab()
    if IsValid(craftingScrollPanel) then craftingScrollPanel:Clear(); end
    local colWide = craftingScrollPanel:GetWide() / 2.1;
    local rowTall = 100;
    local cols = 2;
    local craftingTabGrid = vgui.Create("DGrid", craftingScrollPanel);
    craftingTabGrid:SetSize(craftingScrollPanel:GetWide(), craftingScrollPanel:GetTall());
    craftingTabGrid:SetPos(25, 10);
    craftingTabGrid:SetColWide(colWide);
    craftingTabGrid:SetRowHeight(rowTall);
    craftingTabGrid:SetCols(cols);
    for k, v in pairs(LDRP_SH.CraftItems) do
      local modelDetails = LDRP_SH.AllItems[string.lower(getTableKeys(v.results)[1])];
      local craftingItemPanel = vgui.Create("DPanel");
      craftingItemPanel:SetSize(colWide - 10, rowTall - 10);
      craftingItemPanel:SetPos(5, 5);
      function craftingItemPanel:Paint()
        draw.RoundedBox(3, 0, 0, self:GetWide(), self:GetTall(), Color(100, 100, 100, 100));
        draw.SimpleText(k, "Trebuchet18", 100, self:GetTall() / 2 - 30, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
      end

      local craftingItemIcon = CreateIcon(craftingItemPanel, v.icon, craftingItemPanel:GetWide() * .22, craftingItemPanel:GetTall(), modelDetails.mat or nil, modelDetails.clr or nil, function() end);
      local craftingRecipeNeededContainer = vgui.Create("DPanel", craftingItemPanel);
      craftingRecipeNeededContainer:SetSize(craftingItemPanel:GetWide() - (craftingItemPanel:GetWide() * .22) - 5, 40);
      craftingRecipeNeededContainer:SetPos(100, craftingItemPanel:GetTall() / 2 - 20);
      table.insert(markupObjs, {
        obj = {},
        parent = craftingRecipeNeededContainer,
        recipe = v.recipe
      });

      local craftBtn = vgui.Create("DButton", craftingItemPanel);
      craftBtn:SetSize(100, 30);
      craftBtn:SetPos(craftingItemPanel:GetWide() - 105, craftingItemPanel:GetTall() / 2 + 10);
      craftBtn:SetText("");
      function craftBtn:Paint()
        draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255));
        draw.SimpleTextOutlined("Craft", "Trebuchet24", self:GetWide() / 2, self:GetTall() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255));
      end

      craftBtn.DoClick = function() RunConsoleCommand("__crft", k); end;
      craftingTabGrid:AddItem(craftingItemPanel);
    end
  end

  populateCraftingTab();
  updateMarkupObjs();
  return craftingTab;
end
