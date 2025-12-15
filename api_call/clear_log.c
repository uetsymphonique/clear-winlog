/*
 * clear_log.c - Clear Windows Event Logs using API
 * Usage: clear_log.exe [LogName]
 * Default: clears Application, System, Security logs
 * Requires: Administrator privileges
 */

#include <windows.h>
#include <stdio.h>

// Clear a single event log by name
BOOL ClearLog(const char* logName) {
    HANDLE hLog;
    BOOL result;

    printf("[*] Opening log: %s\n", logName);
    
    hLog = OpenEventLogA(NULL, logName);
    if (hLog == NULL) {
        printf("[!] Failed to open %s (Error: 0x%X)\n", logName, GetLastError());
        return FALSE;
    }

    printf("[*] Clearing log: %s\n", logName);
    
    result = ClearEventLogA(hLog, NULL);  // NULL = don't backup
    if (!result) {
        printf("[!] Failed to clear %s (Error: 0x%X)\n", logName, GetLastError());
        CloseEventLog(hLog);
        return FALSE;
    }

    printf("[+] Successfully cleared: %s\n", logName);
    CloseEventLog(hLog);
    return TRUE;
}

int main(int argc, char* argv[]) {
    // Default logs to clear
    const char* defaultLogs[] = { "Application", "System", "Security" };
    int logCount = 3;
    int success = 0;
    int i;

    printf("\n=== Windows Event Log Cleaner ===\n\n");

    if (argc > 1) {
        // Clear specific log from command line
        printf("[*] Target: %s\n\n", argv[1]);
        if (ClearLog(argv[1])) {
            success++;
        }
    } else {
        // Clear default logs
        printf("[*] Clearing default logs: Application, System, Security\n\n");
        for (i = 0; i < logCount; i++) {
            if (ClearLog(defaultLogs[i])) {
                success++;
            }
            printf("\n");
        }
    }

    printf("=================================\n");
    printf("[*] Result: %d/%d logs cleared\n", success, (argc > 1) ? 1 : logCount);
    
    return (success > 0) ? 0 : 1;
}

