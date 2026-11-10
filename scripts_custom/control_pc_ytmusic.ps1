param(
  [string]$Action = "playpause",
  [string]$Query = "",
  [string]$SpeakText = ""
)

# 1. Hablar por los parlantes de la PC (Voz de Aisha en español)
if ($SpeakText -ne "") {
  try {
    Add-Type -AssemblyName System.Speech
    $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    foreach ($v in $synth.GetInstalledVoices()) {
      if ($v.VoiceInfo.Name -like "*Sabina*" -or $v.VoiceInfo.Culture.Name -like "es-*") {
        $synth.SelectVoice($v.VoiceInfo.Name)
        break
      }
    }
    $synth.Rate = 1
    $synth.Volume = 100
    $synth.SpeakAsync($SpeakText) | Out-Null
  } catch {}
}

# 2. Control de Ventana Única en el Escritorio Físico "Winsta0\Default" (Reutiliza la pestaña actual con Ctrl+L sin abrir pestañas nuevas)
$code = @"
using System;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;

public class RealDesktopMediaCtrl {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] public static extern IntPtr OpenDesktop(string lpszDesktop, uint dwFlags, bool fInherit, uint dwDesiredAccess);
    [DllImport("user32.dll")] public static extern bool SetThreadDesktop(IntPtr hDesktop);
    [DllImport("user32.dll")] public static extern bool EnumDesktopWindows(IntPtr hDesktop, EnumWindowsProc lpfn, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    public const uint WM_APPCOMMAND = 0x0319;
    public const int APPCOMMAND_VOLUME_MUTE = 8;
    public const int APPCOMMAND_VOLUME_DOWN = 9;
    public const int APPCOMMAND_VOLUME_UP = 10;
    public const int APPCOMMAND_MEDIA_NEXTTRACK = 11;
    public const int APPCOMMAND_MEDIA_PREVIOUSTRACK = 12;
    public const int APPCOMMAND_MEDIA_STOP = 13;
    public const int APPCOMMAND_MEDIA_PLAY_PAUSE = 14;

    public const byte VK_MEDIA_NEXT_TRACK = 0xB0;
    public const byte VK_MEDIA_PREV_TRACK = 0xB1;
    public const byte VK_MEDIA_PLAY_PAUSE = 0xB3;
    public const byte VK_VOLUME_MUTE = 0xAD;
    public const byte VK_VOLUME_DOWN = 0xAE;
    public const byte VK_VOLUME_UP = 0xAF;
    public const byte VK_CONTROL = 0x11;
    public const byte VK_RETURN = 0x0D;
    public const byte VK_L = 0x4C;
    public const byte VK_V = 0x56;
    public const byte VK_W = 0x57;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct STARTUPINFO {
        public Int32 cb; public string lpReserved; public string lpDesktop; public string lpTitle;
        public Int32 dwX; public Int32 dwY; public Int32 dwXSize; public Int32 dwYSize;
        public Int32 dwXCountChars; public Int32 dwYCountChars; public Int32 dwFillAttribute;
        public Int32 dwFlags; public Int16 wShowWindow; public Int16 cbReserved2;
        public IntPtr lpReserved2; public IntPtr hStdInput; public IntPtr hStdOutput; public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess; public IntPtr hThread; public int dwProcessId; public int dwThreadId;
    }

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CreateProcess(
        string lpApplicationName, string lpCommandLine, IntPtr lpProcessAttributes, IntPtr lpThreadAttributes,
        bool bInheritHandles, uint dwCreationFlags, IntPtr lpEnvironment, string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo, out PROCESS_INFORMATION lpProcessInformation);

    public static IntPtr FindBraveWindow(IntPtr hDesk) {
        IntPtr ytmHwnd = IntPtr.Zero;
        IntPtr anyBraveHwnd = IntPtr.Zero;
        EnumDesktopWindows(hDesk, (hWnd, lp) => {
            if (IsWindowVisible(hWnd)) {
                var sbTitle = new StringBuilder(512);
                var sbClass = new StringBuilder(256);
                GetWindowText(hWnd, sbTitle, 512);
                GetClassName(hWnd, sbClass, 256);
                string title = sbTitle.ToString();
                if (sbClass.ToString() == "Chrome_WidgetWin_1" && title.Contains("Brave")) {
                    if (title.Contains("YouTube Music")) ytmHwnd = hWnd;
                    else if (anyBraveHwnd == IntPtr.Zero) anyBraveHwnd = hWnd;
                }
            }
            return true;
        }, IntPtr.Zero);
        return ytmHwnd != IntPtr.Zero ? ytmHwnd : anyBraveHwnd;
    }

    public static void SendMediaCommandToBrave(int appCommand, byte vk) {
        IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
        if (hDesk != IntPtr.Zero) SetThreadDesktop(hDesk);

        // Enviar UNA SOLA señal limpia (evita doble disparo)
        IntPtr targetHwnd = FindBraveWindow(hDesk);
        if (targetHwnd != IntPtr.Zero) {
            IntPtr lParam = (IntPtr)(appCommand << 16);
            PostMessage(targetHwnd, WM_APPCOMMAND, targetHwnd, lParam);
        } else {
            keybd_event(vk, 0, 1, UIntPtr.Zero);
            keybd_event(vk, 0, 3, UIntPtr.Zero);
        }
    }

    public static void CloseCurrentTabInBrave() {
        IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
        if (hDesk != IntPtr.Zero) SetThreadDesktop(hDesk);
        IntPtr targetHwnd = FindBraveWindow(hDesk);
        if (targetHwnd != IntPtr.Zero) {
            SetForegroundWindow(targetHwnd);
            Thread.Sleep(120);
            keybd_event(VK_CONTROL, 0, 0, UIntPtr.Zero);
            keybd_event(VK_W, 0, 0, UIntPtr.Zero);
            keybd_event(VK_W, 0, 2, UIntPtr.Zero);
            keybd_event(VK_CONTROL, 0, 2, UIntPtr.Zero);
        }
    }

    public static void NavigateInSameTabOrOpenApp(string braveExe, string url) {
        IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
        if (hDesk != IntPtr.Zero) SetThreadDesktop(hDesk);

        // Buscar si ya tenés una ventana de Brave con YouTube Music activa
        IntPtr ytmHwnd = IntPtr.Zero;
        EnumDesktopWindows(hDesk, (hWnd, lp) => {
            if (IsWindowVisible(hWnd)) {
                var sbTitle = new StringBuilder(512);
                var sbClass = new StringBuilder(256);
                GetWindowText(hWnd, sbTitle, 512);
                GetClassName(hWnd, sbClass, 256);
                string title = sbTitle.ToString();
                if (sbClass.ToString() == "Chrome_WidgetWin_1" && title.Contains("YouTube Music")) {
                    ytmHwnd = hWnd;
                }
            }
            return true;
        }, IntPtr.Zero);

        if (ytmHwnd != IntPtr.Zero) {
            // Reutilizar LA MISMA pestaña de YouTube Music (Ctrl+L -> Pegar URL -> Enter) sin abrir otra pestaña
            ShowWindow(ytmHwnd, 9);
            SetForegroundWindow(ytmHwnd);
            Thread.Sleep(150);
            // Ctrl + L (Seleccionar barra de direcciones de esa misma pestaña)
            keybd_event(VK_CONTROL, 0, 0, UIntPtr.Zero);
            keybd_event(VK_L, 0, 0, UIntPtr.Zero);
            keybd_event(VK_L, 0, 2, UIntPtr.Zero);
            keybd_event(VK_CONTROL, 0, 2, UIntPtr.Zero);
            Thread.Sleep(120);
            // Ctrl + V (Pegar nueva canción en la misma pestaña)
            keybd_event(VK_CONTROL, 0, 0, UIntPtr.Zero);
            keybd_event(VK_V, 0, 0, UIntPtr.Zero);
            keybd_event(VK_V, 0, 2, UIntPtr.Zero);
            keybd_event(VK_CONTROL, 0, 2, UIntPtr.Zero);
            Thread.Sleep(120);
            // Enter
            keybd_event(VK_RETURN, 0, 0, UIntPtr.Zero);
            keybd_event(VK_RETURN, 0, 2, UIntPtr.Zero);
        } else {
            // Si no había ninguna ventana de YouTube Music abierta, abrir una sola
            STARTUPINFO si = new STARTUPINFO();
            si.cb = Marshal.SizeOf(si);
            si.lpDesktop = "Winsta0\\Default";
            PROCESS_INFORMATION pi;
            string cmd = "\"" + braveExe + "\" --profile-directory=\"Default\" \"" + url + "\"";
            CreateProcess(null, cmd, IntPtr.Zero, IntPtr.Zero, false, 0x00000010, IntPtr.Zero, null, ref si, out pi);
        }
    }
}
"@
Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue

