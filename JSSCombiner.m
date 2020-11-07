//
//  JSSCombiner.m
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/27/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import "JSSCombiner.h"
@import AppKit;

#import "JSSUtils.h"

@implementation JSSCombiner {
  NSString *_imagePath;
  NSString *_sheetName;
  NSInteger _sheetWidth;
  NSInteger _sheetHeight;
  NSInteger _spriteHeight;
  NSInteger _spriteWidth;
}

-(instancetype)initWithImagePath:(NSString *)imagePath
                       sheetName:(NSString *)sheetName
                      sheetWidth:(NSInteger)sheetWidth
                     sheetHeight:(NSInteger)sheetHeight
                     spriteWidth:(NSInteger)spriteWidth
                    spriteHeight:(NSInteger)spriteHeight {
  if(self = [super init]) {
    _imagePath = [imagePath copy];
    _sheetName = [sheetName copy];
    _sheetWidth = sheetWidth;
    _sheetHeight = sheetHeight;
    _spriteHeight = spriteHeight;
    _spriteWidth = spriteWidth;
  }

  return self;
}

-(void)combine {
  NSBitmapImageRep *imageRep =
      [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: NULL
                                              pixelsWide: _sheetWidth
                                              pixelsHigh: _sheetHeight
                                           bitsPerSample: 8
                                         samplesPerPixel: 4
                                                hasAlpha: YES
                                                isPlanar: NO
                                          colorSpaceName: NSDeviceRGBColorSpace
                                            bitmapFormat: NSAlphaFirstBitmapFormat
                                             bytesPerRow: _sheetWidth * 4
                                            bitsPerPixel: 32];

  NSXMLDocument *spriteSheetDoc = [[NSXMLDocument alloc] init];
  NSXMLElement *rootElement = [NSXMLElement elementWithName: @"spritesheet"];
  [spriteSheetDoc setRootElement: rootElement];
  NSXMLElement *nameElement = [NSXMLElement elementWithName: @"name" stringValue: _sheetName];
  [rootElement addChild: nameElement];
  [rootElement addChild: [NSXMLElement elementWithName: @"width" stringValue: [@(_sheetWidth) stringValue]]];
  [rootElement addChild: [NSXMLElement elementWithName: @"height" stringValue: [@(_sheetHeight) stringValue]]];
  [rootElement addChild: spriteSize(_spriteWidth, _spriteHeight)];
  NSXMLElement *spritesElement = [NSXMLElement elementWithName: @"sprites"];
  [rootElement addChild: spritesElement];

  NSGraphicsContext *graphicsContext =
      [NSGraphicsContext graphicsContextWithBitmapImageRep: imageRep];

  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext: graphicsContext];

  NSFileManager *files = [NSFileManager defaultManager];
  NSMutableArray *images = [NSMutableArray array];
  for(NSString *file in [files contentsOfDirectoryAtPath: _imagePath error: nil]) {
    if(![[file lowercaseString] containsString: @".png"]) {
      continue;
    }
    [images addObject: file];
  }

  NSInteger spritesPerRow = _sheetWidth / _spriteWidth;
  [images enumerateObjectsUsingBlock: ^(NSString *imageName, NSUInteger idx, BOOL *stop) {
    NSInteger x = idx % spritesPerRow;
    NSInteger y = idx / spritesPerRow;

    // Process Image
    NSString *fullPath = [NSString pathWithComponents: @[_imagePath, imageName] ];
    NSImage *sprite = [[NSImage alloc] initWithContentsOfFile: fullPath];
    [sprite drawInRect: NSMakeRect(x * _spriteWidth, y * _spriteHeight, _spriteWidth, _spriteHeight)];

    // Update XML
    NSXMLElement *spriteElement = [NSXMLElement elementWithName: @"sprite"];
    [spriteElement setAttributesWithDictionary: @{
      @"name" : [imageName stringByDeletingPathExtension],
      @"x" : [@(x) stringValue],
      @"y" : [@(y) stringValue]}
     ];
    [spritesElement addChild: spriteElement];
  }];

  NSData *pngData = [imageRep representationUsingType: NSPNGFileType properties: @{}];
  [pngData writeToFile: [NSString stringWithFormat: @"%@.png", _sheetName] atomically: NO];

  NSData *xmlData = [spriteSheetDoc XMLDataWithOptions: NSXMLNodePrettyPrint];
  [xmlData writeToFile: [NSString stringWithFormat: @"%@.xml", _sheetName] atomically: NO];

  [NSGraphicsContext restoreGraphicsState];
}

@end
