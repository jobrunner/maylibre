//
//  MayImagePickerController.m
//  MayImagePickerController
//
//  Created by Jo Brunner on 29.10.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
@import Photos;

#import "MayImagePickerController.h"


@interface MayImagePickerController ()

@property (nonatomic, strong) UIViewController *currentViewController;

@end


@implementation MayImagePickerController

#pragma mark UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // start the desired action
    switch (self.sourceType) {
        case SourceTypeCamera:
            [self takePhoto];
            break;
        
        case SourceTypeLibrary:
        default:
            [self takeImageFromLibrary];
    }
}

#pragma mark MayImagePicker methods

+ (void)lastTakenImageFromLibrary:(void(^)(UIImage *image, NSDictionary *info))complete {
    
    PHFetchOptions *options = [PHFetchOptions new];
    
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                              ascending:NO]];
    options.fetchLimit = 1;
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                      options:options];
    PHAsset *asset = [result firstObject];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    [manager requestImageForAsset:asset
                       targetSize:size
                      contentMode:PHImageContentModeAspectFit
                          options:nil
                    resultHandler:^(UIImage *image, NSDictionary *info) {

                        complete(image, info);
                    }];
}

- (void)takeImageFromLibrary {
    
    UIImagePickerController *picker = [UIImagePickerController new];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self addViewControllerAsChildViewController:picker];
}

- (void)takePhoto {
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        picker.showsCameraControls = YES;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self addViewControllerAsChildViewController:picker];
}

#pragma mark - UIImagePickerController Delegates

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];

    [self removeFromParentViewController];

    if ([self.delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {

        [self.delegate imagePicker:self
                    didSelectImage:chosenImage];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker removeFromParentViewController];
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        
        [self.delegate imagePickerDidCancel:self];
    }
}

#pragma mark Container management

- (void)addViewControllerAsChildViewController:(UIViewController *)viewController {
    
    if (self.currentViewController) {
        [self removeCurrentViewController];
    }
    
    [self addChildViewController:viewController];
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    viewController.view.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    viewController.view.frame = self.view.bounds;
    
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    self.currentViewController = viewController;
}

- (void)removeCurrentViewController {
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
}

@end
