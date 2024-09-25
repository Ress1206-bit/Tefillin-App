//
//  EULAView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 9/23/24.
//

import SwiftUI

struct EULAView: View {
    
    @Environment(ContentModel.self) private var contentModel

    var body: some View {
        VStack {
            ScrollView {
                Text("End User License Agreement (EULA)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("""
                    Please read the following terms and conditions carefully before using the Tefillin Wrap Social app. Your use of the app indicates that you accept these terms.

                    1. **User-Generated Content:**
                    You are responsible for the content you post on the app. There is zero tolerance for objectionable content, including but not limited to offensive language, hate speech, or explicit material.

                    2. **Content Moderation:**
                    The app employs content filtering mechanisms to prevent the posting of inappropriate content. Users can report any content they find objectionable.

                    3. **User Blocking:**
                    Users have the ability to block others if they find their behavior to be abusive or offensive. Blocked users will not be able to interact with you within the app.

                    4. **Privacy Policy:**
                    We are committed to protecting your privacy. Your data will be handled in accordance with our Privacy Policy, which can be found [here](#).

                    5. **Changes to the Agreement:**
                    We may update this EULA from time to time. We will notify you of any significant changes by posting the new terms on the app.

                    By clicking "Agree", you agree to abide by these terms and conditions. If you do not agree to these terms, you must discontinue use of the app immediately.
                    """)
                    .padding()
                    .multilineTextAlignment(.leading)

                Spacer()
            }

            Button(action: {
                contentModel.agreeToEULA()
            }) {
                Text("Agree")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    EULAView()
}
