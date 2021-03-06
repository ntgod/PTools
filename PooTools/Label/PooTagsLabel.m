//
//  PooTagsLabel.m
//  XMNiao_Shop
//
//  Created by MYX on 2017/3/16.
//  Copyright © 2017年 邓杰豪. All rights reserved.
//

#import "PooTagsLabel.h"
#import "PMacros.h"
#import "Utils.h"
#import <Masonry/Masonry.h>

#define BTN_Tags_Tag        784843

@implementation PooTagsLabelConfig
@end

@interface PooTagsLabel ()
@property (nonatomic,strong) PooTagsLabelConfig *curConfig;
@property (nonatomic,strong) NSArray *normalTagsArr;
@property (nonatomic,assign) BOOL showImage;
@property (nonatomic,assign) CGFloat viewW;
@property (nonatomic,strong) NSArray *selectedTagsArr;
@property (nonatomic,strong) NSArray *tagsTitleArr;

@property (nonatomic,assign) NSInteger section;
@property (nonatomic,strong) NSMutableArray <NSNumber *>*rowLastTagArr;
@property (nonatomic,strong) NSMutableArray <NSNumber *>*sectionCountArr;
@end

@implementation PooTagsLabel

-(instancetype)initWithTagsNormalArray:(NSArray *)tagsNormalArr tagsSelectArray:(NSArray *)tagsSelectArr tagsTitleArray:(NSArray *)tagsTitleArr config:(PooTagsLabelConfig *)config wihtSection:(NSInteger)sectionIndex
{
    if (self = [super init])
    {
        for (UIView *subView in self.subviews)
        {
            [subView removeFromSuperview];
        }
        
        self.tag = sectionIndex;
        self.showImage = YES;
        self.normalTagsArr = tagsNormalArr;
        self.selectedTagsArr = tagsSelectArr;
        self.tagsTitleArr = tagsTitleArr;
        _curConfig = config;
        _multiSelectedTags = [NSMutableArray array];
        if (config.selectedDefaultTags.count)
        {
            [_multiSelectedTags addObjectsFromArray:config.selectedDefaultTags];
        }
                
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImageView *bgImageView = [UIImageView new];
            bgImageView.userInteractionEnabled = YES;
            self.bgImageView = bgImageView;
            [self addSubview:bgImageView];
            
            CGRect lastBtnRect = CGRectZero;
            CGFloat hMargin = 0.0, orgin_Y = 0.0, itemContentMargin = self.curConfig.itemContentEdgs > 0 ? self.curConfig.itemContentEdgs : 10.0, topBottomSpace = (self.curConfig.topBottomSpace > 0 ? self.curConfig.topBottomSpace : 15.0);
            UIFont *font = kDEFAULT_FONT(self.curConfig.fontName ? self.curConfig.fontName:kDevLikeFont_Bold, self.curConfig.fontSize > 0 ? self.curConfig.fontSize : 12.0);
            
            self.section = 0;
            NSInteger row = 0;

            self.rowLastTagArr = [NSMutableArray array];

            for (int i = 0; i < self.normalTagsArr.count; i++)
            {
                UIImage *normalImage = kImageNamed(self.normalTagsArr[i]);
                NSString *title = self.tagsTitleArr[i];
                
                CGFloat titleWidth = self.curConfig.itemWidth;
                

                if ((CGRectGetMaxX(lastBtnRect) + self.curConfig.itemHerMargin + titleWidth + 2 * itemContentMargin) > CGRectGetWidth(self.frame))
                {
                    lastBtnRect.origin.x = 0.0;
                    hMargin = 0.0;
                    lastBtnRect.size.width = 0.0;
                    orgin_Y += (self.curConfig.itemHeight + self.curConfig.itemVerMargin);
                    
                    NSInteger currentRowLastTag = row - BTN_Tags_Tag;
                    [self.rowLastTagArr addObject:[NSNumber numberWithInteger:currentRowLastTag]];
                    
                    self.section += 1;
                }
                
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(hMargin + CGRectGetMaxX(lastBtnRect), topBottomSpace + orgin_Y, self.curConfig.itemWidth, self.curConfig.itemHeight)];
                lastBtnRect = btn.frame;
                hMargin = self.curConfig.itemHerMargin;
                btn.tag = BTN_Tags_Tag + i;
                row = BTN_Tags_Tag + i;
                [self addSubview:btn];

                ///标题设置
                switch (self.curConfig.showStatus) {
                    case PooTagsLabelShowWithImageStatusNoTitle:
                    {
                        [btn setTitleColor:kClearColor forState:UIControlStateNormal];
                        [btn setTitle:title forState:UIControlStateNormal];
                        [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
                        [btn setBackgroundImage:kImageNamed(self.selectedTagsArr[i]) forState:UIControlStateSelected];
                    }
                        break;
                    default:
                    {
                        UIColor *normorTitleColor = self.curConfig.normalTitleColor ? self.curConfig.normalTitleColor : [UIColor grayColor];
                        UIColor *selectedTitleColor = self.curConfig.selectedTitleColor ? self.curConfig.selectedTitleColor : [UIColor greenColor];
                        
                        [btn setTitleColor:normorTitleColor forState:UIControlStateNormal];
                        [btn setTitleColor:selectedTitleColor forState:UIControlStateSelected];
                        [btn setTitle:title forState:UIControlStateNormal];
                        [btn setTitle:title forState:UIControlStateSelected];
                        [btn setImage:normalImage forState:UIControlStateNormal];
                        [btn setImage:kImageNamed(self.selectedTagsArr[i]) forState:UIControlStateSelected];
                        [btn layoutButtonWithEdgeInsetsStyle:self.curConfig.insetsStyle imageTitleSpace:self.curConfig.imageAndTitleSpace];
                    }
                        break;
                }
                
                btn.backgroundColor = self.curConfig.backgroundColor ? self.curConfig.backgroundColor : kClearColor;
                btn.titleLabel.font = font;
                [btn addTarget:self action:@selector(tagBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                
                CGRect frame = self.frame;
                frame.size.height = CGRectGetMaxY(btn.frame) + topBottomSpace;
                self.frame = frame;
                self.bgImageView.frame = self.bounds;
                
                ///边框
                if (self.curConfig.hasBorder)
                {
                    btn.clipsToBounds = YES;
                    btn.layer.cornerRadius = self.curConfig.cornerRadius > 0 ? self.curConfig.cornerRadius : self.curConfig.itemHeight / 2.0;
                    btn.layer.borderColor = self.curConfig.borderColor.CGColor;
                    btn.layer.borderWidth = self.curConfig.borderWidth > 0.0 ? self.curConfig.borderWidth : 0.5;
                }
                
                ///可选中
                if (self.curConfig.isCanSelected)
                {
                    //多选
                    if (self.curConfig.isMulti)
                    {
                        for (NSString *str in self.curConfig.selectedDefaultTags)
                        {
                            if ([title isEqualToString:str])
                            {
                                btn.selected = YES;
                            }
                        }
                    }
                    else
                    {  //单选
                        if ([title isEqualToString:self.curConfig.singleSelectedTitle])
                        {
                            btn.selected = YES;
                            self.selectedBtn = btn;
                        }
                    }
                }
                else
                {  //不可选中
                    btn.enabled = NO;
                }
                
            }
            if (self.tagHeightBlock) {
                self.tagHeightBlock(self, self.frame.size.height);
            }
            
//            PNSLog(@"最后一行section>>>>>%ld",(long)self.section);

            [self.rowLastTagArr addObject:[NSNumber numberWithInteger:self.normalTagsArr.count-1]];
            
//            PNSLog(@"每行最后一个的tag数组>>>>>>>%@",self.rowLastTagArr);

            self.sectionCountArr = [NSMutableArray array];
            for (int i = 0; i < self.rowLastTagArr.count; i++) {
                if (i == 0) {
                    NSInteger currentRowCount = [self.rowLastTagArr[i] integerValue]+1;
                    [self.sectionCountArr addObject:[NSNumber numberWithInteger:currentRowCount]];
                }
                else
                {
                    NSInteger currentRowCount = [self.rowLastTagArr[i] integerValue] - [self.rowLastTagArr[i-1] integerValue];
                    [self.sectionCountArr addObject:[NSNumber numberWithInteger:currentRowCount]];
                }
            }
            
            if (self.tagViewHadSectionAndSetcionLastTagAndTagInSectionCountBlock)
            {
                self.tagViewHadSectionAndSetcionLastTagAndTagInSectionCountBlock(self, self.section, self.rowLastTagArr, self.sectionCountArr);
            }
            [self setTagPosition:config.tagPosition];

        });
    }
    return self;
}

