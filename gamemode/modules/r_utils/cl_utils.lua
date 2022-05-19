cUtils = cUtils || {}

cUtils.funcs = cUtils.funcs || {}

cUtils.config = cUtils.config || {}

function cUtils.funcs.ScreenScale(num, h)

	local devw = 2560 --Development height

	local devh = 1440 --Development width

	

	return num * (h and (ScrH() / devh) or (ScrW() / devw))

end

function cUtils.funcs.EditScrollBarStyle(scrollpanel, colour)

	local scrollbar = scrollpanel.VBar

	scrollbar.btnUp:SetVisible(false)

	scrollbar.btnDown:SetVisible(false)

	scrollbar:SetCursor("hand")

	scrollbar.btnGrip:SetCursor("hand")



	function scrollbar:PerformLayout()

		local wide = scrollbar:GetWide()

		local scroll = scrollbar:GetScroll() / scrollbar.CanvasSize

		local barSize = math.max(scrollbar:BarScale() * (scrollbar:GetTall() - (wide * 2)), cUtils.funcs.ScreenScale(10))

		local track = scrollbar:GetTall() - (wide * 2) - barSize

		track = track + 1



		scroll = scroll * track



		scrollbar.btnGrip:SetPos(0, (wide + scroll) - cUtils.funcs.ScreenScale(15, true))

		scrollbar.btnGrip:SetSize(wide, barSize + cUtils.funcs.ScreenScale(30))

	end

	local colour = colour or Color(10, 10, 10, 175)

	function scrollbar:Paint(w, h)

		cUtils.funcs.Rect(0, 0, scrollbar:GetWide() / 1.5, scrollbar:GetTall(), Color(colour.r, colour.g, colour.b, 100))

	end

	function scrollbar.btnGrip:Paint(w, h) 

		cUtils.funcs.Rect(0, 0, scrollbar.btnGrip:GetWide() / 1.5, scrollbar.btnGrip:GetTall(), colour or color_white)

	end

end

function cUtils.funcs.Rect(x, y, w, h, col)

	surface.SetDrawColor(col)

	surface.DrawRect(x, y, w, h)

end