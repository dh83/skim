//
//  SKTemplateManager.m
//  Skim
//
//  Created by Christiaan Hofman on 8/19/11.
/*
 This software is Copyright (c) 2011-2012
 Christiaan Hofman. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Christiaan Hofman nor the names of any
    contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SKTemplateManager.h"
#import "NSFileManager_SKExtensions.h"
#import "NSString_SKExtensions.h"

#define TEMPLATES_DIRECTORY @"Templates"


@implementation SKTemplateManager

+ (id)sharedManager {
    static id sharedManager = nil;
    if (sharedManager == nil)
        sharedManager = [[self alloc] init];
    return sharedManager;
}

- (void)dealloc {
    SKDESTROY(customTemplateTypes);
    [super dealloc];
}

- (NSArray *)customTemplateTypes {
    if (customTemplateTypes == nil) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSMutableArray *templates = [NSMutableArray array];
        
        for (NSString *appSupportPath in [[NSFileManager defaultManager] applicationSupportDirectories]) {
            NSString *templatesPath = [appSupportPath stringByAppendingPathComponent:TEMPLATES_DIRECTORY];
            BOOL isDir;
            if ([fm fileExistsAtPath:templatesPath isDirectory:&isDir] && isDir) {
                for (NSString *file in [fm subpathsAtPath:templatesPath]) {
                    if ([file hasPrefix:@"."] == NO && [[file stringByDeletingPathExtension] isEqualToString:@"notesTemplate"] == NO)
                        [templates addObject:file];
                }
            }
        }
        [templates sortUsingSelector:@selector(caseInsensitiveCompare:)];
        customTemplateTypes = [templates copy];
    }
    return customTemplateTypes;
}

- (void)resetCustomTemplateTypes {
    SKDESTROY(customTemplateTypes);
}

- (NSString *)pathForTemplateType:(NSString *)typeName {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *fullPath = nil;
    
    for (NSString *appSupportPath in [[fm applicationSupportDirectories] arrayByAddingObject:[[NSBundle mainBundle] sharedSupportPath]]) {
        fullPath = [[appSupportPath stringByAppendingPathComponent:TEMPLATES_DIRECTORY] stringByAppendingPathComponent:typeName];
        if ([fm fileExistsAtPath:fullPath] == NO)
            fullPath = nil;
        else break;
    }
    
    return fullPath;
}

- (NSString *)fileNameExtensionForTemplateType:(NSString *)typeName {
    return [[self customTemplateTypes] containsObject:typeName] ? [typeName pathExtension] : nil;
}

- (NSString *)displayNameForTemplateType:(NSString *)typeName {
    return [[self customTemplateTypes] containsObject:typeName] ? [typeName stringByDeletingPathExtension] : nil;
}

- (NSString *)templateTypeForDisplayName:(NSString *)name {
    for (NSString *typeName in [self customTemplateTypes]) {
        if ([[self displayNameForTemplateType:typeName] isEqualToString:name])
            return typeName;
    }
    return nil;
}

- (BOOL)isRichTextTemplateType:(NSString *)isRichTextTemplateFile {
    static NSSet *types = nil;
    if (types == nil)
        types = [[NSSet alloc] initWithObjects:@"rtf", @"doc", @"docx", @"odt", @"webarchive", @"rtfd", nil];
    return [types containsObject:[[isRichTextTemplateFile pathExtension] lowercaseString]];
}

- (BOOL)isRichTextBundleTemplateType:(NSString *)typeName {
    return [[typeName pathExtension] isCaseInsensitiveEqual:@"rtfd"];
}

@end
