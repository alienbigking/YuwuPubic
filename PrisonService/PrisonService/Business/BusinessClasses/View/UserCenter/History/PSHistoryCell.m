//
//  PSHistoryCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSHistoryCell.h"

@implementation PSHistoryCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    UIImageView *bgImageView = [UIImageView new];
    bgImageView.image = [[UIImage imageNamed:@"userCenterHistoryIconBg"] stretchImage];
    [self addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    CGFloat sidePadding = 15;
    CGFloat verticalPadding = 10;
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgImageView.mas_top);
        make.left.mas_equalTo(bgImageView.mas_left);
        make.right.mas_equalTo(bgImageView.mas_right);
        make.bottom.mas_equalTo(bgImageView.mas_bottom);
    }];
    _iconView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"userCenterHistoryicon"]];
    [contentView addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.top.mas_equalTo(verticalPadding);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(22);
    }];

    _iconLable=[UILabel new];
    [contentView addSubview:_iconLable];
    _iconLable.font=AppBaseTextFont3;
    _iconLable.textColor=AppBaseTextColor1;
    _iconLable.text=@"王二(41000)";
    [_iconLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconView.mas_right).offset(sidePadding);
        make.top.mas_equalTo(verticalPadding);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(150);
    }];
    
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString*language = langArr.firstObject;
    _statusButton=[UIButton new];
    [contentView addSubview:_statusButton];
    _statusButton.titleLabel.font=FontOfSize(12);
    [_statusButton setTitle:@"审核中" forState:UIControlStateNormal];
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(contentView.mas_right).offset(-100-sidePadding);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(100);
        }];
    }else{
        [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(contentView.mas_right).offset(-50-sidePadding);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(50);
        }];
    }
     _statusButton.layer.cornerRadius=11;
    [_statusButton setBackgroundColor: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]];
    _statusButton.titleLabel.numberOfLines=0;
//    [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(contentView.mas_right).offset(-50-sidePadding);
//        make.top.mas_equalTo(verticalPadding);
//        make.height.mas_equalTo(22);
//        make.width.mas_equalTo(50);
//    }];
    
    _cancleButton=[UIButton new];
    [contentView addSubview:  _cancleButton];
      _cancleButton.titleLabel.font=FontOfSize(12);
    NSString*cancel_meet=NSLocalizedString(@"cancel_meet",@"取消会见" );
    [_cancleButton setTitle:cancel_meet forState:UIControlStateNormal];
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        [  _cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_statusButton.mas_left).offset(-10);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(100);
        }];
    }else{
        [  _cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_statusButton.mas_left).offset(-10);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(60);
        }];
    }
     _cancleButton.layer.cornerRadius=11;
    [_cancleButton setTitleColor:UIColorFromRGB(153, 153, 153) forState:UIControlStateNormal];
    _cancleButton.contentHorizontalAlignment=UIControlContentVerticalAlignmentCenter;
    [_cancleButton.layer setBorderWidth:1.0];
    _cancleButton.titleLabel.numberOfLines=0;
    _cancleButton.layer.borderColor=UIColorFromRGB(153, 153, 153).CGColor;
//    [  _cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(_statusButton.mas_left).offset(-10);
//        make.top.mas_equalTo(verticalPadding);
//        make.height.mas_equalTo(22);
//        make.width.mas_equalTo(60);
//    }];
    
    _dateTextLabel = [UILabel new];
    _dateTextLabel.font = FontOfSize(12);
    _dateTextLabel.textAlignment = NSTextAlignmentLeft;
    _dateTextLabel.textColor = AppBaseTextColor2;
    _dateTextLabel.text = @"会见日期";
    [contentView addSubview:_dateTextLabel];
    [_dateTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
       // make.right.mas_equalTo(-sidePadding);
        make.top.mas_equalTo(_iconView.mas_bottom).offset(sidePadding+10);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(100);
    }];
    
    _dateLabel = [UILabel new];
    _dateLabel.font = FontOfSize(12);
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.textColor = AppBaseTextColor2;
    [contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.top.mas_equalTo(_iconView.mas_bottom).offset(sidePadding+10);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(self.frame.size.width-2*sidePadding-100);
    }];
    
    
    _otherLabel = [UILabel new];
    _otherLabel.font = FontOfSize(12);
    _otherLabel.textAlignment = NSTextAlignmentRight;
    _otherLabel.textColor = AppBaseTextColor2;
    [contentView addSubview:_otherLabel];
    [_otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_dateTextLabel.mas_bottom).offset(verticalPadding);
        make.bottom.mas_equalTo(-verticalPadding);
        //make.height.mas_equalTo(13);
        make.right.mas_equalTo(-sidePadding);
        make.width.mas_equalTo(self.frame.size.width-sidePadding-90);
    }];
    
    
//    _otherTextLabel = [UILabel new];
//    _otherTextLabel.font = FontOfSize(12);
//    _otherTextLabel.textAlignment = NSTextAlignmentLeft;
//    _otherTextLabel.textColor = AppBaseTextColor2;
//    _otherTextLabel.text = @"拒绝原因";
//    [contentView addSubview:_otherTextLabel];
//    [_otherTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(_otherLabel.mas_top);
////        make.bottom.mas_equalTo(-verticalPadding);
//        make.height.mas_equalTo(13);
//        make.left.mas_equalTo(sidePadding);
//        make.width.mas_equalTo(50);
//    }];
    
    _otherTextLabel = [PSLabel new];
    _otherTextLabel.font = FontOfSize(12);
    _otherTextLabel.textAlignment = NSTextAlignmentLeft;
    _otherTextLabel.textColor = AppBaseTextColor2;
    _otherTextLabel.text = @"拒绝原因";
    [contentView addSubview:_otherTextLabel];
    [_otherTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_otherLabel.mas_top);
        make.bottom.mas_equalTo(-verticalPadding);
        //make.height.mas_equalTo(13);
        make.left.mas_equalTo(sidePadding);
        make.width.mas_equalTo(50);
    }];
    _otherTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
    _otherTextLabel.numberOfLines=0;
    [_otherTextLabel setVerticalAlignment:VerticalAlignmentTop];
  
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
