//
//  GameScene.swift
//  FlappyBird
//
//  Created by kobayashi on 2016/08/17.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // node
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var itemNode:SKNode!
    var bird:SKSpriteNode!
    
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemLabelNode:SKLabelNode!
    
    
    // 衝突判定カテゴリー
    let birdCategory:   UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory:   UInt32 = 1 << 2
    let scoreCategory:  UInt32 = 1 << 3
    let itemCategory:   UInt32 = 1 << 4
    
    
    // スコア
    var score = 0
    var itemScore = 0
    
    // ベストスコア保存場所
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var groundHeight:CGFloat = 0 // 地面の高さサイズ
    var itemCnt = 0 // アイム名用のカウンタ
    
    // サウンド設定
    let sound: SKAction = SKAction.playSoundFileNamed("getItem.mp3", waitForCompletion: true)

    
    // SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMoveToView(view: SKView) {
        
        // 物理演算を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        // 背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        addChild(wallNode)

        itemNode = SKNode()
        addChild(itemNode)
        
    
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        setupScoreLabel()
        
        //runAction(self.sound)
    }
    
    // 地面をセット
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // 必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        groundHeight = groundTexture.size().height
        
        // スクロールアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: 5.0)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置
        CGFloat(0).stride(to: needNumber, by: 1.0).forEach {i in let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * size.width / 2, y: groundTexture.size().height / 2)
            
            // スプライトにアクションを設定する
            sprite.runAction(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size())
            
            // 衝突のカテゴリーを設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.dynamic = false
            
            // シーンにスプライトを追加する
            scrollNode.addChild(sprite)
        
        }
    }
    
    // 雲をセット
    func setupCloud() {
        // 雲の映像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // 必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width, y: 0, duration: 20.0)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveByX(cloudTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        CGFloat(0).stride(to: needCloudNumber, by: 1.0).forEach { i in let sprite = SKSpriteNode(texture: cloudTexture)
            
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトを表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            // スプライトにアニメーションを設定する
            sprite.runAction(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
            
        }
    }
    
    // 壁をセット
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .Linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        // 画面がまで移動するアクションを作成
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration: 4.0)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 壁を生成するアクションを生成
        let createWallAnimation = SKAction.runBlock({
            // 壁を生成するアクションを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0 // 雲より手前、地面より奥
            
            // 画面のY軸の中央線
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height / 2 - random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            // 下側スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            // 衝突の時は動かないように設定する
            under.physicsBody?.dynamic = false
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 上側の壁のスプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            // 追突時に動かないように設定する
            upper.physicsBody?.dynamic = false
            
            wall.addChild(upper)
            
            // スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.runAction(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.waitForDuration(2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }
    
    // 鳥をセット
    func setupBird() {
        // 鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.Linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.Linear
        
        // 2種類のテクスチャを交互に変更するアニメーション作成
        let texturesAnimation = SKAction.animateWithTextures([birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(texturesAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: 20, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突カテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        // アニメーションを設定
        bird.runAction(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
        
    }
    
    // アイテムをセット
    func setupItem() {
        // アイテムの画像を読み込む
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = .Linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
        
        // 待機する
        let stopItem = SKAction.waitForDuration(1.5)
        
        // 画面まで移動するアクションを作成
        let moveItem = SKAction.moveByX(-movingDistance, y: 0, duration: 3.0)
        
        // 自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([stopItem, moveItem, removeItem])
        
        // アイテムを生成するアクションを生成
        let createItemAnimation = SKAction.runBlock({
            // アイテムを生成するアクションを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0.0)
            item.zPosition = -40.0
            
            // アイテムのY座標を上下ランダムにさせるときの最大値
            let random_y_range = ceil(self.frame.size.height - self.groundHeight - (itemTexture.size().height * 2))
            
            // アイテムのY軸の下限
            let under_item_lowest_y = UInt32(self.groundHeight + itemTexture.size().height)
            
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            
            var under_wall_y = CGFloat(0)
            // アイテムの位置を決定（5割の確率で表示）
            if arc4random_uniform(UInt32(10)) < 5 {
                under_wall_y = CGFloat(under_item_lowest_y + random_y)
            }
            
            
            // アイテムを作成
            let item_a = SKSpriteNode(texture: itemTexture)
            item_a.position = CGPoint(x: 0.0, y: under_wall_y)
            item_a.name = String(self.itemCnt)
            self.itemCnt += 1
            item.addChild(item_a)
            
            // スプライトに物理演算を設定する
            item_a.physicsBody = SKPhysicsBody(rectangleOfSize: itemTexture.size())
            
            // 衝突の時は動かないように設定する
            item_a.physicsBody?.dynamic = false
            //
            item_a.physicsBody?.categoryBitMask = self.itemCategory
            item_a.physicsBody?.contactTestBitMask = self.birdCategory
            
            item.runAction(itemAnimation)
            
            self.itemNode.addChild(item)
        })
        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.waitForDuration(2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }

    
    
    // SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBeginContact(contact: SKPhysicsContact) {
        // ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新か斬新か確認する
            var bestScore = userDefaults.integerForKey("BEST")
            if score > bestScore {
                bestScore = score
                    bestScore = score
                    bestScoreLabelNode.text = "Best Score:\(bestScore)"
                    userDefaults.setInteger(bestScore, forKey: "BEST")
                    userDefaults.synchronize()
            }
        } else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory{
            // アイテムを取った
            print("GetItem")
            
            // 効果音を鳴らす
            self.runAction(self.sound)
            
            // アイテムスコアを更新
            itemScore += 1
            itemLabelNode.text = "Item Score:\(itemScore)"

            // アイテムを削除
            contact.bodyA.node?.removeFromParent()
            
            //let itemName = contact.bodyA.node?.name
            //let aItem = itemNode.childNodeWithName(itemName!)
            //aItem!.removeFromParent()
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.runAction(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    // リスタート処理
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        itemScore = 0
        itemLabelNode.text = "Item Score:\(score)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        itemNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
        // item name用カウンタをリセット
        itemCnt = 0
    }
    
    // スコア用のラベル
    func setupScoreLabel() {
        // アイテムスコアのラベル
        itemScore = 0
        itemLabelNode = SKLabelNode()
        itemLabelNode.fontColor = UIColor.blackColor()
        itemLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        itemLabelNode.zPosition = 100
        itemLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        itemLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemLabelNode)
        
        // スコアのラベル
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        // ベストスコアのラベル
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
}