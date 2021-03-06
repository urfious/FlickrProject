//
//  ViewController.m
//  FlickrProject
//
//  Created by Luka Usalj on 03/04/15.
//  Copyright (c) 2015 Luka Usalj. All rights reserved.
//

#import "FLCViewController.h"
#import "FLCBackgroundView.h"
#import "FLCLoginFormView.h"
#import "FLCButton.h"
#import "FLCExploreViewController.h"
#import "ImageFilter.h"

@interface FLCViewController ()
@property (strong, nonatomic) FLCBackgroundView *backgroundView;
@property (strong, nonatomic) FLCLoginFormView *loginFormView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) NSDictionary *viewsDictionary;
@property (strong, nonatomic) NSDictionary *metrics;
@property (strong, nonatomic) FLCButton *exploreViewButton;
@property (strong, nonatomic) FLCButton *signInFormButton;
@property (strong, nonatomic) UIButton *closeFormButton;
@end

@implementation FLCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConstraints];
    [self positionLogoInCenter];
    [self addConstraintsToLoginForm];
    [self.backgroundView startTransition];
}

- (void)positionLogoInCenter
{
    [self.view.constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSLayoutConstraint class]]) {
            NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
            if ([constraint.firstItem isKindOfClass:[NSString class]]) {
                NSString *constraintString = (NSString *)constraint.firstItem;
                NSLog(@"%@", constraintString);
                if ([constraintString isEqualToString:@"V:|-(logoOffset)-[logo]"]) {
                    [self.view removeConstraint:constraint];
                }
            }
        }
    }];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
}

- (void)setupConstraints
{
    [self addSizeConstraintsToLogo];
    [self addConstraintsToButtomButtons];
}

- (void)addBackgroundConstraints
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background]|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:self.viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[background]|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:self.viewsDictionary]];
    
}

- (void)addSizeConstraintsToLogo
{
    [self.logoImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[logo(width)]"
                                                              options:0
                                                              metrics:self.metrics
                                                                views:self.viewsDictionary]];
    
    [self.logoImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logo(height)]"
                                                              options:NSLayoutFormatAlignAllCenterX
                                                              metrics:self.metrics
                                                                views:self.viewsDictionary]];
}

- (void)prepareLoginForm
{
    [self.backgroundView stopBackground];
    [self positionLogoOnTop];
    [self.loginFormView setUsernameAsResponder];
    
    [UIView transitionWithView:self.backgroundView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.view layoutIfNeeded];
                        self.loginFormView.alpha = 1;
                        self.closeFormButton.alpha = 1;
                    } completion:^(BOOL finished) {
                        self.exploreViewButton.alpha = 0;
                        self.signInFormButton.alpha = 0;
                        [self.backgroundView.layer removeAllAnimations];
                        self.backgroundView.scrollEnabled = NO;
                    }];
}

- (void)closeForm
{
    self.backgroundView.scrollEnabled = YES;
    [self clearForm];
    [self.loginFormView setWindowAsResponder];
    [self resetAllConstraints];
    [self addSizeConstraintsToLogo];
    [self positionLogoInCenter];
    [self addConstraintsToLoginForm];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.loginFormView.alpha = 0;
                         self.closeFormButton.alpha = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              self.exploreViewButton.alpha = 1;
                                              self.signInFormButton.alpha = 1;
                                          }];
                     }];
    
    [self.backgroundView resumeBackground];
}

- (void)clearForm
{
    self.loginFormView.username = @"";
    self.loginFormView.password = @"";
}

- (void)resetAllConstraints
{
    [self.logoImageView removeFromSuperview];
    [self.loginFormView removeFromSuperview];
    [self.closeFormButton removeFromSuperview];
    
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.loginFormView];
    [self.view addSubview:self.closeFormButton];
}

- (void)positionLogoOnTop
{
    [self.view.constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSLayoutConstraint class]]) {
            NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
            if (constraint.firstAttribute == NSLayoutAttributeCenterY) {
                [self.view removeConstraint:constraint];
            }
        }
    }];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(logoOffset)-[logo]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:self.metrics
                                                                        views:self.viewsDictionary]];
}

