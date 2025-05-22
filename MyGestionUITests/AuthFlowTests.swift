// MyGestionUITests/AuthFlowTests.swift
import XCTest

final class AuthFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest"]
        app.launch()
    }

    func testSignUpAndLoginFlow() {
        // 1) On part de l'écran de connexion
        let connexionTitle = app.staticTexts["Connexion"]
        XCTAssertTrue(connexionTitle.waitForExistence(timeout: 2))

        // 2) Aller à l'inscription
        let signUpButton = app.buttons["Pas de compte ? Inscrivez-vous"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        XCTAssertTrue(app.staticTexts["Inscription"].waitForExistence(timeout: 2))

        // 3) Remplir l'inscription
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Mot de passe"]
        let confirmField = app.secureTextFields["Confirme mot de passe"]
        XCTAssertTrue(emailField.exists && passwordField.exists && confirmField.exists)
        emailField.tap(); emailField.typeText("test@example.com")
        passwordField.tap(); passwordField.typeText("Abcd1234")
        confirmField.tap(); confirmField.typeText("Abcd1234")

        app.buttons["S’inscrire"].tap()

        // 4) Retour sur connexion
        XCTAssertTrue(connexionTitle.waitForExistence(timeout: 3))

        // 5) Tester le login
        emailField.tap(); clear(textField: emailField); emailField.typeText("test@example.com")
        passwordField.tap(); clear(textField: passwordField); passwordField.typeText("Abcd1234")
        app.buttons["Se connecter"].tap()

        // 6) S'assurer qu'on arrive sur le bon dashboard
        let clientTitle = app.staticTexts["👔 Dashboard Chef d’entreprise"]
        let indepTitle  = app.staticTexts["🛠 Dashboard Indépendant"]
        XCTAssertTrue(clientTitle.waitForExistence(timeout: 3) || indepTitle.waitForExistence(timeout: 3))
    }

    // Helper pour effacer un champ
    private func clear(textField: XCUIElement) {
        guard let stringValue = textField.value as? String else { return }
        textField.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        textField.typeText(deleteString)
    }
}

// Note : Assurez-vous d'avoir un schéma 'MyGestionUITests' actif avant de lancer ⌘U.