-(instancetype)initWithTagsArray:(NSArray *)tagsArr config:(PooTagsLabelConfig *)config wihtSection:(NSInteger)sectionIndex
{
    
    if (self = [super init])
    {
        for (UIView *subView in self.subviews)
        {
            [subView removeFromSuperview];
        }
        
        self.tag = sectionIndex;
        self.showImage = NO;
        self.normalTagsArr = tagsArr;
        _curConfig = config;
        _multiSelectedTags = [NSMutableArray array];
        if (config.selectedDefaultTags.count)
        {
            [_multiSelectedTags addObjectsFromArray:config.selectedDefaultTags];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIImageView *bgImageView = [UIImageView new];
            bgImageView.userInteractionEnabled = YES;
            self.bgImageView = bgImageView;
            [self addSubview:bgImageView];
            
            CGRect lastBtnRect = CGRectZero;
            CGFloat hMargin = 0.0, orgin_Y = 0.0, itemContentMargin = config.itemContentEdgs > 0 ? config.itemContentEdgs : 10.0, topBottomSpace = (config.topBottomSpace > 0 ? config.topBottomSpace : 15.0);
            
            UIFont *font = kDEFAULT_FONT(config.fontName ? config.fontName:kDevLikeFont_Bold, config.fontSize > 0 ? config.fontSize : 12.0);
            
            self.section = 0;
            NSInteger row = 0;

            self.rowLastTagArr = [NSMutableArray array];
            
            for (int i = 0; i < tagsArr.count; i++)
            {
                NSString *title = tagsArr[i];
                CGFloat titleWidth = [title sizeWithAttributes:@{NSFontAttributeName : font}].width;
                
                if ((CGRectGetMaxX(lastBtnRect) + config.itemHerMargin + titleWidth + 2 * itemContentMargin) > CGRectGetWidth(self.frame))
                {
                    lastBtnRect.origin.x = 0.0;
                    hMargin = 0.0;
                    lastBtnRect.size.width = 0.0;
                    orgin_Y += (config.itemHeight + config.itemVerMargin);

                    NSInteger currentRowLastTag = row - BTN_Tags_Tag;
                    [self.rowLastTagArr addObject:[NSNumber numberWithInteger:currentRowLastTag]];
                    
                    self.section += 1;
                }

                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(hMargin + CGRectGetMaxX(lastBtnRect), topBottomSpace + orgin_Y, titleWidth+2*itemContentMargin, config.itemHeight)];
                lastBtnRect = btn.frame;
                hMargin = config.itemHerMargin;
                btn.tag = BTN_Tags_Tag + i;
                row = BTN_Tags_Tag + i;
                [self addSubview:btn];
//                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(self).offset(hMargin+lastBtnRect.origin.x);
//                    make.top.equalTo(self).offset(topBottomSpace + orgin_Y);
//                    make.width.offset(titleWidth+2*itemContentMargin);
//                    make.height.offset(config.itemHeight);
//                }];
                
//                PNSLog(@">>>>>>>>>>>>>>>>>>>>>>>%@",NSStringFromCGRect(btn.frame));

                ///标题设置
                UIColor *normorTitleColor = config.normalTitleColor ? config.normalTitleColor : [UIColor grayColor];
                UIColor *selectedTitleColor = config.selectedTitleColor ? config.selectedTitleColor : [UIColor greenColor];
                [btn setTitle:title forState:UIControlStateNormal];
                [btn setTitleColor:normorTitleColor forState:UIControlStateNormal];
                [btn setTitleColor:selectedTitleColor forState:UIControlStateSelected];
                
                ///图片设置
                if (config.normalBgImage)
                {
                    [btn setBackgroundImage:[UIImage imageNamed:config.normalBgImage] forState:UIControlStateNormal];
                }
                if (config.selectedBgImage)
                {
                    [btn setBackgroundImage:[UIImage imageNamed:config.selectedBgImage] forState:UIControlStateSelected];
                }
                
                btn.titleLabel.font = font;
                [btn addTarget:self action:@selector(tagBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                
                CGRect frame = self.frame;
                frame.size.height = CGRectGetMaxY(btn.frame) + topBottomSpace;
                self.frame = frame;
                self.bgImageView.frame = self.bounds;
                
                if (config.hasBorder)
                {
                    btn.clipsToBounds = YES;
                    btn.layer.cornerRadius = config.cornerRadius > 0 ? config.cornerRadius : config.itemHeight / 2.0;
                    btn.layer.borderWidth = config.borderWidth > 0.0 ? config.borderWidth : 0.5;
                }
                ///可选中
                if (config.isCanSelected)
                {
                    //多选
                    if (config.isMulti)
                    {
                        for (NSString *str in config.selectedDefaultTags)
                        {
                            if ([title isEqualToString:str])
                            {
                                btn.selected = YES;
                            }
                        }
                    }
                    else
                    {  //单选
                        if ([title isEqualToString:config.singleSelectedTitle])
                        {
                            btn.selected = YES;
                            self.selectedBtn = btn;
                        }
                    }
                    
                    if (btn.selected) {
                        if (config.hasBorder)
                        {
                            UIColor *borderC = config.borderColorSelected ? config.borderColorSelected : [UIColor grayColor];
                            btn.layer.borderColor = borderC.CGColor;
                        }
                        btn.backgroundColor = config.backgroundSelectedColor ? config.backgroundSelectedColor : kClearColor;
                    }
                    else
                    {
                        if (config.hasBorder)
                        {
                            UIColor *borderC = config.borderColor ? config.borderColor : [UIColor grayColor];
                            btn.layer.borderColor = borderC.CGColor;
                        }
                        btn.backgroundColor = config.backgroundColor ? config.backgroundColor : kClearColor;
                    }
                }
                else
                {  //不可选中
                    btn.enabled = NO;
                }
            }
            if (self.tagHeightBlock) {
                self.tagHeightBlock(self, self.frame.size.height);
            }
            
//            PNSLog(@"最后一行section>>>>>%ld",(long)self.section);

            [self.rowLastTagArr addObject:[NSNumber numberWithInteger:self.normalTagsArr.count-1]];
            
//            PNSLog(@"每行最后一个的tag数组>>>>>>>%@",self.rowLastTagArr);

            self.sectionCountArr = [NSMutableArray array];
            for (int i = 0; i < self.rowLastTagArr.count; i++) {
                if (i == 0) {
                    NSInteger currentRowCount = [self.rowLastTagArr[i] integerValue]+1;
                    [self.sectionCountArr addObject:[NSNumber numberWithInteger:currentRowCount]];
                }
                else
                {
                    NSInteger currentRowCount = [self.rowLastTagArr[i] integerValue] - [self.rowLastTagArr[i-1] integerValue];
                    [self.sectionCountArr addObject:[NSNumber numberWithInteger:currentRowCount]];
                }
            }
            
            if (self.tagViewHadSectionAndSetcionLastTagAndTagInSectionCountBlock)
            {
                self.tagViewHadSectionAndSetcionLastTagAndTagInSectionCountBlock(self, self.section, self.rowLastTagArr, self.sectionCountArr);
            }
            [self setTagPosition:config.tagPosition];
        });
    }
    return self;
}


