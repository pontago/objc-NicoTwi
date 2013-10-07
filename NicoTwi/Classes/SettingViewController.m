//
//  SettingViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/23.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "SettingViewController.h"
#import "AddOnViewController.h"

NSString * const URL_SUPPORT  = @"http://www.nicotwi.com/";
NSString * const URL_LICENSE  = @"http://www.nicotwi.com/pages/license";
NSString * const URL_TWITTER  = @"https://twitter.com/happytar0";
NSString * const URL_APPSTORE = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=662853330&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";

@interface SettingViewController () {
    QAppearance *appearance_;
}

- (QRootElement*)buildAboutData_;
- (NSString*)twScreenNameListElement_;

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      appearance_ = [[QAppearance alloc] init];
      appearance_.sectionTitleColor = HEXCOLOR(BAR_TEXT_COLOR);
      appearance_.labelFont = [UIFont systemFontOfSize:14];
      appearance_.entryFont = [UIFont systemFontOfSize:12];
      appearance_.valueColorEnabled = [UIColor darkGrayColor];
      appearance_.entryTextColorEnabled = [UIColor darkGrayColor];
      appearance_.tableGroupedBackgroundColor = HEXCOLOR(BACKGROUND_COLOR);
      appearance_.tableBackgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"設定"];
    self.navigationItem.leftBarButtonItems = [[FlatUIUtils sharedInstance] menuBarButtonItem:[UIImage imageNamed:ICON_MENU]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}


- (QRootElement*)buildSettingData {
    QRootElement *rootElement = [[QRootElement alloc] init];
    rootElement.appearance = appearance_;
    rootElement.grouped = YES;
    rootElement.title = @"設定";

    // アドオン
    QSection *addonSection = [[QSection alloc] initWithTitle:@"アドオン"];
    [rootElement addSection:addonSection];

    QLabelElement *addonElement = [[QLabelElement alloc] initWithTitle:@"アプリ内の広告を削除" Value:@""];
    addonElement.onSelected = ^{
      AddOnViewController *addonViewController = [[AddOnViewController alloc] init];
      [self displayViewController:addonViewController];
    };
    [addonSection addElement:addonElement];


    // 全般
    QSection *generalSection = [[QSection alloc] initWithTitle:@"全般"];
    [rootElement addSection:generalSection];

    // スリープ
    NSNumber *sleepDisabled = [[UserConfig sharedInstance] getConfig:@"SLEEP_DISABLED"];
    QBooleanElement *sleepDisabledElement = [[QBooleanElement alloc] initWithTitle:@"画面スリープを無効" BoolValue:[sleepDisabled boolValue]];
    sleepDisabledElement.onSelected = ^{
      [[UserConfig sharedInstance] saveConfig:@"SLEEP_DISABLED" value:@(![sleepDisabled boolValue])]; 
      [[UserConfig sharedInstance] updateIdleTimerDisabled];
    };
    [generalSection addElement:sleepDisabledElement];

    // 動画URLを開くアプリ
    NSArray *keys = @[@"ニコニコ動画公式アプリ", @"SmilePlayer", @"標準ブラウザ", @"内蔵ブラウザ"];
    __block NSArray *values = @[OPEN_VIDEO_APP_OFFICIAL, OPEN_VIDEO_APP_SMILEPLAYER, OPEN_VIDEO_APP_SAFARI, OPEN_VIDEO_APP_BUILTIN];
    NSString *openVideoApp = [[UserConfig sharedInstance] getConfig:@"OPEN_VIDEO_APP"];
    QRadioElement *openAppElement = [[QRadioElement alloc] initWithItems:keys
      selected:[values indexOfObject:openVideoApp] title:@"動画を開くアプリ"];
    openAppElement.grouped = YES;
    __block QRadioElement *blockOpenAppElement = openAppElement;
    openAppElement.onSelected = ^{
      [[UserConfig sharedInstance] saveConfig:@"OPEN_VIDEO_APP" value:values[blockOpenAppElement.selected]]; 
    };
    [generalSection addElement:openAppElement];

    // URLを開くアプリ
    keys = @[@"標準ブラウザ", @"内蔵ブラウザ"];
    __block NSArray *openUrlValues = @[OPEN_VIDEO_APP_SAFARI, OPEN_VIDEO_APP_BUILTIN];
    NSString *openUrlApp = [[UserConfig sharedInstance] getConfig:@"OPEN_URL_APP"];
    QRadioElement *openUrlAppElement = [[QRadioElement alloc] initWithItems:keys
      selected:[openUrlValues indexOfObject:openUrlApp] title:@"URLを開くアプリ"];
    openUrlAppElement.grouped = YES;
    __block QRadioElement *blockOpenUrlAppElement = openUrlAppElement;
    openUrlAppElement.onSelected = ^{
      [[UserConfig sharedInstance] saveConfig:@"OPEN_URL_APP" value:openUrlValues[blockOpenUrlAppElement.selected]]; 
    };
    [generalSection addElement:openUrlAppElement];

    // クリップ登録確認
    NSNumber *clipConfirmAdd = [[UserConfig sharedInstance] getConfig:@"CLIP_CONFIRM_ADD"];
    QBooleanElement *clipConfirmAddElement = [[QBooleanElement alloc] initWithTitle:@"クリップ登録確認" 
      BoolValue:[clipConfirmAdd boolValue]];
    clipConfirmAddElement.onSelected = ^{
      [[UserConfig sharedInstance] saveConfig:@"CLIP_CONFIRM_ADD" value:@(![clipConfirmAdd boolValue])]; 
    };
    [generalSection addElement:clipConfirmAddElement];



    // Twitter
    QSection *twitterSection = [[QSection alloc] initWithTitle:@"Twitter"];
    [rootElement addSection:twitterSection];

    QLabelElement *twAccountListElement = [[QLabelElement alloc] initWithTitle:@"選択アカウント" Value:[self twScreenNameListElement_]];
    __block QLabelElement *blockTwAccountListElement = twAccountListElement;
    twAccountListElement.onSelected = ^{
      TwAccountViewController *twAccountViewController = [[TwAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];

      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:twAccountViewController];
      navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

      [self presentViewController:navigationController animated:YES completion:NULL dismissCompletion:^{
        blockTwAccountListElement.value = [self twScreenNameListElement_];
        [self.quickDialogTableView reloadCellForElements:blockTwAccountListElement, nil];
      }];
    };
    [twitterSection addElement:twAccountListElement];


    // About
    QSection *aboutSection = [[QSection alloc] init];
    [rootElement addSection:aboutSection];

    QLabelElement *aboutElement = [[QLabelElement alloc] initWithTitle:@"このアプリについて" Value:@""];
    aboutElement.onSelected = ^{
      [self displayViewControllerForRoot:[self buildAboutData_]];
    };
    [aboutSection addElement:aboutElement];


    // レビュー
    QSection *reviewSection = [[QSection alloc] init];
    [rootElement addSection:reviewSection];

    QLabelElement *reviewElement = [[QLabelElement alloc] initWithTitle:@"レビューを書く" Value:@""];
    reviewElement.onSelected = ^{
      NSURL *url = [NSURL URLWithString:URL_APPSTORE];
      if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
      }
    };
    [reviewSection addElement:reviewElement];

    [self setRoot:rootElement];

    return rootElement;
}

