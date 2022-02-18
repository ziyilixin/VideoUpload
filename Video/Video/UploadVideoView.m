//
//  UploadVideoView.m
//  yunbaolive
//
//  Created by Mac on 2020/9/17.
//  Copyright © 2020 cat. All rights reserved.
//

#define MAS_SHORTHAND
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define RGB_COLOR(_STR_,a) ([UIColor colorWithRed:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(1, 2)] UTF8String], 0, 16)] intValue] / 255.0 green:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(3, 2)] UTF8String], 0, 16)] intValue] / 255.0 blue:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(5, 2)] UTF8String], 0, 16)] intValue] / 255.0 alpha:a])

#import "UploadVideoView.h"
#import "Masonry.h"
#import "CFToolClass.h"
#import "UIView+Extension.h"

@interface UploadVideoView ()
@property (nonatomic, strong) UIView *contentView;
@end

@implementation UploadVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 2*SCREEN_HEIGHT-154, SCREEN_WIDTH, 154)];
        contentView.backgroundColor = RGB_COLOR(@"#F2F2F2", 1.0);
        contentView.layer.mask = [[CFToolClass sharedInstance] setViewLeftTop:6 andRightTop:6 andView:contentView];
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton setTitle:@"从手机相册选择" forState:UIControlStateNormal];
        [photoButton setTitleColor:RGB_COLOR(@"#333333", 1.0) forState:UIControlStateNormal];
        photoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [photoButton addTarget:self action:@selector(selectVideo) forControlEvents:UIControlEventTouchUpInside];
        photoButton.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:photoButton];
        [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.height.mas_equalTo(57);
        }];

        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:RGB_COLOR(@"#333333", 1.0) forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton addTarget:self action:@selector(cancelSelect:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.right.bottom.equalTo(self.contentView);
           make.top.equalTo(photoButton.mas_bottom).offset(6);
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.y = 0;
            self.contentView.y = SCREEN_HEIGHT - 154;
        }];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.3 animations:^{
        self.y = SCREEN_HEIGHT;
        self.contentView.y = 2*SCREEN_HEIGHT - 154;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)selectVideo {
    [UIView animateWithDuration:0.3 animations:^{
        self.y = SCREEN_HEIGHT;
        self.contentView.y = 2*SCREEN_HEIGHT - 154;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (self.block) {
        self.block();
    }
}

- (void)cancelSelect:(UIButton *)button {
    [UIView animateWithDuration:0.3 animations:^{
        self.y = SCREEN_HEIGHT;
        self.contentView.y = 2*SCREEN_HEIGHT - 154;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
