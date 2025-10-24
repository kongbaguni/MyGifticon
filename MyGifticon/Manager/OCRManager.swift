//
//  OCRManager.swift
//  MyGifticon
//
//  Created by Changyeol Seo on 8/19/25.
//
import Vision
import UIKit

fileprivate extension String {
    var extractDates:[String] {
        let pattern = #"\b\d{4}\.\d{2}\.\d{2}\b"#
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(self.startIndex..<self.endIndex, in: self)
            let matches = regex.matches(in: self, range: range)
            return matches.compactMap {
                Range($0.range, in: self).map { String(self[$0]) }
            }
        } catch {
            print("정규식 에러: \(error)")
            return []
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
    
    func getGifticon(completion:@escaping (GifticonModel?) -> Void) {
        var barcode:String? = nil
        var text:String? = nil
        func process() {
            guard let barcode = barcode,
                  let text = text,
                  let limitdate = text.extractDates.last
            else {
                return
            }
            
            completion(.init(title: text, barcode: barcode, limitDate: limitdate ))
        }

        performBarcodeDetection { txt  in
            barcode = txt
            process()
        }
        
        performOCR { txt in
            text = txt
            process()
        }
        
        
    }
}
