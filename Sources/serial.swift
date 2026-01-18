/*
 Read Arduino data in a thread, and publish it on request.
 
 If the Arduino data is comma-separated numbers, hopefully you won't need
 to change this file at all.

 by Dr. Orion Lawlor and Gemini 3 Thinking, lawlor@alaska.edu, 2026-01-15 (Public Domain)
*/
import Foundation
import SwiftSerial // from https://github.com/olawlor/SwiftSerial

// 'final' helps performance, '@unchecked Sendable' because we do our own locking
final class ArduinoBridge : @unchecked Sendable {
	public let verbose : Bool
    private let serialPort: SerialPort
    private var sensorValues: [Float] = []
    private let lock = NSLock() // synchronizes sensorValues array access

    init(path: String, verbose: Bool = false) {
		self.verbose = verbose
        self.serialPort = SerialPort(path: path)
		if (verbose) { print("Serial port path: '\(path)'") }
    }

    func startListening() {
        do {
            try serialPort.openPort()
            let port = serialPort
            try port.setSettings(baudRateSetting: .symmetrical(.baud9600), minimumBytesToRead: 1, timeout:1)
			if (verbose) { print("Successfully opened serial port") }
            
			Task {
				do {
					// This yields a full String every time a newline is detected
					for await line in try port.asyncLines() {
						// Trim whitespace/carriage returns if your device sends \r\n
						let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
						if (verbose) { print("  Serial data: \(cleanLine)") }
						
						if !cleanLine.isEmpty {
							self.parseLine(cleanLine)
						}
					}
				} catch {
					print("Serial stream encountered an error: \(error)")
				}
			}
        } catch {
            print("\n\nERROR on serial port: \(error)\n\n")
        }
    }

    // Called from our serial read thread with each ASCII line of data
    private func parseLine(_ line: String) {
        // Simple ASCII Parsing: "100 200" -> [100.0, 200.0]
        let newValues = line.split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .compactMap { Float($0) }
                            
        //print("Parsed serial data '\(line)' to \(newValues.count) float(s)")
        
        // Only update if we actually got valid data
        if !newValues.isEmpty {
            lock.lock()
            self.sensorValues = newValues
            lock.unlock()
        }
    }
    
    // Get recent Arduino data.  
    //  Always returns at least 10 values, to avoid out-of-bounds errors reading missing data.
    //  Padding data is set to -1.0
    func getData() -> [Float] {
        lock.lock() // gemini insists you need a lock to make the copy be threadsafe
        defer { lock.unlock() } // unlock before returning
        
        //print("Sensor values: \(sensorValues.count)")
        var retValues : [Float] = [Float](repeating: -1.0, count: max(10,sensorValues.count))
        
        // Copy out existing data
        for i in 0..<sensorValues.count {
            retValues[i] = sensorValues[i]
        }
        return retValues
    }
}

