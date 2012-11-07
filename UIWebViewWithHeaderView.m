/*
 UIWebView-with-Header-and-Footer
 
 Copyright (c) 2012 Protected Trust, LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */


#import "UIWebViewWithHeaderView.h"
#include <stdlib.h>

@interface UIWebViewWithHeaderView() {
    UIView *_headerView;
    UIView *_footerView;
    float _headerViewHeight;
    float _footerViewHeight;
}

@property(nonatomic,retain) UIScrollView* webScrollView;
@property(nonatomic,assign) id<UIScrollViewDelegate> oldScrollViewDelegate;
@property(nonatomic,assign) float actualContentHeight;
@property(nonatomic,assign) float actualContentWidth;
@property(nonatomic,assign) BOOL shouldScrollToTopOnLayout;

@end

@implementation UIWebViewWithHeaderView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self createWebView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
        
		[self createWebView];
    }
    return self;
}

-(id)init {
	self = [super init];
    if (self) {
        
		[self createWebView];
    }
    return self;
}

-(void) createWebView {
	
    if (self.webView == nil)
    {
        // defaults
        self.headerViewHeight = 0;
        self.footerViewHeight = 0;
        
        // create webview
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
        self.webView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.webView];
	}
    
}

-(void) layoutHeaderAndFooterViews {
	
	if (self.webScrollView) {
		
		
		// get my frame size
		CGRect rcSelf = [self frame];
		
		// get scroll info
		CGPoint offset = self.webScrollView.contentOffset;
		CGSize contentSize = self.webScrollView.contentSize;
		
		// set content height
		contentSize.height = self.webScrollView.contentSize.width * self.actualContentHeight / self.actualContentWidth;
		self.webScrollView.contentSize = contentSize;
		
		if (self.headerView) {
			
            // position the header
			CGRect rcHeader = self.headerView.frame;
			rcHeader.origin.y = 0 - rcHeader.size.height;
			rcHeader.origin.x = offset.x;
			rcHeader.size.width = rcSelf.size.width;
			rcHeader.size.height = self.headerViewHeight;
			self.headerView.frame = rcHeader;
		}
		
		if (self.footerView) {
			
            // position the footer
			CGRect rcFooter = self.footerView.frame;
			rcFooter.origin.y = contentSize.height;
			rcFooter.origin.x = offset.x;
			rcFooter.size.width = rcSelf.size.width;
			rcFooter.size.height = self.footerViewHeight;
			self.footerView.frame = rcFooter;
        }
		
		
	}
}

-(void) layoutSubviews {
    
    
	// set content inset on scrollview
	if (self.webScrollView) {
		
		self.webView.frame = CGRectMake(0,
										0,
										self.frame.size.width,
										self.frame.size.height);
	}
	else {
		// set frame of web control
		if (self.webView) {
			self.webView.frame = CGRectMake(0,
											self.headerViewHeight,
											self.frame.size.width,
											self.frame.size.height - self.footerViewHeight);
		}
	}
	[self layoutHeaderAndFooterViews];
}

-(void) setHeaderView:(UIView *)view {
    
	// remove old header if there is one
	if (self->_headerView) {
		if ([self->_headerView superview] == self) {
			[self->_headerView removeFromSuperview];
		}
		self->_headerView = nil;
	}
	
	// set new one
	self->_headerView = view;
	
	[self setNeedsLayout];
}

-(UIView*) headerView {
	return self->_headerView;
}

-(void) setFooterView:(UIView *)view {
	
	// remove old footer if there is one
	if (self->_footerView) {
		if ([self->_footerView superview] == self) {
			[self->_footerView removeFromSuperview];
		}
		self->_footerView = nil;
	}
	
	// set new one
	self->_footerView = view;
	
	[self setNeedsLayout];
}

-(UIView*) footerView {
	return self->_footerView;
}

-(void) setHeaderViewHeight:(float)height {
	self->_headerViewHeight = height;
	[self setNeedsLayout];
}

-(float) headerViewHeight {
	return self->_headerViewHeight;
}

-(void) setFooterViewHeight:(float)height {
	self->_footerViewHeight = height;
	[self setNeedsLayout];
}

-(float) footerViewHeight {
	return self->_footerViewHeight;
}