-(void)setTagPosition:(PooTagPosition)position
{
    for (int j = 0; j < (self.section+1); j++) {
        CGFloat totalW = 0.0;
                                
        for (int i = ((j == 0) ? 0 : ([self.rowLastTagArr[j-1] intValue]+1)); i < ([self.rowLastTagArr[j] intValue]+1); i++) {
            UIButton *currentBtn = [self viewWithTag:i+BTN_Tags_Tag];//当前

            totalW += CGRectGetWidth(currentBtn.frame);
        }
//        PNSLog(@"当行(%d)总w:%f",j,totalW);

        CGFloat currentSectionTotalW = totalW+self.curConfig.itemHerMargin*([self.sectionCountArr[j] integerValue]+1);
        
        CGFloat xxxxxxxxx;
        switch (position) {
            case PooTagPositionCenter:
            {
                
                if ((self.frame.size.width - currentSectionTotalW) < 0)
                {
                    xxxxxxxxx = 0;
                }
                else
                {
                    xxxxxxxxx = (self.frame.size.width - currentSectionTotalW)/2;
                }
            }
                break;
            case PooTagPositionLeft:
            {
                xxxxxxxxx = 0;
            }
                break;
            case PooTagPositionRight:
            {
                xxxxxxxxx = self.frame.size.width - currentSectionTotalW + self.curConfig.itemHerMargin;
            }
                break;
            default:
            {
                xxxxxxxxx = self.curConfig.itemHerMargin;
            }
                break;
        }
//        PNSLog(@"当行(%d)x位置::%f",j,xxxxxxxxx);
        
        for (int i = ((j == 0) ? 0 : ([self.rowLastTagArr[j-1] intValue]+1)); i < [self.rowLastTagArr[j] intValue]+1; i++) {
                UIButton *currentBtn = [self viewWithTag:i+BTN_Tags_Tag];//当前
                UIButton *lastBtn = [self viewWithTag:i-1+BTN_Tags_Tag];//上一个
            if (i == ((j == 0) ? 0 : ([self.rowLastTagArr[j-1] intValue]+1)))
            {
                currentBtn.frame = CGRectMake(xxxxxxxxx, currentBtn.frame.origin.y, currentBtn.frame.size.width, currentBtn.frame.size.height);
            }
            else
            {
                currentBtn.frame = CGRectMake(lastBtn.frame.origin.x+lastBtn.frame.size.width+self.curConfig.itemHerMargin, currentBtn.frame.origin.y, currentBtn.frame.size.width, currentBtn.frame.size.height);
            }
        }

    }
    
}
//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    CGRect lastBtnRect = CGRectZero;
//    CGFloat hMargin = 0.0, orgin_Y = 0.0, itemContentMargin = self.curConfig.itemContentEdgs > 0 ? self.curConfig.itemContentEdgs : 10.0, topBottomSpace = (self.curConfig.topBottomSpace > 0 ? self.curConfig.topBottomSpace : 15.0);
//
//    UIFont *font = kDEFAULT_FONT(self.curConfig.fontName ? self.curConfig.fontName:kDevLikeFont_Bold, self.curConfig.fontSize > 0 ? self.curConfig.fontSize : 12.0);
//
//    for (int i = 0; i < self.normalTagsArr.count; i++)
//    {
//        NSString *title = self.normalTagsArr[i];
//        CGFloat titleWidth;
//        if (self.showImage)
//        {
//            titleWidth = self.curConfig.itemWidth;
//        }
//        else
//        {
//            titleWidth = [title sizeWithAttributes:@{NSFontAttributeName : font}].width;
//        }
//
//        if ((CGRectGetMaxX(lastBtnRect) + self.curConfig.itemHerMargin + titleWidth + 2 * itemContentMargin) > CGRectGetWidth(self.frame))
//        {
//            lastBtnRect.origin.x = 0.0;
//            hMargin = 0.0;
//            lastBtnRect.size.width = 0.0;
//            orgin_Y += (self.curConfig.itemHeight + self.curConfig.itemVerMargin);
//        }
//
//        UIButton *btn = [self viewWithTag:BTN_Tags_Tag + i];
//        if (self.showImage) {
//            btn.frame = CGRectMake(hMargin + CGRectGetMaxX(lastBtnRect), topBottomSpace + orgin_Y, self.curConfig.itemWidth, self.curConfig.itemHeight);
//        }
//        else
//        {
//            btn.frame = CGRectMake(hMargin + CGRectGetMaxX(lastBtnRect), topBottomSpace + orgin_Y, titleWidth+2*itemContentMargin, self.curConfig.itemHeight);
//        }
//        lastBtnRect = btn.frame;
//        hMargin = self.curConfig.itemHerMargin;
//
//        CGRect frame = self.frame;
//        frame.size.height = CGRectGetMaxY(btn.frame) + topBottomSpace;
//        self.frame = frame;
//        self.bgImageView.frame = self.bounds;
//    }
//
//    if (self.tagHeightBlock) {
//        self.tagHeightBlock(self, self.frame.size.height);
//    }
//}

