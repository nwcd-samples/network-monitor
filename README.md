# Network Monitoring

## Background
Due to network issue, some Chinese customers may not open crossing border web sites like sellercentral.amazon.com timely, to decrease the impact, some customers found a way, that is trying to find some IP addresses from third part websites, then update the Windows hosts file. To streamline the process, we developed a Windows batch tool to automatically complete above actions. Here are the key points:
1. Use Windows batch instead of Powershell to decreaase Memory usage
2. Running and analyzing ping output to get high quality IP periodically
3. Wrap the batch files as Windows service

> Please note, this tool is only verified on Windows Server 2012
## Workflow

Below is the workflow, from the illustration we can find it consists of 5 steps:

* Setup Windows scheluer
* Wrap batch scripts as Windows service
* Loop `domain-names.txt` to get every domain name
* Run Windows ping command and analyzing the output
* Update Windows hosts file accordingly


![network](https://github.com/nwcd-samples/network-monitor/assets/5533748/5a5212ef-3981-4a95-8ea4-e49a945dc7f1)

### Setup Window scheduler
Use Windows `schtasks` command to create a scheduler task ,which is running hourly to detect the network status. You can found details on `start.bat`

### Wrap batch scripts as Windows service
To manipulate the batchs conveniently in runtime ,we wrap them as a Windows service, then we can `start`, `stop` the process easily. This part of code is also in start.bat

### Loop `domain-names.txt` to get every domain name
Since different customers concern different crossing border websites, so we can configure the cooresonding domain names in `domain-names.txt`. One name per line. Here is the sample
```
www.google.com
www.amazon.com
```

### Run Windows ping command and analyzing output
We use `ping` command to monitor networt status for eadch domain name. As we known, ping will repeat 4 times by default. Then we can check ping statistics information to judge if there is any data lost or delay. However, since network is not stable all time, some output will show `请求超时。`(request timeout)

```
C:\Users\Administrator>ping sellercentral.amazon.com

正在 Ping e251656.a.akamaiedge.net [23.59.252.137] 具有 32 字节的数据:
请求超时。
请求超时。
来自 23.59.252.137 的回复: 字节=32 时间=123ms TTL=46
来自 23.59.252.137 的回复: 字节=32 时间=125ms TTL=46
```

So we need to check each output line to collect how many request timeout occurred for every domain name, if the sum exceeds 3 times, we consider this IP is low quality, then run `ping` command again. The max retry number is 3, if it retry 3 times and still timeout, which indicates current domain setting in hosts should be update, then we remove this item from hosts file. Dont' worry ,since check the network hourly, if we found the high quanlity IP in the following period, we also append it to hosts files. 

You can get code detail from `dns-monitor.bat`

### Update hosts file
Once analyzing completed, it's time to update `hosts` file. We only update this file in following condition:
Ping domain name failed after max time reties, AND the domain name exists in hosts file, then we REMOVE this line to let following ping action has chance to request new IP for the same domain name 
Ping domain name succeeded, but the domain name doesn't exist in host file. Then we APPEND it to hosts file to save DNS resolving time.

You can get code details on `hosts-update.bat`

In addition, we also developed `log-util.bat` to serve other batch scripts to record runtime information for troubleshooting. See `log-util.bat` to get more details
