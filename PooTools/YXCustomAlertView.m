//
//  YXCustomAlertView.m
//  YXCustomAlertView
//
//  Created by Houhua Yan on 16/7/12.
//  Copyright © 2016年 YanHouhua. All rights reserved.

//

#import "YXCustomAlertView.h"
#import "PMacros.h"

@interface YXCustomAlertView()
{
    UIFont *viewFont;
    UIColor *alertTitleColor;
    UIColor *alertBottomButtonColor;
    UIColor *verLineColor;
    UIView *verLine;
}

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation YXCustomAlertView


- (instancetype) initAlertViewWithFrame:(CGRect)frame andSuperView:(UIView *)superView withButtonAndTitleFont:(UIFont *)btFont titleColor:(UIColor * _Nonnull)tColor bottomButtonTitleColor:(UIColor * _Nullable )bbtColor verLineColor:(UIColor * _Nullable )vlColor moreButtonTitleArray:(NSArray * _Nonnull)mbtArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.middleView.frame = superView.frame;
        [superView addSubview:_middleView];
        viewFont = btFont;
        alertTitleColor = tColor;
        alertBottomButtonColor = bbtColor;
        verLineColor = vlColor;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, _centerY);
        [superView addSubview:self];
        
        
        self.titleLabel.frame = CGRectMake(0, 0, frame.size.width, TitleViewH);
        self.titleLabel.font = btFont;
        [self addSubview:_titleLabel];
        
        self.customView = [[UIView alloc] initWithFrame:CGRectMake(0, BOTTOM(self.titleLabel), frame.size.width, frame.size.height-TitleViewH-BottomButtonH)];
        [self addSubview:self.customView];

        CGFloat btnW = (frame.size.width - (mbtArray.count-1)*1)/mbtArray.count;
        for (int i = 0 ; i < mbtArray.count; i++) {
            CGRect buttonFrame = CGRectMake(btnW*i+1*i, frame.size.height-BottomButtonH, btnW, BottomButtonH);
            UIButton *btn = [self creatButtonWithFrame:buttonFrame title:mbtArray[i]];
            btn.tag = i;
            [btn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        if (mbtArray.count != 1) {
            for (int j = 0; j < (mbtArray.count-1); j++) {
                verLine = [[UIView alloc] initWithFrame:CGRectMake(btnW+1*j+btnW*j,frame.size.height-43, 1, 43)];
                if (verLineColor == nil) {
                    verLine.backgroundColor = kRGBColor(213, 213, 215);
                }
                else
                {
                    verLine.backgroundColor = verLineColor;
                }
                [self addSubview:verLine];
            }
        }

        UIView *horLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-43, frame.size.width, 0.5)];
        horLine.backgroundColor = verLine.backgroundColor;
        [self addSubview:horLine];

    }
    
    return self;
    
}

- (UIButton *) creatButtonWithFrame:(CGRect) frame title:(NSString *)title
{
    UIButton *cancelBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = frame;
    if (alertBottomButtonColor == nil) {
        [cancelBtn setTitleColor:kRGBColor(0 , 84, 166) forState:UIControlStateNormal];
    }
    else
    {
        [cancelBtn setTitleColor:alertBottomButtonColor forState:UIControlStateNormal];
    }
    [cancelBtn setTitle:title forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = viewFont;
    
    return cancelBtn;
}


#pragma mark - Action
- (void)confirmBtnClick:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(customAlertView:clickedButtonAtIndex:)]) {
        [_delegate customAlertView:self clickedButtonAtIndex:sender.tag];
    }
    
}


#pragma mark - 注销视图
- (void) dissMiss
{
    
    if (_middleView) {
        [_middleView removeFromSuperview];
        _middleView = nil;
    }
    
    [self removeFromSuperview];

    if ([_delegate respondsToSelector:@selector(customAlertViewWasDismiss)]) {
        [_delegate customAlertViewWasDismiss];
    }
}

#pragma mark - getter And setter

- (void) setTitleStr:(NSString *)titleStr
{
    _titleLabel.text = titleStr;
}


- (UIView *) middleView
{
    if (_middleView == nil) {
        _middleView = [[UIView alloc] init];
        _middleView.backgroundColor = [UIColor blackColor];
        _middleView.alpha = 0.65;
    }
    
    return _middleView;
}

- (UILabel *) titleLabel{
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = viewFont;
        _titleLabel.textColor = alertTitleColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _titleLabel;
}


@end