- (void)tagBtnAction:(UIButton *)sender
{
    ///可选中
    if (_curConfig.isCanSelected)
    {
        //多选
        if (_curConfig.isMulti)
        {
            //可以取消选中
            if (_curConfig.isCanCancelSelected)
            {
                sender.selected = !sender.selected;
                if (sender.selected == YES)
                {
                    if (![_multiSelectedTags containsObject:sender.currentTitle])
                    {
                        [_multiSelectedTags addObject:sender.currentTitle];
                    }
                }
                else
                {
                    if ([_multiSelectedTags containsObject:sender.currentTitle]) {
                        [_multiSelectedTags removeObject:sender.currentTitle];
                    }
                }
            }
            else
            {
                sender.selected = YES;
                
                if (![_multiSelectedTags containsObject:sender.currentTitle])
                {
                    [_multiSelectedTags addObject:sender.currentTitle];
                }
            }
        }
        else
        {  //单选
            //可以取消选中
            if (_curConfig.isCanCancelSelected)
            {
                if (self.selectedBtn == sender)
                {
                    sender.selected = !sender.selected;
                    if (sender.selected == YES)
                    {
                        self.selectedBtn = sender;
                    }
                    else
                    {
                        self.selectedBtn = nil;
                    }
                }
                else
                {
                    self.selectedBtn.selected = NO;
                    sender.selected = YES;
                    self.selectedBtn = sender;
                }
            }
            else
            {
                //不可以取消选中
                self.selectedBtn.selected = NO;
                [self btnBackgroundColorAndBorderColor:self.selectedBtn];
                sender.selected = YES;
                self.selectedBtn = sender;
            }
        }
    }
    
    [self btnBackgroundColorAndBorderColor:sender];
    
    //点击回调
    NSInteger index = sender.tag - BTN_Tags_Tag;
    if (self.tagBtnClickedBlock)
    {
        self.tagBtnClickedBlock(self, sender, index);
    }
}

