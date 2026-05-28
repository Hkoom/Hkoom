#import <UIKit/UIKit.h>
#import <substrate.h>

// ─── مفاتيح الحفظ ───────────────────────────────────────────
#define kWelcomeShown   @"hkoom_welcome_shown"
#define kThemeColor     @"hkoom_theme_color"
#define kAppDomain      @"com.hkoom.tweak"

// ─── استرجاع اللون المحفوظ ───────────────────────────────────
static UIColor *savedThemeColor() {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kAppDomain];
    NSData *data = [d objectForKey:kThemeColor];
    if (!data) return [UIColor systemPurpleColor];
    UIColor *c = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                   fromData:data
                                                      error:nil];
    return c ?: [UIColor systemPurpleColor];
}

static void saveThemeColor(UIColor *color) {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kAppDomain];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:color
                                        requiringSecureCoding:YES
                                                        error:nil];
    [d setObject:data forKey:kThemeColor];
    [d synchronize];
}

// ═══════════════════════════════════════════════════════════════
// شاشة الترحيب
// ═══════════════════════════════════════════════════════════════
@interface HkoomWelcomeView : UIView
+ (void)showIfNeeded;
@end

@implementation HkoomWelcomeView

+ (void)showIfNeeded {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kAppDomain];
    if ([d boolForKey:kWelcomeShown]) return;
    [d setBool:YES forKey:kWelcomeShown];
    [d synchronize];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        // ── الخلفية الكاملة ──
        HkoomWelcomeView *overlay = [[HkoomWelcomeView alloc]
                                      initWithFrame:win.bounds];
        overlay.alpha = 0;
        [win addSubview:overlay];

        // ── gradient زاهي ──
        CAGradientLayer *grad = [CAGradientLayer layer];
        grad.frame = overlay.bounds;
        grad.colors = @[
            (id)[UIColor colorWithRed:0.58 green:0.00 blue:0.83 alpha:1].CGColor,
            (id)[UIColor colorWithRed:0.99 green:0.27 blue:0.55 alpha:1].CGColor,
            (id)[UIColor colorWithRed:1.00 green:0.55 blue:0.00 alpha:1].CGColor
        ];
        grad.startPoint = CGPointMake(0, 0);
        grad.endPoint   = CGPointMake(1, 1);
        [overlay.layer addSublayer:grad];

        // ── بطاقة بيضاء في المنتصف ──
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 340)];
        card.center = overlay.center;
        card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        card.layer.cornerRadius = 28;
        card.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
        card.layer.borderWidth = 1.5;
        // blur effect
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurV = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurV.frame = card.bounds;
        blurV.layer.cornerRadius = 28;
        blurV.clipsToBounds = YES;
        [card addSubview:blurV];

        // ── أيقونة emoji كبيرة ──
        UILabel *emoji = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 300, 80)];
        emoji.text = @"👑";
        emoji.font = [UIFont systemFontOfSize:64];
        emoji.textAlignment = NSTextAlignmentCenter;
        [card addSubview:emoji];

        // ── النص الرئيسي ──
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 260, 50)];
        title.text = @"أهلاً وسهلاً";
        title.font = [UIFont boldSystemFontOfSize:28];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        [card addSubview:title];

        // ── النص الفرعي ──
        UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(20, 178, 260, 60)];
        sub.text = @"بالغالي\nمعك حكووم 🤍";
        sub.font = [UIFont systemFontOfSize:18];
        sub.textColor = [UIColor colorWithWhite:1 alpha:0.92];
        sub.textAlignment = NSTextAlignmentCenter;
        sub.numberOfLines = 2;
        [card addSubview:sub];

        // ── خط فاصل ──
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(60, 248, 180, 1)];
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [card addSubview:line];

        // ── زر إغلاق ──
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(70, 264, 160, 46);
        [btn setTitle:@"ابدأ الاستخدام ✨" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        btn.layer.cornerRadius = 23;
        btn.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        btn.layer.borderWidth = 1;
        [btn addTarget:overlay
                action:@selector(dismiss)
      forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:btn];

        [overlay addSubview:card];

        // ── حركة ظهور ──
        card.transform = CGAffineTransformMakeScale(0.7, 0.7);
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.5
                            options:0
                         animations:^{
            overlay.alpha = 1;
            card.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
}

- (void)dismiss {
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL done) {
        [self removeFromSuperview];
    }];
}

@end

// ═══════════════════════════════════════════════════════════════
// منتقي الألوان (color picker)
// ═══════════════════════════════════════════════════════════════
@interface HkoomColorPickerVC : UIViewController
    <UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) UIColorPickerViewController *picker;
@property (nonatomic, copy)   void (^onColorPicked)(UIColor *);
@end

