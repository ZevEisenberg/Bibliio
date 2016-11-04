//
//  BookListViewController.swift
//  Biblio
//
//  Created by Adam on 10/28/16.
//  Copyright © 2016 Adam Tecle. All rights reserved.
//

import UIKit
import RealmSwift

class BookListViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, BookListCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let backgroundView = UIView()
    
    var books: Results<Book>?
    
    private var willDeleteIndexPath: IndexPath?
    
    private let cellMargin: CGFloat = 14.0
    
    let slideAnimationController = VerticalSlideAnimationController()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        books = (realm.objects(Book.self))
        
        setupCollectionView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = BookDetailViewController()
        
        let navigationController = UINavigationController.init(rootViewController: vc)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        
        DispatchQueue.main.async { [unowned self] in
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Action
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let addBookVC = AddBookViewController()
        let navigationController = UINavigationController.init(rootViewController: addBookVC)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        
        DispatchQueue.main.async { [unowned self] in
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - BookListCellDelegate
    
    func moreButtonPressed(cell: BookListCollectionViewCell) {
        
        let indexPath = collectionView.indexPath(for: cell)!
        let book = books?[indexPath.row]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (action) in
            guard let bookToDelete = book
                else { return }
            
            self.realm.beginWrite()
            self.realm.delete(bookToDelete)
            try! self.realm.commitWrite()
            self.books = self.realm.objects(Book.self)
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
        }
        
        alertController.addAction(destroyAction)
        
        present(alertController, animated: true)
    }
    
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookListCollectionViewCell", for: indexPath) as! BookListCollectionViewCell
        
        cell.delegate = self
        
        let book = books?[indexPath.row]
        
        cell.book = book
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let books = self.books
            else { return 0 }
        return books.count
    }
    
    // MARK: - Setup
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let width = UIScreen.main.bounds.width - (cellMargin * 2)
        let height = UIScreen.main.bounds.height * 0.3
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.register(UINib.init(nibName: "BookListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookListCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
    }
}

extension BookListViewController: UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideAnimationController.isPresenting = true
        return slideAnimationController;
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideAnimationController.isPresenting = false
        return slideAnimationController
    }
}

extension BookListViewController: AddBookViewControllerDelegate {
   
    public func addBookViewController(_ vc: AddBookViewController, _ didSave: Book) {
        books = realm.objects(Book.self)
        collectionView.performBatchUpdates({ [unowned self] in
            let indexSet = IndexSet(integer: 0)
            self.collectionView.reloadSections(indexSet)
            }, completion: nil)
    }
}
