//
//  ModalView.swift
//  FaceDetectionInAR
//
//  Created by Edward Luo on 2021-06-10.
//

import Foundation
import SwiftUI

struct ModalView: View {
    @ObservedObject var viewModel: ModalViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Source")
                Image(uiImage: viewModel.sourceImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400, alignment: .center)
                Text("Processed \(viewModel.facesFound)")
                Image(uiImage: viewModel.processedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400, alignment: .center)
            }
        }
        .padding()
    }
}

class ModalViewModel: ObservableObject {
    @Published var sourceImage = UIImage(systemName: "photo.fill")!
    @Published var processedImage = UIImage(systemName: "photo.fill")!
    @Published var facesFound = 0

    func updateSource(with uiImage: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.sourceImage = uiImage ?? UIImage(systemName: "photo.fill")!
        }
    }

    func updateProcessed(with uiImage: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.processedImage = uiImage ?? UIImage(systemName: "photo.fill")!
        }
    }

    func updateFacesCount(with count: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.facesFound = count
        }
    }
}
