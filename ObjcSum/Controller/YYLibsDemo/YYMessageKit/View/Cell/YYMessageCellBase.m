//
//  YYMessageCellBase.m
//  ObjcSum
//
//  Created by sihuan on 15/12/30.
//  Copyright © 2015年 sihuan. All rights reserved.
//

#import "YYMessageCellBase.h"
#import "YYMessageModel.h"


@implementation YYMessageCellBase

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setContext];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setContext];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)layoutSubviews {
    CGFloat cellWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat x = _cellConfig.contentViewInsets.left;
    CGFloat labeWidth = cellWidth - (_cellConfig.contentViewInsets.left+_cellConfig.contentViewInsets.right);
    
    _cellTopLabel.frame = CGRectMake(x, _cellConfig.contentViewInsets.top, labeWidth, _cellTopLabel.height);
    
    _bubbleTopLabel.y = _cellTopLabel.bottom;
    _bubbleTopLabel.width = labeWidth - _avatarImageView.width;
    _bubbleContainerView.y = _bubbleTopLabel.bottom;
    _bubbleContainerView.size = CGSizeMake(
                                           _messageModel.contentSize.width + _cellConfig.bubbleViewInsets.left + _cellConfig.bubbleViewInsets.right,
                                           _messageModel.contentSize.height + _cellConfig.bubbleViewInsets.top +_cellConfig.bubbleViewInsets.bottom);
    
    //头像上下位置设置
    if (_cellConfig.avatarImageViewShowAtTop) {
        _avatarImageView.y = _cellTopLabel.bottom;
    } else {
        _avatarImageView.bottom = _bubbleContainerView.bottom;
    }
    
    if (_messageModel.message.isOutgoing) {
        _avatarImageView.right = cellWidth - _cellConfig.contentViewInsets.right;
        _bubbleTopLabel.right = _avatarImageView.left;
        _bubbleContainerView.right = _avatarImageView.left;
    } else {
        _avatarImageView.left = _cellConfig.contentViewInsets.left;
        _bubbleTopLabel.left = _avatarImageView.right;
        _bubbleContainerView.left = _avatarImageView.right;
    }
    
//    _bubbleImageView.size = _bubbleContainerView.size;
    
    _cellBottomLabel.frame = CGRectMake(x,
                                     _bubbleContainerView.bottom,
                                     labeWidth,
                                     _cellBottomLabel.height);
}

#pragma mark - Public

- (void)setContext {
    _cellConfig = [YYMessageCellConfig defaultConfig];
    
    [self.contentView addSubview:self.cellTopLabel];
    [self.contentView addSubview:self.bubbleTopLabel];
    
    [self.contentView addSubview:self.avatarImageView];
//    [self.bubbleContainerView addSubview:self.bubbleImageView];
    [self.contentView addSubview:self.bubbleContainerView];
    
    [self.contentView addSubview:self.cellBottomLabel];
    self.contentView.backgroundColor = [UIColor orangeColor];
}

/**
 *  cell的唯一标志符
 */
+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

- (void)renderWithMessageModel:(YYMessageModel *)messageModel atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView {
    _messageModel = messageModel;
    _indexPath = [indexPath copy];
    _collectionView = collectionView;
    
    [self setCellTopLabelText:messageModel.displaySendTime];
    [self setBubbleTopLabelText:messageModel.message.senderName];
    [self setCellBottomLabelText:messageModel.message.senderName];
}

#pragma mark - Private

- (void)setCellTopLabelText:(NSString *)text {
    _cellTopLabel.text = text;
    _cellTopLabel.height = text.length > 0 ? _cellConfig.cellTopLabelHeight : 0;
}
- (void)setBubbleTopLabelText:(NSString *)text {
    if (_cellConfig.bubbleTopLabelShow) {
        _bubbleTopLabel.text = text;
        _bubbleTopLabel.height = text.length > 0 && _messageModel.shouldShowNickName ? _cellConfig.bubbleTopLabelHeight : 0;
        _bubbleTopLabel.textAlignment = _messageModel.message.isOutgoing ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
}
- (void)setCellBottomLabelText:(NSString *)text {
    if (_cellConfig.cellBottomLabelShow) {
        _cellBottomLabel.text = text;
        _cellBottomLabel.height = text.length > 0 && _messageModel.shouldShowNickName ? _cellConfig.cellBottomLabelHeight : 0;
        _cellBottomLabel.textAlignment = _messageModel.message.isOutgoing ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
}

- (UILabel *)cellTopLabel {
    if (!_cellTopLabel) {
        _cellTopLabel = [UILabel labelAlignmentCenter];
        _cellTopLabel.font = _cellConfig.cellTopLabelFont;
        _cellTopLabel.textColor = _cellConfig.cellTopLabelColor;
    }
    return _cellTopLabel;
}

- (UILabel *)bubbleTopLabel {
    if (!_bubbleTopLabel) {
        _bubbleTopLabel = [UILabel labelAlignmentCenter];
        _bubbleTopLabel.font = _cellConfig.bubbleTopLabelFont;
        _bubbleTopLabel.textColor = _cellConfig.bubbleTopLabelColor;
    }
    return _bubbleTopLabel;
}

- (UILabel *)cellBottomLabel {
    if (!_cellBottomLabel) {
        _cellBottomLabel = [UILabel labelAlignmentCenter];
        _cellBottomLabel.font = _cellConfig.cellBottomLabelFont;
        _cellBottomLabel.textColor = _cellConfig.cellBottomLabelColor;
    }
    return _cellBottomLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        YYMessageAvatarView *imageView = [YYMessageAvatarView new];
        imageView.bounds = CGRectMake(0, 0, _cellConfig.avatarImageViewWH, _cellConfig.avatarImageViewWH);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView = imageView;
        _avatarImageView.image = [UIImage imageNamed:@"no_data_default"];
    }
    return _avatarImageView;
}

- (UIView *)bubbleContainerView {
    if (!_bubbleContainerView) {
        _bubbleContainerView = [YYMessageBubbleView new];
        _bubbleContainerView.backgroundColor = [UIColor redColor];
    }
    return _bubbleContainerView;
}

//- (UIImageView *)bubbleImageView {
//    if (!_bubbleImageView) {
//        UIImageView *imageView = [UIImageView new];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _bubbleImageView = imageView;
//        _bubbleImageView.origin = CGPointZero;
//    }
//    return _bubbleImageView;
//}


@end