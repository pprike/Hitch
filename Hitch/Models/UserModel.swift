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
    var userType: String? = "Patron"
    

    init(id: String?,name: String?,email: String?,age: Int?,password: String?,userType: String?){

        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.age = age
        self.userType = userType
       
      }
    
    var dictionary: [String: Any] {
        return [
            "id":id!,
            "name": name!,
            "email": email!,
            "age": age! ,
            "password": password!,
            "userType": userType!,
        ]
      }
}
