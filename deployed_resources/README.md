The files in this directory are for new `resources` that have been created in `resource groups` that already exist, or do not need a resource group when being deployed. 

It also helps with CI/CD. The commands for deploying resources can vary depending on what you are deploying. 

The concrete example here is that all the resources coded here need to be deployed with:

 `az deployment group` and not ` az deployment sub` 

 Directory naming matters when it comes to CI \ CD.