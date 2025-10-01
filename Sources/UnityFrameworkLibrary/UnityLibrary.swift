//
//  UnityLibrary.swift
//  APROPLAN
//
//  Created by Marzena Komorowska on 19/09/2025.
//  Copyright © 2025 APROPLAN. All rights reserved.
//

import Foundation
import UIKit
import UnityFramework

public struct UnityObject {
    public var name: String

    public init(name: String) {
        self.name = name
    }
}

public struct UnityFunction<Message: CustomStringConvertible> {
    public var object: UnityObject
    public var name: String
    public var message: Message?

    public init(object: UnityObject, name: String, message: Message? = nil) {
        self.object = object
        self.name = name
        self.message = message
    }
}

@MainActor
public class UnityLibrary: NSObject {
    public static let shared = UnityLibrary()

    public var rootViewController: UIViewController? {
        guard let appController else {
            return nil
        }
        return appController.rootViewController
    }

    public var isShown = false

    private var framework: UnityFramework
    private var listener = UnityLibraryListener()

    private var appController: UnityAppController? {
        guard isShown else { return nil }
        return framework.appController()
    }

    private override init() {
        guard let framework = Self.loadUnityFramework() else {
            fatalError("Couldn't initialize UnityFramework")
        }

        self.framework = framework

        super.init()

        self.framework.register(listener)
    }

    public func showUnity() -> UIViewController? {
        guard isShown == false else { return rootViewController }

        Log.info(Self.self, "Show Unity")

        if framework.appController() != nil {
            framework.pause(false)
        } else {
            framework.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)
        }

        isShown = true

        return framework.appController().rootViewController
    }

    public func hideUnity() {
        guard isShown else { return }

        Log.info(Self.self, "Hide Unity")

        isShown = false

        framework.pause(true)
        framework.appController().rootView.removeFromSuperview()
    }

    public func send<M>(_ function: UnityFunction<M>) {
        framework.sendMessageToGO(withName: function.object.name,
                                  functionName: function.name,
                                  message: function.message?.description)
    }
}

class UnityLibraryListener: NSObject, UnityFrameworkListener {
    public func unityDidUnload(_ notification: Notification!) {
        Log.info(Self.self, "Unity did unload \(String(describing: notification))")
    }

    public func unityDidQuit(_ notification: Notification!) {
        Log.info(Self.self, "Unity did quit \(String(describing: notification))")
    }
}

// MARK: Initialization

extension UnityLibrary {
    static func loadUnityFramework() -> UnityFramework? {
        Log.info(Self.self, "Load UnityFramework")

        let bundlePath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"

        guard let bundle = Bundle(path: bundlePath) else {
            Log.error(Self.self, "Bundle not found")
            return nil
        }

        if bundle.isLoaded == false {
            bundle.load()
        }

        guard let framework = bundle.principalClass?.getInstance() else {
            Log.error(Self.self, "Principal class not found")
            return nil
        }

        if framework.appController() == nil {
            framework.setDataBundleId("com.unity3d.framework")
        }

        return framework
    }
}

// MARK: UI extensions

extension UnityLibrary {
    public func showUnityInView(_ view: UIView) {
        if let viewController = showUnity(), let unityView = viewController.view {
            unityView.frame = view.bounds
            unityView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(unityView)

            UnityLibrary.shared.appController?.window.isHidden = true
        }
    }
}
