---
id: css_to_lua_intro
title: Intro
---

This library is crafted to streamline the creation of elegant HUDs for my ongoing project. Drawing inspiration from CSS's core features, it offers a versatile set of functionalities to enhance your design process.

Built on top of GMod's draw and surface libraries, this tool is tailored for modifying or adding HUDs exclusively within this game mode. However, its versatile design also allows for integration into your own projects, providing flexibility for further customization and development.

Now, let's delve into the structure of this library. In traditional web development, you usually have one root element per page. However, in our HUD environment, you can have multiple roots. These roots serve as the foundation for organizing your HUD into different sections, each starting from its own root.

So whether you're creating a simple heads-up display or a complex user interface, this library provides the framework to bring your creative visions to life within the HUD environment.

## Key Features:

- Box Model: Effortlessly manage the layout and structure of your HUD elements.
- Padding: Fine-tune spacing within your HUD components for optimal presentation.
- Margin: Control the space between individual HUD elements with precision.

For detailed usage instructions, please refer to the API reference provided.

# Using the library
#### On the server
```lua title="(sv_init.lua)"
include("/path/to/library/sv_loader.lua")
```
#### On the client
```lua title="(cl_init.lua)"
CSSHUD = include("/path/to/library/export.lua")
```
Now you can use the library globally throughout your project. Alternatively, if you decide not to include it globally, you have the option to include it locally on a per-module basis using the 'local' keyword. However, remember that you still need to include the 'sv_loader.lua' file on the server.
