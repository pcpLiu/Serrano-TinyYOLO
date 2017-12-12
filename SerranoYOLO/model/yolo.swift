//
//  yolo.swift
//  SerranoYOLO
//
//  Created by ZHONGHAO LIU on 11/25/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import Foundation
import Serrano


fileprivate let paramsFileList = [
    "conv_1_k",
    "conv_2_k",
    "conv_3_k",
    "conv_4_k",
    "conv_5_k",
    "conv_6_k",
    "conv_7_k",
    "conv_8_k",
    "conv_9_k",
    "conv_9_b",
]

func sigmoid(_ input: Float) -> Float {
    return 1.0 / (1.0 + exp(-input))
}

func configureYOLO() -> ComputationGraph {
    let g = ComputationGraph()
    
    // input
    let input = g.tensor("input",
                         shape: TensorShape(dataType: .int, shape: [416, 416, 3]))
    
    // conv block 1
    let (out_conv1, _, _) = g.operation("conv_1",
                                            inputs: [input],
                                            op: ConvOperator2D(numFilters: 16, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: input.shape))
    let (batchnorm1, _, _) = g.operation("bn_1",
                                         inputs: out_conv1,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv1.first!.shape))
    let (out_act1, _, _) = g.operation(inputs: batchnorm1,
                                       op: LeakyReLUOperator(alpha: 0.1))
    
    let (out_poo1, _, _) = g.operation(inputs: out_act1,
                                       op: MaxPool2DOperator(kernelSize: [2, 2],
                                                             channelPosition: TensorChannelOrder.Last,
                                                             paddingMode: PaddingMode.Same))
    
    // conv block 2
    let (out_conv2,_, _) = g.operation("conv_2",
                                       inputs: out_poo1,
                                       op: ConvOperator2D(numFilters: 32, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_poo1.first!.shape))
    let (batchnorm2, _, _) = g.operation("bn_2",
                                         inputs: out_conv2,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv2.first!.shape))
    let (out_act2, _, _) = g.operation(inputs: batchnorm2,
                                       op: LeakyReLUOperator(alpha: 0.1))
    let (out_poo2, _, _) = g.operation(inputs: out_act2,
                                       op: MaxPool2DOperator(kernelSize: [2, 2],
                                                             channelPosition: TensorChannelOrder.Last,
                                                             paddingMode: PaddingMode.Same))
    
    // conv block 3
    let (out_conv3,_, _) = g.operation("conv_3",
                                       inputs: out_poo2,
                                       op: ConvOperator2D(numFilters: 64, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_poo2.first!.shape))
    let (batchnorm3, _, _) = g.operation("bn_3",
                                         inputs: out_conv3,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv3.first!.shape))
    let (out_act3, _, _) = g.operation(inputs: batchnorm3,
                                       op: LeakyReLUOperator(alpha: 0.1))
    let (out_poo3, _, _) = g.operation(inputs: out_act3,
                                       op: MaxPool2DOperator(kernelSize: [2, 2],
                                                             channelPosition: TensorChannelOrder.Last,
                                                             paddingMode: PaddingMode.Same))
    
    // conv block 4
    let (out_conv4,_, _) = g.operation("conv_4",
                                       inputs: out_poo3,
                                       op: ConvOperator2D(numFilters: 128, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_poo3.first!.shape))
    let (batchnorm4, _, _) = g.operation("bn_4",
                                         inputs: out_conv4,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv4.first!.shape))
    let (out_act4, _, _) = g.operation(inputs: batchnorm4,
                                       op: LeakyReLUOperator(alpha: 0.1))
    let (out_poo4, _, _) = g.operation(inputs: out_act4,
                                       op: MaxPool2DOperator(kernelSize: [2, 2],
                                                             channelPosition: TensorChannelOrder.Last,
                                                             paddingMode: PaddingMode.Same))
    
    // conv block 5
    let (out_conv5,_, _) = g.operation("conv_5",
                                       inputs: out_poo4,
                                       op: ConvOperator2D(numFilters: 256, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_poo4.first!.shape))
    let (batchnorm5, _, _) = g.operation("bn_5",
                                         inputs: out_conv5,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv5.first!.shape))
    let (out_act5, _, _) = g.operation(inputs: batchnorm5,
                                       op: LeakyReLUOperator(alpha: 0.1))
    let (out_poo5, _, _) = g.operation(inputs: out_act5,
                                       op: MaxPool2DOperator(kernelSize: [2, 2],
                                                             channelPosition: TensorChannelOrder.Last,
                                                             paddingMode: PaddingMode.Same))
    
    // conv block 6
    let (out_conv6,_, _) = g.operation("conv_6",
                                       inputs: out_poo5,
                                       op: ConvOperator2D(numFilters: 512, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_poo5.first!.shape))
    let (batchnorm6, _, _) = g.operation("bn_6",
                                         inputs: out_conv6,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv6.first!.shape))
    let (out_act6, _, _) = g.operation(inputs: batchnorm6,
                                       op: LeakyReLUOperator(alpha: 0.1))
    let (out_poo6, _, _) = g.operation(inputs: out_act6,
                                       op: MaxPool2DOperator(kernelSize: [2, 2],
                                                             stride: [1, 1],
                                                             channelPosition: TensorChannelOrder.Last,
                                                             paddingMode: PaddingMode.Same))
    
    // conv block 7
    let (out_conv7,_, _) = g.operation("conv_7",
                                       inputs: out_poo6,
                                       op: ConvOperator2D(numFilters: 1024, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_poo6.first!.shape))
    let (batchnorm7, _, _) = g.operation("bn_7",
                                         inputs: out_conv7,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv7.first!.shape))
    let (out_act7, _, _) = g.operation(inputs: batchnorm7,
                                       op: LeakyReLUOperator(alpha: 0.1))
    
    /////////
    
    // conv block  8
    let (out_conv8,_, _) = g.operation("conv_8",
                                       inputs: out_act7,
                                       op: ConvOperator2D(numFilters: 1024, kernelSize: [3, 3],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          biasEnabled: false,
                                                          inputShape: out_act7.first!.shape))
    let (batchnorm8, _, _) = g.operation("bn_8",
                                         inputs: out_conv8,
                                         op: BatchNormOperator(channelOrder: TensorChannelOrder.Last,
                                                               inputShape: out_conv8.first!.shape))
    let (out_act8, _, _) = g.operation(inputs: batchnorm8,
                                       op: LeakyReLUOperator(alpha: 0.1))
    
    //  output
    let (out_conv9,_, _) = g.operation("conv_9",
                                       inputs: out_act8,
                                       op: ConvOperator2D(numFilters: 125, kernelSize: [1, 1],
                                                          padMode: PaddingMode.Same,
                                                          channelPosition: TensorChannelOrder.Last,
                                                          inputShape: out_act8.first!.shape))
    var outputSymbol = out_conv9.first!
    outputSymbol.symbolLabel = "output"
    
    return g
}

