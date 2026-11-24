import pathlib, re

g = pathlib.Path('android/app/build.gradle')
if not g.exists():
    raise SystemExit('FAIL: android/app/build.gradle nahi mila - scaffold step fail hua')

s = g.read_text()
s = re.sub(r'compileSdk = .*', 'compileSdk = 35', s)
s = s.replace('applicationId = "com.nexora.nexora"', 'applicationId = "com.nexora.app"')
g.write_text(s)

m = pathlib.Path('android/app/src/main/AndroidManifest.xml')
if not m.exists():
    raise SystemExit('FAIL: AndroidManifest.xml nahi mila')
t = m.read_text()
if 'INTERNET' not in t:
    t = t.replace('<application', '<uses-permission android:name="android.permission.INTERNET"/>\n    <application', 1)
t = t.replace('android:label="nexora"', 'android:label="Nexora" android:usesCleartextTraffic="true"')
m.write_text(t)

p = pathlib.Path('android/gradle.properties')
p.write_text(p.read_text() + '\nandroid.suppressUnsupportedCompileSdk=35\n')
print('patched ok')
