-- Simple logger to act as a placeholder until one is developed

function writeEvent(content)

  local todayDate = os.date("*t")

  local logContent = todayDate["hour"]..":"..todayDate["min"]..":"..todayDate["sec"].." "..content.."\n"

  local t_filename = "p_logger_"..todayDate["year"]..todayDate["month"]..todayDate["day"]..".txt"

  if file.Exists("p_logger/"..t_filename, "DATA") then

    print("FILE FOUND")
    
    file.Append("p_logger/"..t_filename, logContent)

    return

  end

  if not file.Exists("p_logger/", "DATA") then

    file.CreateDir("p_logger/")

  end

  file.Write("p_logger/"..t_filename, logContent)

end

-- R_GOVERNMENT logging hooks

hook.Add("governmentFundsChanged", "logGFundsChanged", function(amountAdded, newTotalAmount)

  local loggingText = string.format("$%s added to government funds. New total amount $%s", REBELLION.format_num(amountAdded), REBELLION.format_num(newTotalAmount))

  writeEvent(loggingText)
end)

hook.Add("governmentPlayerTaxesChanged", "logGTaxesChanged", function(newValues)
  
  local loggingText = string.format(
    "{player_tax: %f} \n {sales_tax: %f} \n {trading_tax: %d}",
    newValues["player_tax"], newValues["sales_tax"], newValues["trading_tax"]
  )

  writeEvent(loggingText)

end)

hook.Add("playerTaxed", "logGPlayerTaxed", function(ply, amount)

  local loggingText = string.format("%s was taxed $%s", ply:Nick(), REBELLION.format_num(amount))

  writeEvent(loggingText)

end)

hook.Add("entSeized", "logGEntSeized", function(owner, seizer)

  local loggingText = ""

  if not IsValid(owner) and not IsValid(seizer) then

    loggingText = "invalid owner and seizer when attempting to seize entity"

  elseif not IsValid(owner) then

    loggingText = string.format("%s seized a entity from unknown", seizer:Nick())

  elseif not IsValid(seizer) then

    loggingText = string.format("unknown seized a entity from %s", owner:Nick())

  else

    loggingText = string.format("%s seized %s entity", owner:Nick(), seizer:Nick())

  end

  writeEvent(loggingText)

end)

-- Anticheat logging hooks
hook.Add("playerFamilySharing", "logAFamilySharing", function(ply)

  if IsValid(ply) then

    writeEvent(string.format("%s is family sharing", ply:Nick()))

  end

end)

hook.Add("playerUsingVPN", "logAUsingVPN", function(ply)
  
  if IsValid(ply) then

    writeEvent(string.format("%s is using a vpn", ply:Nick()))
    
  end

end)

hook.Add("playerVPNCheckingFailed", "logAVPNCheckFailed", function(ply)

  if IsValid(ply) then

    writeEvent(string.format("VPN Checking for %s failed", ply:Nick()))

  end

end)
-- DarkRP / LiquiddRP logging

hook.Add("PlayerWalletChanged", "logWalletChanged", function(ply, amount, walletTotal)

  if IsValid(ply) then

    local loggingText = string.format("$%s was added to %s's wallet, totaling $%s", REBELLION.format_num(amount), ply:Nick(), REBELLION.format_num(walletTotal))

    writeEvent(loggingText)

  end

end)

hook.Add("DarkRPVarChanged", "logDarkRPVarChanged", function(ply, var, plyVar, value)
  
  if IsValid(ply) then

    local loggingText = string.format("DarkRP var '%s' was changed for %s, new value: %s", var, ply:Nick(), tostring(value))

    writeEvent(loggingText)

  end

end)

hook.Add("PlayerWanted", "logDarkRPWanted", function(actor, ply, reason)

  local loggingText = string.format("%s was wanted by %s for %s", ply:Nick(), actor:Nick(), reason)
  
  writeEvent(loggingText)

end)

hook.Add("playerArrested", "logDarkRPArrested", function(ply, _, arrestor)

  local loggingText = string.format("%s was arrested by %s", ply:Nick(), arrestor:Nick())

  writeEvent(loggingText)

end)