public class YOLOModel {
    
    public static let threshold: Float = 0.1
    
    public static let IOUThreshold: Float = 0.1
    
    public static let eps: Float = 80
    public static let minNeighbor: Int = 3
    
    public static let MAX_NUM_BOX: Int = 6
    
    public static let anchors: [Float] = [ 1.08,1.19,  3.42,4.41,  6.63,11.38,  9.42,5.11,  16.62,10.52]
    
    public static func yoloModel() -> ComputationGraph {
        let model = configureYOLO()
        
        // conv layers
        for i in 1...9 {
            let opSymbolLabel = "conv_\(i)"
            let symbol = model.opSymbols().filter {$0.symbolLabel == opSymbolLabel}.first! as! SerranoOperatorSymbol
            
            let parmFile = "conv_\(i)_k"
            loadParameterConv(paramFileName: parmFile, symbol: symbol, isBias: false)
            
            if i == 9 {
                loadParameterConv(paramFileName: "conv_9_b", symbol: symbol, isBias: true)
            }
        }
        
        // batch norm layers
        for i in 1...8 {
            let opSymbolLabel = "bn_\(i)"
            let symbol = model.opSymbols().filter {$0.symbolLabel == opSymbolLabel}.first!
           
            let parmFile = "batchnorm_\(i)"
            loadParameterBN(paramFileName: parmFile, symbol: symbol as! SerranoOperatorSymbol)
            
        }
        
        return model
    }
    
