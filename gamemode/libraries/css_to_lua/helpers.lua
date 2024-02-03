function Multi_Assert(expectedArgumentType, ...)
  local assertErrorMessage = string.format('Incorrect Argument, Expected %q', expectedArgumentType)
  for _, arg in pairs(...) do
    assert(arg, assertErrorMessage)
  end
end

function Single_Assert(expectedArgumentType, assertArg)
  local assertErrorMessage = string.format('Incorrect Argument, Expected %q', expectedArgumentType)
  assert(assertArg, assertErrorMessage)
end

function IsValidEnum(enumTable, enum)
  Single_Assert('Enum', isstring(enum))
  Single_Assert('Table', istable(enumTable))

  for _, v in pairs(enumTable) do
    if v == enum then
      return true
    end
  end

  return false
end
