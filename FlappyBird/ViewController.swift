//
//  ViewController.swift
//  FlappyBird
//
//  Created by kobayashi on 2016/08/17.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import UIKit
import SpriteKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SKViewに型を変更する
        let skView = self.view as! SKView
        
        // FPSをひょうじする
        skView.showsFPS = true
        
        // ノードの数を表示する
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        // ビューにシーンを表示する
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ステータスバーを消す
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

}