    public static func loadParameterBN(paramFileName: String,symbol: SerranoOperatorSymbol) {
        let op = symbol.serranoOperator as! BatchNormOperator
        op.epsilon = 0.001
        
        let file = Bundle.main.path(forResource: paramFileName, ofType: ".fbs")
        for (label, tensor) in FlatbufferIO.loadSavedParams(file!) {
            if label == "mean" {
                var meanSymbol =  symbol.paramSymbols.filter {$0.symbolLabel == "movingMean"}.first! as! TensorSymbol
                tensor.shape = meanSymbol.shape
                meanSymbol.bindedData = tensor
            } else if label == "variance" {
                var varSymbol =  symbol.paramSymbols.filter {$0.symbolLabel == "movingVar"}.first! as! TensorSymbol
                tensor.shape = varSymbol.shape
                varSymbol.bindedData = tensor
            } else if label == "gamma" {
                var gammaSymbol =  symbol.paramSymbols.filter {$0.symbolLabel == "scale"}.first! as! TensorSymbol
                tensor.shape = gammaSymbol.shape
                gammaSymbol.bindedData = tensor
            } else if label == "beta" {
                var betaSymbol =  symbol.paramSymbols.filter {$0.symbolLabel == "offset"}.first! as! TensorSymbol
                tensor.shape = betaSymbol.shape
                betaSymbol.bindedData = tensor
            }
        }
    }
    
    public static func loadParameterConv(paramFileName: String, symbol: SerranoOperatorSymbol, isBias: Bool) {
        let file = Bundle.main.path(forResource: paramFileName, ofType: ".fbs")
        let (_, tensor) = FlatbufferIO.loadSavedParams(file!).first!
        if isBias {
            var biasSymbol = symbol.paramSymbols.filter {$0.symbolLabel == "bias"}.first! as! TensorSymbol
            tensor.shape = biasSymbol.shape
            biasSymbol.bindedData = tensor
        } else {
            var weightSymbol = symbol.paramSymbols.filter {$0.symbolLabel == "weight"}.first! as! TensorSymbol
            tensor.shape = weightSymbol.shape
            weightSymbol.bindedData = tensor
        }
    }
    
    public static func analyzeResult(_ outTensor: Tensor) -> [BoundingBox] { 
        let softmax = SoftmaxOperator()
        let resultTensor = Tensor(repeatingValue: 0.0, tensorShape: TensorShape(dataType: .float, shape: [20]))
        softmax.outputTensors = [resultTensor]
        softmax.dim = -1
        
        var boxes = [BoundingBox]()
        
        for i in 0..<13 {
            for j in 0..<13 {
                let grid_info_tensor = outTensor.slice(sliceIndex: [i, j])
                let value_vector = grid_info_tensor.flatArrayFloat()
                for boxIndex in 0..<5 {
                    let start = boxIndex * 25
                    let end = start + 25
                    let boxInfo = Array(value_vector[start..<end])
                    
                    // softmax class prediction
                    let class_predicted_values =  Array(boxInfo[5..<boxInfo.count])
                    let inputTensor = Tensor(fromFlatArray: class_predicted_values, tensorShape: TensorShape(dataType: .float, shape: [20]))
                    softmax.inputTensors = [inputTensor]
                    softmax.compute(.CPU)
                    
                    let softmax_values = resultTensor.flatArrayFloat()
                    let (max_class_index, max_class) = argmax(softmax_values)
                    
                    let box_score = sigmoid(boxInfo[4])
                    let confidence = max_class * box_score
                    let w: Float = exp(boxInfo[2]) * anchors[2*boxIndex] * 32.0
                    let h: Float = exp(boxInfo[3]) * anchors[2*boxIndex + 1] * 32.0
                    let x: Float = (sigmoid(boxInfo[0]) + Float(i) * 32.0)
                    let y: Float = (sigmoid(boxInfo[1]) + Float(j) * 32.0)
                    let label = VOC_CLASSES[max_class_index]
                    boxes.append(BoundingBox(x: x, y: y, w: w, h: h, label: label, score: confidence))
                }
            }
        }
        return nms(boxes)
    }
    
