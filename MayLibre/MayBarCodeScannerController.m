//
//  ScannerController.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import AVFoundation;

#import "MayBarCodeScannerController.h"
#import "MayISBN.h"
#import "MayISBNFormatter.h"

@interface MayBarCodeScannerController () <
    AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, strong) UIView *consoleView;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation MayBarCodeScannerController

#pragma mark UIViewController Delegates

- (void)viewDidLoad {

    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    [super viewDidLoad];

    NSError *error = nil;
    [self initScanner:&error];
    
    if (error != nil) {
        // handle Error
        NSLog(@"%@", error.userInfo);
    }
    else {
        [self startScanning];
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

    _consoleView = UIView.new;
    _consoleView.translatesAutoresizingMaskIntoConstraints = NO;
    _consoleView.backgroundColor = UIColor.blackColor;
    _consoleView.alpha = 0.5;

    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelButton.contentMode = UIViewContentModeScaleAspectFit;
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil)
                   forState:UIControlStateNormal];
    [_cancelButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    [_cancelButton addTarget:self
                      action:@selector(didCancelTouchUpInside:)
            forControlEvents:UIControlEventTouchUpInside];
    [_consoleView addSubview:_cancelButton];
    [self.view addSubview:_consoleView];
    [self.view bringSubviewToFront:_highlightView];
    
    // Autolayout
    NSDictionary *viewsDictionary = @{@"consoleView":self.consoleView,
                                      @"cancelButton":self.cancelButton};
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[consoleView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[consoleView(66)]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [_cancelButton.heightAnchor constraintEqualToConstant:44.0].active = YES;
    [_cancelButton.centerXAnchor constraintEqualToAnchor:_consoleView.centerXAnchor].active = YES;
    [_cancelButton.centerYAnchor constraintEqualToAnchor:_consoleView.centerYAnchor].active = YES;
}

- (void)startScanning {
    
    [_session startRunning];

    if ([self.delegate respondsToSelector:@selector(barCodeScannerControllerDidStartScanning:)]) {
        [self.delegate barCodeScannerControllerDidStartScanning:self];
    }
}

- (void)stopScanning {
    
    [_session stopRunning];

    if ([self.delegate respondsToSelector:@selector(barCodeScannerControllerDidStopScanning:)]) {
        [self.delegate barCodeScannerControllerDidStopScanning:self];
    }
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
            [self stopScanning];
            [self captureBarCode:detectionString];
            break;
        }
    }
    
    _highlightView.frame = highlightViewRect;
}

- (void)captureBarCode:(NSString *)barCode {

    NSError *error = nil;
    MayISBN *isbn = [MayISBN ISBNFromString:barCode
                                      error:&error];
    __weak typeof(self)weakSelf = self;
    
    void (^applyActionHandler)() = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(barCodeScannerController:didCaptureISBN:)]) {
            
            [weakSelf.delegate barCodeScannerController:self
                                         didCaptureISBN:isbn];
        }
        [weakSelf dismissViewControllerAnimated:YES
                                     completion:nil];
    };
    
    void (^cancelActionHandler)() = ^{
        [weakSelf dismissViewControllerAnimated:YES
                                     completion:nil];
    };
    
    void (^retryActionHandler)() = ^{
        [weakSelf startScanning];
    };
    
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
    UIAlertController *actionSheet;

    if (error != nil) {
        
        NSLog(@"%@", error.localizedDescription);
        
        // Action Sheet negative
        actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No valid ISBN", nil)
                                                          message:barCode
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:retryAction];
        [actionSheet addAction:cancelAction];
    }
    else {
        // Action Sheet positive
        actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ISBN Found", nil)
                                                          message:[MayISBNFormatter stringFromISBN:isbn]
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:applyAction];
        [actionSheet addAction:retryAction];
        [actionSheet addAction:cancelAction];
    }

    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

#pragma mark Actions

- (void)didCancelTouchUpInside:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}
@end
