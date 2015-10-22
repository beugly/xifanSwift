//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by 173 on 15/10/21.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: binary heap collection type
public protocol BinaryHeapCollectionType
{
    //element Type
    typealias Element;
    
    //element count
    var count:Int{get}
    
    //element count == 0
    var isEmpty:Bool{get}
    
    //append element and resort
    mutating func append(newElement: Element)
    
    //return(and remove) first element and resort
    mutating func popFirst() -> Element?
    
    //update element and resort
    mutating func updateElement(element: Element, atIndex: Int)
}

//MARK: binary heap operator
protocol BinaryHeapOperator{}
extension BinaryHeapOperator
{
    //shift up collection element at index i use isOrderedBefore function
    //return nil when collection no change
    @warn_unused_result
    static func shiftUp<_CT:MutableCollectionType where _CT.Index == Int>
        (collection: _CT, atIndex i: Int, isOrderedBefore iob: (_CT.Generator.Element, _CT.Generator.Element)->Bool) -> _CT?
    {
        guard i > 0 else{return nil;}
        var _temp = collection;
        var _index = i;
        let _ele = _temp[_index];
        repeat{
            let _parentIndex = Self.getParentIndex(ofChildIndex: _index);
            let _parent = _temp[_parentIndex];
            guard iob(_ele, _parent) else {break;}
            _temp[_index] = _parent;
            _temp[_parentIndex] = _ele;
            _index = _parentIndex;
        }while _index > 0
        
        return _temp;
    }
    
    //shift down collection element at index i use isOrderedBefore function
    //return nil when collection no change
    @warn_unused_result
    static func shiftDown<_CT:MutableCollectionType where _CT.Index == Int>
        (collection: _CT, atIndex i: Int, isOrderedBefore iob: (_CT.Generator.Element, _CT.Generator.Element)->Bool) -> _CT?
    {
        let _c = collection.count;
        guard i < _c else{return nil;}
        var _temp = collection;
        let _ele = _temp[i];
        var _index = i;
        repeat{
            var _tempIndex = _index;
            var _childIndex = Self.getChildIndex(ofParentIndex: _tempIndex);
            guard _childIndex < _c else{break;}
            if iob(_temp[_childIndex], _ele){_tempIndex = _childIndex;}
            
            _childIndex++;
            
            if _childIndex < _c && iob(_temp[_childIndex], _temp[_tempIndex]){_tempIndex = _childIndex;}
            
            guard _tempIndex != _index else{break;}
            _temp[_index] = _temp[_tempIndex];
            _temp[_tempIndex] = _ele;
            _index = _tempIndex;
        }while _index < _c
        
        return _temp;
    }
    
    //update collection element at index use isOrderedBefore functoin
    //return nil when collection no change
    @warn_unused_result
    static func updateElement<_CT:MutableCollectionType where _CT.Index == Int>
        (collection: _CT, element: _CT.Generator.Element, atIndex i: Int, isOrderedBefore iob: (_CT.Generator.Element, _CT.Generator.Element)->Bool) -> _CT?
    {
        let _c = collection.count;
        guard i >= 0 && i < _c else{return nil;}
        var _temp = collection;
        _temp[i] = element;
        let _parentIndex = Self.getParentIndex(ofChildIndex: i);
        guard iob(element, _temp[_parentIndex]) else {
            return Self.shiftDown(_temp, atIndex: i, isOrderedBefore: iob);
        }
        return Self.shiftUp(_temp, atIndex: i, isOrderedBefore: iob);
    }
    
    //build collection to priority collection use isOrderedBefore function
    //return nil when collection no change
    @warn_unused_result
    static func build<_CT:MutableCollectionType where _CT.Index == Int>
        (collection: _CT, isOrderedBefore iob: (_CT.Generator.Element, _CT.Generator.Element)->Bool) -> _CT?
    {
        var _index:Int = collection.count >> 1 - 1;
        guard _index > -1 else{return nil;}
        var _temp = collection;
        repeat{
            guard let newTemp = Self.shiftDown(_temp, atIndex: _index--, isOrderedBefore: iob) else {continue;}
            _temp = newTemp;
        }while _index > -1
        return _temp;
    }
    
    //parent node index
    static func getParentIndex(ofChildIndex index:Int) -> Int{return (index - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    static func getChildIndex(ofParentIndex index:Int) -> Int{return ((index << 1) + 1);}
}

//MARK: priority queue use array collection
public struct PriorityArray<T>
{
    //source
    private var _source:[T];
    
    //is ordered before
    private var _isOrderedBefore:(T, T) -> Bool;
    
    //element count
    public var count:Int{return self._source.count;}
    
    //element count == 0
    public var isEmpty:Bool{return self._source.isEmpty;}
}
//MARK: extension public
public extension PriorityArray where T: Comparable
{
    init(max source:[T])
    {
        self.init(source: source){$0 < $1}
    }
    
    init(min source:[T])
    {
        self.init(source: source){$0 > $1}
    }
}
public extension PriorityArray
{
    init(isOrderedBefore:(T, T) -> Bool)
    {
        self.init(source: [], isOrderedBefore:isOrderedBefore);
    }
}
//MARK: extension BinaryHeapOperator
extension PriorityArray: BinaryHeapOperator
{
    //init with resource, compare
    public init(source:[T], isOrderedBefore:(T, T) -> Bool)
    {
        self._isOrderedBefore = isOrderedBefore;
        guard let temp = PriorityArray.build(source, isOrderedBefore: self._isOrderedBefore) else {
            self._source = source;
            return;
        }
        self._source = temp;
    }
}
//MARK: extension CollectionType
extension PriorityArray: CollectionType
{
    public var startIndex: Int {return 0}
    public var endIndex: Int {return self._source.count;}
    public subscript(i: Int) -> Element{return self._source[i]}
}
//MARK: extension binary heap collection type
extension PriorityArray: BinaryHeapCollectionType
{
    //element Type
    public typealias Element = T;
    
    //append element and resort
    public mutating func append(newElement: Element)
    {
        self._source.append(newElement);
        guard let temp = PriorityArray.shiftUp(self._source, atIndex: self.count - 1, isOrderedBefore: self._isOrderedBefore) else {return;}
        self._source = temp;
    }
    
    //return(and remove) first element and resort
    public mutating func popFirst() -> Element?
    {
        if(isEmpty){return nil;}
        let first = self._source[0];
        let end = self._source.removeLast();
        guard !self.isEmpty else{return first;}
        self._source[0] = end;
        guard let temp = PriorityArray.shiftDown(self._source, atIndex: 0, isOrderedBefore: self._isOrderedBefore) else {return first;}
        self._source = temp;
        return first;
    }
    
    //update element and resort
    public mutating func updateElement(element: Element, atIndex: Int)
    {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        guard let temp = PriorityArray.updateElement(self._source, element: element, atIndex: atIndex, isOrderedBefore: self._isOrderedBefore) else {return;}
        self._source = temp;
    }
}