//
//  JSSXMLConverter.m
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/28/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import "JSSXMLConverter.h"
#import "JSSUtils.h"

@implementation JSSXMLConverter {
  NSString *_sourceFile;
  NSString *_destFile;
}

-(instancetype)initWithSourceFile:(NSString *)sourceFile destFile:(NSString *)destFile {
  if(self = [super init]) {
    _sourceFile = [sourceFile copy];
    _destFile = [destFile copy];
  }

  return self;
}

-(void)convert {
  NSURL *url = [NSURL fileURLWithPath: _sourceFile];
  NSXMLDocument *sourceDoc = [[NSXMLDocument alloc] initWithContentsOfURL: url options: NSXMLNodeOptionsNone error:nil];
  NSXMLElement *root = [sourceDoc rootElement];
  // Extract all the attributes from the root.
  NSString *name = [[root attributeForName: @"name"] stringValue];
  NSInteger tileWidth = [[[root attributeForName: @"tilewidth"] stringValue] integerValue];
  NSInteger tileHeight = [[[root attributeForName: @"tileheight"] stringValue] integerValue];
  NSInteger spacing = [[[root attributeForName: @"spacing"] stringValue] integerValue];
  NSInteger margin = [[[root attributeForName: @"margin"] stringValue] integerValue];
  NSInteger tileCount = [[[root attributeForName: @"tilecount"] stringValue] integerValue];
  NSInteger columns = [[[root attributeForName: @"columns"] stringValue] integerValue];
  NSInteger rows = tileCount / columns;

  // Extract info from the image element.
  //<image source="colored.png" width="261" height="131"/>
  NSXMLElement *image = [[root elementsForName: @"image"] firstObject];
  NSInteger imageWidth = [[[image attributeForName: @"width"] stringValue] integerValue];
  NSInteger imageHeight = [[[image attributeForName: @"height"] stringValue] integerValue];
  NSArray<NSXMLElement *> *tiles = [root elementsForName: @"tile"];
  // Convert all the sprites.
  NSXMLElement *spritesElement = [NSXMLElement elementWithName: @"sprites"];
  for(NSXMLElement *tileElement in tiles) {
    NSInteger idNum = [[[tileElement attributeForName: @"id"] stringValue] integerValue];
    NSInteger x = idNum % columns;
    NSInteger y = rows - idNum / columns - 1;
    NSXMLElement *spriteElement = [NSXMLElement elementWithName: @"sprite"];
    NSXMLElement *propertiesElement = [[tileElement elementsForName: @"properties"] firstObject];
    NSMutableString *name = [NSMutableString new];
    for(NSXMLElement *propertyElement in [propertiesElement children]) {
      NSString *prop = [[propertyElement attributeForName: @"name"] stringValue];
      if([prop isEqual: @"type"]) {
        continue;
      }
      NSString *value = [[propertyElement attributeForName: @"value"] stringValue];
      if([value isEqual: @""]) {
        continue;
      }
      if(![name isEqual: @""]) {
        [name appendString: @"_"];
      }
      [name appendString: value];
    }
    if([name isEqual: @""]) {
      // Omit sprites without a name.
      continue;
    }
    NSDictionary<NSString *, NSString *> *attributes = @{
      @"name": [name lowercaseString],
      @"x": [@(x) stringValue],
      @"y": [@(y) stringValue],
    };
    [spriteElement setAttributesWithDictionary: attributes];
    [spritesElement addChild: spriteElement];
  }

  NSXMLDocument *spriteSheetDoc = [[NSXMLDocument alloc] init];
  NSXMLElement *rootElement = [NSXMLElement elementWithName: @"spritesheet"];
  [spriteSheetDoc setRootElement: rootElement];
  NSXMLElement *nameElement = [NSXMLElement elementWithName: @"name" stringValue: name];
  [rootElement addChild: nameElement];
  [rootElement addChild: [NSXMLElement elementWithName: @"width" stringValue: [@(imageWidth) stringValue]]];
  [rootElement addChild: [NSXMLElement elementWithName: @"height" stringValue: [@(imageHeight) stringValue]]];
  [rootElement addChild: spriteSize(tileWidth, tileHeight)];
  [rootElement addChild: [NSXMLElement elementWithName: @"xoffset" stringValue: [@(spacing) stringValue]]];
  [rootElement addChild: [NSXMLElement elementWithName: @"yoffset" stringValue: [@(spacing) stringValue]]];
  [rootElement addChild: [NSXMLElement elementWithName: @"xbuffer" stringValue: [@(margin) stringValue]]];
  [rootElement addChild: [NSXMLElement elementWithName: @"ybuffer" stringValue: [@(margin) stringValue]]];

  [rootElement addChild: spritesElement];


  NSData *xmlData = [spriteSheetDoc XMLDataWithOptions: NSXMLNodePrettyPrint];
  [xmlData writeToFile: _destFile atomically: NO];
}

@end
