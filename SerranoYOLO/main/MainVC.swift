//
//  MainVC.swift
//  SerranoYOLO
//
//  Created by ZHONGHAO LIU on 11/22/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// MARK: - IBOUTLETS
	
	@IBOutlet var navBar: UINavigationBar!
	@IBOutlet var menuTable: UITableView!
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// MARK: - Attributes
	
	public static let cellIdentifier = "YOLOMENU"
	// menu
	var menu = [
		["YOLO Camera"],
	]
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// MARK: - UIViewController
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.configureTable()
		self.configureNavbar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func configureNavbar() {
		self.navBar.topItem?.title = "Serrano + YOLO"
	}
	
	func configureTable() {
		self.menuTable.dataSource = self
		self.menuTable.delegate = self
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// MARK: - Table delegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		switch cell!.textLabel!.text! {
		case "YOLO Camera":
			let photoVC = YoloPhotoVC(nibName: "photoVC",  bundle: nil)
			photoVC.view.bounds = UIScreen.main.bounds
			photoVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
			self.present(photoVC, animated: true, completion: nil)
		default:
			fatalError()
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// MARK: - Table datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.menu.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: MainVC.cellIdentifier)
		if cell == nil {
			cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: MainVC.cellIdentifier)
		}
		cell!.textLabel!.text = menu[indexPath.section][indexPath.row]
		return cell!
	}
	
	
}
