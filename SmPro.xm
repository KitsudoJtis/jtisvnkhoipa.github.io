#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "m.h"

__attribute__((constructor))
static void init_hook() {
    static NSArray<NSString *> *keywords;
    static NSMutableArray *retainedBlocks; // giữ block tránh bị ARC thu hồi

    keywords = @[
        NSSENCRYPT("Restore Defaults"),
        NSSENCRYPT("vip")
    ];
    
    retainedBlocks = [NSMutableArray array];

    SEL sel = @selector(setText:);
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);

    for (unsigned int i = 0; i < classCount; i++) {
        Class cls = classes[i];

        // Bỏ qua các lớp hệ thống không nên hook
        const char *name = class_getName(cls);
        if (strncmp(name, "NS", 2) == 0 || strncmp(name, "UIKB", 4) == 0) continue;

        Method method = class_getInstanceMethod(cls, sel);
        if (!method) continue;

        // Kiểm tra chữ ký method để đảm bảo nhận NSString *
        char returnType[256];
        char argType[256];
        method_getReturnType(method, returnType, sizeof(returnType));
        method_getArgumentType(method, 2, argType, sizeof(argType)); // arg 0 = self, 1 = _cmd, 2 = text

        if (strcmp(returnType, "v") != 0 || strcmp(argType, "@") != 0) continue; // trả về void, nhận NSString *

        IMP originalIMP = method_getImplementation(method);

        // Block hook
        id block = ^(id self, NSString *text) {
            for (NSString *key in keywords) {
                if ([text.lowercaseString containsString:key.lowercaseString]) {
                    text = NSSENCRYPT("Crafted with ♥ by @kitsudo");
                    break;
                }
            }
            ((void(*)(id, SEL, NSString *))originalIMP)(self, sel, text);
        };

        IMP newIMP = imp_implementationWithBlock(block);
        [retainedBlocks addObject:[block copy]]; // giữ block tránh bị thu hồi
        method_setImplementation(method, newIMP);
    }

    free(classes);
}