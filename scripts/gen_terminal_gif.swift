import AppKit
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

// MARK: - Code

let codeLines = [
    "class WuliLiuyue:",
    "    def life(self) -> tuple[list[str], int]:",
    "        langs = [\"Chinese\", \"English\"]",
    "        age = 18",
    "        return langs, age",
    "",
    "    def coding(self) -> tuple[list[list[str]], list[str], list[str]]:",
    "        langs = [",
    "            [\"JS\", \"Dart\"],",
    "            [\"Go\", \"Rust\"]",
    "        ]",
    "",
    "        specialities = [",
    "            \"Fullstack Engineer\",",
    "            \"AI Agent\"",
    "        ]",
    "",
    "        environment = [\"Claude Code\", \"Codex\"]",
    "",
    "        return langs, specialities, environment",
]

// MARK: - Colors

extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

let bgColor = NSColor(hex: 0x010409)
let panelColor = NSColor(hex: 0x0D1117)
let borderColor = NSColor(hex: 0x30363D)
let textColor = NSColor(hex: 0xC9D1D9)
let keywordColor = NSColor(hex: 0xFF7B72)
let typeColor = NSColor(hex: 0xD2A8FF)
let stringColor = NSColor(hex: 0xA5D6FF)
let numberColor = NSColor(hex: 0x79C0FF)
let funcColor = NSColor(hex: 0xFFA657)
let punctColor = NSColor(hex: 0x8B949E)
let dimColor = NSColor(hex: 0x8B949E)
let cursorColor = NSColor(hex: 0x58A6FF)

// MARK: - Tokenizer

struct Token {
    let text: String
    let color: NSColor
}

let keywords: Set<String> = ["class", "def", "return"]
let builtins: Set<String> = ["tuple", "list", "int", "str", "self"]

func tokenize(_ line: String) -> [Token] {
    var tokens: [Token] = []
    let chars = Array(line)
    var i = 0
    var expectName = false

    while i < chars.count {
        let ch = chars[i]

        if ch == " " {
            var j = i
            while j < chars.count && chars[j] == " " { j += 1 }
            tokens.append(Token(text: String(chars[i..<j]), color: textColor))
            i = j
            continue
        }

        if ch == "\"" {
            var j = i + 1
            while j < chars.count && chars[j] != "\"" { j += 1 }
            if j < chars.count { j += 1 }
            tokens.append(Token(text: String(chars[i..<j]), color: stringColor))
            i = j
            expectName = false
            continue
        }

        if ch.isNumber {
            var j = i
            while j < chars.count && chars[j].isNumber { j += 1 }
            tokens.append(Token(text: String(chars[i..<j]), color: numberColor))
            i = j
            expectName = false
            continue
        }

        if ch.isLetter || ch == "_" {
            var j = i
            while j < chars.count && (chars[j].isLetter || chars[j].isNumber || chars[j] == "_") {
                j += 1
            }
            let word = String(chars[i..<j])
            let color: NSColor
            if expectName {
                color = funcColor
            } else if keywords.contains(word) {
                color = keywordColor
            } else if builtins.contains(word) {
                color = typeColor
            } else {
                color = textColor
            }
            tokens.append(Token(text: word, color: color))
            i = j
            expectName = (word == "def" || word == "class")
            continue
        }

        var j = i
        while j < chars.count && !chars[j].isLetter && !chars[j].isNumber && chars[j] != " " && chars[j] != "\"" {
            j += 1
        }
        tokens.append(Token(text: String(chars[i..<j]), color: punctColor))
        i = j
        expectName = false
    }
    return tokens
}

// MARK: - Layout

let fontSize: CGFloat = 17
let font = NSFont(name: "Menlo", size: fontSize) ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
let charWidth = NSAttributedString(string: "M", attributes: [.font: font]).size().width
let lineHeight: CGFloat = 28
let topBarHeight: CGFloat = 52
let padX: CGFloat = 32
let padBottom: CGFloat = 28

let maxLineLen = codeLines.map(\.count).max() ?? 0
let width = Int(ceil(Double(maxLineLen) * Double(charWidth) + Double(padX) * 2 + 60))
let height = Int(ceil(Double(topBarHeight + CGFloat(codeLines.count) * lineHeight + padBottom)))
let codeTop: CGFloat = topBarHeight + 18

// MARK: - Typing timeline

let charsPerSecond: Double = 70
let newlinePause: Double = 0.06
let holdSeconds: Double = 2.0
let fps: Int = 12

var charTimes: [Double] = []
var t: Double = 0
for (lineIndex, line) in codeLines.enumerated() {
    if lineIndex > 0 { t += newlinePause }
    for _ in line {
        charTimes.append(t)
        t += 1.0 / charsPerSecond
    }
}
let typingEnd = t
let totalDuration = typingEnd + holdSeconds
let frameCount = Int(ceil(totalDuration * Double(fps)))

func visibleCharCount(at time: Double) -> Int {
    var count = 0
    for ct in charTimes where ct <= time { count += 1 }
    return count
}

