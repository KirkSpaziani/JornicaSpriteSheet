//
//  main.m
//  SpriteSheet
//
//  Created by Kirk Spaziani on 8/30/15.
//  Copyright (c) 2015 Spazcosoft, LLC. All rights reserved.
//
#import<Foundation/Foundation.h>
@import AppKit;

#import"JSSCombiner.h"
#import"JSSSplitter.h"
#import"JSSConverter.h"
#import"JSSXMLConverter.h"
#import"JSSMooseWriter.h"

void printCommands() {
  // Make a SpriteSheet from a bunch of images.
  printf("SpriteSheet -mode combine -imagePath path -sheetName name -sheetWidth width -sheetHeight height -spriteWidth width -spriteHeight height\n");
  // Color Conversions (Useful to batch update images for Moosestation 256 format).
  printf("SpriteSheet -mode convert -imagePath path -destPath dest -conversions conversionsNumber\n");
  printf("SpriteSheet -mode split TODO\n");
  // Converts a definition file from a tsx file to JornicaSpriteSheet format.
  printf("SpriteSheet -mode convertxml -sourceFile sourceFile.tsx -destFile destFile.xml");
  // Creates a Swift file from a JornicaSpriteSheet formatted xml file for strongly typed sprites.
  printf("SpriteSheet -mode moosewriter -sourceFile sourceFile.xml -destFile destFile.swift");
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];

    NSString *mode = [arguments stringForKey: @"mode"];
    if([mode isEqual: @"convert"]) {
      NSString *sourcePath = [arguments stringForKey: @"imagePath"];
      NSString *destPath = [arguments stringForKey: @"destPath"];
      JSSConversionOptions options = [[arguments stringForKey: @"conversions"] integerValue];
      if(sourcePath == nil || destPath == nil) {
        printCommands();
        return -1;
      }
      JSSConverter *converter =
          [[JSSConverter alloc] initWithConversions: options
                                         sourcePath: sourcePath
                                           destPath: destPath];
      [converter convert];
      return 0;
    } else if ([mode isEqual: @"split"]) {
      printCommands();
      return -1;
    } else if([mode isEqual: @"convertxml"]) {
      NSString *sourceFile = [arguments stringForKey: @"sourceFile"];
      NSString *destFile = [arguments stringForKey: @"destFile"];
      if(sourceFile == nil || destFile == nil) {
        printCommands();
        return -1;
      }
      JSSXMLConverter *converter =
          [[JSSXMLConverter alloc] initWithSourceFile: sourceFile destFile: destFile];
      [converter convert];
      return 0;
    } else if([mode isEqual: @"moosewriter"]) {
      NSString *sourceFile = [arguments stringForKey: @"sourceFile"];
      NSString *destFile = [arguments stringForKey: @"destFile"];
      if(sourceFile == nil || destFile == nil) {
        printCommands();
        return -1;
      }
      JSSMooseWriter *writer =
          [[JSSMooseWriter alloc] initWithSourceFile: sourceFile destFile: destFile];
      [writer write];
      return 0;
    } else if(mode == nil || [mode isEqual: @"combine"]) {
      NSString *imagePath = [arguments stringForKey: @"imagePath"];
      NSString *sheetName = [arguments stringForKey: @"sheetName"];
      NSInteger sheetWidth = [[arguments stringForKey: @"sheetWidth"] integerValue];
      NSInteger sheetHeight = [[arguments stringForKey: @"sheetHeight"] integerValue];
      NSInteger spriteWidth = [[arguments stringForKey: @"spriteWidth"] integerValue];
      NSInteger spriteHeight = [[arguments stringForKey: @"spriteHeight"] integerValue];
      if(imagePath == nil || sheetName == nil || sheetWidth == 0 || sheetHeight == 0 || spriteWidth == 0 || spriteHeight == 0) {
        printCommands();
        return -1;
      }
      JSSCombiner *combiner =
          [[JSSCombiner alloc] initWithImagePath: imagePath
                                       sheetName: sheetName
                                      sheetWidth: sheetWidth
                                     sheetHeight: sheetHeight
                                     spriteWidth: spriteWidth
                                    spriteHeight: spriteHeight];
      [combiner combine];
      return 0;
    }

  }
  printCommands();
  return -1;
}
