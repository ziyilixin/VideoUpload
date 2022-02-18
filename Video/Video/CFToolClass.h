//
//  CFToolClass.h
//  Video
//
//  Created by zzqtkj on 2021/9/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CFToolClass : NSObject
/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;

/**
 设置视图左上圆角
 
 @param leftC 左上半径
 @param rightC 右上半径
 @param view 父视图
 @return layer
 */
- (CAShapeLayer *)setViewLeftTop:(CGFloat)leftC andRightTop:(CGFloat)rightC andView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
