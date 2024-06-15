//
//  PostNewUserRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/06.
//

import Foundation

struct PostNewUserRequest: Requestable {
    
    var path: String = "/users"
    var method: RequestMethod = .post
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
    
    init(id: String, username: String) {
        self.body = [
            "id": id,
            "username": username
        ]
    }
}
