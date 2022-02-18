//
//  UploadVideoView.h
//  yunbaolive
//
//  Created by Mac on 2020/9/17.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UploadVideoBlock)(void);

@interface UploadVideoView : UIView
@property (nonatomic, copy) UploadVideoBlock block;
@end

NS_ASSUME_NONNULL_END
