//
//  CFToolClass.m
//  Video
//
//  Created by zzqtkj on 2021/9/11.
//

#import "CFToolClass.h"

@implementation CFToolClass
static CFToolClass* kSingleObject = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSingleObject = [[super allocWithZone:NULL] init];
    });
    
    return kSingleObject;
}

/**
 设置视图左上圆角
 
 @param leftC 左上半径
 @param rightC 又上半径
 @param view 父视图
 @return layer
 */
- (CAShapeLayer *)setViewLeftTop:(CGFloat)leftC andRightTop:(CGFloat)rightC andView:(UIView *)view{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(leftC, rightC)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}
@end
