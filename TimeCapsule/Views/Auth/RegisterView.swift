import SwiftUI

/// Registration view for creating a new user account with Firebase Auth.
public struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Create Your Vault")
                            .font(Theme.Typography.serifLargeTitle)
                            .foregroundColor(.primary)
                        
                        Text("Begin sealing memories across time.")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Display Name")
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            TextField("Your name or pen name", text: $viewModel.displayName)
                                .font(Theme.Typography.subheadline)
                                .padding(14)
                                .cardSurface(cornerRadius: 12)
                        }
                        
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
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Button {
                        Task {
                            await viewModel.signUp()
                            if viewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                            }
                        }
                    }
                    .tactilePrimary(cornerRadius: 14)
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

