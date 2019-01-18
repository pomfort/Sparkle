//
//  SUUpdateSettingsWindowController.m
//  Sparkle
//
//  Created by Mayur Pawashe on 7/25/15.
//  Copyright (c) 2015 Sparkle Project. All rights reserved.
//

#import "SUUpdateSettingsWindowController.h"
#import <Sparkle/Sparkle.h>

@interface SUUpdateSettingsWindowController ()<SUUpdaterDelegate>

@property (nonatomic) IBOutlet SUUpdater *updater;

@end

@implementation SUUpdateSettingsWindowController

@synthesize updater = _updater;

- (void)awakeFromNib
{
    self.updater.delegate = self;
}

- (NSString *)windowNibName
{
    return NSStringFromClass([self class]);
}

- (IBAction)checkForUpdates:(id __unused)sender
{
    [self.updater checkForUpdates:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(checkForUpdates:)) {
        return [self.updater validateMenuItem:menuItem];
    }
    return YES;
}

#pragma mark - Sparkle Delegate

- (BOOL)itemContainsValidUpdate:(SUAppcastItem *)item forUpdater:(__unused SUUpdater *)updater validationError:(NSError * _Nullable __autoreleasing *)validationError
{
    NSDictionary *envelope = [item.propertiesDictionary objectForKey:@"enclosure"];
    NSString *majorVersionString = [envelope objectForKey:@"major-version"];
    int majorVersion = [majorVersionString intValue];

    if(majorVersion > 1) {
        if(validationError != nil) {
            *validationError = [NSError errorWithDomain:@"com.custom.validation" code:-1 userInfo:@{
                                                                                                    @"major-version" : majorVersionString,
                                                                                                    }];
        }
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)showUpdateValidationError:(NSError *)validationError forUpdater:(__unused SUUpdater *)updater
{
    if([validationError.domain isEqualToString:@"com.custom.validation"]) {
        if(validationError.code == -1) {
            NSString *majorVersion = [validationError.userInfo valueForKey:@"major-version"];

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"New Major Version %@ has been released", majorVersion];
            alert.informativeText = @"Download the newest version from our website";
            [alert addButtonWithTitle:@"Download new version"];
            [alert addButtonWithTitle:@"Close"];

            NSModalResponse response = [alert runModal];

            if(response == NSAlertFirstButtonReturn) {
                NSURL *downloadURL = [NSURL URLWithString:@"https://pomfort.com/livegradepro/what-is-new/"];
                [[NSWorkspace sharedWorkspace] openURL:downloadURL];
            }

            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

@end
