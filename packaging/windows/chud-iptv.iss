; Installeur Windows de Chud IPTV, compilé par Inno Setup 6 :
;   iscc /DAppVersion=0.4.0 packaging\windows\chud-iptv.iss
; Installation par utilisateur, sans droits administrateur : la mise à jour intégrée peut ainsi
; remplacer les fichiers de l'app. La désinstallation ne touche pas aux données de l'utilisateur.

#ifndef AppVersion
  #error Préciser la version : /DAppVersion=x.y.z
#endif

[Setup]
AppId={{6E1C3F7A-2B54-4C1E-9A6D-5F0B7D3C21A4}
AppName=Chud IPTV
AppVersion={#AppVersion}
AppPublisher=Chud IPTV
DefaultDirName={localappdata}\Programs\Chud IPTV
DefaultGroupName=Chud IPTV
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\..\dist\{#AppVersion}
OutputBaseFilename=Chud-IPTV-{#AppVersion}-windows-x64-setup
SetupIconFile=..\..\app\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Chud IPTV.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\app\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Chud IPTV"; Filename: "{app}\Chud IPTV.exe"
Name: "{autodesktop}\Chud IPTV"; Filename: "{app}\Chud IPTV.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Chud IPTV.exe"; Description: "{cm:LaunchProgram,Chud IPTV}"; Flags: nowait postinstall skipifsilent
