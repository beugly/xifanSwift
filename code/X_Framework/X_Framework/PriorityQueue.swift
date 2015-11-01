//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by yeah on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == HeapConvertible ==
public protocol HeapConvertible
{
    //element type
    typealias Element;
    
    //index type
    typealias Index: ForwardIndexType = Int
    
    //MARK: properties
    //============================= properties ===================================
    
    //start index
    var startIndex: Self.Index{get}
    
    //end index
    var endIndex: Self.Index{get}
    
    //branch size, default = 2 <==> binary heap, 4 , 8 etc...
    var branchSize: Self.Index.Distance{get}
    
    //sort according to isOrderedBefore
    var isOrderedBefore: (Self.Element, Self.Element) -> Bool {get}
    
    //subscript
    subscript(position: Self.Index) -> Self.Element{get set}
    
    //MARK: functions
    //============================= functions ===================================
    //shift up element at index
    mutating func shiftUp(index: Self.Index)
    
    //shift down element at index
    mutating func shiftDown(index: Self.Index)
    
    //replace element at index, shift element to heap position
    mutating func replaceElement(element: Self.Element, atIndex: Self.Index)
    
    //priority sequence use isOrderedBefore function
    mutating func build()
    
    //trunk index
    func trunkIndexOf(branchIndex: Self.Index) -> Self.Index
    
