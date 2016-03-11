//
//  AddItemViewController.swift
//  persistenciadatos
//
//  Created by Raul Suarez Dabo on 08/03/16.
//  Copyright © 2016 es.com.suarez. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var search: UISearchBar!
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    var book: Book?
    
    let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        self.managedObjectContext = appDelegate.managedObjectContext
        super.viewDidLoad()
        search.delegate = self
        self.book = Book()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addItemAction(sender: AnyObject) {
        if (self.book!.isCorrect()) {
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext!)
            newItem.setValue(self.book?.getTitle(), forKey: "title")
            newItem.setValue(self.book?.getAuthorsToString(), forKey: "authors")
            if (self.image != nil) {
                newItem.setValue(UIImagePNGRepresentation(self.image.image!), forKey: "image")
            }
            do {
                try self.managedObjectContext!.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            } catch {
                self.showAlert("Error!", message: "Unnexpected problem saving the information")
            }
            
        }
        else {
            self.showAlert("No item to add", message: "Sorry :( it's impossible to add an item if you don't make any search")
        }
    }

    @IBAction func canceItemAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if Reachability.isConnectedToNetwork() == true {
            self.view.endEditing(true)
            
            let url = NSURL(string: self.urls + searchBar.text!)
            
            let sesion = NSURLSession.sharedSession();
            let bloque = {(datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
                do {
                    let dictionary = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableContainers)
                    dispatch_sync(dispatch_get_main_queue(), {
                        let isbn =  self.search.text!
                        self.book!.setTitle(dictionary["ISBN:\(isbn)"]!!["title"] as! NSString as String)
                        self.titleLabel.text = "Title: \(self.book!.getTitle())"
                        let authors = dictionary["ISBN:\(isbn)"]!!["authors"] as! NSArray as Array
                        for item in authors {
                            let name = item["name"] as! NSString as String
                            self.book!.addAuthor(name)
                        }
                        self.authorLabel.text = "Author/s: \(self.book!.getAuthorsToString())"
                        if ((dictionary["ISBN:\(isbn)"]!!["cover"]! != nil) && (dictionary["ISBN:\(isbn)"]!!["cover"]!!["small"]! != nil)) {
                            let cover = dictionary["ISBN:\(isbn)"]!!["cover"]!!["small"] as! NSString as String
                            
                            self.book!.setCover(cover)
                            
                            let coverUrl = NSURL(string: cover)
                            let sesion = NSURLSession.sharedSession();
                            let getCover = {(datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
                                dispatch_sync(dispatch_get_main_queue(), {
                                    self.image.image = UIImage(data: datos!)
                                })
                            }
                            let dt = sesion.dataTaskWithURL(coverUrl!, completionHandler: getCover)
                            dt.resume()
                        }
                    })
                    
                } catch _ as NSError {
                    self.showAlert("Unexpected error", message: "Sorry :( but it looks that we get some kind of error from the API")
                }
                
            }
            
            let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque)
            dt.resume()
            
        }
        else {
            self.showAlert("No internet conection", message: "Sorry :( it's impossible to make this request without internet conection")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
