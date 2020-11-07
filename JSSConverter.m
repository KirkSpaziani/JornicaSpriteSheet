//
//  JSSConverter.m
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/27/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import "JSSConverter.h"
@import AppKit;

typedef NS_ENUM(NSUInteger, JSSPixelType) {
  JSSPixelTypeBlack,
  JSSPixelTypeWhite,
  JSSPixelTypeClear,
  JSSPixelTypeRed,
  JSSPixelTypeGreen,
  JSSPixelTypeBlue,
  JSSPixelTypeMagenta,
};

typedef struct pixel_t {
  Byte r;
  Byte g;
  Byte b;
  Byte a;
} Pixel;

static const Pixel kBlackPixel = { 0, 0, 0, 255 };
static const Pixel kWhitePixel = { 255, 255, 255, 255 };
static const Pixel kClearPixel = { 0, 0, 0, 0 };
static const Pixel kRedPixel = { 255, 0, 0, 255 };
static const Pixel kGreenPixel = { 0, 255, 0, 255 };
static const Pixel kBluePixel = { 0, 0, 255, 255 };
static const Pixel kMagentaPixel = { 255, 0, 255, 255 };

@implementation JSSConverter {
  NSString *_sourcePath;
  NSString *_destPath;
  JSSConversionOptions _conversions;
}

-(instancetype)initWithConversions:(JSSConversionOptions)conversions
                        sourcePath:(NSString *)sourcePath
                          destPath:(NSString *)destPath {
  if(self = [super init]) {
    _sourcePath = sourcePath;
    _destPath = destPath;
    _conversions = conversions;
  }

  return self;
}

-(void)convert {
  NSImage *sprite = [[NSImage alloc] initWithContentsOfFile: _sourcePath];
  NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[sprite TIFFRepresentation]];
  Pixel *pixels = (Pixel *)[imageRep bitmapData];
  NSUInteger pixelCount = (imageRep.pixelsWide * imageRep.pixelsHigh);
  for(NSUInteger i = 0; i < pixelCount; ++i) {
    Pixel pixel = pixels[i];
    pixel = [self transform: pixel];
    pixels[i] = pixel;
  }
  NSData *pngData = [imageRep representationUsingType: NSPNGFileType properties: @{}];
  [pngData writeToFile: _destPath atomically: NO];
}

-(JSSPixelType)pixelType:(Pixel)pixel {
  if(pixel.a < 128) {
    return JSSPixelTypeClear;
  }
  if(pixel.r > 127 && pixel.g > 127 && pixel.b > 127) {
    return JSSPixelTypeWhite;
  }
  if(pixel.r > 127 && pixel.b > 127) {
    return JSSPixelTypeMagenta;
  }
  if(pixel.r > 127) {
    return JSSPixelTypeRed;
  }
  if(pixel.g > 127) {
    return JSSPixelTypeGreen;
  }
  if(pixel.b > 127) {
    return JSSPixelTypeBlue;
  }
  return JSSPixelTypeBlack;
}

-(Pixel)transform:(Pixel)pixel {
  // Analyze the pixel, get the overall quality of it.
  JSSPixelType pixelType = [self pixelType: pixel];
  switch (pixelType) {
  case JSSPixelTypeRed:
    return kRedPixel;
  case JSSPixelTypeGreen:
    return kGreenPixel;
  case JSSPixelTypeBlue:
    return kBluePixel;
  case JSSPixelTypeWhite:
    if(_conversions & JSSConversionOptionsWhiteToRed) {
      return kRedPixel;
    }
    return kWhitePixel;
  case JSSPixelTypeClear:
    if(_conversions & JSSConversionOptionsAlphaToMagenta) {
      return kMagentaPixel;
    }
    return kClearPixel;
  case JSSPixelTypeBlack:
    if(_conversions & JSSConversionOptionsBlackToAlpha) {
      return kClearPixel;
    }
    return kBlackPixel;
  case JSSPixelTypeMagenta:
    return kMagentaPixel;
  }
}

@end
