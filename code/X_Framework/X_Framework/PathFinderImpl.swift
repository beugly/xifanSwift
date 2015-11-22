//
//  PathFinderImpl.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/7.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PFinderElement ==
public class PFinderElement2<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //g, h;
    public private (set) var g, h, f: CGFloat;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PFinderChainable?
    
    public init(g: CGFloat, h: CGFloat, position: T){
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.position = position;
    }
    
    public convenience required init(g: CGFloat, h: CGFloat, position: T, parent: PFinderChainable?) {
        self.init(g: g, h: h, position: position);
        self.parent = parent;
    }
}
extension PFinderElement2: PFinderElementType
{
    public func setParent(parent: PFinderChainable, g: CGFloat) {
        self.g = g;
        self.f = self.g + self.h;
        self.parent = parent;
    }
}

//MARK: == PFinderElement ==
public struct PFinderElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;

    //g, h;
    public private (set) var g, h, f: CGFloat;

    //position
    public private (set) var position: T;

    //parent
    public private(set) var parent: PFinderChainable?
}
extension PFinderElement: PFinderElementType
{
    public init(g: CGFloat, h: CGFloat, position: T, parent: PFinderChainable?) {
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.position = position;
        self.parent = parent;
    }

    public mutating func setParent(parent: PFinderChainable, g: CGFloat) {
        self.g = g;
        self.f = self.g + self.h;
        self.parent = parent;
    }
}

//MARK: == PFPriorityQueue ==
public struct PFPriorityQueue<T: Hashable>{
    
    public typealias Element = PFinderElement<T>
    
    //open list
    private(set) var openList: PriorityQueue<Element>;
    
    //visite list
    private(set) var visiteList: [T: Element];
    
    init(){
        self.openList = PriorityQueue{$0.f < $1.f}
        self.visiteList = [:];
    }
}
extension PFPriorityQueue: PathFinderQueueType{
    //insert element and set element visited
    mutating public func insert(element: Element){
        self.openList.insert(element);
        self.visiteList[element.position] = element;
    }
    
    //pop best element and set element closed
    mutating public func popBest() -> Element?{
        guard let ele = self.openList.popBest() else {return nil;}
        var element = ele;
        element.isClosed = true;
        self.visiteList[element.position] = element;
        return element;
    }
    
    //return visited element at position
    public subscript(position: T) -> Element? {
        return self.visiteList[position];
    }
    
    //return all visited element
    public func allVisitedList() -> [T: T] {
        var list = [T: T]();
        for (key, value) in self.visiteList{
            guard let parent = value.parent as? Element else{continue;}
            list[key] = parent.position;
        }
        return list;
    }
}


//MARK: == GreedyBestPathFinder ==
public struct GreedyBestPathFinder<Request: PathFinderRequestType>{}
extension GreedyBestPathFinder: PathFinderType{
    //queue type
    public typealias Queue = PFPriorityQueue<Request.Position>;
    
    //create queue
    public func queueGenerate() -> Queue {
        return Queue.init();
    }
    
    //search position
    public func searchPosition(position: Request.Position, _ parent: Queue.Element?, _ request: Request, inout _ queue: Queue) {
//        print("WARN: =======================check walkable");
        guard let _ = queue[position] else {
            let h = request.heuristicOf(position);
            let element = Element(g: 0, h: h, position: position, parent: parent as? PFinderChainable);
            queue.insert(element);
            return;
        }
    }
}

//MARK: == AstarPathFinder ==
public struct AstarPathFinder<Request: PathFinderRequestType>{}
extension AstarPathFinder: PathFinderType{
    //queue type
    public typealias Queue = PFPriorityQueue<Request.Position>;
    
    //create queue
    public func queueGenerate() -> Queue {
        return Queue.init();
    }
    
    //search position
    public func searchPosition(position: Request.Position, _ parent: Queue.Element?, _ request: Request, inout _ queue: Queue) {
//        print("WARN: =======================check walkable");

        let h = request.heuristicOf(position);
        guard let p = parent else{
            let ele = Element(g: 0, h: h, position: position, parent: nil);
            queue.insert(ele);
            return;
        }

        let g = p.g + request.costOf(p.position, position)
        guard let visited = queue[position] else {
            let ele = Element(g: g, h: h, position: position, parent: p);
            queue.insert(ele);
            return;
        }
        guard !visited.isClosed && g < visited.g else {return;}
        var element = visited;
        element.setParent(p, g: g);
        guard let i = (queue.openList.indexOf{return $0.position == element.position;})else{return;}
        queue.openList.replaceElement(element, atIndex: i);
        queue.visiteList[element.position] = element;
    }
}

//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<Request: PathFinderRequestType>{}
extension DijkstraPathFinder: PathFinderType{
    //queue type
    public typealias Queue = PFPriorityQueue<Request.Position>;
    
    //create queue
    public func queueGenerate() -> Queue {
        return Queue.init();
    }
    
    //search position
    public func searchPosition(position: Request.Position, _ parent: Queue.Element?, _ request: Request, inout _ queue: Queue) {
//        print("WARN: =======================check walkable");
        guard let p = parent else{
            let ele = Element(g: 0, h: 0, position: position, parent: nil);
            queue.insert(ele);
            return;
        }

        let g = p.g + request.costOf(p.position, position)
        guard let visited = queue[position] else {
            let ele = Element(g: g, h: 0, position: position, parent: p);
            queue.insert(ele);
            return;
        }
        guard !visited.isClosed && g < visited.g else {return;}
        var element = visited;
        element.setParent(p, g: g);
        guard let i = (queue.openList.indexOf{return $0.position == element.position;})else{return;}
        queue.openList.replaceElement(element, atIndex: i);
        queue.visiteList[element.position] = element;

    }
}

//MARK: == PFinderQueue ==
public struct PFinderQueue<T: Hashable>{
    
    public typealias Element = PFinderElement<T>
    
    //open list
    private(set) var openList: [Element];
    
    //visite list
    private(set) var visiteList: [T: Element];
    
    //current index
    private var currentIndex: Int = 0;
    
    init(){
        self.openList = [];
        self.visiteList = [:];
        self.currentIndex = 0;
    }
}
extension PFinderQueue: PathFinderQueueType{
    //insert element and set element visited
    mutating public func insert(element: Element){
        self.openList.append(element);
        self.visiteList[element.position] = element;
    }
    
    //pop best element and set element closed
    mutating public func popBest() -> Element?{
        guard currentIndex < self.openList.count else{return nil;}
        let element = self.openList[self.currentIndex++];
        return element;
    }
    
    //return visited element at position
    public subscript(position: T) -> Element? {
        return self.visiteList[position];
    }
    
    //return all visited element
    public func allVisitedList() -> [T: T] {
        var list: [T: T] = [:];
        for (key, value) in self.visiteList{
            guard let parent = value.parent as? Element else{continue;}
            list[key] = parent.position;
        }
        return list;
    }
}

//MARK: == BreadthBestPathFinder ==
public struct BreadthBestPathFinder<Request: PathFinderRequestType>{}
extension BreadthBestPathFinder: PathFinderType{
    //queue type
    public typealias Queue = PFinderQueue<Request.Position>;
    
    //create queue
    public func queueGenerate() -> Queue {
        return Queue.init();
    }
    
    //search position
    public func searchPosition(position: Request.Position, _ parent: Queue.Element?, _ request: Request, inout _ queue: Queue) {
//        print("WARN: =======================check walkable");
        guard let _ = queue[position] else {
            let element = Element(g: 0, h: 0, position: position, parent: parent as? PFinderChainable);
            queue.insert(element);
            return;
        }
    }
}