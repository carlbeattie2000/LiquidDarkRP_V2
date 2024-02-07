/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  // By default, Docusaurus generates a sidebar from the docs folder structure
  docsSidebar: [
    {
      type: 'category',
      label: 'V2',
      items: [
        'API/V2/intro',
        {
          type: 'category',
          label: 'Libs',
          items: [
            {
              type: 'category',
              label: 'CSS to Lua',
              items: [
                'API/V2/css_to_lua/css_to_lua_intro',
                'API/V2/css_to_lua/base/nodes',
                'API/V2/css_to_lua/base/box_model'
              ]
            }
          ]
        }
      ]
    }
  ],

  // But you can create a sidebar manually
  /*
  tutorialSidebar: [
    'intro',
    'hello',
    {
      type: 'category',
      label: 'Tutorial',
      items: ['tutorial-basics/create-a-document'],
    },
  ],
   */
};

export default sidebars;
