//
//  ObjectiveView.swift
//  JASTIP
//
//  Created by Feivel Qutby on 05/11/26.
//

import SwiftUI

struct ObjectiveView: View {
    var body: some View {
        HStack{
            Circle()
                .frame(width: 50)
            VStack(alignment: .leading){
                Text("DICE GROUP")
                Text("Fei, Den, Toh, Ind, Rai, Pris")
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // Expands to fill all horizontal space
        .background(.gray)

    }
}

#Preview {
    ObjectiveView()
}
