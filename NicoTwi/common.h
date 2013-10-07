//
//  common.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#ifndef NicoTwi_common_h
#define NicoTwi_common_h

#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__)
#define LOG_METHOD NSLog(@"%s", __func__)
#else
#define LOG(...) ;
#define LOG_METHOD ;
#endif


#define HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 \
green:((c>>8)&0xFF)/255.0 \
blue:(c&0xFF)/255.0 \
alpha:1.0];

#define HEXCOLOR_WITH_ALPHA(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 \
green:((c>>8)&0xFF)/255.0 \
blue:(c&0xFF)/255.0 \
alpha:a];


#define BARCOLOR                    0xFAF7F7
#define HIGHLIGHTED_BUTTON_COLOR    0xE5E3E3
#define BAR_TEXT_COLOR              0x201F27
#define BACKGROUND_COLOR            0xF1F1F1
#define BORDER_COLOR                0xB4B4B4
#define SAVE_BUTTON_COLOR           0xD44937

#define ICON_MENU     @"399-list1"
#define ICON_CLOSE    @"433-x"
#define ICON_BACK     @"09-arrow-west"
#define ICON_ACTION   @"211-action"

#define SEARCH_KEYWORD  @"nico.ms OR #nicovideo OR nicovideo.jp/watch/"

#define WEBVIEW_CSS   @"<head><style type=\"text/css\">a { color:#0044cc; }</style></head>"

#define TWITTER_HASHTAG @"#nicotwi"

#define SORT_DESC @"desc"
#define SORT_ASC  @"asc"

#define OPEN_VIDEO_APP_OFFICIAL     @"nico"
#define OPEN_VIDEO_APP_SMILEPLAYER  @"smileplayer"
#define OPEN_VIDEO_APP_SAFARI       @"safari"
#define OPEN_VIDEO_APP_BUILTIN      @"builtin"

#define OPEN_TWITTER_APP_OFFICIAL   @"twitter"

#define APP_NAME  @"激ニコぷんぷん丸"

#endif
