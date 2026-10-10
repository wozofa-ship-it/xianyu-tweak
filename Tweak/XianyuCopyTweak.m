#import <UIKit/UIKit.h>

// ============ 文案引擎（零表情·多样化·无价格·海口固定） ============
static NSString *pick(NSArray *a) { return a[arc4random_uniform((uint32_t)a.count)]; }
static NSArray *pickN(NSArray *a, NSUInteger n) {
    NSMutableArray *c = [a mutableCopy], *o = [NSMutableArray array];
    while (o.count < n && c.count) {
        id it = c[arc4random_uniform((uint32_t)c.count)];
        [o addObject:it]; [c removeObject:it];
    }
    return o;
}
// 用户可配置项，存 NSUserDefaults
static NSString *cfg(NSString *k, NSString *def) {
    NSString *v = [[NSUserDefaults standardUserDefaults] stringForKey:k];
    return (v.length ? v : def);
}
static NSString *fillTpl(NSString *s) {
    s = [s stringByReplacingOccurrencesOfString:@"{service}" withString:cfg(@"xy_service", @"墙面翻新刷漆")];
    s = [s stringByReplacingOccurrencesOfString:@"{contact}" withString:cfg(@"xy_contact", @"闲鱼私聊联系")];
    return s;
}
static void genCopy(NSString **outTitle, NSString **outDesc) {
    NSArray *titles = @[
        @"专业{service}老师傅 免费上门看活",
        @"海口{service} 十年经验 靠谱实在",
        @"{service}上门服务 海口 当天可约",
        @"老师傅{service} 做不好不收钱",
        @"海口{service} 包工包料价格实在",
        @"{service} 海口 口碑老店",
        @"专业{service} 海口 免费报价",
        @"{service} 海口 先看活后定价",
    ];
    NSArray *openers = @[
        @"专业{service}老师傅，海口本地施工队",
        @"海口专业{service}，十几年施工经验",
        @"老师傅承接{service}，海口及周边都可上门",
        @"{service}找老师傅，海口本地人，靠谱实在",
        @"承接各类{service}工程，海口免费上门看活",
        @"海口{service}老师傅，口碑老店，价格实在",
    ];
    NSArray *intros = @[
        @"主做墙面翻新、刮腻子、刷乳胶漆、局部修补，家装工装都接，大小活不挑。",
        @"墙面发霉、开裂、脱皮、泛黄，旧房翻新、二手房刷新，统统搞定。",
        @"新房装修刷漆、旧墙翻新、出租房快速刷新、办公室店铺翻新都有做。",
        @"铲墙皮、批腻子、打磨、上漆一条龙，材料可包工包料也可单出人工。",
        @"局部修补也接，磕碰掉皮、钉眼裂缝、水渍霉斑，当天修当天好。",
        @"环保漆、儿童漆、无味漆都可安排，老人小孩住的房子更要注意环保。",
    ];
    NSArray *points = @[
        @"免费上门看活，现场报价，报价透明无增项",
        @"家具地面全覆盖保护，完工清理现场，干净交工",
        @"十年以上老师傅带队，手艺过硬，细节到位",
        @"做不好不收钱，不满意免费返工",
        @"材料可自带可包料，立邦、多乐士等品牌漆可选",
        @"当天可安排上门，工期短，家装一般2-3天完工",
        @"一年内开裂起皮免费保修，售后有保障",
        @"价格实在，中间不加价，报价就是实价",
        @"回头客和转介绍多，口碑说话",
        @"早8点到晚8点都可联系，响应快",
    ];
    NSArray *closers = @[
        @"有需要的直接联系，免费咨询免费报价。",
        @"先看活后报价，合适再定，不合适交个朋友。",
        @"活干不好不要钱，靠口碑吃饭。",
        @"随时联系，当天可安排上门看活。",
        @"价格好商量，活好才是硬道理。",
        @"欢迎比价，比的是手艺和实在。",
    ];
    NSString *title = fillTpl(pick(titles));
    if (title.length > 30) title = [title substringToIndex:30];
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[fillTpl(pick(openers)) stringByAppendingString:@"。"]];
    [lines addObject:@""];
    [lines addObject:fillTpl(pick(intros))];
    [lines addObject:@""];
    [lines addObject:@"【服务优势】"];
    NSArray *pts = pickN(points, 3 + arc4random_uniform(2));
    for (NSUInteger i = 0; i < pts.count; i++)
        [lines addObject:[NSString stringWithFormat:@"%lu、%@", (unsigned long)i+1, pts[i]]];
    [lines addObject:@""];
    [lines addObject:@"【价格】看活报价，价格面议，报价透明无增项"];
    [lines addObject:@"【区域】海口及周边"];
    [lines addObject:[NSString stringWithFormat:@"【联系】%@", cfg(@"xy_contact", @"闲鱼私聊联系")]];
    [lines addObject:@""];
    [lines addObject:pick(closers)];
    *outTitle = title;
    *outDesc = [lines componentsJoinedByString:@"\n"];
}

