//
//  ScannerController.h
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
@import UIKit;

@protocol MayBarCodeScannerDelegate;

@interface MayBarCodeScannerController : UIViewController

@property (nonatomic, weak) id<MayBarCodeScannerDelegate> delegate;

@end

@protocol MayBarCodeScannerDelegate <NSObject>

@optional

- (void)barCodeScannerController:(MayBarCodeScannerController *)controller
               didCaptureBarCode:(NSString *)barCode;

@end