-(void)btnBackgroundColorAndBorderColor:(UIButton *)sender
{
    if (self.curConfig.hasBorder) {
        if (sender.selected)
        {
            UIColor *borderC = self.curConfig.borderColorSelected ? self.curConfig.borderColorSelected : [UIColor grayColor];
            sender.layer.borderColor = borderC.CGColor;
        }
        else
        {
            UIColor *borderC = self.curConfig.borderColor ? self.curConfig.borderColor : [UIColor grayColor];
            sender.layer.borderColor = borderC.CGColor;
        }
    }
    
    if (sender.selected)
    {
        sender.backgroundColor = self.curConfig.backgroundSelectedColor ? self.curConfig.backgroundSelectedColor : kClearColor;
    }
    else
    {
        sender.backgroundColor = self.curConfig.backgroundColor ? self.curConfig.backgroundColor : kClearColor;
    }
}

-(void)clearTag
{
    for (int i = 0; i < self.normalTagsArr.count; i++)
    {
        UIButton *btn = [self viewWithTag:BTN_Tags_Tag + i];
        btn.selected = NO;
        btn.backgroundColor = self.curConfig.backgroundColor ? self.curConfig.backgroundColor : kClearColor;
        
        if (self.curConfig.hasBorder) {
            UIColor *borderC = self.curConfig.borderColor ? self.curConfig.borderColor : [UIColor grayColor];
            btn.layer.borderColor = borderC.CGColor;
        }
    }
}

