//
//  CellTakenPicture.m
//  Tago
//
//  Created by Vivek Jayaram on 4/30/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "CellTakenPicture.h"

@implementation CellTakenPicture

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
