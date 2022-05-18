#### This guide is not generally about the LiquidRP gamemode it's self, but more so to help others understand the basics of hud painting.

Basic Syntax
===============
When wanting to draw a hud on the players screen, a hook/event needs to be called. This could be a gamemode hook such as ...
```
hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
	-- draw hud
end )
```
Or a net message received from the server ...
```
net.Receive( "PlayerDied", function()
  -- draw hud
end )
```

Moving onto the draw libraries, there are two we can choose from.

(Draw) - The draw library's purpose is to simplify the usage of the surface library. This library can be limiting when moving onto complex huds.
```
 draw.RoundedBox( 
   number cornerRadius, -- the roundness of the box
   number x, -- the position along the x axis on the players screen you want the box to start at
   number y, -- the position along the y axis on the players screen you want the box to start at
   number width, -- the width of the box
   number height, -- the height of the box
   table color -- the color of the boxes background, using GLua Color function.
   )
```

(Surface) - This library gives us more freedom, allowing us draw stuff like textured rectangles.
```
 surface.SetDrawColor( 
   number r, 
   number g, 
   number b, 
   number a = 255 ) -- this function is similar to the Color function, sets the color of the rect we will draw

  surface.SetTexture( number textureID ) -- Sets the texture we will use on the rect we are going to draw. We pass in a texture id.

  surface.DrawTexturedRect( 
    number x, 
    number y, 
    number width, 
    number height ) -- nearly identical to draw.RoundedBox, but we don't set the color inside this function parameters.

  -- If we set the color to 255, 50, 50, 255
  -- then set the textures id to 12
  -- and of course fill in the rect params.
  -- We would end up with a lightish red, with a kinda gradient background rectangle.
```

Positioning & Center HUDs
===============

I found what confused me the most when i first started drawing HUDs, was figuring out how to center stuff on the players screen. In this example, I will show you how to center a rectangle in the middle-bottom of a players screen. In addition, I will center the text inside the rectangle. By the end of the tutorial, we will have created the players' jail timer.

The first thing we are going to do is wait for the hook to be called when the player is arrested.
```
usermessage.Hook("GotArrested", function(msg)

end)
```
We now have our hook, and we are accepting a parameter to read the length of the jail timer, we can start setting up the variables we will be using in the HUD drawing.
```
usermessage.Hook("GotArrested", function(msg)

	local StartArrested = CurTime()

	local ArrestedUntil = msg:ReadFloat()

	
	Arrested = function()

	  if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then

            local hudTimeLeft = string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested)))

	   elseif not LocalPlayer().DarkRPVars.Arrested then

			Arrested = function() end

		end

	end

end)
```
The function we have added uses the two variables just above this function to check whether the player still has time left on their prison sentence. The HUD will be painted if they do.

The box and text will now be drawn at the bottom center of the player's screen using the draw library we saw earlier. Let me explain some of the math involved with centering/positioning HUD elements on a screen.

Our box dimensions are as follows: width = 300, height = 150. 

A player's screen has a width of 900px and a height of 800px. The box should be centered dead center on the screen. 
First we divide the width by two to get the x position of 450. Now that we've located the center of the screen, let's try to position our box there.

