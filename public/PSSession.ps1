1. 当pssession关闭时，使用该pssession执行命令会立即终端。

2. 使用异步线程控制pssession超时
	强制关闭pssession
		下载（不完整）
		执行一半中断
	所以pssession不能强制关闭
	
3. 当前进程获取不到子进程的pssession

4. 获取PSSession
	Get-PSSession|?{$_.ComputerName -eq '172.17.8.179' -and $_.State -eq 'Opened'}
	
5. PSSession销毁问题
	a.多个PS进程都残留同一个终端的PSSession，会导致终端单个用户连接数超限。
	b.一个ps进程残留很多个终端的PSSession（connector服务内存不足）
	
	解法一
		hash算法，计算出该终端落在那个PS进程中（这样的话，对象池方式可能不适用）
		
	解法二
		不复用PSSession
		
	解法三
		手动管理PSSession，保证每个批次，一定释放。（存在，下载不完整）
		
	解法四
		在ps脚本层面做异步处理
		
		
		
		
	1.终端关机  超时验证
	2.原来的线程池2个线程起什么作用
		读进程输出

	
头开始---
业务字段，
头和尾的分界线
体输出
结束---	
	
头开始---
业务字段，
头和尾的分界线
体输出
结束---