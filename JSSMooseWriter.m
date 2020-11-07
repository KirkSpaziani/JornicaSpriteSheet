//
//  JSSMooseWriter.m
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/28/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import "JSSMooseWriter.h"
@import AppKit;

#import "JSSUtils.h"

@implementation JSSMooseWriter {
  NSString *_sourceFile;
  NSString *_destFile;
  NSString *_spriteSheet;
}

-(instancetype)initWithSourceFile:(NSString *)sourceFile destFile:(NSString *)destFile {
  if(self = [super init]) {
    _sourceFile = [sourceFile copy];
    _destFile = [destFile copy];
  }

  return self;
}

-(void)write {
  // Analyze the XML file and write a swift file.
  NSURL *url = [NSURL fileURLWithPath: _sourceFile];
  NSXMLDocument *sourceDoc =
      [[NSXMLDocument alloc] initWithContentsOfURL: url options: NSXMLNodeOptionsNone error:nil];
  NSXMLElement *root = [sourceDoc rootElement];
  NSString *name = [[[root elementsForName: @"name"] firstObject] stringValue];
  _spriteSheet = [name copy];
  name = humpify(name);
  NSArray<NSXMLElement *> *sprites =
      [[[root elementsForName: @"sprites"] firstObject] elementsForName:@"sprite"];
  NSMutableDictionary *structure = [NSMutableDictionary dictionary];
  for(NSXMLElement *sprite in sprites) {
    NSMutableDictionary *current = structure;
    NSString *spriteName = [[sprite attributeForName: @"name"] stringValue];
    NSArray<NSString *> *components = [spriteName componentsSeparatedByString: @"_"];
    while([components count] != 1) {
      NSString *component = [components objectAtIndex: 0];
      NSString *capitalizedComponent = capitalize(component);
      components = [components subarrayWithRange: NSMakeRange(1, [components count] - 1)];
      NSMutableDictionary *d = [current objectForKey: capitalizedComponent];
      if(d == nil) {
        d = [NSMutableDictionary dictionary];
        [current setObject: d forKey:capitalizedComponent];
      }
      current = d;
    }
    [current setObject: [components firstObject] forKey: [components firstObject]];
  }

  // ssWhateverClass -> WhateverClass
  NSString *namespace = [name substringFromIndex: 2];

  NSMutableString *swiftFile = [NSMutableString string];
  [swiftFile appendString: @"import Foundation\n"];
  [swiftFile appendString: @"import Mootaurus\n\n"];

  [swiftFile appendFormat: @"public enum %@ {\n\n", namespace];
  [swiftFile appendString: [self swiftStringFor: structure fullName: @"" indent: 1]];
  [swiftFile appendString: @"}\n"];
  NSData *file = [swiftFile dataUsingEncoding: NSUTF8StringEncoding];
  [file writeToFile: _destFile atomically:NO];
}

-(NSString *)swiftStringFor:(id)value fullName:(NSString *)fullName indent:(NSInteger)indent {
  NSMutableString *swiftString = [NSMutableString string];
  if([value isKindOfClass: [NSString class]]) {
    // Termination case.
    NSString *spriteName = (NSString *)value;
    fullName = [fullName stringByAppendingFormat: @"_%@", value];

    if([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: [spriteName characterAtIndex:0]]) {
      spriteName = [NSString stringWithFormat: @"t%@", spriteName];
    }
    for(NSUInteger i = 0; i < indent; ++i) {
      [swiftString appendString:@"  "];
    }
    [swiftString appendFormat: @"public static var %@: Texture {\n", spriteName];
    for(NSUInteger i = 0; i < indent + 1; ++i) {
      [swiftString appendString:@"  "];
    }
    [swiftString appendFormat:
     @"return Moot.m.textureService.texture(named: \"%@\", fromSpriteSheet: \"%@\")\n",
     [[fullName substringFromIndex: 1] lowercaseString],
     _spriteSheet];
    for(NSUInteger i = 0; i < indent; ++i) {
      [swiftString appendString:@"  "];
    }
    [swiftString appendString: @"}\n\n"];
  } else {
    NSDictionary *dict = (NSDictionary *)value;
    for(NSString *key in [dict allKeys]) {
      if([[dict objectForKey: key] isKindOfClass: [NSString class]]) {
        [swiftString appendString: [self swiftStringFor: [dict objectForKey: key]
                                               fullName: fullName
                                                 indent: indent]];
      } else {
        for(NSUInteger i = 0; i < indent; ++i) {
          [swiftString appendString:@"  "];
        }
        NSString *enumName = key;
        if([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: [enumName characterAtIndex:0]]) {
          enumName = [NSString stringWithFormat: @"t%@", enumName];
        }
        [swiftString appendFormat: @"public enum %@ {\n\n", capitalize(enumName)];
        [swiftString appendString: [self swiftStringFor: [dict objectForKey: key]
                                               fullName: [fullName stringByAppendingFormat: @"_%@", key]
                                                 indent: indent + 1]];
        for(NSUInteger i = 0; i < indent; ++i) {
          [swiftString appendString:@"  "];
        }
        [swiftString appendString: @"}\n\n"];
      }
    }
  }

  return swiftString;
}

@end
