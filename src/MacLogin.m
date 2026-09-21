#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

static NSString * const kFixedPassword = @"123456";
@class MLLoginController;
static MLLoginController *gLoginController = nil;

@interface MLLoginController : NSObject <NSWindowDelegate>
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) NSSecureTextField *passwordField;
@property(nonatomic, strong) NSTextField *statusLabel;
@end

@implementation MLLoginController

- (void)showLoginWindow {
    if (self.window != nil) {
        [self.window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        return;
    }

    NSRect frame = NSMakeRect(0, 0, 380, 220);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                               styleMask:(NSWindowStyleMaskTitled |
                                                          NSWindowStyleMaskClosable |
                                                          NSWindowStyleMaskMiniaturizable)
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    self.window.title = @"Login";
    self.window.delegate = self;
    self.window.releasedWhenClosed = NO;
    self.window.level = NSModalPanelWindowLevel;

    NSView *content = self.window.contentView;

    NSTextField *title = [NSTextField labelWithString:@"Acesso restrito"];
    title.font = [NSFont boldSystemFontOfSize:20.0];
    title.alignment = NSTextAlignmentCenter;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:title];

    NSTextField *hint = [NSTextField labelWithString:@"Digite a senha para continuar"];
    hint.alignment = NSTextAlignmentCenter;
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:hint];

    self.passwordField = [[NSSecureTextField alloc] initWithFrame:NSZeroRect];
    self.passwordField.placeholderString = @"Senha";
    self.passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordField.target = self;
    self.passwordField.action = @selector(submit:);
    [content addSubview:self.passwordField];

    NSButton *button = [NSButton buttonWithTitle:@"Entrar" target:self action:@selector(submit:)];
    button.bezelStyle = NSBezelStyleRounded;
    button.keyEquivalent = @"\r";
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:button];

    self.statusLabel = [NSTextField labelWithString:@""];
    self.statusLabel.textColor = [NSColor systemRedColor];
    self.statusLabel.alignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:self.statusLabel];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:content.topAnchor constant:24.0],
        [title.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24.0],
        [title.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24.0],
        [hint.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:8.0],
        [hint.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24.0],
        [hint.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24.0],
        [self.passwordField.topAnchor constraintEqualToAnchor:hint.bottomAnchor constant:18.0],
        [self.passwordField.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:50.0],
        [self.passwordField.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-50.0],
        [self.passwordField.heightAnchor constraintEqualToConstant:28.0],
        [button.topAnchor constraintEqualToAnchor:self.passwordField.bottomAnchor constant:14.0],
        [button.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],
        [button.widthAnchor constraintEqualToConstant:100.0],
        [self.statusLabel.topAnchor constraintEqualToAnchor:button.bottomAnchor constant:8.0],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24.0],
        [self.statusLabel.bottomAnchor constraintLessThanOrEqualToAnchor:content.bottomAnchor constant:-12.0]
    ]];

    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    [self.passwordField becomeFirstResponder];
}

- (void)submit:(id)sender {
    if ([self.passwordField.stringValue isEqualToString:kFixedPassword]) {
        [self.window orderOut:nil];
        self.passwordField.stringValue = @"";
        self.statusLabel.stringValue = @"";
    } else {
        self.statusLabel.stringValue = @"Senha incorreta.";
        self.passwordField.stringValue = @"";
        [self.passwordField becomeFirstResponder];
    }
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    // Fechar a janela não encerra o aplicativo hospedeiro.
    return YES;
}

@end

__attribute__((visibility("default")))
void MLD_ShowLogin(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gLoginController == nil) {
            gLoginController = [[MLLoginController alloc] init];
        }
        [gLoginController showLoginWindow];
    });
}

__attribute__((constructor))
static void MLD_Initialize(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        MLD_ShowLogin();
    });
}

__attribute__((destructor))
static void MLD_Finalize(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [gLoginController.window orderOut:nil];
        gLoginController = nil;
    });
}
