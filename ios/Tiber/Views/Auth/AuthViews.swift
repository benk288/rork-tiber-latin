import SwiftUI
import Combine

// MARK: - Flow coordinator

private enum AuthScreen: Equatable {
    case signIn
    case signUp
    case confirm(String)
}

/// B000 - Sign In / Sign Up (Figma section 419:1495).
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

// MARK: - Shared pieces (exact Figma components)

/// Header icon button: 24px asset over the illustration (566:2662 / 566:2664).
struct AuthHeaderIcon: View {
    let asset: String
    let fallback: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            if UIImage(named: asset) != nil {
                Image(asset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: fallback)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.gray950)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

/// Forms (566:3585...): 12px label, 52px input, 10px radius, #E7E7E7 stroke.
struct TiberField: View {
    let label: String
    @Binding var text: String
    var secure: Bool = false
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.rubik(12))
                .tracking(0.12)
                .foregroundStyle(Theme.gray600)
            Group {
                if secure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .font(.rubik(16))
            .foregroundStyle(Theme.gray950)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(16)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Theme.gray100, lineWidth: 1)
                    )
            )
        }
    }
}

/// Button - 52px - Fill Container (default): #FAAF30, radius 24, #772C10 label.
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
                .font(.rubik(16, .semibold))
                .tracking(0.16)
                .foregroundStyle(enabled ? Theme.buttonText : Theme.gray600)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(enabled ? Theme.primary : Theme.gray100)
                )
        }
        .disabled(!enabled)
    }
}

/// Button - 52px (secondary): #772C10 border, radius 24.
struct TiberOutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Text(title)
                .font(.rubik(16, .semibold))
                .tracking(0.16)
                .foregroundStyle(Theme.buttonText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Theme.buttonText, lineWidth: 1)
                )
        }
    }
}

/// Round 52px social button with the Google/Apple mark (586:1433).
struct SocialButton: View {
    let asset: String
    let fallback: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            ZStack {
                Circle().strokeBorder(Theme.buttonText, lineWidth: 1)
                if UIImage(named: asset) != nil {
                    Image(asset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: fallback)
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.gray950)
                }
            }
            .frame(width: 52, height: 52)
        }
    }
}

/// The 375x302 illustration banner + overlaid header icons.
private struct AuthHeader: View {
    let illustration: String
    var showBack = false
    var showClose = false
    var onBack: () -> Void = {}
    var onClose: () -> Void = {}

    /// Falls back to the sign-in artwork when this screen's export is absent,
    /// so the header never renders as a flat color block.
    private var resolvedName: String {
        UIImage(named: illustration) != nil ? illustration : "AuthIllustrationSignIn"
    }

    var body: some View {
        FigmaImage(name: resolvedName, placeholder: Theme.orange100)
            .frame(height: 302)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(alignment: .top) {
                HStack {
                    if showBack {
                        AuthHeaderIcon(asset: "IconBack", fallback: "arrow.left", action: onBack)
                    }
                    Spacer()
                    if showClose {
                        AuthHeaderIcon(asset: "IconClose", fallback: "xmark", action: onClose)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 69)
            }
            .ignoresSafeArea(edges: .top)
    }
}

// MARK: - B000 Sign in

struct SignInView: View {
    @Environment(AppState.self) private var app
    var onCreateAccount: () -> Void

    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        email.contains("@") && email.contains(".") && !password.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            AuthHeader(illustration: "AuthIllustrationSignIn")