- (QRootElement*)buildAboutData_ {
    QRootElement *rootElement = [[QRootElement alloc] init];
    rootElement.appearance = appearance_;
    rootElement.grouped = YES;
    rootElement.title = @"このアプリについて";

    QSection *generalSection = [[QSection alloc] init];
    [rootElement addSection:generalSection];

    // バージョン情報
    QLabelElement *versionElement = [[QLabelElement alloc] initWithTitle:@"現在のバージョン" 
      Value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    [generalSection addElement:versionElement];


    // Others
    QSection *othersSection = [[QSection alloc] init];
    [rootElement addSection:othersSection];

    // 公式サイト
    QLabelElement *supportPageElement = [[QLabelElement alloc] initWithTitle:@"公式サイトを開く" Value:@""];
    supportPageElement.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    supportPageElement.onSelected = ^{
      NSURL *url = [NSURL URLWithString:URL_SUPPORT];
      if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
      }
    };
    [othersSection addElement:supportPageElement];

    // Twitter
    QLabelElement *twitterElement = [[QLabelElement alloc] initWithTitle:@"Twitter" Value:@"@happytar0"];
    twitterElement.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    twitterElement.onSelected = ^{
      NSURL *url = [NSURL URLWithString:URL_TWITTER];
      if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
      }
    };
    [othersSection addElement:twitterElement];


    // License
    QSection *licenseSection = [[QSection alloc] init];
    [rootElement addSection:licenseSection];

    QLabelElement *licenseElement = [[QLabelElement alloc] initWithTitle:@"ライセンス" Value:@""];
    licenseElement.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    licenseElement.onSelected = ^{
      UIWebView *webView = [[UIWebView alloc] init];
      webView.dataDetectorTypes = UIDataDetectorTypeNone;
      webView.scalesPageToFit = YES;

      UIViewController *viewController = [[UIViewController alloc] init];
      viewController.view = webView;

      NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_LICENSE]];
      [webView loadRequest:request];

      [self displayViewController:viewController];
    };
    [licenseSection addElement:licenseElement];

    return rootElement;
}


- (void)setQuickDialogTableView:(QuickDialogTableView*)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];

    self.quickDialogTableView.styleProvider = self;
}

- (void)cell:(UITableViewCell*)cell willAppearForElement:(QElement*)element atIndexPath:(NSIndexPath*)indexPath {
//    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];

//    if ([element isKindOfClass:[QRadioElement class]]){
//      ((QEntryTableViewCell*)cell).textField.font = [UIFont systemFontOfSize:13];
//      ((QEntryTableViewCell*)cell).textField.textColor = [UIColor darkGrayColor];
//    }

    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    self.quickDialogTableView.scrollsToTop = NO;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    self.quickDialogTableView.scrollsToTop = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController 
  animated:(BOOL)animated {

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:@"ニコツイ" subtitle:self.navigationItem.title];
}


- (NSString*)twScreenNameListElement_ {
    NSString *twitterIdentifier = [[UserConfig sharedInstance] getConfig:@"TWITTER_IDENTIFIER"];

    if (![twitterIdentifier isEqualToString:@""]) {
      ACAccountStore *accountStore = [[ACAccountStore alloc] init];
      ACAccount *account = [accountStore accountWithIdentifier:twitterIdentifier];
      if (account.username) {
        return [NSString stringWithFormat:@"@%@", account.username];
      }
    }

    return @"未設定";
}

@end
