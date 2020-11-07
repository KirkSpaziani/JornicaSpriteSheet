# JornicaSpriteSheet
Tool to create simple .png sprite sheets on OS X

Here is a small command line Cocoa app that given a folder with .png images, will create a sprite sheet from them. All images must be 32-bit RGBA .png files with the same dimensions. The resulting sprite sheet will also be 32-bit RGBA. The utility also outputs an .xml file in a specific format that is read by my Wraith library, but should be general purpose enough to easily be utilized.

Other functionality includes batch converting the colors in a spritesheet, converting between different formats, and outputting a Swift file to be easily consumed by the Mootaurus Engine. These are currently not documented here, please look at the code if you're interested.

Sample usage:

./SpriteSheet -mode combine -imagePath pictures/items_1 -sheetName items_1 -sheetWidth 128 -sheetHeight 128 -spriteWidth 32 -spriteHeight 32

This will look at all files in the folder pictures/items_1, create a png called items_1.png which is 128x128 32-bit RGBA, tile 32x32 images from the files in it, and output items_1.xml which will give context to a program trying to make use of the sprite sheet.

Sample .xml result file:

    <spritesheet>
      <name>items_1</name>
      <width>128</width>
      <height>128</height>
      <spritesize>
        <width>32</width>
        <height>32</height>
      </spritesize>
      <sprites>
        <sprite name="it_axe" x="0" y="0"></sprite>
        <sprite name="it_blacksmiths_apron" x="1" y="0"></sprite>
        <sprite name="it_gauntlet" x="2" y="0"></sprite>
        <sprite name="it_helm" x="3" y="0"></sprite>
        <sprite name="it_initiates_tunic" x="0" y="1"></sprite>
        <sprite name="it_mail_hauberk" x="1" y="1"></sprite>
        <sprite name="it_reinforced_boots" x="2" y="1"></sprite>
        <sprite name="it_ruby_bracers" x="3" y="1"></sprite>
        <sprite name="it_skull_boots" x="0" y="2"></sprite>
        <sprite name="it_steel_boots" x="1" y="2"></sprite>
      </sprites>
    </spritesheet>

