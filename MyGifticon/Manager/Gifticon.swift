//
//  Gifticon.swift
//  MyGifticon
//
//  이미지에서 GifticonModel 추출
//  Created by Changyeol Seo on 8/19/25.
//
import Vision
import UIKit

fileprivate extension String {
    func fixDatePattern(pattern:String)->String {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        
        // Replaced original single stringByReplacingMatches call with iterative build
        var result = self
        let matches = regex.matches(in: self, options: [], range: range)
        // Build the replacement from the end to preserve ranges
        for match in matches.reversed() {
            guard match.numberOfRanges >= 4 else { continue }
            let year = (self as NSString).substring(with: match.range(at: 1))
            let month = (self as NSString).substring(with: match.range(at: 2))
            let day = (self as NSString).substring(with: match.range(at: 3))
            let replacement = "20\(year).\(month).\(day)"
            let fullRange = match.range(at: 0)
            if let swiftRange = Range(fullRange, in: result) {
                result.replaceSubrange(swiftRange, with: replacement)
            }
        }
        return result
    }
    
    func getMatches(for pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(self.startIndex..<self.endIndex, in: self)
            let matches = regex.matches(in: self, range: range)
            return matches.compactMap {
                Range($0.range, in: self).map { String(self[$0]) }
            }
        } catch {
            return []
        }
    }
    
    var dateStrings:[String] {
       
        let a = self.getMatches(for: #"\b\d{4}\.\d{1,2}\.\d{2}\b"#)
        let b = self.getMatches(for: #"\b\d{4}\-\d{1,2}\-\d{2}\b"#).map { string in
            string.replacingOccurrences(of: "-", with: ".")
        }
        
        let c = self.getMatches(for: #"\d{4}년\s*\d{1,2}월\s*\d{1,2}일"#).map { string in
            string.replacingOccurrences(of: "년 ", with: ".")
                .replacingOccurrences(of: "월 ", with: ".")
                .replacingOccurrences(of: "일", with: "")
        }
        let d = self.fixDatePattern(pattern:"(\\d{2}).(\\d{2}).(\\d{2})")
                .getMatches(for:  #"\b\d{4}\.\d{2}\.\d{2}\b"#)
        
        let f = self.getMatches(for: #"\d{4}/\d{1,2}/\d{2}"#).map { string in
            string.replacingOccurrences(of: "/", with: ".")
        }
        
        return (a + b + c + d + f).sorted()
    }
}

enum GifticonError : LocalizedError {
    case notGifticonImage
    case notFoundGifticonAtClipboard
    var errorDescription: String? {
        switch self {
        case .notGifticonImage:
            return NSLocalizedString("notGifticonImage", comment: "error msg")
        case .notFoundGifticonAtClipboard:
            return NSLocalizedString("notFoundGifticonAtClipboard", comment: "error msg")
        }
    }
}


extension UIImage {
    // MARK: - OCR 수행
    fileprivate func performOCR(completion: @escaping (String?) -> Void) {
        guard let cgImage = self.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("OCR 실패: \(error?.localizedDescription ?? "")")
                return
            }
            
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            DispatchQueue.main.async {
                completion(text)
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko", "en"]  // 한글 + 영어 인식 활성화
        request.usesLanguageCorrection = true        // 언어 교정 활성화

        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("OCR 핸들러 에러: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 바코드/QR코드 인식
    fileprivate func performBarcodeDetection(completion: @escaping (String?) -> Void) {
        guard let cgImage = self.cgImage else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard let results = request.results as? [VNBarcodeObservation], error == nil else {
                print("바코드 인식 실패: \(error?.localizedDescription ?? "")")
                return
            }
            
            // 첫 번째 바코드만 사용
            if let first = results.first, let payload = first.payloadStringValue {
                DispatchQueue.main.async {
                    completion(payload)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("바코드 핸들러 에러: \(error.localizedDescription)")
            }
        }
    }
    
    func getGifticon(completion:@escaping (GifticonModel?, GifticonError?) -> Void) {
        var barcode:String? = nil
        var text:String? = nil
        var refCount = 2
        func process() {
            guard let barcode = barcode,
                  let text = text,
                  let limitdate = text.dateStrings.last
            else {
                if refCount == 0 {
                    completion(nil, .notGifticonImage)
                }
                return
            }
            
            completion(.init(title: text, barcode: barcode, limitDate: limitdate, image: self), nil)
        }

        performBarcodeDetection { txt  in
            barcode = txt
            refCount -= 1
            process()
        }
        performOCR { txt in
            refCount -= 1
            text = txt
            process()
        }
        
    }
}
