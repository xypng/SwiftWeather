//
//  RefreshView.swift
//  FTPullToRefreshDemo
//
//  Created by luckytantanfu on 15/11/2.
//  Copyright © 2015年 futantan. All rights reserved.
//

import UIKit

protocol RefreshViewDelegate {
  func refreshViewDidRefresh(refreshView: RefreshView)
}

class RefreshView: UIView {
  var progress: CGFloat = 0.0
  var isRefreshing: Bool = false
  var delegate: RefreshViewDelegate?
  var activityIndicator: UIActivityIndicatorView!
  var labRefresh:UILabel!
  
  
  unowned var scrollView: UIScrollView
  
  init(frame: CGRect, scrollView: UIScrollView) {
    self.scrollView = scrollView
    super.init(frame: frame)
    self.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
    activityIndicator = UIActivityIndicatorView()
    let labRect = CGRectMake(CGRectGetWidth(self.frame)/2-40+15, CGRectGetHeight(self.frame)-20, 80, 20)
    let activityRect = CGRectMake(CGRectGetWidth(self.frame)/2-40-15, CGRectGetHeight(self.frame)-25, 30, 30)
    labRefresh = UILabel(frame: labRect)
    activityIndicator = UIActivityIndicatorView(frame: activityRect)
    labRefresh.text = "下拉刷新"
    labRefresh.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    labRefresh.font = UIFont.systemFontOfSize(15)
    self.addSubview(labRefresh)
    self.addSubview(activityIndicator)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func animateWithProgress(progress: CGFloat) {
  }
  
  // 触发刷新条件
  func animateWhileRefreshing() {
    isRefreshing = true
    labRefresh.text = "正在刷新"
    print("animate... while refreshing")
  }
  
  // 当刷新工作完成之后调用
  func endRefreshing() {
    isRefreshing = false
    UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseOut], animations: {
      self.shouldRefreshViewBeLocked(false)
      }, completion: nil)
  }
  
  func shouldRefreshViewBeLocked(shouldLock: Bool) {
    var contentInset = self.scrollView.contentInset
    contentInset.top = shouldLock ?
      (contentInset.top + self.frame.size.height) : (contentInset.top - self.frame.size.height)
    self.scrollView.contentInset = contentInset
  }
  
}

// MARK: - UIScrollViewDelegate

extension RefreshView: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    // 计算向下滑动了多少距离
    self.activityIndicator.startAnimating()
    let offsetY = max(-(scrollView.contentOffset.y + scrollView.contentInset.top), 0.0)
    self.progress = min(offsetY / frame.size.height, 1.0)
    if progress==1 && !isRefreshing {
        labRefresh.text = "松开刷新"
    } else if !isRefreshing {
        labRefresh.text = "下拉刷新"
    }
    if !isRefreshing {
      animateWithProgress(progress)
    }
  }
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if !isRefreshing && self.progress == 1.0 {
      delegate?.refreshViewDidRefresh(self)
      animateWhileRefreshing()
      shouldRefreshViewBeLocked(true)
    }
  }
}