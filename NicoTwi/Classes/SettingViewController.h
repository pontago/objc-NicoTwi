//
//  SettingViewController.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/23.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "QuickDialogController.h"

extern NSString* const URL_APPSTORE;

@interface SettingViewController : QuickDialogController <UINavigationControllerDelegate, QuickDialogStyleProvider>

- (QRootElement*)buildSettingData;

@end
