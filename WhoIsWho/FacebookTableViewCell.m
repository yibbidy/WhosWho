//
//  FacebookTableViewCell.m
//  WhoIsWho
//
//  Created by Hongbing Carter on 10/2/13.
//
//

#import "FacebookTableViewCell.h"
#import "Facebook2ViewController.h"


@implementation FacebookTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _imageViews = [[NSMutableArray alloc] initWithCapacity:kNumberOfImages];
        _images = [[NSMutableArray alloc] initWithCapacity:kNumberOfImages];
        _selectedImageIndex = [[NSMutableArray alloc] initWithCapacity:kNumberOfImages];
        
        for (int i = 0; i <kNumberOfImages; i++) {
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kThumbnailMargin*(i+1)) + (kThumbnailLength*i), 2, kThumbnailLength, kThumbnailLength)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.backgroundColor = [UIColor lightGrayColor];
            
            [self.contentView addSubview:imageView];
            imageView.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressed:)];
            tap.delegate = self;
            [imageView addGestureRecognizer:tap];
            imageView.userInteractionEnabled = YES;
            [_imageViews addObject:imageView];
            _selectedImageIndex[i] = [NSNumber numberWithInt:-1]; 
            
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initImages:(NSArray *)imageCollection
{
    [_images addObjectsFromArray:imageCollection];
    for (int i = 0; i <[imageCollection count] && i<kNumberOfImages; i++) {
        UIImage *image = _images[i];
        if (image)  {
            UIImageView *imageView  = _imageViews[i]; 
            imageView.image = image;
        }
     }
}
- (void) imageViewPressed:(UITapGestureRecognizer *)recoginizer {
    NSUInteger index = recoginizer.view.tag;
    if (index < _images.count) {
        
        if ([_selectedImageIndex[recoginizer.view.tag] integerValue] == -1) {
        
            UIImage *image = _images[recoginizer.view.tag];
         //   [self.delegate facebookPhotoGridTableViewCell:self didSelectPhoto:photo withPreviewImage:[(UIImageView *)recoginizer.view image]];
            // Get the width and height of the image
            size_t width = CGImageGetWidth(image.CGImage);
            size_t height = CGImageGetHeight(image.CGImage);
            
            CGContextRef ctx;
            CGColorSpaceRef            colorSpace;
            unsigned char *imageData =nil;// (unsigned char *)malloc(height * width * 4);
            
            colorSpace = CGColorSpaceCreateDeviceRGB();
            ctx = CGBitmapContextCreate(imageData, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
            
            CGContextClearRect(ctx,  CGContextGetPathBoundingBox(ctx));
            CGContextSetRGBFillColor(ctx, 1, 1, 0.0, 0.25f);
            CGContextFillRect(ctx, CGRectMake(0, 0, width, height));
            
            CGContextSetBlendMode(ctx, kCGBlendModeDestinationAtop);
            CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image.CGImage);
            
            CGImageRef ciImage= CGBitmapContextCreateImage(ctx);
            
            UIImage *newImage =  [UIImage imageWithCGImage:ciImage];
            UIImageView *imageView = _imageViews[recoginizer.view.tag];
            
            imageView.image = newImage;
            CGContextRelease(ctx);
            CGColorSpaceRelease(colorSpace);
            CGImageRelease(ciImage);
            _selectedImageIndex[recoginizer.view.tag] = [NSNumber numberWithInt:recoginizer.view.tag];
        }
        else {
            UIImage *image = _images[recoginizer.view.tag];
            UIImageView *imageView = _imageViews[recoginizer.view.tag];
            imageView.image = image;
            _selectedImageIndex[recoginizer.view.tag] = [NSNumber numberWithInt:-1];
        }
    }
}
-(void)dealloc
{
    for (UIImageView *imageView  in _imageViews) {
        [imageView removeFromSuperview];
    }
    [_imageViews removeAllObjects];
    _imageViews = nil;
   
    [_images removeAllObjects];
    _images = nil;
    
    [_selectedImageIndex removeAllObjects];
    _selectedImageIndex = nil;
    

}
@end
