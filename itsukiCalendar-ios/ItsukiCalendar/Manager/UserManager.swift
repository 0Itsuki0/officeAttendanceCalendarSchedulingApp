//
//  UserManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/13.
//

import Foundation

class UserManager: ObservableObject {
//    static private var user: User = User(id: "itsuki@example.com", username: "itsuki")
    
    var userId = ""
    @Published var userName = ""
    
    private let userNameKey = "userName"
    private let userIdKey = "userId"

    init() {

        let savedUserName = UserDefaults.standard.value(forKey: userNameKey) as? String ?? ""
        let savedUserId = UserDefaults.standard.value(forKey: userIdKey) as? String ?? ""
        
        self.userId = savedUserId
        self.userName = savedUserName
    }
    
    
    func shouldPromptUserNameEntry() -> Bool {
        return userId.isEmpty
    }
    
    
    func getUserPoints() async throws -> Int {
        let request = GetUserRequest(id: userId)
        let response = try await request.sendRequest(responseType: UserResponse.self)
        return response.user.pointsRemained
    }
    
    func registerNewUser(_ name: String) async throws {
        let id = UUID().uuidString
        
        let request = PostNewUserRequest(id: id, username: name)
        let _ = try await request.sendRequest(responseType: UserResponse.self)

        UserDefaults.standard.set(id, forKey: userIdKey)
        UserDefaults.standard.set(name, forKey: userNameKey)

        DispatchQueue.main.async {
            self.userId = id
            self.userName = name
        }
    }
    
    func checkExistingUser(id: String, password: String) async throws {
        
        let request = VerifyUserRequest(id: id, password: password)
        let response = try await request.sendRequest(responseType: UserResponse.self)

        UserDefaults.standard.set(id, forKey: userIdKey)
        UserDefaults.standard.set(response.user.username, forKey: userNameKey)
        DispatchQueue.main.async {
            self.userId = id
            self.userName = response.user.username
        }
    }
    
    
    func removeUserInfo() {
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
    
    
    func changeUserName(_ newName: String) async throws {
        
        let request = PutUserInfoRequest(id: self.userId, username: newName)
        let _ = try await request.sendRequest(responseType: UserResponse.self)
        
        UserDefaults.standard.set(newName, forKey: userNameKey)

        DispatchQueue.main.async {
            self.userName = newName
        }
    }
    
    func requestSyncPassword() async throws -> String {
        let password = Utility.randomString(12)
        
        let request = PutUserInfoRequest(id: self.userId, password: password)
        let _ = try await request.sendRequest(responseType: UserResponse.self)

        // register generated password on server
        return password
        
    }
    
    
}
