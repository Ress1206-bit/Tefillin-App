//
//  SwiftUIView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 9/18/24.
//

import SwiftUI

struct TefillinEducationView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // Header Section
                VStack(spacing: 10) {
                    Text("Understanding Tefillin")
                        .font(.custom("Avenir-Heavy", size: 28))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("A guide to understanding the importance, meaning, and practice of wearing Tefillin.")
                        .font(.custom("Avenir", size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // First Section: What is Tefillin?
                VStack(alignment: .leading, spacing: 20) {
                    Image("tefillin_example")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 200)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
                        .padding(.bottom)
                    
                    Text("What is Tefillin?")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
Tefillin, also known as phylacteries, are two black leather boxes containing Hebrew parchment scrolls. These are worn by Jewish men during weekday morning prayers as a reminder of their connection to God. One box is placed on the arm, facing the heart, and the other on the head, symbolizing the dedication of both emotion and intellect to the service of God.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)

                // Second Section: How to Wear Tefillin
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Wear Tefillin")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
Tefillin are traditionally worn during weekday morning prayers. The arm Tefillin is wrapped around the upper left arm and then wound down the arm to the hand. The head Tefillin is placed in the center of the forehead, just above the hairline. Both are tied securely with straps made of leather, which symbolize the binding of one's commitment to God.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                // Third Section: Why is Tefillin Important?
                VStack(alignment: .leading, spacing: 20) {
                    Text("Why is Tefillin Important?")
                        .font(.custom("Avenir-Heavy", size: 24))
                        .foregroundColor(.accentDarkBlue)
                    
                    Text("""
The Torah commands the wearing of Tefillin as a mitzvah, and it is a tangible reminder of Jewish faith. The Tefillin symbolize the relationship between God and the Jewish people. Wearing Tefillin aligns the wearer’s thoughts and actions with their spiritual obligations and serves as a daily connection to tradition and prayer.
""")
                        .font(.custom("Avenir", size: 16))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)

                // Call to Action
                VStack(spacing: 20) {
                    Text("Learn More About Tefillin")
                        .font(.custom("Avenir-Heavy", size: 20))
                        .foregroundColor(.accentDarkBlue)
                    
                    Button(action: {
                        // Action to navigate to further reading or educational video
                    }) {
                        Text("Explore More")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
                
                Spacer()
            }
            .padding(.top, 20)
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.accentBlue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
        }
    }
}

#Preview {
    TefillinEducationView()
}