-(void)reloadTag:(PooTagsLabelConfig *)config
{
    [self clearTag];
    
    for (int i = 0; i < self.normalTagsArr.count; i++)
    {
        NSString *title = self.showImage ? self.tagsTitleArr[i] : self.normalTagsArr[i];

        UIButton *btn = [self viewWithTag:BTN_Tags_Tag + i];
        
        [_multiSelectedTags removeAllObjects];
        [_multiSelectedTags addObjectsFromArray:config.selectedDefaultTags];
        
        btn.backgroundColor = config.backgroundColor ? config.backgroundColor : kClearColor;
        ///可选中
        if (config.isCanSelected)
        {
            //多选
            if (config.isMulti)
            {
                for (NSString *str in config.selectedDefaultTags)
                {
                    if ([title isEqualToString:str])
                    {
                        btn.selected = YES;
                    }
                }
            }
            else
            {  //单选
                if ([title isEqualToString:config.singleSelectedTitle])
                {
                    btn.selected = YES;
                    self.selectedBtn = btn;
                }
            }
            
            if (btn.selected) {
                if (config.hasBorder)
                {
                    UIColor *borderC = config.borderColorSelected ? config.borderColorSelected : [UIColor grayColor];
                    btn.layer.borderColor = borderC.CGColor;
                }
                btn.backgroundColor = config.backgroundSelectedColor ? config.backgroundSelectedColor : kClearColor;
            }
            else
            {
                if (self.curConfig.hasBorder)
                {
                    UIColor *borderC = config.borderColor ? config.borderColor : [UIColor grayColor];
                    btn.layer.borderColor = borderC.CGColor;
                }
                btn.backgroundColor = config.backgroundColor ? config.backgroundColor : kClearColor;
            }
        }
        else
        {  //不可选中
            btn.enabled = NO;
        }
    }
}
@end

