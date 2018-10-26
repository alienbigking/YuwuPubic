//
//  PSLocalMeetingViewController.m
//  PrisonService
//
//  Created by calvin on 2018/5/15.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocalMeetingViewController.h"
#import "PSLocalMeetingStatusView.h"
#import "PSLocalMeetingCountdownCell.h"
#import "PSLocalMeetingIntroduceCell.h"
#import "PSLocalMeetingCancelCell.h"
#import "PSLocalMeetingAppointCell.h"
#import "PSLocalMeetingRouteCell.h"
#import "PSLocalMeetingCalendarView.h"
#import "PSAlertView.h"
#import "NSDate+Components.h"
#import "NSString+Date.h"
#import "PSIMMessageManager.h"
#import "PSCancelReasonView.h"

@interface PSLocalMeetingViewController ()<UITableViewDataSource,UITableViewDelegate,PSIMMessageObserver>

@property (nonatomic, strong) UITableView *meetingTableView;
@property (nonatomic, strong) PSLocalMeetingStatusView *statusView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation PSLocalMeetingViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*local_meetting=NSLocalizedString(@"local_meetting", @"实地会见");
        self.title = local_meetting;
        [[PSIMMessageManager sharedInstance] addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[PSIMMessageManager sharedInstance] removeObserver:self];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestLocalMeeting {
    PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [meetingViewModel requestLocalMeetingDetailCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        
        [self renderContents];
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
    }];
}

- (void)requestCancelLocalMeeting {
    PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [meetingViewModel cancelLocalMeetingDetailCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            NSString*cancel_apply=NSLocalizedString(@"cancel_success", @"取消会见成功");
            [PSTipsView showTips:cancel_apply];
            [self requestLocalMeeting];
        }else{
            [PSTipsView showTips:response.msg];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError];
    }];
}

- (void)cancelMeeting {
    PSCancelReasonView *cancelReasonView = [PSCancelReasonView new];
    [cancelReasonView setDidCancel:^(NSString *reason) {
        PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
        meetingViewModel.cancelReason = reason;
        [self requestCancelLocalMeeting];
    }];
    [cancelReasonView show];
}

- (void)submitAppointmentWithDate:(NSDate *)date {
    PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
    meetingViewModel.appointDate = date;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [meetingViewModel addLocalMeetingDetailCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            [self requestLocalMeeting];
            NSString*apply_success=NSLocalizedString(@"apply_success", @"申请会见成功");
            [PSTipsView showTips:apply_success];
        }else{
            [PSTipsView showTips:response.msg];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError];
    }];
}

- (void)appointDate:(NSDate *)date {
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    NSString*cancel=NSLocalizedString(@"cancel", @"取消");
    NSString*sure_meetting=NSLocalizedString(@"sure_meetting", @"您确定选择%@会见？");
    [PSAlertView showWithTitle:nil message:[NSString stringWithFormat:sure_meetting,[date dateStringWithFormat:@"yyyy-MM-dd"]] messageAlignment:NSTextAlignmentCenter image:[UIImage imageNamed:@"localMeetingAlertIcon"] handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self submitAppointmentWithDate:date];
        }
    } buttonTitles:cancel,determine, nil];
}

- (void)appointMeeting {
    PSLocalMeetingCalendarView *calendarView = [PSLocalMeetingCalendarView new];
    
    [calendarView setAppoint:^(NSDate *date) {
        [self appointDate:date];
    }];
    [calendarView show];
}

