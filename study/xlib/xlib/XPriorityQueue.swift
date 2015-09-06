//
//  PriorityQueue.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//priority quque protocol
protocol XPriorityQueueProtocol{
    //element typealias
    typealias XPQElement;
    
    //push element at end
    mutating func push(element:XPQElement) -> XPQElement;
    
    //get first element and remove it
    mutating func pop() -> XPQElement?;
    
    //update element at index
    mutating func update(element:XPQElement, atIndex:Int) -> XPQElement;
    
    //return element at index
    func getElement(atIndex:Int) -> XPQElement;
    
    //empty?
    var isEmpty:Bool{get};
    
    //elemet count
    var count:Int{get}
}

/**
priority quque
*/
struct XPriorityQueue <T>{
    
    //存储队列
    private var queue:[T];
    
    //排序函数 T1:当前element T2:待检测element
    private var compare:(T, T)->Bool;
    
    //compare 排序函数 T1:当前element T2:待检测element;return true 互换位置 false 不予处理
    init(compare:(T, T) -> Bool)
    {
        self.compare = compare;
        self.queue = [];
    }
}

//extension printable
extension XPriorityQueue: Printable
{
    var description:String{
        return self.queue.description;
    }
}

//extension XPriorityQueueProtocol
extension XPriorityQueue: XPriorityQueueProtocol
{
    typealias XPQElement = T;
    
    mutating func push(element: XPQElement) -> XPQElement {
        self.queue.append(element);
        bubbleUP(self.count - 1);
        return element;
    }
    
    mutating func pop() -> XPQElement? {
        if(isEmpty){return nil;}
        let first = self.queue.first;
        let end = self.queue.removeLast();
        if(!isEmpty)
        {
            self.queue[0] = end;
            sinkDown(0);
        }
        return first;
    }
    
    func getElement(atIndex: Int) -> XPQElement {return self.queue[atIndex];}
    
    mutating func update(element: XPQElement, atIndex: Int) -> XPQElement {
        self.queue[atIndex] = element;
        let e = getElement(atIndex);
        let p_i = getParentIndex(atIndex);
        if(!compare(e, getElement(p_i)))
        {
            bubbleUP(atIndex);
        }
        else
        {
            sinkDown(atIndex);
        }
        return element;
    }
    
    var isEmpty:Bool { return self.queue.isEmpty; }
    var count:Int{ return self.queue.count; }
    
    
    //parent node index
    private func getParentIndex(atIndex:Int) -> Int{return (atIndex - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    private func getChildIndex(atIndex:Int) -> Int{return ((atIndex << 1) + 1);}
    
    //bubble up at index
    private mutating func bubbleUP(atIndex:Int)
    {
        var i = atIndex;
        let e = self.getElement(i);
        while(i > 0)
        {
            let p_i = self.getParentIndex(i);
            let p_e = self.getElement(p_i);
            if(compare(e, p_e)){ break; }
            queue[i] = p_e;
            queue[p_i] = e;
            i = p_i;
        }
    }

    //sink down at index
    private mutating func sinkDown(atIndex:Int)
    {
        let c = self.count;
        var i = atIndex;
        let e = getElement(i);
        
        while(true)
        {
            var index = i;
            
            let left = self.getChildIndex(index);
            if(left >= c){break;}
            if(compare(e, getElement(left))){ index = left; }
            
            
            let right = left + 1;
            if(right < c && compare(getElement(index), getElement(right))){ index = right; }
            
            if(index == i){break;}
            self.queue[i] = getElement(index);
            self.queue[index] = e;
            i = index;
        }
    }
    
}