- (NSDictionary *)viewsDictionary
{
    if (!_viewsDictionary) {
        _viewsDictionary = @{@"loginForm":self.loginFormView,
                             @"logo":self.logoImageView,
                             @"explore":self.exploreViewButton,
                             @"signIn":self.signInFormButton,
                             @"X":self.closeFormButton};
    }
    return _viewsDictionary;
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView) {
        self.logoImageView = [UIImageView new];
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.logoImageView.image = [UIImage imageNamed:@"logo"];
        [self.view addSubview:self.logoImageView];
        [self addSizeConstraintsToLogo];
    }
    return _logoImageView;
}

- (NSDictionary *)metrics
{
    if (!_metrics) {
        float scaleFactor = self.logoImageView.image.size.width / self.logoImageView.image.size.height;
        
        float height = self.view.bounds.size.height/8;
        float width = scaleFactor * height;
        
        float logoOffset = self.view.bounds.size.height/16;
        
        float bottomBtnSizeV = self.view.bounds.size.height/14;
        
        float formSizeV = 3 * bottomBtnSizeV + 20;
        
        _metrics = @{@"width":[NSNumber numberWithFloat:width],
                     @"height":[NSNumber numberWithFloat:height],
                     @"logoOffset":[NSNumber numberWithFloat:logoOffset],
                     @"formSizeV":[NSNumber numberWithFloat:formSizeV],
                     @"explore":self.exploreViewButton,
                     @"signIn":self.signInFormButton,
                     @"bottomBtnSizeV":[NSNumber numberWithFloat:bottomBtnSizeV]};
    }
    return _metrics;
}

- (FLCLoginFormView *)loginFormView
{
    if (!_loginFormView) {
        _loginFormView = [FLCLoginFormView new];
        _loginFormView.translatesAutoresizingMaskIntoConstraints = NO;
        _loginFormView.alpha = 0;
        [self.view addSubview:_loginFormView];
    }
    return _loginFormView;
}

- (UIButton *)exploreViewButton
{
    if (!_exploreViewButton) {
        _exploreViewButton = [FLCButton new];
        _exploreViewButton.backgroundColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
        [_exploreViewButton setTitle:@"Explore" forState:UIControlStateNormal];
        [_exploreViewButton addTarget:self action:@selector(moveToExploreView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_exploreViewButton];
    }
    return _exploreViewButton;
}

- (void)moveToExploreView
{
    [self performSegueWithIdentifier:@"exploreViewSegue" sender:self];
}

- (FLCButton *)signInFormButton
{
    if (!_signInFormButton) {
        _signInFormButton = [FLCButton new];
        _signInFormButton.backgroundColor = [UIColor colorWithRed:123/255.0 green:12/255.0 blue:114/255.0 alpha:1];
        [_signInFormButton setTitle:@"Sign in" forState:UIControlStateNormal];
        [_signInFormButton addTarget:self action:@selector(prepareLoginForm) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_signInFormButton];
    }
    return _signInFormButton;
}

- (UIButton *)closeFormButton
{
    if (!_closeFormButton) {
        _closeFormButton = [UIButton new];
        _closeFormButton.alpha = 0;
        [_closeFormButton setTitle:@"X" forState:UIControlStateNormal];
        [_closeFormButton.titleLabel setFont:[UIFont systemFontOfSize:30]];
        _closeFormButton.tintColor = [UIColor blackColor];
        [_closeFormButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeFormButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeFormButton addTarget:self action:@selector(closeForm) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_closeFormButton];
    }
    return _closeFormButton;
}

- (void)addConstraintsToLoginForm
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logo]-(logoOffset)-[loginForm(formSizeV)]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:self.metrics
                                                                        views:self.viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[X][loginForm]"
                                                                      options:NSLayoutFormatAlignAllRight
                                                                      metrics:self.metrics
                                                                        views:self.viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[loginForm]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary]];
}

- (void)addConstraintsToButtomButtons
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[explore]-[signIn]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[explore(bottomBtnSizeV)]-8-|"
                                                                      options:0
                                                                      metrics:self.metrics
                                                                        views:self.viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[signIn(bottomBtnSizeV)]-8-|"
                                                                      options:0
                                                                      metrics:self.metrics
                                                                        views:self.viewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exploreViewButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.signInFormButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
}

- (FLCBackgroundView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[FLCBackgroundView alloc]initWithFrame:self.view.frame];
//        _backgroundView = [FLCBackgroundView new];
        [self.view insertSubview:_backgroundView atIndex:0];
    }
    return _backgroundView;
}

@end