$bravePaths = @(
  "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
  "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
)
$braveExe = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
foreach ($p in $bravePaths) {
  if (Test-Path $p) { $braveExe = $p; break }
}

switch ($Action.ToLower()) {
  "playpause" {
    [RealDesktopMediaCtrl]::SendMediaCommandToBrave([RealDesktopMediaCtrl]::APPCOMMAND_MEDIA_PLAY_PAUSE, [RealDesktopMediaCtrl]::VK_MEDIA_PLAY_PAUSE)
  }
  "next" {
    [RealDesktopMediaCtrl]::SendMediaCommandToBrave([RealDesktopMediaCtrl]::APPCOMMAND_MEDIA_NEXTTRACK, [RealDesktopMediaCtrl]::VK_MEDIA_NEXT_TRACK)
  }
  "prev" {
    [RealDesktopMediaCtrl]::SendMediaCommandToBrave([RealDesktopMediaCtrl]::APPCOMMAND_MEDIA_PREVIOUSTRACK, [RealDesktopMediaCtrl]::VK_MEDIA_PREV_TRACK)
  }
  "volup" {
    1..4 | ForEach-Object {
      [RealDesktopMediaCtrl]::SendMediaCommandToBrave([RealDesktopMediaCtrl]::APPCOMMAND_VOLUME_UP, [RealDesktopMediaCtrl]::VK_VOLUME_UP)
      Start-Sleep -Milliseconds 40
    }
  }
  "voldown" {
    1..4 | ForEach-Object {
      [RealDesktopMediaCtrl]::SendMediaCommandToBrave([RealDesktopMediaCtrl]::APPCOMMAND_VOLUME_DOWN, [RealDesktopMediaCtrl]::VK_VOLUME_DOWN)
      Start-Sleep -Milliseconds 40
    }
  }
  "mute" {
    [RealDesktopMediaCtrl]::SendMediaCommandToBrave([RealDesktopMediaCtrl]::APPCOMMAND_VOLUME_MUTE, [RealDesktopMediaCtrl]::VK_VOLUME_MUTE)
  }
  "close_tab" {
    [RealDesktopMediaCtrl]::CloseCurrentTabInBrave()
  }
  "open_ytm" {
    Set-Clipboard -Value "https://music.youtube.com/"
    [RealDesktopMediaCtrl]::NavigateInSameTabOrOpenApp($braveExe, "https://music.youtube.com/")
  }
  "search_ytm" {
    $encoded = [uri]::EscapeDataString($Query)
    $targetUrl = "https://music.youtube.com/search?q=$encoded"
    try {
      $res = Invoke-WebRequest -Uri "https://www.youtube.com/results?search_query=$encoded" -UseBasicParsing -TimeoutSec 5
      $m = [regex]::Match($res.Content, '"videoId":"([a-zA-Z0-9_-]{11})"')
      if ($m.Success) {
        $vid = $m.Groups[1].Value
        $targetUrl = "https://music.youtube.com/watch?v=$vid"
      }
    } catch {}
    Set-Clipboard -Value $targetUrl
    [RealDesktopMediaCtrl]::NavigateInSameTabOrOpenApp($braveExe, $targetUrl)
  }
}

if ($SpeakText -ne "") {
  Start-Sleep -Seconds 3
}
