//
//  Extensions+UITableViewCell.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension UITableViewCell {
    var tableView: UITableView? {
        var view = self.superview
        while view != nil && view!.isKind(of: UITableView.self) == false {
            view = view!.superview
        }
        return view as? UITableView
    }
}
