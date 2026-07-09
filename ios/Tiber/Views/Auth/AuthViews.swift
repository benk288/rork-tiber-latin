import SwiftUI

// MARK: - Flow coordinator

private enum AuthScreen: Equatable {
    case signIn
    case signUp
    case confirm(String)
}

/// Sign in -> Create account -> Confirm registration, as separate screens.
struct AuthFlowView: View {
    @State private var screen: AuthScreen = .signIn

    var body: some View {
        ZStack {
            switch screen {
            case .signIn:
                SignInView(onCreateAccount: { screen = .signUp })
                    .transition(.opacity)
            case .signUp:
                SignUpView(
                    onBack: { screen = .signIn },
                    onSubmit: { email in screen = .confirm(email) }
                )
                .transition(.opacity)
            case .confirm(let email):
                ConfirmRegistrationView(email: email, onBack: { screen = .signUp })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: screen)
    }
}

// MARK: - Shared form pieces

/// Labeled rounded text field in the Tiber form style.
struct TiberField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var secure: Bool = false
    var keyboard: UIKeyboardType = .default
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.gray500)
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.gray400)
                }
                Group {
                    if secure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.system(size: 16))
                .foregroundStyle(Theme.gray950)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Theme.gray200, lineWidth: 1.5)
                    )
            )
        }
    }
}

/// Full-width filled capsule button.
struct TiberPrimaryButton: View {
    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(enabled ? .white : Theme.gray400)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(enabled ? Theme.orange400 : Theme.gray100))
        }
        .disabled(!enabled)
    }
}

/// Full-width outlined capsule button.
struct TiberOutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.orange600)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Capsule().strokeBorder(Theme.orange400, lineWidth: 1.5)
                )
        }
    }
}

/// Round Google / Apple sign-in button.
struct SocialCircleButton: View {
    enum Kind { case google, apple }
    let kind: Kind
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().strokeBorder(Theme.gray200, lineWidth: 1.5))
                switch kind {
                case .google:
                    Text("G")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(hex: "4285F4"))
                case .apple:
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.gray950)
                }
            }
            .frame(width: 50, height: 50)
        }
    }
}

/// Pink inline error banner.
struct AuthErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Theme.pink600)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.pink100))
    }
}

/// Circular back button drawn over illustration headers.
struct AuthBackButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.gray950)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color.white.opacity(0.92)))
        }
    }
}

// MARK: - Sign in

struct SignInView: View {
    @Environment(AppState.self) private var app
    let onCreateAccount: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthHeaderIllustration()
                    .frame(height: 280)

                VStack(spacing: 18) {
                    Text("Sign in to Tiber")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.gray950)
                        .padding(.top, 22)

                    TiberField(
                        label: "Email address",
                        text: $email,
                        keyboard: .emailAddress,
                        icon: "envelope"
                    )

                    VStack(alignment: .trailing, spacing: 8) {
                        TiberField(label: "Password", text: $password, secure: true, icon: "lock")
                        Button("Forgot password ?") {}
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.orange600)
                    }

                    if let error {
                        AuthErrorBanner(message: error)
                    }

                    TiberPrimaryButton(title: "Sign in") { signIn() }

                    HStack(spacing: 14) {
                        SocialCircleButton(kind: .google) { socialSignIn() }
                        SocialCircleButton(kind: .apple) { socialSignIn() }
                    }
                    .padding(.top, 2)

                    Text("or create a new account:")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.gray400)

                    TiberOutlineButton(title: "Create account") { onCreateAccount() }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .scrollBounceBehavior(.basedOnSize)
    }

    // Demo auth: any tap signs in, no validation.
    private func signIn() {
        Haptics.success()
        app.signIn(email: email.isEmpty ? "davidsilva@mail.com" : email)
    }

    private func socialSignIn() {
        Haptics.success()
        app.signIn(email: email.isEmpty ? "davidsilva@mail.com" : email)
    }
}

// MARK: - Create account

struct SignUpView: View {
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AuthHeaderIllustration()
                        .frame(height: 280)
                    AuthBackButton(action: onBack)
                        .padding(.leading, 20)
                        .padding(.top, 56)
                }

                VStack(spacing: 18) {
                    Text("Create account to Tiber")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.gray950)
                        .padding(.top, 22)

                    TiberField(
                        label: "Email address",
                        text: $email,
                        keyboard: .emailAddress,
                        icon: "envelope"
                    )
                    TiberField(label: "Password", text: $password, secure: true, icon: "lock")
                    TiberField(label: "Repeat password", text: $repeatPassword, secure: true, icon: "lock")

                    if let error {
                        AuthErrorBanner(message: error)
                    }

                    TiberPrimaryButton(title: "Create account") { submit() }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .scrollBounceBehavior(.basedOnSize)
    }

    // Demo auth: always advances to the confirmation screen.
    private func submit() {
        Haptics.success()
        onSubmit(email.isEmpty ? "davidsilva@mail.com" : email)
    }
}

// MARK: - Confirm registration

struct ConfirmRegistrationView: View {
    @Environment(AppState.self) private var app
    let email: String
    let onBack: () -> Void

    @State private var code = ""
    @State private var secondsLeft = 60
    @State private var showMismatch = false

    // Demo auth: the button is always tappable and any code confirms.
    private var codeReady: Bool { true }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    ConfirmHeaderIllustration()
                        .frame(height: 280)
                    AuthBackButton(action: onBack)
                        .padding(.leading, 20)
                        .padding(.top, 56)
                }

                VStack(spacing: 14) {
                    Text("Confirm registration")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.gray950)
                        .padding(.top, 22)

                    Text("We've sent confirmation code to your\nemail address:")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.gray500)
                        .multilineTextAlignment(.center)

                    Text(email)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.gray950)

                    if showMismatch {
                        Button {
                            resend()
                        } label: {
                            Text("Code doesn't match. ")
                                .foregroundStyle(Theme.pink600)
                            + Text("Resend code?")
                                .foregroundStyle(Theme.orange600)
                                .underline()
                        }
                        .font(.system(size: 13, weight: .semibold))
                    } else if secondsLeft > 0 {
                        Text("Resend code in \(secondsLeft)s")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.orange600)
                    } else {
                        Button("Resend code") { resend() }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.orange600)
                    }

                    TiberField(
                        label: "Enter code",
                        text: $code,
                        keyboard: .numberPad
                    )
                    .padding(.top, 8)

                    TiberPrimaryButton(title: "Confirm code", enabled: codeReady) { confirm() }
                        .padding(.top, 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .scrollBounceBehavior(.basedOnSize)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if secondsLeft > 0 { secondsLeft -= 1 }
            }
        }
    }

    private func confirm() {
        Haptics.success()
        app.signIn(email: email)
    }

    private func resend() {
        Haptics.tap()
        showMismatch = false
        code = ""
        secondsLeft = 60
    }
}

#Preview {
    AuthFlowView()
        .environment(AppState())
}