    public static func argmax(_ input: [Float]) -> (Int, Float) {
        var maxval: Float = -Float.infinity
        var mamxindex = 0
        for (index, val) in input.enumerated() {
            if maxval < val {
                maxval = val
                mamxindex = index
            }
        }
        return (mamxindex, maxval)
    }
    
    
    public static func IOU(a: BoundingBox, b: BoundingBox) -> Float {
        
        let areaA = a.w * a.h
        if areaA <= 0 { return 0 }
        
        let areaB = b.w * b.h
        if areaB <= 0 { return 0 }
        
        let intersectionMinX = max(a.x, b.x)
        let intersectionMinY = max(a.y, b.y)
        let intersectionMaxX = min(a.x + a.w, b.x + b.w)
        let intersectionMaxY = min(a.y + a.h, b.y + b.h)
        let intersectionArea = max(intersectionMaxY - intersectionMinY, 0) *
            max(intersectionMaxX - intersectionMinX, 0)
        return Float(intersectionArea / (areaA + areaB - intersectionArea))
    }
    
    /// distance of two bounding boxes.
    public static func distance(_ a: BoundingBox, _ b: BoundingBox) -> Float {
        if a.label != b.label {
            return Float.infinity
        }
        
        return sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y))
    }
    
    /// neigh bour of an box
    public static func neighbors(_ box: BoundingBox, _ eps: Float,  boxes: [BoundingBox]) -> [BoundingBox] {
        var n = [BoundingBox]()
        for aBox in boxes {
            if aBox != box && distance(box, aBox) <= eps {
                n.append(box)
            }
        }
        return n
    }
    
    /// Do non-maximum surpression.
    /// Roughfly use modified DBSCAN
    public static func nms(_ boxes: [BoundingBox]) -> [BoundingBox]{
        // not include core boxes
        var clusteredBoxes = [BoundingBox: Int]()
        var coreBoxes = [Int: BoundingBox]()
       
        // get core boxes
        for box in boxes {
            let neighbor = neighbors(box, eps, boxes: boxes)
            if neighbor.count >= minNeighbor {
                coreBoxes[coreBoxes.count] = box
            } else {
                clusteredBoxes[box] = -1
            }
        }
        
        // expand cluster from core boxes
        for (cluster_label, box) in coreBoxes {
            for neighborBox in neighbors(box, eps, boxes: boxes) {
                if (clusteredBoxes.keys.contains {$0 == neighborBox}) {
                    clusteredBoxes[neighborBox] = cluster_label
                }
            }
        }
        
        // exapand cluster from non-core clustered boxes
        for (box, cluster_label) in clusteredBoxes {
            if cluster_label == -1 {
                continue
            }
            
            for neighborBox in neighbors(box, eps, boxes: boxes) {
                if clusteredBoxes[neighborBox] != -1 {
                    clusteredBoxes[box] = clusteredBoxes[neighborBox]
                }
            }
        }
        
        var resultBox = [BoundingBox] ()
        for (clusterLabel, coreBox) in coreBoxes {
            var x = coreBox.x
            var y = coreBox.y
            var h = coreBox.h
            var w = coreBox.w
            var score = coreBox.score
            let label = coreBox.label
            for (neighborBox, _) in (clusteredBoxes.filter {$0.value == clusterLabel}) {
                x = (x + neighborBox.x) / 2
                y = (y + neighborBox.y) / 2.0
                h = (h + neighborBox.h) / 2.0
                w = (w + neighborBox.w) / 2.0
                score = max(score, neighborBox.score)
            }
            resultBox.append(BoundingBox(x: x, y: y, w: w, h: h, label: label, score: score))
        }
        
        // get max N to show
        resultBox.sort(by: { $0.0.score > $0.1.score})
        if resultBox.count > 3 {
            resultBox = Array(resultBox[0..<3])
        }
        return resultBox
    }
}
