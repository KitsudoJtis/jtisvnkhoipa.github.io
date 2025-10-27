// Tweak.xm
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Định nghĩa NSDictionary cho các bản dịch
static NSDictionary *translationDict = nil;

// Cache các NSRegularExpression
static NSDictionary<NSString *, NSRegularExpression *> *regexCache = nil;

// Danh sách các mẫu regex và bản dịch
static NSArray<NSDictionary *> *regexPatterns = nil;

// Hàm kiểm tra chuỗi hợp lệ
static BOOL isValidString(NSString *string) {
    return string != nil && [string isKindOfClass:[NSString class]] && string.length > 0;
}

// Hàm dịch văn bản
static NSString *translateText(NSString *originalText) {
    if (!isValidString(originalText)) return originalText;

    // Dịch bằng NSDictionary
    NSString *translated = translationDict[originalText];
    if (translated) return translated;

    // Dịch bằng regex
    NSString *result = originalText;
    for (NSDictionary *patternInfo in regexPatterns) {
        NSString *pattern = patternInfo[@"pattern"];
        NSString *replacement = patternInfo[@"replacement"];
        NSRegularExpression *regex = regexCache[pattern];
        if (regex) {
            result = [regex stringByReplacingMatchesInString:result
                                                    options:0
                                                      range:NSMakeRange(0, result.length)
                                               withTemplate:replacement];
        }
    }
    return result;
}

// Hàm khởi tạo dữ liệu dịch và regex
static void loadTranslations() {
    translationDict = @{
        @"Okey" : @"Ok",
        @"Refresh" : @"Làm mới",
        @"Done" : @"Xong",
        @"Cancel" : @"Huỷ",
        @"Continue" : @"Tiếp tục",
        @"AppList" : @"Danh sách Ứng dụng",
        @"Tips" : @"Gợi Ý",
        @"Developer" : @"Nhà phát triển",
        @"Manual" : @"Thủ công",
        @"Search name or identifier" : @"Tìm tên hoặc định danh...",
        @"\nClick on the app that needs to be downgraded or upgraded and wait for the version data to be loaded \n\nSelect the version that needs to be installed and then return to the desktop and wait for it to be installed \n\nThis app is only valid for official apps installed from the AppStore" : @"\n• Nhấp vào ứng dụng cần hạ cấp hoặc nâng cấp và đợi tải dữ liệu phiên bản \n\n• Chọn phiên bản cần cài đặt rồi quay lại màn hình desktop và đợi cài đặt\n\n• Ứng dụng này chỉ hợp lệ cho các ứng dụng chính thức được cài đặt từ AppStore\nViệt Hoá bởi JTISVN",
        @"DOWNGRADE MODE" : @"Chế Độ Hạ Cấp",
        @"@Netskao" : @"@Netskao - Việt Hoá bởi @Kitsudo",
        @"Switch AppStore Accounts" : @"Chuyển đổi tài khoản AppStore",
        @"AppStore Account List" : @"Danh sách tài khoản AppStore",
        @"SWIPE LEFT TO QUICKLY DELETE LOGGED IN ACCOUNTS" : @"Vuốt sang trái để XÓA NHANH TÀI KHOẢN ĐÃ ĐĂNG NHẬP",
        @"Quickly switch between logged-in accounts in the AppStore" : @"Chuyển đổi nhanh giữa các tài khoản đã đăng nhập trong AppStore",
        @"Current Version" : @"Phiên Bản",
        @"Follow Channel" : @"Kênh Telegram",
        @"Follow Author" : @"Theo Dõi Tác Giả",
        @"Data Source" : @"Nguồn Dữ Liệu",
        @"See other applications to learn more" : @"Xem các ứng dụng khác để tìm hiểu thêm",
        @"Explore more fun together at Twitter" : @"Cùng nhau khám phá nhiều niềm vui hơn tại Twitter",
        @"Online version data from bilin.eu.org / sharklatan.com / i4.cn" : @"Dữ liệu phiên bản trực tuyến từ bilin.eu.org / sharklatan.com / i4.cn",
        @"DEVELOPER" : @"Nhà Phát Triển",
        @"Get Version Data..." : @"Đang Tìm Phiên Bản...",
        @"DowngradeApp © 2018 - 2024\n\nDeveloped ♥︎ by Netskao\n\n不要为了越狱放弃升级的乐趣\n\nAll Rights Reserved By initnil.com" : @"DowngradeApp © 2018 - 2024\n\nDeveloped ♥︎ bởi Netskao\nTranslation ♥︎ bởi Kitsudo\n\n不要为了越狱放弃升级的乐趣\n\nAll Rights Reserved By initnil.com",
    };

    regexPatterns = @[
@{
            @"pattern": @"Name:([^’']+)\nVersion:([^’']+)\nIdentifier:([^’']+)",
            @"replacement": @"Tên: $1\nPhiên bản:$2\nĐịnh danh:$3",
            @"options": @(NSRegularExpressionCaseInsensitive)
        },
@{
            @"pattern": @"Version ([^’']+)",
            @"replacement": @"Phiên bản  $1",
            @"options": @(NSRegularExpressionCaseInsensitive)
        },
@{
            @"pattern": @"Please enter the ID number of the version that needs to be downgraded or upgraded",
            @"replacement": @"Vui lòng nhập mã ID của phiên bản cần hạ cấp hoặc nâng cấp",
            @"options": @(NSRegularExpressionCaseInsensitive)
        },
@{
            @"pattern": @"Name:\nVersion:([^’']+)\nIdentifier:([^’']+)",
            @"replacement": @"Tên: \nPhiên bản:$1\nĐịnh danh:$2",
            @"options": @(NSRegularExpressionCaseInsensitive)
        },
    ];

    // Cache NSRegularExpression
    NSMutableDictionary *tempRegexCache = [NSMutableDictionary dictionary];
    NSError *error = nil;

    for (NSDictionary *patternInfo in regexPatterns) {
        NSString *pattern = patternInfo[@"pattern"];
        NSRegularExpressionOptions options = [patternInfo[@"options"] unsignedIntegerValue];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                              options:options
                                                                                error:&error];
        if (!error && regex) {
            tempRegexCache[pattern] = regex;
        } else if (error) {
            NSLog(@"[TranslationTweak] Regex error for pattern %@: %@", pattern, error.localizedDescription);
        }
    }

    regexCache = [tempRegexCache copy];
}

