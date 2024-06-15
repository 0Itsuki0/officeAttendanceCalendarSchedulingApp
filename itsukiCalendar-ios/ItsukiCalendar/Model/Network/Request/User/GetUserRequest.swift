//
//  GetUserRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/06.
//

import Foundation


struct GetUserRequest: Requestable {
    
    var path: String = "/users/:id"
    var method: RequestMethod = .get
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
    
    init(id: String) {
        self.pathParams = [":id": id]
    }
}
