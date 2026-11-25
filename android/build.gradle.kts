signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}

buildTypes {
    release {
        if (keystorePropertiesFile.exists()) {
            signingConfig = signingConfigs.getByName("release")
        } else {
            // Fallback for GitHub Actions or builds without the keystore
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