![box positioning image one](https://i.postimg.cc/T1JsDQ8Y/center-first-guide-p1.png)

As you can see, we moved the box to the x-axis we discovered, but it is still not in the centre. That's because we're putting the box's 0 x-axis at the axis we discovered instead of the box's middle axis in the centre of the screen. 

So, let's do some more math to properly position the box.
We will now find the centre of the box we are drawing by dividing the width of the box by 2.

So we now have the screen's x position of 450, which we calculated by dividing the screen's width by 2, and the box's centre of 150, which we also calculated.
So, to find the x axis on which to place our box, subtract the box's centre from the centre of the screen's axis.
As a result, (450-150) = 300. 

![box centered](https://i.postimg.cc/2j7RVppD/center-first-guide-p2.png)

So we've now centred the box along the x axis.
We can repeat the previous step for the box's and screen's height, and then centre the box on the y axis.

X(325) = (800/2) - (150/2) 

![completed centre of box](https://i.postimg.cc/xd6N0p0y/center-first-guide-p3.png)

Now that we've seen an iluastrated example, let's write some code and make that jail timer HUD. If you want to continue with this section, you'll need a copy of Garrysmod and, preferably, LiquidRP or DarkRP. 

If you're using LiquidRP, go to the file cl hud.lua and find the line beginning at 134 and delete it all the way to line 142. So we should be left with something like this. 
```
usermessage.Hook("GotArrested", function(msg)

	local StartArrested = CurTime()

	local ArrestedUntil = msg:ReadFloat()

	
	Arrested = function()

		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then

            local hudTimeLeft = string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested)))

      

		elseif not LocalPlayer().DarkRPVars.Arrested then 
			Arrested = function() end
	    end

	end

end)
```

To begin, we'll need to determine the width and height of our box.
I've decided to use 30% of the player's screen width and 70% of their height.
Using the ScrW() function, we can get the player's screen width and then multiply it by 0.3 to get 30 percent. 

So now I'll make two variables to store these in for easy reference, and then calculate the x and y as we did above and save them in their respective variables (x, y). Note: We aren't doing the same calculations with the y axis as we are setting it our selfs to be close to the bottom of the screen.  
```
usermessage.Hook("GotArrested", function(msg)

	local StartArrested = CurTime()

	local ArrestedUntil = msg:ReadFloat()

	
	Arrested = function()

		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then

            local hudTimeLeft = string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested)))

            local bWidth = ScrW() * .3
            local bHeight = 70

            local x = (ScrW() / 2) - (bWidth / 2)
            local y = ScrH() - 100

      

		elseif not LocalPlayer().DarkRPVars.Arrested then 
			Arrested = function() end
		end

	end

end)
```
Let's begin by drawing a rounded box. 
We'll rely on the variables we calculated earlier.
We'll make the background a lightish red with a transparency of 200.  
```
usermessage.Hook("GotArrested", function(msg)

	local StartArrested = CurTime()

	local ArrestedUntil = msg:ReadFloat()

	
	Arrested = function()

		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then

            local hudTimeLeft = string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested)))

            local bWidth = ScrW() * .3
            local bHeight = 70

            local x = (ScrW() / 2) - (bWidth / 2)
            local y = ScrH() - 100

            draw.RoundedBox(5, x, y, bWidth, bHeight, Color(255, 50, 50, 200)) -- this line

		elseif not LocalPlayer().DarkRPVars.Arrested then 
			Arrested = function() end
		end

	end

end)
```
Now let's add that centred text in the middle of the box we've drawn.
This can be the most confusing part, but once you've broken it down, you'll have a much better understanding. We align the text centre, centre along both axis with text_align_center, now using the width as an example, we get the box x axis and then add the width of the box divided by two, and that should now be centered in the middle of the box. We repeat the steps for the y axis.

```
usermessage.Hook("GotArrested", function(msg)

	local StartArrested = CurTime()

	local ArrestedUntil = msg:ReadFloat()

	
	Arrested = function()

		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then

            local hudTimeLeft = string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested)))

            local bWidth = ScrW() * .3
            local bHeight = 70

            local x = (ScrW() / 2) - (bWidth / 2)
            local y = ScrH() - 100

            draw.RoundedBox(5, x, y, bWidth, bHeight, Color(255, 50, 50, 200))

            draw.SimpleTextOutlined(
              hudTimeLeft, 
              "Trebuchet24", 
              x + (bWidth/2), 
              y + (bHeight / 2), 
              Color(255,255,255,255), 
              TEXT_ALIGN_CENTER, 
              TEXT_ALIGN_CENTER, 
              2,Color(0,0,0,255)
              )

		elseif not LocalPlayer().DarkRPVars.Arrested then 
			Arrested = function() end
		end

	end

end)
```

Finally we should end up with a red rounded box, at the bottom centre of our screen.

![complete image](https://steamuserimages-a.akamaihd.net/ugc/1822280943662205253/9998A0A0DDB6F3A48B7646B47CEE9FE660426BAB/?imw=1024&imh=576&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true)

<div align="center">
  <a href="https://github.com/carlbeattie2000">
    <img src="https://i.postimg.cc/8CQr0HG8/authored-by.png" alt="twitter">
  </a>
</div>