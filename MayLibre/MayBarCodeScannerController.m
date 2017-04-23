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
@property (nonatomic, strong) id subjectAreaDidChangeObserver;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) MayBarCodeScannerSetupResult setupResult;


- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer *)sender;

@end

@implementation MayBarCodeScannerController

#pragma mark UIViewController Delegates

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.navigationController setToolbarHidden:YES
                                       animated:YES];
    // Create Session Queue
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);

    // Create the AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];

    [self initPreviewLayer];
    
    // Handle Authorization
    [self authorizeCamara];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    dispatch_async(self.sessionQueue, ^{

        switch (self.setupResult) {
                
            case MayBarCodeScannerSetupResultSuccess:
            {
                [self startScanning];
                break;
            }

            case MayBarCodeScannerSetupResultCameraNotAuthorized:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *message
                    = NSLocalizedString(@"MayLibre doesn't have permission to use the camera, please change privacy settings",
                                        @"Alert message when the user has denied access to the camera");
                    
                    UIAlertController *alertController
                    = [UIAlertController alertControllerWithTitle:@"MayLibre"
                                                          message:message
                                                   preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction
                    = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",
                                                                       @"Alert OK button")
                                               style:UIAlertActionStyleCancel
                                             handler:nil];
                    
                    [alertController addAction:cancelAction];
                    
                    // Provide quick access to Settings
                    UIAlertAction *settingsAction
                    = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings",
                                                                       @"Alert button to open Settings")
                                               style:UIAlertActionStyleDefault
                                             handler:^( UIAlertAction *action ) {
                                                 
                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                             }];
                    
                    [alertController addAction:settingsAction];
                    
                    [self presentViewController:alertController
                                       animated:YES
                                     completion:nil];
                });
                break;
            }
                
            case MayBarCodeScannerSetupResultSessionConfigurationFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
            
                    NSString *message
                    = NSLocalizedString(@"Unable to capture bar codes",
                                        @"Alert message when something goes wrong during capture session configuration");
                    
                    UIAlertController *alertController
                    = [UIAlertController alertControllerWithTitle:@"MayLibre"
                                                          message:message
                                                   preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction
                    = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",
                                                                       @"Alert OK button")
                                               style:UIAlertActionStyleCancel
                                             handler:nil];
                    
                    [alertController addAction:cancelAction];
                    
                    [self presentViewController:alertController
                                       animated:YES
                                     completion:nil];
                });
                break;
            }
        }
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    
    dispatch_async(self.sessionQueue, ^{
        if (self.setupResult == MayBarCodeScannerSetupResultSuccess) {
            [self stopScanning];
        }
    });
    
    [super viewDidDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark Authorization

- (void)authorizeCamara {

    self.setupResult = MayBarCodeScannerSetupResultSuccess;

    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        
            // The user has previously granted access to the camera
        case AVAuthorizationStatusAuthorized:
        {
            break;
        }

        // The user has not yet been presented with the option to grant video access.
        // We suspend the session queue to delay session running until the access request has completed.
        case AVAuthorizationStatusNotDetermined:
        {
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         if (!granted) {
                                             self.setupResult = MayBarCodeScannerSetupResultCameraNotAuthorized;
                                         }
                                         dispatch_resume( self.sessionQueue );
                                     }];
            break;
        }
            
        default:
        {
            // The user has previously denied access
            self.setupResult = MayBarCodeScannerSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

// Should be called on the session queue
- (void)configureSession {

    if (self.setupResult != MayBarCodeScannerSetupResultSuccess) {
    
        return;
    }

    [self.session beginConfiguration];
    
    // Create a default video device
    AVCaptureDevice *videoDevice
    = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                         mediaType:AVMediaTypeVideo
                                          position:AVCaptureDevicePositionUnspecified];
    NSError *error = nil;

    // Create a input device
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                   error:&error];
    if (error != nil) {
        NSLog( @"Could not create video device input: %@", error );
        self.setupResult = MayBarCodeScannerSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        
        return;
    }

    
    if ([self.session canAddInput:videoDeviceInput]) {
    
        // Adds input device to video session
        [self.session addInput:videoDeviceInput];

        if (self.device.autoFocusRangeRestrictionSupported) {
            if ([self.device lockForConfiguration:nil]) {
                self.device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
                [self.device unlockForConfiguration];
            }
        }
        
        self.deviceInput = videoDeviceInput;
        self.device = videoDevice;
        
        /*
         Why are we dispatching this to the main queue?
         Because AVCaptureVideoPreviewLayer is the backing layer for AVCamManualPreviewView and UIView
         can only be manipulated on the main thread.
         Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
         on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
         
         Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
         handled by -[AVCamManualCameraViewController viewWillTransitionToSize:withTransitionCoordinator:].
         */
        dispatch_async(dispatch_get_main_queue(), ^{

            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;

            // Orientation is relevant for iPads where supported
            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewLayer;
            previewLayer.connection.videoOrientation = initialVideoOrientation;
        });
        
        // configure session with metadata output
        _metadataOutput = [AVCaptureMetadataOutput new];
        [_metadataOutput setMetadataObjectsDelegate:self
                                              queue:dispatch_get_main_queue()];
        [_session addOutput:_metadataOutput];
        
        if ([_metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code];
        }
    }
    else {
        NSLog( @"Could not add video device input to the session" );
        self.setupResult = MayBarCodeScannerSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];

        return;
    }
    
    [self.session commitConfiguration];
}


