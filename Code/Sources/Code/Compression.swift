//
//  File.swift
//  
//
//  Created by Lucas Stomberg on 2/26/21.
//

import Foundation
import Compression

public enum CompressionAlgorithm {
    case lz4   // speed is critical
    case lz4a  // space is critical
    case zlib  // reasonable speed and space
    case lzfse // better speed and space
}

public enum CompressionOperation {
    case compression
    case decompression
}

/// return compressed or uncompressed data depending on the operation
private func perform(_ operation: CompressionOperation,
             on input: Data,
             using algorithm: CompressionAlgorithm,
             workingBufferSize: Int = 2000) -> Data?  {
    // set the algorithm
    let streamAlgorithm: compression_algorithm
    
    switch algorithm {
        case .lz4:   streamAlgorithm = COMPRESSION_LZ4
        case .lz4a:  streamAlgorithm = COMPRESSION_LZMA
        case .zlib:  streamAlgorithm = COMPRESSION_ZLIB
        case .lzfse: streamAlgorithm = COMPRESSION_LZFSE
    }
    
    // set the stream operation and flags
    let streamOperation: compression_stream_operation
    let flags: Int32
    
    switch operation {
        case .compression:
            streamOperation = COMPRESSION_STREAM_ENCODE
            flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
        case .decompression:
            streamOperation = COMPRESSION_STREAM_DECODE
            flags = 0
    }
    
    // 1: create a stream
    let streamPointer = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    defer {
        streamPointer.deallocate()
    }
    
    // 2: initialize the stream
    var stream = streamPointer.pointee
    var status = compression_stream_init(&stream, streamOperation, streamAlgorithm)
    guard status != COMPRESSION_STATUS_ERROR else {
        return nil
    }
    defer {
        compression_stream_destroy(&stream)
    }
    
    // 3: set up a destination buffer
    let dstSize = workingBufferSize
    let dstPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
    defer {
        dstPointer.deallocate()
    }
    
    // process the input
    return input.withUnsafeBytes { srcRawBufferPointer in
        // 1
        var output = Data()
        
        // 2
        let srcBufferPointer = srcRawBufferPointer.bindMemory(to: UInt8.self)
        guard let srcPointer = srcBufferPointer.baseAddress else {
            return nil
        }
        
        stream.src_ptr = srcPointer
        stream.src_size = input.count
        stream.dst_ptr = dstPointer
        stream.dst_size = dstSize
        
        // 3
        while status == COMPRESSION_STATUS_OK {
            // process the stream
            status = compression_stream_process(&stream, flags)
            // collect bytes from the stream and reset
            switch status {
                case COMPRESSION_STATUS_OK:
                    // 4
                    output.append(dstPointer, count: dstSize)
                    stream.dst_ptr = dstPointer
                    stream.dst_size = dstSize
                case COMPRESSION_STATUS_ERROR:
                    return nil
                case COMPRESSION_STATUS_END:
                    // 5
                    output.append(dstPointer, count: stream.dst_ptr - dstPointer)
                default:
                    fatalError()
            }
        }
        return output
    }
}

/// Compressed keeps the compressed data and the algorithm
/// together as one unit, so you never forget how the data was
/// compressed.
public struct Compressed {
    public let data: Data
    public let algorithm: CompressionAlgorithm
    
    /// Compresses the input with the specified algorithm. Returns nil if it fails.
    public static func compress(input: Data, with algorithm: CompressionAlgorithm) -> Compressed? {
        guard let data = perform(.compression, on: input, using: algorithm) else {
            return nil
        }
        return Compressed(data: data, algorithm: algorithm)
    }
    
    /// Uncompressed data. Returns nil if the data cannot be decompressed.
    public func decompressed() -> Data? {
        return perform(.decompression, on: data, using: algorithm)
    }
}

/// For discoverability, adds a compressed method to Data
public extension Data {
    /// Returns compressed data or nil if compression fails.
    func compressed(with algorithm: CompressionAlgorithm) -> Compressed? {
        return Compressed.compress(input: self, with: algorithm)
    }
}

public extension Data {
    func zlibCompressed() -> Data? {
        Compressed.compress(input: self, with: .zlib)?.data
    }
    
    func zlibDecompressed() -> Data? {
        Compressed(data: self, algorithm: .zlib).decompressed()
    }
}

public extension NSData {
    @objc
    func zlibCompressed() -> NSData? {
        let compressed = Compressed.compress(input: self as Data, with: .zlib)
        return compressed?.data as NSData?
    }
    
    @objc
    func zlibDecompressed() -> NSData? {
        let compressed = Compressed(data: self as Data, algorithm: .zlib)
        return compressed.decompressed() as NSData?
    }
}
