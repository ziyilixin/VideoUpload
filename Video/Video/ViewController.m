//
//  ViewController.m
//  Video
//
//  Created by zzqtkj on 2021/9/11.
//

#define MAS_SHORTHAND
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define maxTime 10.0

#define RGB_COLOR(_STR_,a) ([UIColor colorWithRed:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(1, 2)] UTF8String], 0, 16)] intValue] / 255.0 green:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(3, 2)] UTF8String], 0, 16)] intValue] / 255.0 blue:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(5, 2)] UTF8String], 0, 16)] intValue] / 255.0 alpha:a])

#import "ViewController.h"
#import "Masonry.h"
#import "UploadVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *picImageView;
@property (nonatomic,strong)NSString *filePath;
@property (nonatomic,strong)NSString *imagePath;
@property (nonatomic, strong) NSData *videoData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *picImageView = [[UIImageView alloc] init];
    picImageView.image = [UIImage imageNamed:@"upload_video"];
    picImageView.userInteractionEnabled = YES;
    [self.view addSubview:picImageView];
    self.picImageView = picImageView;
    [self.picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(100);
        make.width.height.mas_equalTo(100);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadVideo)];
    [self.picImageView addGestureRecognizer:tap];
}

- (void)uploadVideo {
    
    UploadVideoView *uploadVideo = [[UploadVideoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    uploadVideo.backgroundColor = RGB_COLOR(@"#000000", 0.5);
    uploadVideo.block = ^{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.delegate = self;
            ipc.allowsEditing = YES;
            ipc.videoMaximumDuration = maxTime;//最长时间
            ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            //ipc.videoQuality = UIImagePickerControllerQualityTypeHigh;
            ipc.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
            
            if (@available(iOS 11.0,*)) {
                [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
            }
            
            [self presentViewController:ipc animated:YES completion:nil];
        }
    };
    [self.view addSubview:uploadVideo];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    if (@available(iOS 11.0,*)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];

        CMTime time = [asset duration];
        int seconds = ceil(time.value / time.timescale);

        if (seconds > maxTime) {
            NSLog(@"最多上传%.2f秒内视频",maxTime);
            [picker dismissViewControllerAnimated:YES completion:nil];
            return;
        }

        NSString *videoPath = info[UIImagePickerControllerMediaURL];
        NSLog(@"相册视频路径是: %@",videoPath);
        //进行视频导出
        [self startExportVideoWithVideoAsset:asset completion:^(NSString *outputPath) {
            [self getSomeMessageWithFilePath:self.filePath];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:outputPath]];
            self.videoData = data;
        }];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSString *outputPath))completion {
    
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    NSString *pre = nil;
    if ([presets containsObject:AVAssetExportPreset3840x2160]) {
        pre = AVAssetExportPreset3840x2160;
    }
    else if ([presets containsObject:AVAssetExportPreset1920x1080]) {
        pre = AVAssetExportPreset1920x1080;
    }
    else if ([presets containsObject:AVAssetExportPreset1280x720]) {
        pre = AVAssetExportPreset1280x720;
    }
    else if ([presets containsObject:AVAssetExportPreset960x540]) {
        pre = AVAssetExportPreset960x540;
    }
    else {
        pre = AVAssetExportPreset640x480;
    }
    
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[[formater stringFromDate:[NSDate date]] stringByAppendingString:@".mov"]];
        NSLog(@"video outputPath = %@",outputPath);
        
        //删除原来的 防止重复选
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:self.imagePath error:nil];
        
        self.filePath = outputPath;
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        session.shouldOptimizeForNetworkUse = YES;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        }
        else if (supportedTypeArray.count == 0) {
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        }
        else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
        }
        
        //Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void){
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown"); break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting"); break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting"); break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(outputPath);
                        }
                    });
                }  break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed"); break;
                default: break;
            }
        }];
        
    }
}

//获取视频第一帧
- (void)getSomeMessageWithFilePath:(NSString *)filePath {
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [AVURLAsset assetWithURL:fileUrl];
    self.picImageView.image = [self getImageWithAsset:asset];
}

- (UIImage *)getImageWithAsset:(AVAsset *)asset {
    
    AVURLAsset *assetUrl = (AVURLAsset *)asset;
    NSParameterAssert(assetUrl);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:assetUrl];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = 0;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

@end
