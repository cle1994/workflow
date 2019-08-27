import Workflow
import WorkflowUI


struct LoginScreen: Screen {
    var title: String
    var email: String
    var onEmailChanged: (String) -> Void
    var password: String
    var onPasswordChanged: (String) -> Void
    var onLoginTapped: () -> Void
}


extension ViewRegistry {

    public mutating func registerLoginScreen() {
        self.register(screenViewControllerType: LoginViewController.self)
    }

}


fileprivate final class LoginViewController: ScreenViewController<LoginScreen> {
    let welcomeLabel: UILabel
    let emailField: UITextField
    let passwordField: UITextField
    let button: UIButton

    required init(screen: LoginScreen, viewRegistry: ViewRegistry) {
        welcomeLabel = UILabel(frame: .zero)
        emailField = UITextField(frame: .zero)
        passwordField = UITextField(frame: .zero)
        button = UIButton(frame: .zero)
        super.init(screen: screen, viewRegistry: viewRegistry)

        update(with: screen)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        welcomeLabel.textAlignment = .center

        emailField.placeholder = "email@address.com"
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.textContentType = .emailAddress
        emailField.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        emailField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)

        passwordField.placeholder = "password"
        passwordField.isSecureTextEntry = true
        passwordField.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        passwordField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)

        button.backgroundColor = UIColor(red: 41/255, green: 150/255, blue: 204/255, alpha: 1.0)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

        view.addSubview(welcomeLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(button)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let inset: CGFloat = 12.0
        let height: CGFloat = 44.0
        var yOffset = (view.bounds.size.height - (3 * height + inset)) / 2.0

        welcomeLabel.frame = CGRect(
            x: view.bounds.origin.x,
            y: view.bounds.origin.y,
            width: view.bounds.size.width,
            height: yOffset)

        emailField.frame = CGRect(
            x: view.bounds.origin.x,
            y: yOffset,
            width: view.bounds.size.width,
            height: height)
            .insetBy(dx: inset, dy: 0.0)

        yOffset += height + inset

        passwordField.frame = CGRect(
            x: view.bounds.origin.x,
            y: yOffset,
            width: view.bounds.size.width,
            height: height)
            .insetBy(dx: inset, dy: 0.0)

        yOffset += height + inset

        button.frame = CGRect(
            x: view.bounds.origin.x,
            y: yOffset,
            width: view.bounds.size.width,
            height: height)
            .insetBy(dx: inset, dy: 0.0)
    }

    override func screenDidChange(from previousScreen: LoginScreen) {
        update(with: screen)
    }

    private func update(with screen: LoginScreen) {
        welcomeLabel.text = screen.title
        emailField.text = screen.email
        passwordField.text = screen.password
    }

    @objc private func textDidChange(sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        if sender == emailField {
            screen.onEmailChanged(text)
        } else if sender == passwordField {
            screen.onPasswordChanged(text)
        }
    }

    @objc private func buttonTapped(sender: UIButton) {
        screen.onLoginTapped()
    }
}