#pragma mark Helper


- (void)initPreviewLayer {
    
    self.highlightView = [UIView new];
    self.highlightView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    self.highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.highlightView.layer.borderWidth = 3;
    
    [self.view addSubview:self.highlightView];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:self.previewLayer];
    
    self.consoleView = UIView.new;
    self.consoleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.consoleView.backgroundColor = UIColor.blackColor;
    self.consoleView.alpha = 0.5;
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Camera Cancel button")
                       forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:UIColor.whiteColor
                            forState:UIControlStateNormal];
    [self.cancelButton addTarget:self
                          action:@selector(didCancelTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.consoleView addSubview:self.cancelButton];
    [self.view addSubview:self.consoleView];
    [self.view bringSubviewToFront:self.highlightView];
    
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
    
    [self.cancelButton.heightAnchor constraintEqualToConstant:44.0].active = YES;
    [self.cancelButton.centerXAnchor constraintEqualToAnchor:self.consoleView.centerXAnchor].active = YES;
    [self.cancelButton.centerYAnchor constraintEqualToAnchor:self.consoleView.centerYAnchor].active = YES;
}

- (void)startScanning {
    
    self.highlightView.frame = CGRectZero;

    if (self.device.autoFocusRangeRestrictionSupported) {
        if ([self.device lockForConfiguration:nil]) {
            self.device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
            [self.device unlockForConfiguration];
        }
    }
    
    [self.session startRunning];

    if ([self.delegate respondsToSelector:@selector(barCodeScannerControllerDidStartScanning:)]) {
        [self.delegate barCodeScannerControllerDidStartScanning:self];
    }
}

- (void)stopScanning {
    
    [self.session stopRunning];

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
                [self.previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                
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
    
    UIAlertAction *applyAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Apply", @"Barcode Apply action")
                             style:UIAlertActionStyleDefault
                           handler:applyActionHandler];

    UIAlertAction *retryAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", @"Barcode Retry action")
                             style:UIAlertActionStyleDefault
                           handler:retryActionHandler];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Barcode Cancel action")
                             style:UIAlertActionStyleDestructive
                           handler:cancelActionHandler];
    
    UIAlertController *actionSheet;

    if (error != nil) {
        
        NSLog(@"%@", error.localizedDescription);
        
        // Action Sheet negative
        actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(
                                                                                    @"No valid ISBN",
                                                                                    @"Alert message when scanned ISBN is not valid")
                                                          message:barCode
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:retryAction];
        [actionSheet addAction:cancelAction];
    }
    else {
        // Action Sheet positive
        actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ISBN Found",
                                                                                    @"Alert message when scanned ISBN is valid")
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

- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer {

    CGPoint layerPoint = [recognizer locationInView:recognizer.view];
    CGPoint devicePoint = [self.previewLayer captureDevicePointOfInterestForPoint:layerPoint];
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus
         andRestriction:AVCaptureAutoFocusRangeRestrictionNone
         exposeWithMode:AVCaptureExposureModeAutoExpose
          atDevicePoint:devicePoint
      subjectAreaChange:YES];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
       andRestriction:(AVCaptureAutoFocusRangeRestriction)restriction
       exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point
    subjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    if ([self.device lockForConfiguration:nil] ) {
        
        if (self.device.autoFocusRangeRestrictionSupported) {
            self.device.autoFocusRangeRestriction = restriction;
        }
        
        if (self.device.isFocusPointOfInterestSupported
            && [self.device isFocusModeSupported:focusMode]) {
                
            self.device.focusPointOfInterest = point;
            self.device.focusMode = focusMode;
        }
            
        if (self.device.isExposurePointOfInterestSupported
            && [self.device isExposureModeSupported:exposureMode]) {
                
            self.device.exposurePointOfInterest = point;
            self.device.exposureMode = exposureMode;
        }
            
        self.device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
        
        if (monitorSubjectAreaChange) {

            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
            void (^subjectAreaDidChangeBlock)(NSNotification *) = ^(NSNotification *notification) {
                
                if (self.device.focusMode == AVCaptureFocusModeLocked){

                    [self resetFocus];
                }
            };
            
            self.subjectAreaDidChangeObserver
            = [notificationCenter addObserverForName:AVCaptureDeviceSubjectAreaDidChangeNotification
                                              object:nil
                                               queue:nil
                                          usingBlock:subjectAreaDidChangeBlock];
        }
        
        [self.device unlockForConfiguration];
    }
}

- (void)resetFocus {

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self.subjectAreaDidChangeObserver
                                  name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                object:nil];
    
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
         andRestriction:AVCaptureAutoFocusRangeRestrictionNear
         exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:CGPointMake(.5f, .5f)
      subjectAreaChange:NO];
}

@end
