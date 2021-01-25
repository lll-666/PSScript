ConvertToJson(Get-Process |
sort ProcessName -unique |
Select-Object ProcessName,Product,Path,ProductVersion,PriorityClass,Basepriority,Company,Description
BasePriority,Company,Container,CPU,Description,EnableRaisingEvents,ExitCode,ExitTime ,FileVersion,Handle,HandleCount,HasExited,Id,MachineName,MainModule,MainWindowHandle,MainWindowTitle,MaxWorkingSet,MinWorkingSet,Modules,NonpagedSystemMemorySize,NonpagedSystemMemorySize64,PagedMemorySize,PagedMemorySize64,PagedSystemMemorySize,PagedSystemMemorySize64,Path,PeakPagedMemorySize,PeakPagedMemorySize64,PeakVirtualMemorySize,PeakVirtualMemorySize64,PeakWorkingSet,PeakWorkingSet64,PriorityBoostEnabled,PriorityClass,PrivateMemorySize,PrivateMemorySize64,PrivilegedProcessorTime,ProcessName,ProcessorAffinity,Product,ProductVersion,Responding,SafeHandle ,SessionId,Site,StandardError,StandardInput,StandardOutput,StartInfo,StartTime,SynchronizingObject,Threads,TotalProcessorTime,UserProcessorTime,VirtualMemorySize,VirtualMemorySize64,WorkingSet,WorkingSet64
)