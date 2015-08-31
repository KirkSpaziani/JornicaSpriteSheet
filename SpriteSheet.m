//
//  $Id: main.m 3178 2015-08-31 00:51:01Z kirk $
//  SpriteSheet
//
//  Created by Kirk Spaziani on 8/30/15.
//  Copyright (c) 2015 Spazcosoft, LLC. All rights reserved.
//
#import<Foundation/Foundation.h>
@import AppKit;


NSXMLElement *spriteSize(NSInteger width, NSInteger height) {
	NSXMLElement *spriteSizeElement = [NSXMLElement elementWithName: @"spritesize"];
	NSXMLElement *widthElement = [NSXMLElement elementWithName: @"width" stringValue: [@(width) stringValue]];
	NSXMLElement *heightElement = [NSXMLElement elementWithName: @"height" stringValue: [@(height) stringValue]];
	
	[spriteSizeElement addChild: widthElement];
	[spriteSizeElement addChild: heightElement];
	
	return spriteSizeElement;
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];
		
		NSString *imagePath = [arguments stringForKey: @"imagePath"];
		NSString *sheetName = [arguments stringForKey: @"sheetName"];
		NSInteger sheetWidth = [[arguments stringForKey: @"sheetWidth"] integerValue];
		NSInteger sheetHeight = [[arguments stringForKey: @"sheetHeight"] integerValue];
		NSInteger spriteWidth = [[arguments stringForKey: @"spriteWidth"] integerValue];
		NSInteger spriteHeight = [[arguments stringForKey: @"spriteHeight"] integerValue];
		
		if(imagePath == nil || sheetName == nil || sheetWidth == 0 || sheetHeight == 0 || spriteWidth == 0 || spriteHeight == 0) {
			printf("SpriteSheet -imagePath path -sheetName name -sheetWidth width -sheetHeight height -spriteWidth width -spriteHeight height\n");
			return -1;
		}
		
		NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: NULL
																			 pixelsWide: sheetWidth
																			 pixelsHigh: sheetHeight
																		  bitsPerSample: 8
																		samplesPerPixel: 4
																			   hasAlpha: YES
																			   isPlanar: NO
																		 colorSpaceName: NSDeviceRGBColorSpace
																		   bitmapFormat: NSAlphaFirstBitmapFormat
																			bytesPerRow: sheetWidth * 4
																		   bitsPerPixel: 32];
		
		NSXMLDocument *spriteSheetDoc = [[NSXMLDocument alloc] init];
		NSXMLElement *rootElement = [NSXMLElement elementWithName: @"spritesheet"];
		[spriteSheetDoc setRootElement: rootElement];
		NSXMLElement *nameElement = [NSXMLElement elementWithName: @"name" stringValue: sheetName];
		[rootElement addChild: nameElement];
		[rootElement addChild: [NSXMLElement elementWithName: @"width" stringValue: [@(sheetWidth) stringValue]]];
		[rootElement addChild: [NSXMLElement elementWithName: @"height" stringValue: [@(sheetHeight) stringValue]]];
		[rootElement addChild: spriteSize(spriteWidth, spriteHeight)];
		NSXMLElement *spritesElement = [NSXMLElement elementWithName: @"sprites"];
		[rootElement addChild: spritesElement];
		
		NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithBitmapImageRep: imageRep];
		
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext: graphicsContext];
		
		NSFileManager *files = [NSFileManager defaultManager];
		NSArray *images = [files contentsOfDirectoryAtPath: imagePath error: nil];

		NSInteger spritesPerRow = sheetWidth / spriteWidth;
		[images enumerateObjectsUsingBlock: ^(NSString *imageName, NSUInteger idx, BOOL *stop) {
			NSInteger x = idx % spritesPerRow;
			NSInteger y = idx / spritesPerRow;

			// Process Image
			NSString *fullPath = [NSString pathWithComponents: @[ imagePath, imageName] ];
			NSImage *sprite = [[NSImage alloc] initWithContentsOfFile: fullPath];
			[sprite drawInRect: NSMakeRect(x * spriteWidth, y * spriteHeight, spriteWidth, spriteHeight)];
			
			// Update XML
			NSXMLElement *spriteElement = [NSXMLElement elementWithName: @"sprite"];
			[spriteElement setAttributesWithDictionary: @{ @"name" : [imageName stringByDeletingPathExtension],
														   @"x" : [@(x) stringValue],
														   @"y" : [@(y) stringValue]}];
			[spritesElement addChild: spriteElement];
		}];
		
		NSData *pngData = [imageRep representationUsingType: NSPNGFileType properties: nil];
		[pngData writeToFile: [NSString stringWithFormat: @"%@.png", sheetName] atomically: NO];
		
		NSData *xmlData = [spriteSheetDoc XMLDataWithOptions: NSXMLNodePrettyPrint];
		[xmlData writeToFile: [NSString stringWithFormat: @"%@.xml", sheetName] atomically: NO];
			 
		[NSGraphicsContext restoreGraphicsState];
	}
	
    return 0;
}
