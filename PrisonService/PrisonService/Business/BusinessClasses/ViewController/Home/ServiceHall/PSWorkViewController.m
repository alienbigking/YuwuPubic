//
//  PSWorkViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWorkViewController.h"
#import "PSWorkCell.h"
#import "NSString+Date.h"
#import "PSWebViewController.h"
#import "PSBusinessConstants.h"
#import "PSContentManager.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"

@interface PSWorkViewController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>



@end

@implementation PSWorkViewController

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMore {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    workViewModel.jailId=self.jailId;
    @weakify(self)
    [workViewModel loadMoreNewsCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    workViewModel.jailId=self.jailId;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    if ([self showAdv]) {
        [workViewModel refreshAllDataCompleted:^(PSResponse *response) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        } failed:^(NSError *error) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        }];
    }else{
        [workViewModel refreshNewsCompleted:^(PSResponse *response) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        } failed:^(NSError *error) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        }];
    }
}

- (void)updateUI {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    if ([self showAdv]) {
        _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.55467) imageURLStringsGroup:workViewModel.advUrls];
        NSString*serviceHallAdvDefault=NSLocalizedString(@"serviceHallAdvDefault", @"工作动态");
        _advView.placeholderImage = [UIImage imageNamed:serviceHallAdvDefault];
        _advView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        self.workTableView.tableHeaderView = _advView;
    }else{
        self.workTableView.tableHeaderView = nil;
    }
    [self reloadContents];
}

- (void)reloadContents {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    if (workViewModel.hasNextPage) {
        @weakify(self)
        self.workTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.workTableView.mj_footer = nil;
    }
    [self.workTableView.mj_header endRefreshing];
    [self.workTableView.mj_footer endRefreshing];
    [self.workTableView reloadData];
}

- (void)renderContents {
    _workTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.workTableView.dataSource = self;
    self.workTableView.delegate = self;
    self.workTableView.emptyDataSetSource = self;
    self.workTableView.emptyDataSetDelegate = self;
    self.workTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.workTableView.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.workTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.workTableView registerClass:[PSWorkCell class] forCellReuseIdentifier:@"PSWorkCell"];
    self.workTableView.tableFooterView = [UIView new];
    if (@available(iOS 11.0, *)) {
        self.workTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.workTableView];
    [self.workTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"userCenterAccountBack"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.top.mas_equalTo(10);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backButton.mas_top);
        make.bottom.mas_equalTo(backButton.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(100);
    }];
    _titleLabel = titleLabel;
     
}

//- (void)setTitimeNSString *)title {
//
//   _titleLabel.text = title;
//}

- (BOOL)showAdv {
    return YES;
}

- (BOOL)hiddenNavigationBar {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
    [self refreshData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    return workViewModel.newsData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSWorkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSWorkCell"];
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    PSNews *news = workViewModel.newsData[indexPath.row];
    cell.dateLabel.text = [news.createdAt timestampToMonthDayString];
    cell.titleLabel.text = news.title;
    cell.detailLabel.text = news.summary;
    cell.prisonLabel.text = self.jailName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    PSNews *news = workViewModel.newsData[indexPath.row];
    NSString *url = [NSString stringWithFormat:@"%@%@",NewsUrl,news.id];
    PSWebViewController *newsDetailViewController = [[PSWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    newsDetailViewController.enableUpdateTitle = NO;
    if (workViewModel.newsType==1) {
        newsDetailViewController.title = @"狱务公开";
    }
    else if (workViewModel.newsType==2){
        newsDetailViewController.title=@"工作动态";
    }
    else {
         newsDetailViewController.title = @"新闻详情";
    }
   
    newsDetailViewController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:newsDetailViewController animated:YES];
    newsDetailViewController.hidesBottomBarWhenPushed=NO;


}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    UIImage *emptyImage = workViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return workViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    NSString *tips = workViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return workViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];

}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    return workViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:@"点击加载" attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
