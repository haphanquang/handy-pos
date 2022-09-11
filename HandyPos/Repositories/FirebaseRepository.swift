//
//  FirebaseRepository.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/31.
//

import Foundation
import Firebase
import Combine

class FirebaseRepository {
    private let ref = Database.database().reference()
    
    func saveMessage(
        name: String,
        email: String,
        subject: String,
        content: String
    ) -> AnyPublisher<ContactMessage, Error> {
        return Future<ContactMessage, Error> { signal in
            let message = ContactMessage(name: name, email: email, subject: subject, content: content)
            self.ref
                .child("messages")
                .child(message.id)
                .setValue(message.dictionary)
            signal(.success(message))
        }.eraseToAnyPublisher()
    }
}

struct ContactMessage {
    let id = UUID().uuidString
    let name: String
    let email: String
    let subject: String
    let content: String
    
    var dictionary: [String: String] {
        var dict = ["name": name, "email": email, "subject": subject, "content": content]
        dict["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return dict
    }
}

enum FirebaseError: Error { }
