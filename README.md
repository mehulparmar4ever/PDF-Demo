# PDF-Demo
An iOS PDF viewer and annotator written in Swift that can be embedded into any application.

Requirements:

iOS 9 or above
Xcode 8 or above
Swift 3.0


Note:
This project is still in early stages. Right now the PDF reader works both programmatically and through interface builder. This PDF reader supports interactive forms and provides methods for overlaying text, signature and checkbox elements onto the page, as well as rendering a PDF with the elements burned back onto the PDF. See the example project for how to implement.

Usage:
Swift 3.0

let path = Bundle.main.path(forResource: "sample", ofType: "pdf")!
let document = try! PDFDocument(filePath: path, password: "password_if_needed")
let pdf = PDFViewController(document: document)

self.navigationController?.pushViewController(pdf, animated: true)
