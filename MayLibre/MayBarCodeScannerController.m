//
//  ScannerController.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import AVFoundation;

#import "MayBarCodeScannerController.h"

@interface MayBarCodeScannerController () <
    AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *highlightView;

@end

@implementation MayBarCodeScannerController

#pragma mark UIViewController Delegates

- (void)viewDidLoad {
    
    [super viewDidLoad];

    NSError *error = nil;
    [self initScanner:&error];
    
    if (error != nil) {
        // handle Error
        NSLog(@"%@", error.userInfo);
    }
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark Helper

- (void)initScanner:(NSError **)error {
    
    _highlightView = [UIView new];
    _highlightView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    
    [self.view addSubview:_highlightView];
    
    _session = [AVCaptureSession new];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device
                                                         error:error];

    if (_deviceInput == nil) {

        return;
    }

    [_session addInput:_deviceInput];
    _metadataOutput = [AVCaptureMetadataOutput new];
    
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:dispatch_get_main_queue()];
    [_session addOutput:_metadataOutput];

    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;

    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = self.view.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];

    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
}

#pragma mark Delegates

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeEAN13Code];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {

                barCodeObject =
                (AVMetadataMachineReadableCodeObject *)
                [_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                
                break;
            }
        }
        
        if (detectionString != nil) {
            [_session stopRunning];
            [self captureBarCode:detectionString];
            break;
        }
    }
    
    _highlightView.frame = highlightViewRect;
}

- (void)captureBarCode:(NSString *)barCode {

    void (^applyActionHandler)() = ^{
        if ([self.delegate respondsToSelector:@selector(barCodeScannerController:didCaptureBarCode:)]) {
            
            [self.delegate barCodeScannerController:self
                                  didCaptureBarCode:barCode];
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    void (^cancelActionHandler)() = ^{
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    void (^retryActionHandler)() = ^{
        [_session startRunning];
    };
    
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BarCode Found", nil)
                                                      message:barCode
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *applyAction;
    applyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Apply", nil)
                                           style:UIAlertActionStyleDefault
                                         handler:applyActionHandler];

    UIAlertAction *retryAction;
    retryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil)
                                           style:UIAlertActionStyleDefault
                                         handler:retryActionHandler];
    UIAlertAction *cancelAction;
    cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                            style:UIAlertActionStyleDestructive
                                          handler:cancelActionHandler];
    [actionSheet addAction:applyAction];
    [actionSheet addAction:retryAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
