import SwiftUI

/// Elegant authentication screen with email login, registration link, and instant guest demo mode.
public struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isShowingRegister: Bool = false
    
    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    // Brand Icon & Hero Title
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.terracotta.opacity(0.12))
                                .frame(width: 88, height: 88)
                            
                            Image(systemName: "hourglass.bottomhalf.filled")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundColor(Theme.Colors.terracotta)
                        }
                        
                        Text("TimeCapsule")
                            .font(Theme.Typography.serifLargeTitle)
                            .foregroundColor(.primary)
                        
                        Text("Lock your thoughts today.\nUnlock your memories tomorrow.")
                            .font(Theme.Typography.serifQuote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            TextField("you@example.com", text: $viewModel.email)
                                .font(Theme.Typography.subheadline)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(14)
                                .cardSurface(cornerRadius: 12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            SecureField("At least 6 characters", text: $viewModel.password)
                                .font(Theme.Typography.subheadline)
                                .padding(14)
                                .cardSurface(cornerRadius: 12)
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(Theme.Typography.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await viewModel.signIn()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                }
                            }
                        }
                        .tactilePrimary(cornerRadius: 14)
                        .disabled(viewModel.isLoading)
                        
                        Button {
                            isShowingRegister = true
                        } label: {
                            Text("Create an Account")
                        }
                        .tactileSecondary(cornerRadius: 14)
                        
                        // Guest Demo Mode
                        Button {
                            viewModel.continueAsGuest()
                        } label: {
                            Text("Explore as Guest (Offline Demo)")
                                .font(Theme.Typography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .underline()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .sheet(isPresented: $isShowingRegister) {
                RegisterView(viewModel: viewModel)
            }
        }
    }
}