- (void)renderContents {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _meetingTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _meetingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _meetingTableView.dataSource = self;
    _meetingTableView.delegate = self;
    [_meetingTableView registerClass:[PSLocalMeetingCountdownCell class] forCellReuseIdentifier:@"PSLocalMeetingCountdownCell"];
    [_meetingTableView registerClass:[PSLocalMeetingIntroduceCell class] forCellReuseIdentifier:@"PSLocalMeetingIntroduceCell"];
    [_meetingTableView registerClass:[PSLocalMeetingCancelCell class] forCellReuseIdentifier:@"PSLocalMeetingCancelCell"];
    [_meetingTableView registerClass:[PSLocalMeetingAppointCell class] forCellReuseIdentifier:@"PSLocalMeetingAppointCell"];
    [_meetingTableView registerClass:[PSLocalMeetingRouteCell class] forCellReuseIdentifier:@"PSLocalMeetingRouteCell"];
    [self.contentView addSubview:_meetingTableView];
    [_meetingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    _statusView = [[PSLocalMeetingStatusView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 260 + CGRectGetMinY(self.navigationController.navigationBar.frame))];
    PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
    PSLocalMeeting *localMeeting = meetingViewModel.localMeeting;
    if (localMeeting) {
        if ([localMeeting.status isEqualToString:@"PENDING"]) {
            _statusView.status = PSLocalMeetingPending;
        }else if ([localMeeting.status isEqualToString:@"PASSED"]) {
            NSInteger leftDays = [[localMeeting.applicationDate stringToDateWithFormat:@"yyyy-MM-dd"] dayIntervalSinceDate:[NSDate date]];
            NSInteger totalDays = [[localMeeting.applicationDate stringToDateWithFormat:@"yyyy-MM-dd"] dayIntervalSinceDate:[localMeeting.createdAt timestampToDate]];
            _statusView.status = PSLocalMeetingCountdown;
            _statusView.clock.progress = totalDays > 0 ? ((totalDays - leftDays) * 1.0 / totalDays) : 0;
        }else{
            _statusView.status = PSLocalMeetingWithoutAppointment;
        }
    }else{
        _statusView.status = PSLocalMeetingWithoutAppointment;
    }
    _meetingTableView.tableHeaderView = _statusView;
    if (@available(iOS 11.0, *)) {
        self.meetingTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (BOOL)hiddenNavigationBar {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contentView = [UIView new];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self requestLocalMeeting];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.row == 0) {
        height = 60;
    }else if (indexPath.row == 1){
        height = 90;
    }else if (indexPath.row == 2){
        PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
        PSLocalMeeting *localMeeting = meetingViewModel.localMeeting;
        if ([localMeeting.status isEqualToString:@"PASSED"]) {
            height = [PSLocalMeetingRouteCell cellHeightWithRouteString:meetingViewModel.routeString];
        }else{
            height = 120;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        {
            NSString*disappointment=NSLocalizedString(@"disappointment", @"您还未预约");
            NSString*Appointment_pending=NSLocalizedString(@"Appointment_pending", @"预约审核中");
            NSString*Appointment_countdowm=NSLocalizedString(@"Appointment_countdowm", @"预约倒计-%ld天");
            PSLocalMeetingCountdownCell *countdownCell = [tableView dequeueReusableCellWithIdentifier:@"PSLocalMeetingCountdownCell"];
            PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
            PSLocalMeeting *localMeeting = meetingViewModel.localMeeting;
            if (localMeeting) {
                if ([localMeeting.status isEqualToString:@"PENDING"]) {
                    countdownCell.countdownLabel.text = Appointment_pending;
                }else if ([localMeeting.status isEqualToString:@"PASSED"]) {
                    NSInteger leftDays = [[localMeeting.applicationDate stringToDateWithFormat:@"yyyy-MM-dd"] dayIntervalSinceDate:[NSDate date]];
                    countdownCell.countdownLabel.text = [NSString stringWithFormat:Appointment_countdowm,(long)leftDays];
                }else{
                    countdownCell.countdownLabel.text = disappointment;
                }
            }else{
                countdownCell.countdownLabel.text = disappointment;
            }
            cell = countdownCell;
        }
            break;
        case 1:
        {
//            PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
            PSLocalMeetingIntroduceCell *introduceCell = [tableView dequeueReusableCellWithIdentifier:@"PSLocalMeetingIntroduceCell"];
//            [introduceCell setTextAtIndex:^NSString *(NSInteger index) {
//                NSString *text = nil;
//                if (index >= 0 && index < meetingViewModel.introduceTexts.count) {
//                    text = meetingViewModel.introduceTexts[index];
//                }
//                return text;
//            }];
            cell = introduceCell;
        }
            break;
        case 2:
        {
            PSLocalMeetingViewModel *meetingViewModel = (PSLocalMeetingViewModel *)self.viewModel;
            PSLocalMeeting *localMeeting = meetingViewModel.localMeeting;
            if (localMeeting) {
                if ([localMeeting.status isEqualToString:@"PENDING"]) {
                    PSLocalMeetingCancelCell *cancell = [tableView dequeueReusableCellWithIdentifier:@"PSLocalMeetingCancelCell"];
                    @weakify(self)
                    [cancell.cancelButton bk_whenTapped:^{
                        @strongify(self)
                        [self cancelMeeting];
                    }];
                    cell = cancell;
                }else if ([localMeeting.status isEqualToString:@"PASSED"]) {
                    PSLocalMeetingRouteCell *routeCell = [tableView dequeueReusableCellWithIdentifier:@"PSLocalMeetingRouteCell"];
                    routeCell.routeLabel.text = localMeeting.visitAddress;
                    routeCell.prisonLabel.text = meetingViewModel.prisonerDetail.jailName;
                    routeCell.locateLabel.text = localMeeting.address;
                    [routeCell updateRouteString:meetingViewModel.routeString];
                    @weakify(self)
                    [routeCell.cancelButton bk_whenTapped:^{
                        @strongify(self)
                        [self cancelMeeting];
                    }];
                    cell = routeCell;
                }else{
                    PSLocalMeetingAppointCell *appointCell = [tableView dequeueReusableCellWithIdentifier:@"PSLocalMeetingAppointCell"];
                    @weakify(self)
                    [appointCell.appointButton bk_whenTapped:^{
                        @strongify(self)
                        [self appointMeeting];
                    }];
                    cell = appointCell;
                }
            }else{
                PSLocalMeetingAppointCell *appointCell = [tableView dequeueReusableCellWithIdentifier:@"PSLocalMeetingAppointCell"];
                @weakify(self)
                [appointCell.appointButton bk_whenTapped:^{
                    @strongify(self)
                    [self appointMeeting];
                }];
                cell = appointCell;

                
            }
        }
            break;
        default:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        }
            break;
    }
    return cell;
}

#pragma mark - PSIMMessageObserver
- (void)receivedLocalMeetingMessage:(PSMeetingMessage *)message {
    [PSTipsView showTips:message.msg];
    
    [self requestLocalMeeting];
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
