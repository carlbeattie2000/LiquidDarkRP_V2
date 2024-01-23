# How are modules loaded?

I just spent the better part of an hour trying to dig through and remember how
modules are loaded, as my memory was telling me I had to include the files in some
init file, will I was right, but all the modules are loaded automatically.

To create a new module, create a new folder inside ```gamemode\modules\``` then add the cl, sh and sv files.

So if we was going to make a new module lottery, we should end up with a folder structure like so:
```bash
-gamemode
    -modules
        -lottery
            -cl_init.lua
            -sh_init.lua
            -sv_init.lua
```

You can disable any module from inside ```gamemode\config.lua``` by just adding the module folder name to the ```GM.Config.DisabledModules```
It's best to also add a check inside the cl,sh and sv files just to make sure you have no side affects, so inside my lottery module folder I would have this
check at the very top of each file.
```lua
-- R_LOTTERY is a global variable declared inside the r_lottery module, which I would have added a .Config with the module name
if GM.Config.DisabledModules[R_LOTTERY.Config.moduleName] then return; end
```


TLDR; You don't need to worry about including modules manually, if you have the correct files inside your new module folder it will be loaded.
