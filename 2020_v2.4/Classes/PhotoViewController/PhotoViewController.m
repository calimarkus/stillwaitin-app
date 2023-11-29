//
//  PhotoViewController.m
//  StillWaitin
//
//

#import "ZoomTransitionProtocol.h"

#import "PhotoViewController.h"
#import "SWColors.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

@interface PhotoViewController () <UIScrollViewDelegate, ZoomTransitionProtocol>
@property (nonatomic, copy) NSString *photoFilePath;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) CGFloat initialZoomScale;
@end

@implementation PhotoViewController

- (instancetype)initWithPhotoFilePath:(NSString*)filePath {
  self = [super init];
  if (self) {
    self.title = NSLocalizedString(@"keyPhoto", nil);
    self.photoFilePath = filePath;

    self.navigationItem.rightBarButtonItem = ({
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                    target:self
                                                    action:@selector(share:)];
    });
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = SWColorPhotoViewerBackground();

  // add scrollview
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.delegate = self;
  [self.view addSubview:scrollView];
  self.scrollView = scrollView;

  // add imageview
  UIImage *image = [UIImage imageWithContentsOfFile:self.photoFilePath];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  imageView.clipsToBounds = YES;
  [scrollView addSubview:imageView];
  [imageView sizeToFit];
  self.imageView = imageView;

  // setup double tap recognizer
  UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
  doubleTapRecognizer.numberOfTapsRequired = 2;
  [scrollView addGestureRecognizer:doubleTapRecognizer];

  // setup tap recognizer
  UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
  [recognizer requireGestureRecognizerToFail:doubleTapRecognizer];
  [scrollView addGestureRecognizer:recognizer];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // setup zooming
  CGFloat widthScale = self.scrollView.frameWidth/self.imageView.image.size.width;
  CGFloat heightScale = self.scrollView.frameHeight/self.imageView.image.size.height;
  self.scrollView.minimumZoomScale = widthScale;
  self.scrollView.maximumZoomScale = widthScale*4.0;
  self.scrollView.zoomScale = widthScale;

  // use aspect fill on ipad
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    self.scrollView.zoomScale = MAX(widthScale, heightScale); // aspect fit
    self.scrollView.contentOffset = CGPointMake((self.imageView.frameWidth-self.scrollView.frameWidth)/2.0, 0); // center again
  }

  // remember initial scale
  self.initialZoomScale = self.scrollView.zoomScale;
}

- (void)share:(UIBarButtonItem*)sender {
  UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.photoFilePath]];
  [controller presentOptionsMenuFromBarButtonItem:sender animated:YES];
}

- (UIView *)viewForZoomTransition {
  return self.imageView;
}

#pragma mark UITapGestureRecognizer

- (void)singleTapRecognized:(UITapGestureRecognizer*)recognizer {
  if (self.scrollView.zoomScale == self.initialZoomScale) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)doubleTapRecognized:(UITapGestureRecognizer*)recognizer {
  if (self.scrollView.zoomScale != self.initialZoomScale) {
    [self.scrollView setZoomScale:self.initialZoomScale animated:YES];
  } else {
    [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
  }
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  // image should stay centered
  CGFloat diff = scrollView.frameHeight-self.imageView.frameHeight;
  if (diff > 0) {
    self.imageView.frameY = floor(diff/2.0);
  } else {
    self.imageView.frameY = 0;
  }
}

@end