// MARK: - Rendering

func draw(_ text: String, color: NSColor, x: CGFloat, y: CGFloat, ctx: CGContext) {
    let attr = NSAttributedString(
        string: text,
        attributes: [
            .font: font,
            .foregroundColor: color,
        ]
    )
    let line = CTLineCreateWithAttributedString(attr)
    ctx.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, ctx)
}

func drawFrame(_ ctx: CGContext, visibleCount: Int, cursorOn: Bool) {
    // Flip to top-left coordinates
    ctx.translateBy(x: 0, y: CGFloat(height))
    ctx.scaleBy(x: 1, y: -1)
    ctx.textMatrix = CGAffineTransform(scaleX: 1, y: -1)

    // Background
    ctx.setFillColor(bgColor.cgColor)
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

    // Terminal panel
    let inset: CGFloat = 12
    let panel = CGRect(x: inset, y: inset, width: CGFloat(width) - inset * 2, height: CGFloat(height) - inset * 2)
    let path = CGPath(roundedRect: panel, cornerWidth: 10, cornerHeight: 10, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(panelColor.cgColor)
    ctx.fillPath()
    ctx.addPath(path)
    ctx.setStrokeColor(borderColor.cgColor)
    ctx.setLineWidth(1)
    ctx.strokePath()

    // Traffic light dots
    let dotColors: [NSColor] = [NSColor(hex: 0xFF5F56), NSColor(hex: 0xFFBD2E), NSColor(hex: 0x27C93F)]
    for (i, color) in dotColors.enumerated() {
        let dot = CGRect(x: inset + 20 + CGFloat(i) * 24, y: 20, width: 12, height: 12)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: dot)
    }

    // Title
    let title = "wuliLiuyue — profile.py"
    let titleAttr = NSAttributedString(
        string: title,
        attributes: [
            .font: NSFont(name: "Menlo", size: 12) ?? font,
            .foregroundColor: dimColor,
        ]
    )
    let titleLine = CTLineCreateWithAttributedString(titleAttr)
    let titleWidth = CGFloat(CTLineGetTypographicBounds(titleLine, nil, nil, nil))
    ctx.textPosition = CGPoint(x: (CGFloat(width) - titleWidth) / 2, y: 19)
    CTLineDraw(titleLine, ctx)

    // Code
    var remaining = visibleCount
    var cursorRect: CGRect?

    for (lineIndex, line) in codeLines.enumerated() {
        let lineChars = line.count
        let visible = max(0, min(lineChars, remaining))
        remaining -= lineChars
        if remaining < 0 { remaining = 0 }

        let y = codeTop + CGFloat(lineIndex) * lineHeight
        if visible == 0 { continue }

        let tokens = tokenize(line)
        var x = padX
        var consumed = 0
        var cursorX: CGFloat = padX

        for token in tokens {
            let tokenLen = token.text.count
            if consumed >= visible { break }
            let take = min(tokenLen, visible - consumed)
            let part = String(token.text.prefix(take))
            draw(part, color: token.color, x: x, y: y, ctx: ctx)
            x += CGFloat(take) * charWidth
            consumed += take
            cursorX = x
        }

        if cursorOn && remaining <= 0 && visible < lineChars {
            cursorRect = CGRect(x: cursorX, y: y - 2, width: charWidth - 2, height: fontSize + 4)
        }
    }

    // Cursor
    if cursorOn, let rect = cursorRect {
        ctx.setFillColor(cursorColor.withAlphaComponent(0.85).cgColor)
        ctx.fill(rect)
    }
}

func renderFrame(visibleCount: Int, cursorOn: Bool) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    drawFrame(ctx, visibleCount: visibleCount, cursorOn: cursorOn)
    return ctx.makeImage()!
}

// MARK: - Export via ImageIO (system GIF encoder)

let delay = Double(Int(round(100.0 / Double(fps)))) / 100.0
var images: [CGImage] = []
images.reserveCapacity(frameCount)

for frame in 0..<frameCount {
    let time = Double(frame) / Double(fps)
    let visible = visibleCharCount(at: time)
    let cursorOn = time <= typingEnd || Int(time / 0.5) % 2 == 0
    images.append(renderFrame(visibleCount: visible, cursorOn: cursorOn))
}

let outputURL = URL(fileURLWithPath: "assets/about-me.gif")
guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.gif.identifier as CFString,
    images.count,
    nil
) else {
    fatalError("cannot create GIF destination")
}

for image in images {
    let gifProperties: [CFString: Any] = [
        kCGImagePropertyGIFDictionary: [
            kCGImagePropertyGIFDelayTime: delay,
            kCGImagePropertyGIFLoopCount: 0,
        ]
    ]
    CGImageDestinationAddImage(destination, image, gifProperties as CFDictionary)
}

guard CGImageDestinationFinalize(destination) else {
    fatalError("failed to write GIF")
}

print("width=\(width) height=\(height) frames=\(frameCount) duration=\(String(format: "%.1f", totalDuration))s")
