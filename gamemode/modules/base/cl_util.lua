function DarkRP.textWrap(text, font, pxWidth)
	local total = 0

	surface.SetFont(font)

	local spaceSize = surface.GetTextSize(' ')
	text = text:gsub("(%s?%w+)", function(word)
			local char = string.sub(word, 1, 1)
			if char == "\n" or char == "\t" then
				total = 0
			end

			local wordlen = surface.GetTextSize(word)
			total = total + wordlen


			-- Wrap around when the max width is reached
			if wordlen >= pxWidth then -- Split the word if the word is too big
				local splitWord, splitPoint = charWrap(word, pxWidth)
				total = splitPoint
				return splitWord
			elseif total < pxWidth then
				return word
			end

			-- Split before the word
			if char == ' ' then
				total = wordlen - spaceSize
				return '\n' .. string.sub(word, 2)
			end

			total = wordlen
			return "\n" .. word
		end)

	return text
end