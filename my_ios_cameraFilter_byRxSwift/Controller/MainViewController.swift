//
//  MainViewController.swift
//  my_ios_cameraFilter_byRxSwift
//
//  Created by 危末狂龍 on 2023/3/3.
//

import UIKit
import SnapKit
import RxSwift

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    //MARK: - UI
    let MainPhotoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.image = UIImage(systemName: "")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let FilterButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.backgroundColor = .lightGray
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("FilterButton", for: .normal)
        return button
    }()
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationUI()
        FilterButton.addTarget(self, action: #selector(applyFilterButtonPressed), for: .touchUpInside)
    }
    
    func setupNavigationUI() {
        title = "CameraFilter"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoView))
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(MainPhotoImageView)
        view.addSubview(FilterButton)
        
        MainPhotoImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 10, left: 10, bottom: 100, right: 10))
        }
        FilterButton.snp.makeConstraints { (make) in
            make.top.equalTo(MainPhotoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    func prepare(for photosCVC: PhotoCollectionViewController) {
        
        photosCVC.selectedPhoto.subscribe(onNext: { [weak self] photo in
            DispatchQueue.main.async {
                self?.updateUI(with: photo)
            }
        }).disposed(by: disposeBag)
        
    }
    
    private func updateUI(with image: UIImage) {
        self.MainPhotoImageView.image = image
        self.FilterButton.isHidden = false
    }
    
    @objc func addPhotoView() {
        let photosCVC = PhotoCollectionViewController()
        prepare(for: photosCVC)
        let addPhotoNC = UINavigationController(rootViewController: photosCVC )
        present(addPhotoNC, animated: true, completion: nil)
    }
    
    @objc func applyFilterButtonPressed() {
        
        guard let sourceImage = self.MainPhotoImageView.image else {
            return
        }
        
       FiltersService().applyFilter(to: sourceImage)
        .subscribe(onNext: { filteredImage in
            
            DispatchQueue.main.async {
                self.MainPhotoImageView.image = filteredImage
            }
            
        }).disposed(by: disposeBag)
        
    }
    
}