    //branch index
    func branchIndexOf(trunkIndex: Self.Index) -> Self.Index
}
//MARK: extension public
extension HeapConvertible
{
    //shift up element at index
    public mutating func shiftUp(index: Self.Index)
    {
        //shift element
        let shiftElement = self[index];

        //shift index
        var shiftIndex = index;
        
        //shift up
        repeat{
            //trunk index
            let trunkIndex = self.trunkIndexOf(shiftIndex);
            
            //if trunkIndex is startIndex reuturn, otherwise shift next trunk
            guard self.startIndex.distanceTo(trunkIndex) > -1 else{break;}
            let trunkElement = self[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Self.Index)
    {
        //if index < endIndex continue otherwise return;
        guard index.distanceTo(self.endIndex) > 0 else {return;}
        
        //endindex
        let endi = self.endIndex;
        
        //shift element
        let shiftElement = self[index];
        
        //trunk index
        var trunkIndex = index;
        
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //first branch index
            var branchIndex = self.branchIndexOf(shiftIndex);
            guard branchIndex.distanceTo(endi) > 0 else{break;}
            
            //branch count
            var branchCount = self.branchSize;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self[branchIndex], self[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchIndex = branchIndex.advancedBy(1);
                branchCount -= 1;
            }while branchIndex.distanceTo(endi) > 0 && branchCount > 0
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //replace element at index
    public mutating func replaceElement(element: Self.Element, atIndex: Self.Index)
    {
        //out of bounds return otherwise continue
        guard self.startIndex.distanceTo(atIndex) >= 0 && atIndex.distanceTo(self.endIndex) > 0 else {return;}
        
        self[atIndex] = element;
        
        //if element is better shiftup otherwise shiftdown
        let trunkIndex = self.trunkIndexOf(atIndex);
        guard self.isOrderedBefore(element, self[trunkIndex]) else{
            self.shiftUp(atIndex);
            return;
        }
        self.shiftDown(atIndex);
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.startIndex.distanceTo(self.endIndex) > 0 else {return;}
        var _index = self.trunkIndexOf(self.endIndex.advancedBy(-1))
        repeat{
            self.shiftDown(_index);
            _index = _index.advancedBy(-1);
        }while self.startIndex.distanceTo(_index) > -1
    }
    
    //trunk index, implement yourself for better efficiency
    public func trunkIndexOf(branchIndex: Self.Index) -> Self.Index
    {
        print("trunkIndexOf @warn :: trunk index, implement yourself for better efficiency")
        let distance = self.startIndex.distanceTo(branchIndex);
        let trunkDistance = (distance - 1) / self.branchSize;
        return self.startIndex.advancedBy(trunkDistance);
    }
    
    //branch index implement yourself for better efficiency
    public func branchIndexOf(trunkIndex: Self.Index) -> Self.Index
    {
        print("branchIndexOf @warn :: branch index implement yourself for better efficiency")
        let distance = self.startIndex.distanceTo(trunkIndex);
        let branchDistance = distance * self.branchSize + 1;
        return self.startIndex.advancedBy(branchDistance);
    }
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == PriorityQueueType ==
public protocol PriorityQueueType
{
    //indexable _Element type
    typealias Element;
    
    //index
    typealias Index: ForwardIndexType = Int;
    
    //MARK: properties
    //============================= properties ===================================
    //count
    var count: Self.Index.Distance{get}
    
    //'self' is empty
    var isEmpty: Bool{get}
    
    //subscript
    subscript(position: Self.Index) -> Self.Element{get}
    
    //MARK: functions
    //============================= functions ===================================
    //append element and resort
    mutating func insert(element: Self.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Element?
    
    //replace element at index, shift element to heap position
    mutating func replaceElement(element: Self.Element, atIndex: Self.Index)
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//======================================== implement =================================================

//MARK: == ArrayBinaryHeap ==
public struct ArrayBinaryHeap<T>
{
    //branch size, default = 2 <==> binary heap, 4 , 8 etc...
    public let branchSize: Int = 2;
    
    //sort according to isOrderedBefore
    private (set) public var isOrderedBefore: (T, T) -> Bool;
    
    //source
    public var source: [T];
    
    init(source: [T], isOrderedBefore: (T, T) -> Bool)
    {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source;
        self.build();
    }
}

//extension HeapConvertible
extension ArrayBinaryHeap: HeapConvertible
{
    public var startIndex: Int{return self.source.startIndex}
    
    //end index
    public var endIndex: Int{return self.source.endIndex;}
    
    //subscript (get)
    public subscript(position: Int) -> T{
        set{
            self.source[position] = newValue;
        }
        get{
            return self.source[position];
        }
    }
    
    //trunk index
    public func trunkIndexOf(branchIndex: Int) -> Int
    {
        return (branchIndex - 1) >> 1;
    }
    
    //branch index
    public func branchIndexOf(trunkIndex: Int) -> Int
    {
        return trunkIndex << 1 + 1;
    }
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == BinaryPriorityQueue ==
public struct BinaryPriorityQueue<T>
{
    //Source type
    public typealias HeapType = ArrayBinaryHeap<T>;
    
    //MARK: properties
    //============================= properties ===================================
    //heap
    private (set) var heap: HeapType;
    
    
    //init
    public init(source: [T], isOrderedBefore: (T, T) -> Bool)
    {
        self.heap = HeapType(source: source, isOrderedBefore: isOrderedBefore);
    }
}
extension BinaryPriorityQueue where T: Comparable
{
    //minimum heap
    public init(minimum source: [T])
    {
        self.init(source: source){return $0 > $1;}
    }
    
    //maximum heap
    public init(maximum source: [T])
    {
        self.init(source: source){return $0 < $1;}
    }
}

//MARK: extension PriorityQueueType
extension BinaryPriorityQueue: PriorityQueueType
{
    
    
    //MARK: properties
    //============================= properties ===================================
    //count
    public var count: Int{return self.heap.source.count;}
    
    //'self' is empty
    public var isEmpty: Bool{return self.heap.source.isEmpty}
    
    //start index
    public var startIndex: Int{return self.heap.source.startIndex}
    
    //end index
    public var endIndex: Int{return self.heap.source.endIndex;}
    
    //subscript (get)
    public subscript(position: Int) -> T{
        return self.heap[position];
    }
    
    //MARK: functions
    //============================= functions ===================================
    
    public func generate() -> IndexingGenerator<[T]> {
        return self.heap.source.generate();
    }
    
    //append element and resort
    mutating public func insert(element: T)
    {
        self.heap.source.append(element);
        self.heap.shiftUp(self.count - 1);
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T?
    {
        if(self.isEmpty){return nil;}
        let first = self.heap[0];
        let end = self.heap.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.heap[0] = end;
        self.heap.shiftDown(0);
        return first;
    }
    
    //replace
    mutating public func replaceElement(element: T, atIndex: Int)
    {
        self.heap.replaceElement(element, atIndex: atIndex);
    }
}



//======================================== OLD =================================================



//MARK: PrioritySequence
public protocol PrioritySequence: SequenceType
{
    //Data source type
    typealias DataSource: MutableCollectionType;
    
    //generator
    typealias Generator = Self.DataSource.Generator;
    
    //source
    var source: Self.DataSource{get}
    
    //append element and resort
    mutating func insert(element: Self.Generator.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Generator.Element?
    
    //update element and resort
    mutating func updateElement(element: Self.Generator.Element, atIndex: Self.DataSource.Index)
}
public extension PrioritySequence
{
    //count
    var count: Self.DataSource.Index.Distance{return self.source.count;}
    
    //is empty
    var isEmpty: Bool{return self.source.isEmpty;}
}
public extension PrioritySequence where Self.Generator == Self.DataSource.Generator
{
    func generate() -> Self.Generator {
        return self.source.generate();
    }
}

//MARK: priority sequence convertible
protocol PrioritySequenceProcessor
{
    //mutable collection type
    typealias MC: MutableCollectionType
    
    //trunkIndex
    func trunkIndex(index: Self.MC.Index) -> Self.MC.Index
    
    //branchIndex
    func branchIndex(index: Self.MC.Index) -> Self.MC.Index
    
    //shift up sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftUp(sequence: Self.MC, atIndex i: Self.MC.Index, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
    
    //shift down sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftDown(sequence: Self.MC, atIndex i: Self.MC.Index, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
    
    //update sequence element at index use isOrderedBefore functoin
    //return nil when collection no change
    @warn_unused_result
    func updateElement(sequence: Self.MC, element: Self.MC.Generator.Element, atIndex i: Self.MC.Index, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
    
    //build sequence to priority sequence use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func build(sequence: Self.MC, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
}
//extension where Index == Int
extension PrioritySequenceProcessor where Self.MC.Index == Int
{
    //element type
    private typealias _Ele = Self.MC.Generator.Element;
    
    //shift up sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftUp(sequence: Self.MC, atIndex i: Int, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        guard i > 0 else{return nil;}
        var _temp = sequence;
        var _bIndex = i;
        let _branch = _temp[_bIndex];
        repeat{
            let _tIndex = self.trunkIndex(_bIndex);
            let _trunk = _temp[_tIndex];
            guard iob(_branch, _trunk) else {break;}
            _temp[_bIndex] = _trunk;
            _temp[_tIndex] = _branch;
            _bIndex = _tIndex;
        }while _bIndex > 0
        return _temp;
    }
    
    //shift down sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftDown(sequence: Self.MC, atIndex i: Int, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        let _c = sequence.count;
        guard i < _c else{return nil;}
        var _temp = sequence;
        let _trunk = _temp[i];
        var _tIndex = i;
        repeat{
            var _tempIndex = _tIndex;
            var _childIndex = self.branchIndex(_tempIndex);
            guard _childIndex < _c else{break;}
            if iob(_temp[_childIndex], _trunk){_tempIndex = _childIndex;}
        
            _childIndex++;
            if _childIndex < _c && iob(_temp[_childIndex], _temp[_tempIndex]){_tempIndex = _childIndex;}
            
            guard _tempIndex != _tIndex else{break;}
            _temp[_tIndex] = _temp[_tempIndex];
            _temp[_tempIndex] = _trunk;
            _tIndex = _tempIndex;
        }while _tIndex < _c
        
        return _temp;
    }
    
    //update sequence element at index use isOrderedBefore functoin
    //return nil when collection no change
    @warn_unused_result
    func updateElement(sequence: Self.MC, element: _Ele, atIndex i: Int, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        let _c = sequence.count;
        guard i >= 0 && i < _c else{return nil;}
        var _temp = sequence;
        _temp[i] = element;
        let _parentIndex = self.trunkIndex(i);
        guard iob(element, _temp[_parentIndex]) else {
            return self.shiftDown(_temp, atIndex: i, isOrderedBefore: iob);
        }
        return self.shiftUp(_temp, atIndex: i, isOrderedBefore: iob);
    }
    
    //build sequence to priority sequence use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func build(sequence: Self.MC, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
         var _index:Int = self.trunkIndex(sequence.count - 1);
        guard _index > -1 else{return nil;}
        var _temp = sequence;
        repeat{
            guard let newTemp = self.shiftDown(_temp, atIndex: _index--, isOrderedBefore: iob) else {continue;}
            _temp = newTemp;
        }while _index > -1
        return _temp;
    }
}



//MARK: PriorityArray struct
public struct PriorityArray<_Element>: PrioritySequence, PrioritySequenceProcessor
{
    //Data source type
    public typealias DataSource = Array<_Element>;
    
    //mutable collection tyupe
    typealias MC = DataSource;
    
    //source
    private(set) public var source: DataSource;
    
    //sort according to isOrderedBefore
    private let isOrderedBefore: (_Element, _Element) -> Bool;
    
    //init
    //sort according to isOrderedBefore
    public init(isOrderedBefore:(_Element, _Element) -> Bool, source:DataSource? = nil)
    {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source ?? [];
        self.source = self.build(self.source, isOrderedBefore: isOrderedBefore) ?? [];
    }
}
extension PriorityArray
{
    //append element and resort
    mutating public func insert(element: DataSource.Element)
    {
        self.source.append(element);
        guard let temp = self.shiftUp(self.source, atIndex: self.count - 1, isOrderedBefore: self.isOrderedBefore) else {return;}
        self.source = temp;
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> DataSource.Element?
    {
        if(isEmpty){return nil;}
        let first = self.source[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.source[0] = end;
        guard let temp = self.shiftDown(self.source, atIndex: 0, isOrderedBefore: self.isOrderedBefore) else {return first;}
        self.source = temp;
        return first;
    }
    
    //update element and resort
    mutating public func updateElement(element: DataSource.Element, atIndex: DataSource.Index)
    {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        guard let temp = self.updateElement(self.source, element: element, atIndex: atIndex, isOrderedBefore: self.isOrderedBefore) else {return;}
        self.source = temp;
    }
    
    //trunkIndex
    func trunkIndex(index: Int) -> Int
    {
        return (index - 1) >> 1;
    }
    
    //branchIndex
    func branchIndex(index: Int) -> Int
    {
        return ((index << 1) + 1);
    }
}
//MARK: extension public
public extension PriorityArray where _Element: Comparable
{
    init(max source:[_Element])
    {
        self.init(isOrderedBefore: {return $0 < $1}, source: source);
    }
    
    init(min source:[_Element])
    {
        self.init(isOrderedBefore: {return $0 > $1}, source: source);

    }
}