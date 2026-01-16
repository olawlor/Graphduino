/*
 Show Arduino data onscreen with graphics.

 by Dr. Orion Lawlor and Gemini 3 Thinking, lawlor@alaska.edu, 2026-01-15 (Public Domain)
*/
import Raylib // from https://github.com/STREGAsGate/Raylib

// 1. Setup Serial
let arduino = ArduinoBridge(path: "/dev/ttyACM0") // <- copy this from Arduino IDE
arduino.startListening()

// 2. Setup Graphics
Raylib.initWindow(800, 600, "Graphduino: Sprite Controller")
Raylib.setTargetFPS(60)

let arrowTex = Raylib.loadTexture("img/arrow.png")
let textSize : Int32 = 20 // pixel height of text

while !Raylib.windowShouldClose {
    // Fetch the latest parsed data
    let sensors : [Float] = arduino.getData()
    
    // Erase the background:
    Raylib.beginDrawing()
    Raylib.clearBackground(Color(r: 10, g: 10, b: 60, a: 255))
    
    for i in 0...9 {
        if sensors[i] != -1.0 {
            // Draw an arrow at this pixel (x,y) location:
            Raylib.drawTexture(arrowTex, Int32(50+100*i), Int32(500-100*sensors[i]), .white)
        }
    }
    
    Raylib.drawText("Raw Input: \(sensors[0]) V", 10, 10, textSize, .lime)
    Raylib.endDrawing()
}

Raylib.closeWindow()

