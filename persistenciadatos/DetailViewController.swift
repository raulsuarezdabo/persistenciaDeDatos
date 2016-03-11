//
//  DetailViewController.swift
//  persistenciadatos
//
//  Created by Raul Suarez Dabo on 08/03/16.
//  Copyright © 2016 es.com.suarez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var authorsLabel: UILabel!

    @IBOutlet weak var image: UIImageView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.titleLabel {
                label.text = detail.valueForKey("title")!.description
            }
            if let label = self.authorsLabel {
                label.text = detail.valueForKey("authors")!.description
            }
            if let label = self.image {
                label.image = UIImage(data: detail.valueForKey("image")! as! NSData)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

