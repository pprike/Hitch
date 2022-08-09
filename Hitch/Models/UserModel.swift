//
//  UserModel.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-31.
//

import UIKit

class UserModel: NSObject {

    var id: String?
    var name: String?
    var email: String?
    var age: Int?
    var password: String?
    var userType: String? = Constants.userPatron
    var phone: String?
    

    init(id: String?,name: String?,email: String?,age: Int?,password: String?,userType: String?,phone: String?){

        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.age = age
        self.userType = userType
        self.phone = phone
      }
    
    var dictionary: [String: Any] {
        return [
            "id":id!,
            "name": name!,
            "email": email!,
            "age": age! ,
            "password": password!,
            "userType": userType!,
            "phone": phone!,
            "profilePic":""
        ]
      }
}
