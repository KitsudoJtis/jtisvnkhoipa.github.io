#import <UIKit/UIKit.h>
#import "main.h"
#import "SCLAlertView/SCLAlertView.h"

// Màu từ HEX
#define UIColorFromHEX(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

SCLAlertView *alert;

@implementation KitsudoFramework
static KitsudoFramework *active;

+ (void)load {
    // Hiển popup ngay khi mở app
    dispatch_async(dispatch_get_main_queue(), ^{
        alert = [[SCLAlertView alloc] initWithNewWindow];
        active = [KitsudoFramework new];
        [active start];
    });
}

- (void)start {
    // Hiệu ứng hiển thị
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSlideInToCenter;
    alert.backgroundType = SCLAlertViewBackgroundTransparent;
    alert.cornerRadius = 20.0f;

    // Màu nền và màu nút
    alert.backgroundViewColor = UIColorFromHEX(0x2E2B35);
    alert.customViewColor = UIColorFromHEX(0x40E0D0);

    // Link và các nút
    [alert addButton:@" KÊNH TELEGRAM " actionBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/jtisvn"]
                                           options:@{} completionHandler:nil];
    }];
    [alert addButton:@" TELEGRAM CHAT " actionBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/jailbreaktrolliossupport"]
                                           options:@{} completionHandler:nil];
    }];
    [alert addButton:@" TELEGRAM ADMIN " actionBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/Kitsudo"]
                                           options:@{} completionHandler:nil];
    }];
    [alert addButton:@" FACEBOOK GROUP " actionBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/share/g/1NBGe3sM87/?mibextid=wwXIfr"]
                                           options:@{} completionHandler:nil];
    }];
    [alert addButton:@" ỦNG HỘ JTISVN " actionBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://jtisvn.github.io/donate/donate.html"]
                                           options:@{} completionHandler:nil];
    }];

    // Tải và bo tròn logo
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://jtisvn.github.io/icons/avatar.webp"]];
    UIImage *logoImage = [UIImage imageWithData:data];
    UIGraphicsBeginImageContextWithOptions(logoImage.size, NO, logoImage.scale);
    CGRect rect = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:logoImage.size.width / 2] addClip];
    [logoImage drawInRect:rect];
    UIImage *roundedLogo = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Hiển thị popup
    [alert showCustom:alert
                image:roundedLogo
                color:[UIColor clearColor]
                title:@"JTISVN REPO "
             subTitle:@"Cảm ơn bạn đã theo dõi JTISVN.\nBấm vào Logo để tắt thông báo."
     closeButtonTitle:nil
             duration:9999999999.0f];

    // Tuỳ chỉnh giao diện
    UIView *alertContainer = [alert valueForKey:@"contentView"];
    if (alertContainer) {
        alertContainer.layer.cornerRadius = 18.0;
        alertContainer.layer.masksToBounds = YES;

        // --- Viền xanh lá ---
        CAGradientLayer *gradientBorder = [CAGradientLayer layer];
        gradientBorder.colors = @[
            (id)UIColorFromHEX(0x7FFF9F).CGColor,
            (id)UIColorFromHEX(0x3CFF7F).CGColor
        ];
        gradientBorder.startPoint = CGPointMake(0, 0);
        gradientBorder.endPoint = CGPointMake(1, 1);
        gradientBorder.frame = alertContainer.bounds;

        CAShapeLayer *shape = [CAShapeLayer layer];
        CGFloat corner = 18.0;
        shape.path = [UIBezierPath bezierPathWithRoundedRect:alertContainer.bounds cornerRadius:corner].CGPath;
        shape.lineWidth = 3.0f;
        shape.fillColor = UIColor.clearColor.CGColor;
        shape.strokeColor = UIColor.blackColor.CGColor;
        gradientBorder.mask = shape;
        [alertContainer.layer addSublayer:gradientBorder];

        // --- Hiệu ứng phát sáng (glow) ---
        alertContainer.layer.shadowColor = UIColorFromHEX(0x3CFF7F).CGColor;
        alertContainer.layer.shadowOpacity = 0.6;
        alertContainer.layer.shadowRadius = 18.0;
        alertContainer.layer.shadowOffset = CGSizeZero;
    }

    // Đổi màu tiêu đề
    UILabel *titleLabel = [alert valueForKey:@"labelTitle"];
    if (titleLabel) titleLabel.textColor = UIColorFromHEX(0x9B8AFF);
}

@end