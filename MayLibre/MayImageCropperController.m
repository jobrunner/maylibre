//
//  MayImageCropperController.m
//  MayImageCropperController
//
//  Created by Jo Brunner on 29.10.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "HIPImageCropperView.h"
#import "MayImageCropperController.h"

@interface MayImageCropperController ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) HIPImageCropperView *cropperView;
@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation MayImageCropperController

- (instancetype)initWithOriginalImage:(UIImage *)image {

    if (self = [super init]) {
    
        _originalImage = image;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    [self initCropperViewWithFrame:self.view.bounds
                      cropAreaSize:CGSizeMake(300.0, 300.0 * (66.0 / 44.0))];
}

- (void)initCropperViewWithFrame:(CGRect)frame cropAreaSize:(CGSize)size {
    
    _cropperView = [[HIPImageCropperView alloc]
                    initWithFrame:frame
                    cropAreaSize:size
                    position:HIPImageCropperViewPositionCenter];
    
    [self.view addSubview:_cropperView];
    
    [_cropperView setOriginalImage:_originalImage];
    
    // @todo: Cancel button and styling
    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [captureButton setTitle:NSLocalizedString(@"Capture", nil)
                   forState:UIControlStateNormal];
    
    [captureButton sizeToFit];
    [captureButton setFrame:CGRectMake(self.view.frame.size.width - captureButton.frame.size.width - 10.0,
                                       self.view.frame.size.height - captureButton.frame.size.height - 10.0,
                                       captureButton.frame.size.width, captureButton.frame.size.height)];
    
    [captureButton setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleLeftMargin)];
    
    [captureButton addTarget:self
                      action:@selector(didTapCaptureButton:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:captureButton];
}

- (void)didTapCaptureButton:(id)sender {

    if ([self.delegate respondsToSelector:@selector(imageCropper:didCaptureImage:)]) {
        [self.delegate imageCropper:self
                    didCaptureImage:[_cropperView processedImage]];
    }
}

- (void)didCancelCaptureButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(imageCropperDidCancel:)]) {
        [self.delegate imageCropperDidCancel:self];
    }
}

@end
