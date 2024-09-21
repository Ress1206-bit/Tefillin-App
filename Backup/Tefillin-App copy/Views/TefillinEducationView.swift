//
//  SwiftUIView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 9/18/24.
//

import SwiftUI

struct TefillinEducationView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                VStack(spacing: 10) {
                    Text("Understanding Tefillin")
                        .font(.custom("Avenir-Heavy", size: 28))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("Discover the significance and the practice of wearing Tefillin, a sacred Jewish tradition.")
                        .font(.custom("Avenir", size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Image("tefillin.jpg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 200)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
                            .padding(.bottom, 45)
                        Spacer()
                    }
                    
                    Text("What Are Tefillin?")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
Tefillin are a set of small black leather boxes containing scrolls of parchment inscribed with verses from the Torah. The word "tefillin" means "attachments" or "bindings," and these sacred items are worn by Jewish men during weekday morning prayers. Tefillin serve as a physical reminder of the commandments and the special relationship between God and the Jewish people.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 20) {
                    Text("The Commandment of Tefillin")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
The Torah commands that tefillin be worn as a sign of the covenant between God and the Jewish people. This is based on the verse in Deuteronomy (6:8), "Bind them as a sign upon your hand, and let them be a reminder between your eyes." By wearing tefillin, one expresses devotion to God and fulfills a central mitzvah, physically binding oneself to God’s words.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Wear Tefillin")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
Tefillin are worn on the arm and the head. The arm tefillin is placed on the weaker arm (left for right-handed people) near the heart, while the head tefillin is placed just above the forehead. This placement signifies the dedication of both the heart and the mind to God. The tefillin are bound using leather straps that wrap around the arm and hand.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 20) {
                    Text("The Meaning Behind Tefillin")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
Each part of the tefillin has deep spiritual significance. The arm tefillin is placed near the heart, symbolizing our emotions and deeds, while the head tefillin sits above the brain, representing intellect. By wearing tefillin, we bring together thought, feeling, and action in service to God. It is a daily reminder to align our lives with divine purpose.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)

                
                Spacer()
            }
            .padding(.top, 20)
            .background(LinearGradient(gradient: Gradient(colors: [colorScheme == .light ? .white : .black, Color.accentBlue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
        }
    }
}

#Preview {
    TefillinEducationView()
}
