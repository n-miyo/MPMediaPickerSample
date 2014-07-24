// -*- mode:objc -*-

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) MPMediaItem *mediaItem;
@property (nonatomic) AVAudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self resetPlayer];
  self.playButton.enabled = NO;
  self.titleLabel.text = @"(no music)";
}

- (IBAction)pressPicker:(id)sender
{
  [self.player stop];

  MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
  picker.delegate = self;
  picker.allowsPickingMultipleItems = NO;
  picker.showsCloudItems = NO;
  picker.prompt = @"music picker";

  [self presentViewController:picker animated:YES completion: nil];
}

- (IBAction)pressPlay:(id)sender
{
  if (!self.mediaItem) {
    [self resetPlayer];
    return;
  }

  if (self.player) {
    [self stopPlayer];
  } else {
    [self runPlayer];
  }
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
  MPMediaItem *i;

  self.playButton.enabled = NO;
  self.mediaItem = nil;
  if (mediaItemCollection.items.count <= 0) {
    goto exit;
  }

  i = mediaItemCollection.items[0];
  if ([[i valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
    self.titleLabel.text = @"(sorry, not on the device)";
    [self resetPlayer];
    goto exit;
  }

  self.mediaItem = i;
  self.titleLabel.text = [i valueForProperty:MPMediaItemPropertyTitle];
  NSLog(@"selected title: %@", self.titleLabel.text);
  NSLog(@"URL: %@", [i valueForProperty:MPMediaItemPropertyAssetURL]);
  [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
  self.playButton.enabled = YES;

exit:
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark private

- (void)resetPlayer
{
  [self stopPlayer];
  self.playButton.enabled = NO;
}

- (void)stopPlayer
{
  [self.player stop];
  self.player = nil;
  [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)runPlayer
{
  NSURL *url = [self.mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
  self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  [self.player play];
  [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
}

@end

// EOF
