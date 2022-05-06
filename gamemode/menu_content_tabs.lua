function F4Bank(parent)

	local bankWindow = vgui.Create("DPanel", parent)

	bankWindow:SetSize(400, 400)

	bankWindow:SetPos(20, 20)

	function bankWindow:Paint()
		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(200, 200, 200, 255))
	end

	local icon = vgui.Create("DPanel", bankWindow)

	icon:SetSize(30,30)

	function icon:Paint()

		surface.SetDrawColor(100, 100, 100, 255)
		surface.SetMaterial(R_F4_MATS.bankingIcon)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())

	end

	return bankWindow

end

function F4BankVault(parent)

	local bankVaultWindow = vgui.Create("DPanel", parent)

	bankVaultWindow:SetSize(400, 400)

	bankVaultWindow:SetPos(20, 20)

	function bankVaultWindow:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(100, 100, 100, 255))

	end

	return bankVaultWindow

end

function F4OreProcessing(parent)

	local oreProcessingWindow = vgui.Create("DPanel", parent)

	oreProcessingWindow:SetSize(400, 400)

	oreProcessingWindow:SetPos(20, 20)

	function oreProcessingWindow:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return oreProcessingWindow

end

function F4Achivements(parent)

	local achivements = vgui.Create("DPanel", parent)

	achivements:SetSize(400, 400)

	achivements:SetPos(20, 20)

	function achivements:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return achivements

end

function F4CharacterBoosters(parent)

	local characterBoosters = vgui.Create("DPanel", parent)

	characterBoosters:SetSize(400, 400)

	characterBoosters:SetPos(20, 20)

	function characterBoosters:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return characterBoosters

end

function F4ViewCases(parent)

	local viewCases = vgui.Create("DPanel", parent)

	viewCases:SetSize(400, 400)

	viewCases:SetPos(20, 20)

	function viewCases:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return viewCases

end

function F4PlayerStores(parent)

	local playerStores = vgui.Create("DPanel", parent)

	playerStores:SetSize(400, 400)

	playerStores:SetPos(20, 20)

	function playerStores:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return playerStores

end

function F4PlayerRewards(parent)

	local playerRewards = vgui.Create("DPanel", parent)

	playerRewards:SetSize(400, 400)

	playerRewards:SetPos(20, 20)

	function playerRewards:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return playerRewards

end

function F4StockMarket(parent)


	local stockMarket = vgui.Create("DPanel", parent)

	stockMarket:SetSize(400, 400)

	stockMarket:SetPos(20, 20)

	function stockMarket:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50, 255))

	end

	return stockMarket

end

print("menu tabs loaded!!!!!!!")