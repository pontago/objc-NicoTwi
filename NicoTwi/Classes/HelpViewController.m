//
//  HelpViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/06/12.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "HelpViewController.h"

NSUInteger const HELP_PAGES   = 4;
CGSize const HELP_IMAGE_SIZE  = {640, 775};

@interface HelpViewController () {
    UIScrollView *scrollView_;
    SMPageControl *pageControl_;
    BOOL pageControlUsed_;
}

- (void)pageControlDidChanged:(UIPageControl*)control;
- (void)doDone_:(id)sender;

@end

@implementation HelpViewController

@synthesize howToMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.howToMode = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"ヘルプ"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ICON_CLOSE]
      style:UIBarButtonItemStylePlain target:self action:@selector(doDone_:)];

    self.view.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);

    NSInteger pageCount = HELP_PAGES;
    if (self.howToMode) pageCount++;

    scrollView_ = [[UIScrollView alloc] init];
    scrollView_.frame = CGRectMake(0, 0, self.view.frame.size.width, HELP_IMAGE_SIZE.height);
    scrollView_.pagingEnabled = YES;
    scrollView_.showsHorizontalScrollIndicator = NO;
    scrollView_.showsVerticalScrollIndicator = NO;
    scrollView_.contentSize = CGSizeMake(self.view.frame.size.width * pageCount, HELP_IMAGE_SIZE.height);
    scrollView_.delaysContentTouches = NO;
    scrollView_.delegate = self;

    for (NSInteger i = 0; i < HELP_PAGES; ++i) {
      UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"howto%d", i + 1]];
      UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
      CGRect frame = imageView.frame;
      frame.origin.x = self.view.frame.size.width * i;
      frame.origin.y = 0.0f;
      imageView.frame = frame;
      [scrollView_ addSubview:imageView];
    }

    if (self.howToMode) {
      UILabel *label = [[UILabel alloc] initWithFrame:
        CGRectMake(self.view.frame.size.width * HELP_PAGES + 20.0f, 100.0f, 
          self.view.frame.size.width - 40.0f, 130.0f)];
      label.backgroundColor = [UIColor clearColor];
      label.textColor = [UIColor darkGrayColor];
      label.numberOfLines = 0;
      label.textAlignment = UITextAlignmentLeft;
//      label.lineBreakMode = NSLineBreakByTruncatingTail;
      label.font = [UIFont systemFontOfSize:13];
      label.text = @"以上で使い方の説明は終わりです\nこの説明はメニューの「ヘルプ」からいつでも表示できます\n\n「設定」からいつも使っている動画プレイヤーに変更しましょう\n左上の閉じるボタンを押すとアプリが開始されます";
      [scrollView_ addSubview:label];
    }

    [self.view addSubview:scrollView_];

    pageControl_ = [[SMPageControl alloc] init];
    pageControl_.frame = CGRectMake(0, self.view.frame.size.height - 62.0f, self.view.frame.size.width, 10.0f);
    pageControl_.numberOfPages = pageCount;
    pageControl_.currentPage = 0;
    pageControl_.hidesForSinglePage = NO;
    pageControl_.pageIndicatorTintColor = HEXCOLOR(0x999999);
    pageControl_.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl_.pageIndicatorImage = [UIImage imageNamed:@"pageDot"];
    pageControl_.currentPageIndicatorImage = [UIImage imageNamed:@"currentPageDot"];

    [pageControl_ addTarget:self action:@selector(pageControlDidChanged:) 
      forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl_];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pageControlDidChanged:(UIPageControl*)control {
    NSInteger page = pageControl_.currentPage;
    CGRect frame = scrollView_.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView_ scrollRectToVisible:frame animated:YES];

    pageControlUsed_ = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed_ = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed_ = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (pageControlUsed_) return;

    CGFloat width = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
    pageControl_.currentPage = page;
}

- (void)doDone_:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES];
}

@end
