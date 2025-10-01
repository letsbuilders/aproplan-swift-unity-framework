//
//  Log.swift
//  UnityFramework
//
//  Created by Marzena Komorowska on 01/10/2025.
//

struct Log {
    static func info(_ source: Any, _ message: String) {
        print("INFO: \(type(of: source)): \(message)")
    }

    static func error(_ source: Any, _ message: String) {
        print("ERROR: \(type(of: source)): \(message)")
    }
}
