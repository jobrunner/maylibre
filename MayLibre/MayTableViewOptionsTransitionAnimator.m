#import "MayTableViewOptionsTransitionAnimator.h"

@implementation MayTableViewOptionsTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIView *sourceView      = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    
    CGFloat gapWidthPercent = 0.25;
    
    CGRect endFrame = CGRectMake(screenWidth * gapWidthPercent,
                                 0,
                                 screenWidth * (1.0 - gapWidthPercent),
                                 screenHeight);
    if (self.presenting) {
        
        sourceView.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:sourceView];
        [transitionContext.containerView addSubview:destinationView];
        
        CGRect startFrame = endFrame;
        
        // setting initial position of destination
        startFrame.origin.x += screenWidth;
        destinationView.frame = startFrame;
        
        [UIView animateWithDuration:0.3
                         animations:^{
            
                             sourceView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                             sourceView.alpha = 0.8;
        }];
        
        CGFloat offset = 0.1 * (endFrame.origin.x - startFrame.origin.x);
        
        [UIView animateWithDuration:0.4
                         animations:^{
                             
                             CGRect frame = destinationView.frame;
                             frame.origin.x = endFrame.origin.x + offset;
                             destinationView.frame = frame;

                         } completion:^(BOOL finished) {

                             [UIView animateWithDuration:0.25 animations:^{

                                 CGRect frame = destinationView.frame;
                                 frame.origin.x = endFrame.origin.x;
                                 destinationView.frame = frame;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [transitionContext completeTransition:YES];
                                 
                             }];
                         }];
    }
    else {
        
        destinationView.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:destinationView];
        [transitionContext.containerView addSubview:sourceView];
        
        endFrame.origin.x += screenWidth;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             // reset background to "active" state
                             destinationView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
                             destinationView.alpha = 1.0;
                             sourceView.frame = endFrame;
                             
                         } completion:^(BOOL finished) {
                             
                             [transitionContext completeTransition:YES];
                         }];
    }
}

@end
