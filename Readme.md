# Yster.ADHealthCheck

---

A PowerShell module to perform Active Directory health checks

## Instructions

This module can be loaded as-is by importing Yster.ADHealthCheck.psd1. This is mainly intended for development purposes.

To speed up module load time and minimize the amount of files that needs to be signed, distributed and installed, this module contains a build script that will package up the module into three files:

- Yster.ADHealthCheck.psd1
- Yster.ADHealthCheck.psm1
- license.txt

To build the module, make sure you have the following pre-req modules:

- Pester (Required Version 4.1.1)
- InvokeBuild (Required Version 3.2.1)
- PowerShellGet (Required Version 1.6.0)
- ModuleBuilder (Required Version 1.0.0)

Start the build by running the following command from the project root:

```powershell
Invoke-Build
```

This will package all code into files located in .\bin\Yster.ADHealthCheck. That folder is now ready to be installed, copy to any path listed in you PSModulePath environment variable and you are good to go!

---
Maintained by Sean Quinlan
