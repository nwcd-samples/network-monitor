# Network Monitoring

## Background
Due to network issue, some Chinese customers may not open crossing border web sites like sellercentral.amazon.com timely, to decrease the impact, some customers found a way, that is trying to find some IP addresses from third part websites, then update the Windows hosts file. To streamline the process, we developed a Windows batch project to automatically complete above actions. Here are the key points:
1. Use Windows batch instead of Powershell to decreaase Memory usage
2. Running and analyzing ping output to get high quality IP periodically
3. Wrap the batch files as Windows service

> Please note, this project is only verified on Windows Server 2012
## Workflow

Below is the workflow, from the illustration we can find it consists of 4 steps:

* Setup Windows scheluer
* Wrap batch scripts as Windows service
* Run Windows ping actions and analyzing the output
* Update Windows hosts file accordingly

![network-monitor](https://github.com/nwcd-samples/network-monitor/assets/5533748/fdb7aeb9-94ab-4b44-b58f-0cc2900a64a2)

### Setup Window scheduler
Use Windows `schtasks` command to create a scheduler task ,which is running hourly to detect the network status. You can found details on start.bat

### Wrap batch scripts as Windows service
To manipulate the batchs conveniently ,we wrap them as a Windows service, then we can start, stop the process easily. This part of code is also in start.bat

### 