#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)sender didFailLoadWithError:(NSError *)error {
	// forward web view delegate invocations
	if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
		[self.delegate webView:sender didFailLoadWithError:error];
	}
}

- (BOOL)webView:(UIWebView *)sender shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// forward web view delegate invocations
	if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
		return [self.delegate webView:sender shouldStartLoadWithRequest:request navigationType:navigationType];
	}
	else
		return YES;
}

-(void) webViewDidFinishLoad:(UIWebView *)sender {
	
	// forward web view delegate invocations
	if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
		[self.delegate webViewDidFinishLoad:sender];
	}
	
    self.webScrollView = self.webView.scrollView;
    self.webScrollView.scrollsToTop = YES;
    
	// remove shadows from bounce
    for (UIView* shadowView in [self.webScrollView subviews])
    {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
    }
    
    // save reference to old delegate and assign new one
    if (self.webScrollView.delegate)
        self.oldScrollViewDelegate = self.webScrollView.delegate;
    else if ([self.webView conformsToProtocol:@protocol(UIScrollViewDelegate)])
        self.oldScrollViewDelegate = self.webView;
    self.webScrollView.delegate = self;
    
    if (self.headerView) {
        // readd the header control so it stays on top
        [self.webScrollView addSubview:self.headerView];
    }
    
    if (self.footerView) {
        // readd the header control so it stays on top
        [self.webScrollView addSubview:self.footerView];
    }
    
    NSString* jsSetViewport =
    @"var meta = document.createElement('meta'); \
    meta.name = 'viewport'; \
    meta.content = 'user-scalable=yes, initial-scale=1.0, maximum-scale=5.0'; \
    document.getElementsByTagName('head')[0].appendChild(meta);";
    [self.webView stringByEvaluatingJavaScriptFromString:jsSetViewport];
    
    [self recalculateContentHeight];
	
	[self setNeedsLayout];
}

- (void)recalculateContentHeight {
    NSString* bottomDivID = [NSString stringWithFormat:@"bottomdiv%u", arc4random()];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@" \
                                                          var ele = document.createElement('div'); \
                                                          ele.setAttribute('id', '%@'); \
                                                          ele.setAttribute('style', 'width: 100%%; height: 1px; clear: both;'); \
                                                          document.body.appendChild(ele);", bottomDivID]];
    
    // get the actual content size of the body
    self.actualContentHeight = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('%@').offsetTop", bottomDivID]] floatValue];
    if (self.actualContentHeight < 1.0) {
        self.actualContentHeight = self.frame.size.height / 2 - self.headerViewHeight - self.footerViewHeight;
    }
    
    self.actualContentWidth = self.webScrollView.contentSize.width;
    if (self.actualContentWidth < 1.0) {
        self.actualContentWidth = self.frame.size.width;
    }
    
    self.webScrollView.contentInset = UIEdgeInsetsMake(self.headerViewHeight, 0, self.footerViewHeight, 0);
    self.webScrollView.contentOffset = CGPointMake(0, 0-self.headerViewHeight);
    
    [self setNeedsLayout];
}

- (void)webViewDidStartLoad:(UIWebView *)sender {
	// forward web view delegate invocations
	if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
		[self.delegate webViewDidStartLoad:sender];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
	//
	
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
		//
		[self.oldScrollViewDelegate scrollViewDidScroll:scrollView];
	}
	
	
	[self layoutHeaderAndFooterViews];
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView {
	//
	
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
		//
		[self.oldScrollViewDelegate scrollViewDidZoom:scrollView];
	}
	
	[self layoutHeaderAndFooterViews];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
		
		[self.oldScrollViewDelegate scrollViewWillBeginDragging:scrollView];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
		
		[self.oldScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
		//
		[self.oldScrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
		
		[self.oldScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
		
		[self.oldScrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
		
		return [self.oldScrollViewDelegate viewForZoomingInScrollView:scrollView];
	}
	else
		return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view  {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
		
		[self.oldScrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
	}
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
		
		[self.oldScrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
	}
	
	[self layoutHeaderAndFooterViews];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
		
		[self.oldScrollViewDelegate scrollViewDidScrollToTop:scrollView];
	}
}

@end