// ============ 悬浮窗 ============
static UIWindow *floatWindow;
static UIButton *floatBtn;

@interface FloatDrag : NSObject @end
@implementation FloatDrag
+ (void)drag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
@end

static UIViewController *topVC(void) {
    UIWindow *key = nil;
    for (UIWindow *w in UIApplication.sharedApplication.windows)
        if (w.isKeyWindow) { key = w; break; }
    UIViewController *vc = key.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}
static void showToast(NSString *msg) {
    UILabel *t = [[UILabel alloc] init];
    t.text = msg; t.textColor = UIColor.whiteColor;
    t.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    t.textAlignment = NSTextAlignmentCenter; t.font = [UIFont systemFontOfSize:14];
    t.layer.cornerRadius = 8; t.clipsToBounds = YES;
    [t sizeToFit];
    t.frame = CGRectMake(0, 0, t.frame.size.width + 32, t.frame.size.height + 16);
    t.center = CGPointMake(floatWindow.bounds.size.width/2, floatWindow.bounds.size.height - 140);
    [floatWindow addSubview:t];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{ [t removeFromSuperview]; });
}

// ---- 设置面板 ----
static void showSettings(void) {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"文案设置"
        message:@"配置后点 AI 一键写，设置自动保存" preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *tf){
        tf.placeholder = @"服务类型"; tf.text = cfg(@"xy_service", @"墙面翻新刷漆");
    }];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *tf){
        tf.placeholder = @"联系方式"; tf.text = cfg(@"xy_contact", @"闲鱼私聊联系");
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"AI 一键写" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a){
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            NSString *s = ac.textFields[0].text; if (s.length) [d setObject:s forKey:@"xy_service"];
            NSString *c = ac.textFields[1].text; if (c.length) [d setObject:c forKey:@"xy_contact"];
            [d synchronize];
            // 生成并给选择
            NSString *title, *desc; genCopy(&title, &desc);
            UIAlertController *ac2 = [UIAlertController alertControllerWithTitle:@"文案已生成"
                message:[NSString stringWithFormat:@"标题：%@\n\n%@", title,
                    [desc substringToIndex:MIN(150, desc.length)]]
                preferredStyle:UIAlertControllerStyleAlert];
            [ac2 addAction:[UIAlertAction actionWithTitle:@"复制标题" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *x){ [UIPasteboard generalPasteboard].string = title; showToast(@"标题已复制"); }]];
            [ac2 addAction:[UIAlertAction actionWithTitle:@"复制描述" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *x){ [UIPasteboard generalPasteboard].string = desc; showToast(@"描述已复制"); }]];
            [ac2 addAction:[UIAlertAction actionWithTitle:@"换一版" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *x){ showSettings(); }]];
            [ac2 addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil]];
            [topVC() presentViewController:ac2 animated:YES completion:nil];
        }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [topVC() presentViewController:ac animated:YES completion:nil];
}

__attribute__((constructor))
static void tweakInit(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
        CGRect scr = UIScreen.mainScreen.bounds;
        floatWindow = [[UIWindow alloc] initWithFrame:scr];
        floatWindow.windowLevel = UIWindowLevelAlert + 1;
        floatWindow.backgroundColor = UIColor.clearColor;
        floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatBtn.frame = CGRectMake(scr.size.width - 76, scr.size.height - 220, 60, 60);
        floatBtn.layer.cornerRadius = 30;
        floatBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.45 blue:0.95 alpha:0.92];
        [floatBtn setTitle:@"文案" forState:UIControlStateNormal];
        floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [floatBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        floatBtn.layer.shadowColor = UIColor.blackColor.CGColor;
        floatBtn.layer.shadowOpacity = 0.3; floatBtn.layer.shadowOffset = CGSizeMake(0, 2);
        UIAction *tap = [UIAction actionWithHandler:^(__kindof UIAction *a){ showSettings(); }];
        [floatBtn addAction:tap forControlEvents:UIControlEventTouchUpInside];
        [floatBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc]
            initWithTarget:[FloatDrag class] action:@selector(drag:)]];
        // 让拖动和点击共存：拖动手势不吃掉点击
        for (UIGestureRecognizer *g in floatBtn.gestureRecognizers)
            if ([g isKindOfClass:[UIPanGestureRecognizer class]]) g.cancelsTouchesInView = NO;
        [floatWindow addSubview:floatBtn];
        floatWindow.hidden = NO;
    });
}