// Hook UILabel
%hook UILabel
- (void)setText:(NSString *)text {
    if (isValidString(text)) {
        %orig(translateText(text));
    } else {
        %orig(text);
    }
}
%end

// Hook UITextView
%hook UITextView
- (void)setText:(NSString *)text {
    if (isValidString(text)) {
        %orig(translateText(text));
    } else {
        %orig(text);
    }
}
%end

// Hook UIButton
%hook UIButton
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    if (isValidString(title)) {
        %orig(translateText(title), state);
    } else {
        %orig(title, state);
    }
}
%end

// Hook UIAlertController
%hook UIAlertController
- (void)setTitle:(NSString *)title {
    if (isValidString(title)) {
        %orig(translateText(title));
    } else {
        %orig(title);
    }
}
- (void)setMessage:(NSString *)message {
    if (isValidString(message)) {
        %orig(translateText(message));
    } else {
        %orig(message);
    }
}
%end

// Hook UINavigationItem
%hook UINavigationItem
- (void)setTitle:(NSString *)title {
    if (isValidString(title)) {
        %orig(translateText(title));
    } else {
        %orig(title);
    }
}
%end

// Hook UITextField
%hook UITextField
- (void)setPlaceholder:(NSString *)placeholder {
    if (isValidString(placeholder)) {
        %orig(translateText(placeholder));
    } else {
        %orig(placeholder);
    }
}
%end

// Hook NSAttributedString trong UILabel - ĐÃ SỬA LỖI
%hook UILabel
- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText && attributedText.length > 0) {
        NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] init];
        
        // Vòng lặp duyệt qua từng đoạn có attributes khác nhau
        [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length)
                                           options:0
                                        usingBlock:^(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop) {
            // Lấy chuỗi con và dịch nó
            NSString *substring = [attributedText.string substringWithRange:range];
            NSString *translatedSubstring = translateText(substring);
            
            // Tạo attributed string mới với chuỗi đã dịch và attributes cũ
            NSAttributedString *newSubAttributedString = [[NSAttributedString alloc] initWithString:translatedSubstring attributes:attrs];
            
            // Nối vào kết quả cuối cùng
            [newAttributedString appendAttributedString:newSubAttributedString];
        }];
        
        %orig(newAttributedString);
    } else {
        %orig(attributedText);
    }
}
%end


// Hook UIApplication
%hook UIApplication
- (NSString *)displayName {
    NSString *originalName = %orig;
    return isValidString(originalName) ? translateText(originalName) : originalName;
}
%end

// Constructor
%ctor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            loadTranslations();
            if (@available(iOS 15.0, *)) {
                %init;
            } else {
                NSLog(@"[TranslationTweak] This tweak requires iOS 14 or later.");
            }
        }
    });
}