@implementation HkoomColorPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"اختر اللون 🎨";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // عرض اللون الحالي
    UIView *preview = [[UIView alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 60)];
    preview.backgroundColor = savedThemeColor();
    preview.layer.cornerRadius = 16;
    preview.tag = 99;
    [self.view addSubview:preview];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, 30)];
    lbl.text = @"اللون الحالي";
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:lbl];

    // زر فتح Color Picker
    UIButton *pickBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pickBtn.frame = CGRectMake(20, 210, self.view.bounds.size.width - 40, 50);
    [pickBtn setTitle:@"🎨  اختر لوناً جديداً" forState:UIControlStateNormal];
    pickBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    pickBtn.backgroundColor = savedThemeColor();
    pickBtn.tintColor = [UIColor whiteColor];
    pickBtn.layer.cornerRadius = 14;
    pickBtn.tag = 100;
    [pickBtn addTarget:self action:@selector(openPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickBtn];

    // أزرار ألوان سريعة
    NSArray *quickColors = @[
        [UIColor systemPurpleColor],
        [UIColor systemPinkColor],
        [UIColor systemBlueColor],
        [UIColor systemTealColor],
        [UIColor systemOrangeColor],
        [UIColor systemRedColor],
    ];
    CGFloat bw = 50, gap = (self.view.bounds.size.width - 40 - bw*6) / 5;
    for (int i = 0; i < quickColors.count; i++) {
        UIButton *qb = [UIButton buttonWithType:UIButtonTypeCustom];
        qb.frame = CGRectMake(20 + i*(bw+gap), 286, bw, bw);
        qb.backgroundColor = quickColors[i];
        qb.layer.cornerRadius = bw/2;
        qb.layer.borderWidth = 2;
        qb.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
        qb.tag = 200 + i;
        [qb addTarget:self action:@selector(quickColor:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:qb];
    }

    UILabel *ql = [[UILabel alloc] initWithFrame:CGRectMake(0, 260, self.view.bounds.size.width, 22)];
    ql.text = @"ألوان سريعة";
    ql.textAlignment = NSTextAlignmentCenter;
    ql.font = [UIFont systemFontOfSize:13];
    ql.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:ql];
}

- (void)openPicker {
    UIColorPickerViewController *cp = [[UIColorPickerViewController alloc] init];
    cp.selectedColor = savedThemeColor();
    cp.delegate = self;
    [self presentViewController:cp animated:YES completion:nil];
}

- (void)quickColor:(UIButton *)btn {
    NSArray *quickColors = @[
        [UIColor systemPurpleColor],[UIColor systemPinkColor],
        [UIColor systemBlueColor],[UIColor systemTealColor],
        [UIColor systemOrangeColor],[UIColor systemRedColor],
    ];
    UIColor *c = quickColors[btn.tag - 200];
    [self applyColor:c];
}

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)vp {
    [self applyColor:vp.selectedColor];
}

- (void)applyColor:(UIColor *)color {
    saveThemeColor(color);
    // تحديث preview والأزرار
    UIView *preview = [self.view viewWithTag:99];
    preview.backgroundColor = color;
    UIButton *pickBtn = (UIButton *)[self.view viewWithTag:100];
    pickBtn.backgroundColor = color;
    if (self.onColorPicked) self.onColorPicked(color);
    // إشعار باقي الـ views
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"HkoomThemeColorChanged"
                      object:color];
}

@end

// ═══════════════════════════════════════════════════════════════
// Hook — تطبيق اللون على Navigation Bar
// ═══════════════════════════════════════════════════════════════
%hook UINavigationBar

- (void)layoutSubviews {
    %orig;
    // تطبيق اللون فقط داخل إعدادات hkoom
    NSString *title = self.topItem.title;
    if ([title containsString:@"hkoom"] || [title containsString:@"حكووم"]) {
        UIColor *tc = savedThemeColor();
        UINavigationBarAppearance *app = [[UINavigationBarAppearance alloc] init];
        [app configureWithOpaqueBackground];
        app.backgroundColor = tc;
        app.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.standardAppearance = app;
        self.scrollEdgeAppearance = app;
        self.tintColor = [UIColor whiteColor];
    }
}

%end

// ═══════════════════════════════════════════════════════════════
// Hook — تطبيق اللون على Cells داخل إعدادات التويك
// ═══════════════════════════════════════════════════════════════
%hook UITableViewCell

- (void)layoutSubviews {
    %orig;
    if ([NSStringFromClass(self.class) containsString:@"Beegram"] ||
        [NSStringFromClass(self.class) containsString:@"hkoom"]) {
        self.textLabel.textColor = savedThemeColor();
        self.imageView.tintColor = savedThemeColor();
    }
}

%end

// ═══════════════════════════════════════════════════════════════
// Hook — AppDelegate لإظهار رسالة الترحيب
// ═══════════════════════════════════════════════════════════════
%hook AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)app {
    %orig;
    [HkoomWelcomeView showIfNeeded];
}

%end

// ─── Constructor ─────────────────────────────────────────────
%ctor {
    // استماع لتغيير اللون وتطبيقه على كل الـ navigation bars
    [[NSNotificationCenter defaultCenter]
        addObserverForName:@"HkoomThemeColorChanged"
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *n) {
        // إعادة رسم الـ UI
        for (UIWindow *w in [UIApplication sharedApplication].windows) {
            [w.rootViewController.view setNeedsLayout];
        }
    }];
}
