//
//  OnboardingScreenViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class OnboardingScreenViewController: UIViewController {
    
    // Buttons
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var onboardingScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // Create Button Action for Instagram and Twitter Page 
    
    @IBAction func btn_OpenInstagramPage(_ sender: Any) {
        let url = URL(string: "https://www.instagram.com/airstrike7on7/")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    @IBAction func btn_OpenTwitterPage(_ sender: Any) {
        let url = URL(string: "https://twitter.com/airstrike7on7")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonColors()
        changeStatusBarColor()
        onboardingScrollView.contentSize = CGSize(width: self.view.bounds.width * 4, height: onboardingScrollView.bounds.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - Helper Functions

extension OnboardingScreenViewController {
    
    fileprivate func setupButtonColors() {
        signUpButton.tintColor = Colors.lightTextColor
        signUpButton.backgroundColor = Colors.airstrikeDarkColor
        
        loginButton.tintColor = Colors.lightTextColor
        loginButton.backgroundColor = Colors.onboardingButtonColor
    }
    
    fileprivate func changeStatusBarColor() {
        UIApplication.shared.statusBarStyle = .default
    }
    
}

// MARK: - IBActions

extension OnboardingScreenViewController {
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
    }
   
    @IBAction func signUpButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        onboardingScrollView.setContentOffset(onboardingScrollView.offsetForPageIndex(pageIndex: sender.currentPage), animated: true)
    }
    
}

// MARK: - ScrollView Delegate

extension OnboardingScreenViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.currentPageIndex)
        pageControl.currentPage = scrollView.currentPageIndex
    }
}
