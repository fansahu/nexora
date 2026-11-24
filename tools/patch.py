import pathlib, re

g = pathlib.Path('android/app/build.gradle')
s = g.read_text()

if 'keystoreProperties' not in s:
    s = s.replace('android {', """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {""", 1)

s = s.replace('    buildTypes {', """    signingConfigs {
        release {
            storeFile = file(keystoreProperties['storeFile'])
            storePassword = keystoreProperties['storePassword']
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
        }
    }

    buildTypes {""", 1)

s = s.replace('signingConfig = signingConfigs.debug', 'signingConfig = signingConfigs.release')
s = re.sub(r'minSdk = .*', 'minSdk = 23', s)
s = re.sub(r'compileSdk = .*', 'compileSdk = 35', s)
s = re.sub(r'targetSdk = .*', 'targetSdk = 34', s)
s = s.replace('applicationId = "com.nexora.nexora"', 'applicationId = "com.nexora.app"')
g.write_text(s)

m = pathlib.Path('android/app/src/main/AndroidManifest.xml')
t = m.read_text()
if 'INTERNET' not in t:
    t = t.replace('<application', '<uses-permission android:name="android.permission.INTERNET"/>\n    <application', 1)
t = t.replace('android:label="nexora"', 'android:label="Nexora" android:usesCleartextTraffic="true"')
m.write_text(t)

p = pathlib.Path('android/gradle.properties')
p.write_text(p.read_text() + '\nandroid.suppressUnsupportedCompileSdk=35\n')
print('patched')
