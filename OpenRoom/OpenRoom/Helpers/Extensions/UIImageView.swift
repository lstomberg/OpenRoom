//
//  UIImageView.swift
//  OpenRoom
//
//  Created by Lucas Stomberg ( https://www.lucasstomberg.com )
//  Copyright © 2016 'Lucas Stomberg'. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

extension UIImageView {
    public func setImageWithURL(_ url: String, filter: ImageFilter? = nil, placeholder: UIImage? = nil, completion: ((DataResponse<UIImage>) -> Void)? = nil) {
        af_setImage(withURL: URL(string: url)!, placeholderImage: placeholder, filter: filter, imageTransition: .crossDissolve(0.3), completion: {
            (response: DataResponse<UIImage>) in
            if let error = response.result.error {
                print(error.localizedDescription)
            }
            completion?(response)
        })
    }
}
