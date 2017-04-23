//
//  ScannerController.h
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
@import UIKit;
#import "MayISBN.h"

#define kMayBarCodeScannerErrorDomain                  @"MayLibreBarCodeScannerErrorDomain"

typedef NS_ENUM(NSUInteger, MayBarCodeScannerErrorNumber) {
    MayBarCodeScannerErrorOk = 0,
    MayBarCodeScannerBarCodeType
};

typedef NS_ENUM(NSInteger, MayBarCodeScannerSetupResult) {
    MayBarCodeScannerSetupResultSuccess,
    MayBarCodeScannerSetupResultCameraNotAuthorized,
    MayBarCodeScannerSetupResultSessionConfigurationFailed
};

@protocol MayBarCodeScannerDelegate;

@interface MayBarCodeScannerController : UIViewController

@property (nonatomic, weak) id<MayBarCodeScannerDelegate> delegate;

- (void)startScanning;
- (void)stopScanning;

@end

@protocol MayBarCodeScannerDelegate <NSObject>

@optional

- (void)barCodeScannerControllerDidStartScanning:(MayBarCodeScannerController *)controller;
- (void)barCodeScannerControllerDidStopScanning:(MayBarCodeScannerController *)controller;
- (void)barCodeScannerController:(MayBarCodeScannerController *)controller
                  didCaptureISBN:(MayISBN *)isbn;

@end
