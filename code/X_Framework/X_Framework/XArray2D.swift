//
//  XArrayND.swift
//  xlib
//
//  Created by 173 on 15/9/16.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//orient
enum XArrayNDOrient
{
    case Horizontal(Int, Int)
    case Vertical(Int, Int)
    
    init(columns:Int)
    {
        self = .Horizontal(1, columns);
    }
    
    init(rows:Int)
    {
        self = .Vertical(rows, 1);
    }
    
    private func _convert2Index(column:Int, _ row:Int) -> Int
    {
        switch self{
        case .Horizontal(let c, let r):
            return column * c + row * r;
        case .Vertical(let c, let r):
            return column * c + row * r;
        }
    }
}

//XArray2DType protocol
protocol XArray2DType
{
    //element
    typealias _Element;
    
    //source
    var source:[Self._Element?]{get}
    
    //columns
    var columns:Int{get}
    
    //rows
    var rows:Int{get}
    
    //orient
    var orient:XArrayNDOrient{get}
    
    //subscript
    subscript(i:Int) -> Self._Element?{set get}
}

extension XArray2DType
{
    //count
    var count:Int{return self.source.count;}
    
    //subscript
    subscript(column:Int, row:Int) -> Self._Element?{
        set{
            guard let index = self.getPosition(column, row) else{return;}
            self[index] = newValue;
        }
        get{
            guard let index = self.getPosition(column, row) else{return nil;}
            return self[index];
        }
    }
    
    //out of bounds?
    func outOfBounds(column:Int, _ row:Int) -> Bool{
        return column < 0 || column >= columns || row < 0 || row >= rows;
    }
    
    //get position at source
    func getPosition(column:Int, _ row:Int) -> Int?{
        guard !outOfBounds(column, row) else{return nil;}
        return self.orient._convert2Index(column, row);
    }
}

extension XArray2DType where _Element: Equatable
{
    func indexOf(element:Self._Element) -> Int?
    {
        let index = self.source.indexOf{return $0 == element;}
        return index?.littleEndian;
    }
}

//MARK: XArray2D
struct XArray2D<T>
{
    private(set) var source:[T?];
    private(set) var columns:Int;
    private(set) var rows:Int;
    private(set) var orient:XArrayNDOrient;
    
    private init(columns:Int, rows:Int, orient:XArrayNDOrient)
    {
        self.columns = columns;
        self.rows = rows;
        self.source = Array<T?>(count: columns * rows, repeatedValue: nil);
        self.orient = orient;
    }
    
    init(columnFirst columns:Int, rows:Int)
    {
        self.init(columns: columns, rows: rows, orient: XArrayNDOrient(columns: columns))
    }
    
    init(rowFirst columns:Int, rows:Int)
    {
        self.init(columns: columns, rows: rows, orient: XArrayNDOrient(rows: rows))
    }
}

//MARK: extension XArray2DType
extension XArray2D: XArray2DType
{
    typealias _Element = T;
    
    subscript(i:Int) -> T?{
        set{
            guard i >= 0 && i < self.count else{return;}
            self.source[i] = newValue;
        }
        get{
            return self.source[i];
        }
    }
}

//MARK: extension CustomStringConvertible
extension XArray2D: CustomStringConvertible
{
    var description:String{
        var text:String = "";
        for r in 0..<self.rows
        {
            for c in 0..<self.columns
            {
                if let v = self[c, r]
                {
                    text += "\(v) ";
                    continue;
                }
                text += "\(self[c, r]) ";
            }
            text += "\n";
        }
        return text;
    }
}
