//
//  FacebookTableViewCell.h
//  WhoIsWho
//
//  Created by Hongbing Carter on 10/2/13.
//
//

#import <UIKit/UIKit.h>

static CGFloat kThumbnailLength = 75;
static CGFloat kThumbnailMargin = 4;
static NSUInteger kNumberOfImages = 4;

@interface FacebookTableViewCell : UITableViewCell {
    
}
@property(strong, nonatomic) NSMutableArray *images;
@property(strong, nonatomic) NSMutableArray *imageViews;
@property(strong, nonatomic) NSMutableArray *selectedImageIndex;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)initImages:(NSArray *)imageCollection;

@end
