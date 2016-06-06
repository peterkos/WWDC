//
//  ActionButtonsController.swift
//  WWDC
//
//  Created by Guilherme Rambo on 26/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ActionButtonsViewController: NSViewController {
    
    var session: Session! {
        didSet {
            updateUI()
        }
    }
    
    var stackView: NSStackView {
        return view as! NSStackView
    }
    
    var watchHDVideoCallback: () -> () = {}
    var watchVideoCallback: () -> () = {}
    var showSlidesCallback: () -> () = {}
    var toggleWatchedCallback: () -> () = {}
    var afterCallback: () -> () = {}
    
    /* these outlets are not weak because we will be removing the buttons from the view
       but we have to keep our reference to put them back later */
    @IBOutlet var slidesButton: NSButton!
    @IBOutlet var progressButton: NSButton!
    
    // Quality selector + label are in their own stack
    @IBOutlet var qualitySelector: NSPopUpButton!
    @IBOutlet weak var qualityStack: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        if !self.viewLoaded {
            return
        }
        
        noSession()
        
        if let session = session {
            setSessionCanBeWatched(true)
            setSessionCanBeWatchedInHD((session.hdVideoURL != ""))
            setSessionHasSlides((session.slidesURL != ""))
            reflectSessionProgress()
        } else {
            noSession()
        }
    }
    
    private func noSession() {
        setSessionCanBeWatched(false)
        setSessionCanBeWatchedInHD(false)
        setSessionHasSlides(false)
        hideProgressButton()
    }
    
    private func setSessionCanBeWatched(can: Bool) {
        if can && qualityStack.superview === self.view {
            qualitySelector.addItemWithTitle("Standard")
        } else if can {
            qualityStack.addView(qualitySelector, inGravity: .Top)
            qualitySelector.addItemWithTitle("Standard")
        }
    }
    private func setSessionCanBeWatchedInHD(can: Bool) {
        if can && qualityStack.superview === self.view {
            qualitySelector.addItemWithTitle("HD")
        } else if can {
            qualityStack.addView(qualitySelector, inGravity: .Top)
            qualitySelector.addItemWithTitle("HD")
        }
    }
    private func setSessionHasSlides(has: Bool) {
        if has {
            stackView.addView(slidesButton, inGravity: .Top)
        } else {
            if slidesButton.superview != nil {
                slidesButton.removeFromSuperviewWithoutNeedingDisplay()
            }
        }
    }
    private func hideProgressButton() {
        if progressButton.superview != nil {
            progressButton.removeFromSuperviewWithoutNeedingDisplay()
        }
    }
    
    private struct ProgressButtonTitles {
        static let MarkAsWatched = NSLocalizedString("Mark as Watched", comment: "mark as watched button title")
        static let MarkAsUnwatched = NSLocalizedString("Mark as Unwatched", comment: "mark as unwatched button title")
    }
    
    private func reflectSessionProgress() {
        if session.progress < 100 {
            progressButton.title = ProgressButtonTitles.MarkAsWatched
            if progressButton.superview == nil {
                stackView.addView(progressButton, inGravity: .Top)
            }
        } else {
            progressButton.title = ProgressButtonTitles.MarkAsUnwatched
            if progressButton.superview == nil {
                stackView.addView(progressButton, inGravity: .Top)
            }
        }
    }
    
    @IBAction func qualitySelected(sender: NSPopUpButton) {
        if (sender.indexOfSelectedItem == 0) {
            watchVideoCallback()
            afterCallback()
        } else if (sender.indexOfSelectedItem == 1) {
            watchHDVideoCallback()
            afterCallback()
        } else {
            print("ERROR!")
        }
        
    }
    
    @IBAction func watchSlides(sender: NSButton) {
        showSlidesCallback()
        afterCallback()
    }
    @IBAction func toggleWatched(sender: NSButton) {
        toggleWatchedCallback()
        afterCallback()
    }
}
