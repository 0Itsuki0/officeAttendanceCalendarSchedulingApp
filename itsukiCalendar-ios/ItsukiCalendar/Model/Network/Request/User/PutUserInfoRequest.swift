//
//  PutUserInfoRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/06.
//

import Foundation

struct PutUserInfoRequest: Requestable {
    
    var path: String = "/users/:id"
    var method: RequestMethod = .put
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
    
    init(id: String, password: String) {
        self.pathParams = [":id": id]
        self.body = ["password": password]
    }
    
    init(id: String, username: String) {
        self.pathParams = [":id": id]
        self.body = ["username": username]
    }
}
