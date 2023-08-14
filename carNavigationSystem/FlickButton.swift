//
//  FlickButton.swift
//  carNavigationSystem
//
//  Created by K I on 2023/08/14.
//

import UIKit

protocol FlickButtonDelegate {

    // コンポーネントビューが表示される直前に呼び出されます。
    func flickButton(_ flickButton: FlickButton, componentsWillAppear: [FlickButton.Location: UIView])

    // コンポーネントビューが表示された直後に呼び出されます。
    func flickButton(_ flickButton: FlickButton, componentsDidAppear: [FlickButton.Location: UIView])

    // フリック入力後に呼び出されます。
    func flickButton(_ flickButton: FlickButton, didFlick activatedView: UIView)

    // コンポーネントビューが非表示になる直前に呼び出されます。
    func flickButton(_ flickButton: FlickButton, componentsWillDisappear: [FlickButton.Location: UIView])

    // コンポーネントビューが非表示になった直後に呼び出されます。
    func flickButton(_ flickButton: FlickButton, componentsDidDisappear: [FlickButton.Location: UIView])

}

// デフォルト実装では何も処理を行いません。
extension FlickButtonDelegate {
    func flickButton(_ flickButton: FlickButton, componentsWillAppear: [FlickButton.Location: UIView]) {}
    func flickButton(_ flickButton: FlickButton, componentsDidAppear: [FlickButton.Location: UIView]) {}
    func flickButton(_ flickButton: FlickButton, didFlick activatedView: UIView) {}
    func flickButton(_ flickButton: FlickButton, componentsWillDisappear: [FlickButton.Location: UIView]) {}
    func flickButton(_ flickButton: FlickButton, componentsDidDisappear: [FlickButton.Location: UIView]) {}
}

class FlickButton: UIButton {

    // 各コンポーネントビューの位置を区別する
    enum Location {
        case top
        case bottom
        case left
        case right
    }

    //-----------------------------------------------------
    // 各コンポーネントビューです。
    // 設定時にすでにコンポーネントビューが設定されていたら、スーパービューから取り除きます。
    // 設定後にコンポーネントビューを保持する配列にセットします。
    var topView: UIView? {
        willSet {
            guard let topView = topView else {
                return
            }
            topView.removeFromSuperview()
        }
        didSet {
            guard let topView = topView else {
                return
            }
            componentViews[.top] = topView
        }
    }

    var bottomView: UIView? {
        willSet {
            guard let bottomView = bottomView else {
                return
            }
            bottomView.removeFromSuperview()
        }
        didSet {
            guard let bottomView = bottomView else {
                return
            }
            componentViews[.bottom] = bottomView
        }
    }

    var leftView: UIView? {
        willSet {
            guard let leftView = leftView else {
                return
            }
            leftView.removeFromSuperview()
        }
        didSet {
            guard let leftView = leftView else {
                return
            }
            componentViews[.left] = leftView
        }
    }

    var rightView: UIView? {
        willSet {
            guard let rightView = rightView else {
                return
            }
            rightView.removeFromSuperview()
        }
        didSet {
            guard let rightView = rightView else {
                return
            }
            componentViews[.right] = rightView
        }
    }
    //-----------------------------------------------------

    // 各コンポーネントビューと自身のデフォルトカラーです。
    // フリックによってアクティブ状態になっていない場合に背景色に設定されます。
    var defaultColor: UIColor? {
        didSet {
            backgroundColor = defaultColor
        }
    }

    // フリックによってアクティブになった場合に背景色に設定されます。
    var activeColor: UIColor?

    var delegate: FlickButtonDelegate?

    //------------------------------------------------------------------------------
    // 各コンポーネントビューと自身とのマージンを設定できます。
    // ここに設定した数値分離れた場所にコンポーネントビューが配置されます。
    // 例) componentMargins = UIEdgeInsets(top: 2, left: 4, bottom: 6, right: 8)
    //
    //                [topView]
    //                    |
    //                    2
    //                    |
    // [leftView]-4-[FlickButton]-8-[rightView]
    //                    |
    //                    6
    //                    |
    //                [bottomView]
    var componentMargins = UIEdgeInsets.zero
    //------------------------------------------------------------------------------

    // 設定されているコンポーネントビューを保持します。
    private(set) var componentViews = [Location: UIView]()