            // Title and Form (419:12986): 24 below illustration, gap 32.
            VStack(spacing: 32) {
                Text("Sign in to Tiber")
                    .font(.rubik(20, .semibold))
                    .tracking(0.2)
                    .foregroundStyle(Theme.gray950)

                VStack(spacing: 16) {
                    TiberField(label: "Email address", text: $email, keyboard: .emailAddress)
                    VStack(alignment: .trailing, spacing: 8) {
                        TiberField(label: "Password", text: $password, secure: true)
                        Text("Forgot password ?")
                            .font(.rubik(12, .medium))
                            .tracking(0.12)
                            .foregroundStyle(Theme.link)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer(minLength: 16)

            // Button Type - full with icon (586:1384)
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    SocialButton(asset: "IconGoogle", fallback: "g.circle") {
                        app.signIn(email: email.isEmpty ? "player@tiber.app" : email)
                    }
                    SocialButton(asset: "IconApple", fallback: "apple.logo") {
                        app.signIn(email: email.isEmpty ? "player@tiber.app" : email)
                    }
                    TiberPrimaryButton(title: "Sign in", enabled: canSubmit) {
                        app.signIn(email: email)
                    }
                }
                Text("or, create a new account :")
                    .font(.rubik(12))
                    .tracking(0.12)
                    .foregroundStyle(Theme.gray600)
                TiberOutlineButton(title: "Create account", action: onCreateAccount)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - B100 Sign up (+ B101 error state)

struct SignUpView: View {
    @Environment(AppState.self) private var app
    var onBack: () -> Void
    var onSubmit: (String) -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            AuthHeader(illustration: "AuthIllustrationSignUp", showBack: true, onBack: onBack)

            VStack(spacing: 32) {
                Text("Create account to Tiber")
                    .font(.rubik(20, .semibold))
                    .tracking(0.2)
                    .foregroundStyle(Theme.gray950)

                VStack(spacing: 16) {
                    TiberField(label: "Email address", text: $email, keyboard: .emailAddress)
                    TiberField(label: "Password", text: $password, secure: true)
                    TiberField(label: "Repeat password", text: $repeatPassword, secure: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer(minLength: 16)

            VStack(spacing: 16) {
                // B101 - Sign up error banner
                if showError {
                    Text("There was a mistake signing up. Please try again later.")
                        .font(.rubik(12, .medium))
                        .tracking(0.12)
                        .foregroundStyle(Theme.pink600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Theme.pink50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Theme.pink300, lineWidth: 1)
                                )
                        )
                        .transition(.opacity)
                }

                TiberPrimaryButton(title: "Create account") {
                    let valid = email.contains("@") && email.contains(".")
                        && !password.isEmpty && password == repeatPassword
                    if valid {
                        showError = false
                        onSubmit(email)
                    } else {
                        withAnimation { showError = true }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - B111/B112/B113/B114 Confirm registration

struct ConfirmRegistrationView: View {
    @Environment(AppState.self) private var app
    let email: String
    var onBack: () -> Void

    @State private var code = ""
    @State private var secondsLeft = 60
    @State private var codeIncorrect = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            AuthHeader(
                illustration: "AuthIllustrationConfirm",
                showBack: true,
                showClose: true,
                onBack: onBack,
                onClose: onBack
            )

            // Title and Form (419:13132): gap 24.
            VStack(spacing: 24) {
                Text("Confirm registration")
                    .font(.rubik(20, .semibold))
                    .tracking(0.2)
                    .foregroundStyle(Theme.gray950)

                VStack(spacing: 12) {
                    Text("We\u{2019}ve sent confirmation code to your\nemail address :")
                        .font(.rubik(14))
                        .tracking(0.14)
                        .lineSpacing(14 * 0.3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.gray600)
                    Text(email.isEmpty ? "davidsilva@mail.com" : email)
                        .font(.rubik(14, .semibold))
                        .tracking(0.14)
                        .foregroundStyle(Theme.gray950)
                }

                resendRow

                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter code")
                        .font(.rubik(12))
                        .tracking(0.12)
                        .foregroundStyle(Theme.gray600)
                    TextField("", text: $code)
                        .font(.rubik(16, .semibold))
                        .foregroundStyle(Theme.gray950)
                        .keyboardType(.numberPad)
                        .padding(16)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Theme.gray100, lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer(minLength: 16)

            TiberPrimaryButton(title: "Confirm code", enabled: !code.isEmpty) {
                if code.count >= 4 {
                    app.signIn(email: email)
                } else {
                    withAnimation { codeIncorrect = true }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
        .onReceive(timer) { _ in
            if secondsLeft > 0 { secondsLeft -= 1 }
        }
    }

    /// B111 "Resend code in 60s" / B114 "Resend code" / B113 "Code incorrect."
    @ViewBuilder
    private var resendRow: some View {
        if codeIncorrect {
            HStack(spacing: 8) {
                Text("Code incorrect.")
                    .font(.rubik(12, .medium))
                    .tracking(0.12)
                    .foregroundStyle(Theme.pink600)
                Button {
                    resend()
                } label: {
                    Text("Resend code?")
                        .font(.rubik(12, .medium))
                        .tracking(0.12)
                        .underline()
                        .foregroundStyle(Theme.link)
                }
            }
        } else if secondsLeft > 0 {
            (Text("Resend code in ")
                .font(.rubik(12))
                .foregroundStyle(Theme.gray600)
             + Text("\(secondsLeft)s")
                .font(.rubik(12, .medium))
                .foregroundStyle(Theme.gray950))
                .tracking(0.12)
        } else {
            Button {
                resend()
            } label: {
                Text("Resend code")
                    .font(.rubik(12, .medium))
                    .tracking(0.12)
                    .underline()
                    .foregroundStyle(Theme.link)
            }
        }
    }

    private func resend() {
        Haptics.tap()
        codeIncorrect = false
        secondsLeft = 60
        code = ""
    }
}

#Preview("Sign in") {
    AuthFlowView()
        .environment(AppState())
}
