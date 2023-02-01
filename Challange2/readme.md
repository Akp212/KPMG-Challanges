We Can get the Instance Metadata using these command:

In Case of Windows, open powershell and run below command:

* Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -NoProxy -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64*

In Case of linux, run below command:

* curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq 

**The response of above command will be JSON string**