    // フリック入力によってアクティブになったビューをユーザに分かりやすいように
    // 少しの間表示状態にするために使用します。
    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizers()
    }

    // 各GestureRecognizerを設定します。
    // UILongPressGestureRecognizer: ロングプレスによって各コンポーネントビューを表示します。
    // UIPanGestureRecognizer: 上下左右のフリック入力の判定に使用します。
    private func setupGestureRecognizers() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.25
        addGestureRecognizer(longPressGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }

    // 各コンポーネントビューを表示します。
    // componentMarginsに設定された値を考慮して表示位置を決定します。
    private func addComponentViews() {
        delegate?.flickButton(self, componentsWillAppear: componentViews)
        for (location, componentView) in componentViews {
            componentView.backgroundColor = defaultColor
            addSubview(componentView)
            let safeAreaFrame = safeAreaLayoutGuide.layoutFrame
            switch location {
            case .top:
                componentView.frame = CGRect(
                    x: safeAreaFrame.origin.x,
                    y: safeAreaFrame.origin.y - safeAreaFrame.height - componentMargins.top,
                    width: safeAreaFrame.width,
                    height: safeAreaFrame.height
                )
            case .bottom:
                componentView.frame = CGRect(
                    x: safeAreaFrame.origin.x,
                    y: safeAreaFrame.origin.y + safeAreaFrame.height + componentMargins.bottom,
                    width: safeAreaFrame.width,
                    height: safeAreaFrame.height
                )
            case .left:
                componentView.frame = CGRect(
                    x: safeAreaFrame.origin.x - safeAreaFrame.width - componentMargins.left,
                    y: safeAreaFrame.origin.y,
                    width: safeAreaFrame.width,
                    height: safeAreaFrame.height
                )
            case .right:
                componentView.frame = CGRect(
                    x: safeAreaFrame.origin.x + safeAreaFrame.width + componentMargins.right,
                    y: safeAreaFrame.origin.y,
                    width: safeAreaFrame.width,
                    height: safeAreaFrame.height
                )
            }
        }
        delegate?.flickButton(self, componentsDidAppear: componentViews)
    }

    // 各コンポーネントビューを非表示にします。
    private func removeComponentViews() {
        delegate?.flickButton(self, componentsWillDisappear: componentViews)
        for componentView in componentViews.values {
            componentView.backgroundColor = defaultColor
            componentView.removeFromSuperview()
        }
        delegate?.flickButton(self, componentsDidDisappear: componentViews)
    }

    // フリック入力時に呼び出されます。
    // ユーザの指の位置からどのビューが選択されているかを判定し、背景色を変更します。
    private func handlePanGestureChanged(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        let activatedView = activeView(at: location)
        ([self] + componentViews.values).forEach { componentView in
            componentView.backgroundColor = (activatedView == componentView) ? activeColor : defaultColor
        }
    }

    // フリック入力終了時に呼び出されます。
    // デリゲートにフリック入力が終了したことを通知します。
    // フリック入力によってアクティブになったビューはすぐに非表示にするのではなく、ユーザに分かりやすいように0.2秒間表示した状態を保っています。
    private func handlePanGestureEnded(_ sender: UIPanGestureRecognizer) {

        let location = sender.location(in: self)
        let activatedView = activeView(at: location)
        delegate?.flickButton(self, didFlick: activatedView)

        backgroundColor = defaultColor
        removeComponentViews()
        if activatedView != self {
            addSubview(activatedView)
            activatedView.backgroundColor = activeColor
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handleRemovingActivatedViewEvent(_:)), userInfo: activatedView, repeats: false)
        }
    }

    // フリック入力時のユーザの指の座標から、選択されているビューを判定し返します。
    // どのビューも選択されていなければFlickButton自身が返されます。
    private func activeView(at location: CGPoint) -> UIView {
        let width = safeAreaLayoutGuide.layoutFrame.width
        let height = safeAreaLayoutGuide.layoutFrame.height
        if let topView = topView, location.y < 0 && ((0 <= location.x && location.x <= width) || abs(location.x) <= abs(location.y)) {
            return topView
        } else if let bottomView = bottomView, height < location.y && ((0 <= location.x && location.x <= width) || abs(location.x) <= abs(location.y)) {
            return bottomView
        } else if let leftView = leftView, location.x < 0 && ((0 <= location.y && location.y <= height) || abs(location.y) <= abs(location.x)) {
            return leftView
        } else if let rightView = rightView, width < location.x && ((0 <= location.y && location.y <= height) || abs(location.y) <= abs(location.x)) {
            return rightView
        }
        return self
    }

    // フリック入力によってアクティブになり少しの間表示状態を保っていたビューを非表示にします。
    @objc
    private func handleRemovingActivatedViewEvent(_ timer: Timer) {
        guard let activatedView = timer.userInfo as? UIView else {
            return
        }
        activatedView.removeFromSuperview()
    }

    // ロングプレスジェスチャーの開始によって各コンポーネントビューを表示します。
    // ロングプレスジェスチャーの終了によって各コンポーネントビューを非表示にします。
    @objc
    private func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            addComponentViews()
        } else if sender.state == .ended {
            removeComponentViews()
        }
    }

    // パンジェスチャーのコールバックです。
    @objc
    private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            backgroundColor = activeColor
            addComponentViews()
        } else if sender.state == .changed {
            handlePanGestureChanged(sender)
        } else if sender.state == .ended {
            handlePanGestureEnded(sender)
        }
    }

}

extension FlickButton: UIGestureRecognizerDelegate {

    // UILongPressGestureRecognizerとUIPanGestureRecognizerが同時に認識されるようにしています。
    // 以下の記事を参考にしました。
    // https://qiita.com/ruwatana/items/16997b1b416512c20fb6
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}


